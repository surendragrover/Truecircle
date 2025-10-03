import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../models/cbt_models.dart';

/// Offline hypnotherapy session manager (privacy-first, on-device only)
class HypnotherapyService extends ChangeNotifier {
  static HypnotherapyService? _instance;
  static HypnotherapyService get instance => _instance ??= HypnotherapyService._();
  HypnotherapyService._();

  static const _boxName = 'hypnotherapy_sessions';
  Box? _box;

  Future<void> init() async {
    if (_box != null) return; _box = await Hive.openBox(_boxName);
  }

  List<HypnotherapySessionLog> getSessions() {
    if (_box == null) return [];
    return _box!.values.whereType<HypnotherapySessionLog>().toList()
      ..sort((a,b)=> b.startedAt.compareTo(a.startedAt));
  }

  Future<HypnotherapySessionLog> startSession({required String scriptKey, required int relaxationBefore, required String focusIntent}) async {
    await init();
    final id = DateTime.now().toIso8601String();
    final log = HypnotherapySessionLog(
      id: id,
      startedAt: DateTime.now(),
      completedAt: null,
      scriptKey: scriptKey,
      relaxationRatingBefore: relaxationBefore,
      relaxationRatingAfter: relaxationBefore,
      focusIntent: focusIntent,
      notes: '',
    );
    await _box!.put(id, log);
    notifyListeners();
    return log;
  }

  Future<void> completeSession(String id, {required int relaxationAfter, String? notes}) async {
    await init();
    final log = _box!.get(id);
    if (log is HypnotherapySessionLog) {
      log.completedAt = DateTime.now();
      log.relaxationRatingAfter = relaxationAfter;
      if (notes != null) log.notes = notes;
      await log.save();
      notifyListeners();
    }
  }

  Map<String,String> getScriptMetadata(String key, {bool hindi = false}) {
    // Lightweight predefined scripts (placeholder, kept fully on-device)
    final data = <String,Map<String,String>>{
      'calm_breath': {
        'title_en': 'Calming Breath Focus',
        'title_hi': 'शांत श्वास फोकस',
        'desc_en': 'Guided gentle breath visualization for stress release.',
        'desc_hi': 'तनाव कम करने हेतु कोमल श्वास दृश्यकरण मार्गदर्शन।',
      },
      'deep_sleep': {
        'title_en': 'Deep Sleep Drift',
        'title_hi': 'गहरी नींद विश्राम',
        'desc_en': 'Progressive relaxation imagery for better sleep.',
        'desc_hi': 'बेहतर नींद हेतु क्रमिक विश्राम कल्पना।',
      },
      'confidence_anchor': {
        'title_en': 'Confidence Anchor',
        'title_hi': 'आत्मविश्वास एंकर',
        'desc_en': 'Positive suggestion sequence for confidence uplift.',
        'desc_hi': 'आत्मविश्वास बढ़ाने हेतु सकारात्मक सुझाव अनुक्रम।',
      }
    };
    final script = data[key] ?? data.values.first;
    return {
      'title': hindi? script['title_hi']!: script['title_en']!,
      'desc': hindi? script['desc_hi']!: script['desc_en']!,
    };
  }
}
