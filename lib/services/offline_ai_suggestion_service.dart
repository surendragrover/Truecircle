import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'json_data_service.dart';

/// Offline AI Suggestion Service
/// Emulates lightweight on‑device AI by selecting culturally aware, bilingual
/// suggestions deterministically (date + simple hashing) so output feels
/// dynamic without network / heavy models. Activated only after model
/// download flag is stored in Hive.
class OfflineAISuggestionService {
  OfflineAISuggestionService._();
  static final OfflineAISuggestionService instance = OfflineAISuggestionService._();

  /// Hive settings box name
  static const String _settingsBox = 'truecircle_settings';

  /// Returns true if model download flag was set (per phone or global fallback)
  Future<bool> isModelReady() async {
    try {
      final box = Hive.isBoxOpen(_settingsBox)
          ? Hive.box(_settingsBox)
          : await Hive.openBox(_settingsBox);
      // Try phone specific first
      final phone = box.get('current_phone_number') as String?;
      if (phone != null) {
        return box.get('${phone}_models_downloaded', defaultValue: false) as bool;
      }
      return box.get('global_models_downloaded', defaultValue: false) as bool;
    } catch (e) {
      debugPrint('[OfflineAISuggestionService] isModelReady error: $e');
      return false; // Fail safe: treat as not ready
    }
  }

  /// Daily breathing suggestion (wraps existing JSON rotation) with gating
  Future<Map<String, dynamic>?> getDailyBreathingSuggestion() async {
    if (!await isModelReady()) return null; // Gate behind model readiness
    return JsonDataService.instance.getTodaysBreathingTip();
  }

  /// Daily meditation suggestion (wraps existing JSON rotation) with gating
  Future<Map<String, dynamic>?> getDailyMeditationSuggestion() async {
    if (!await isModelReady()) return null;
    return JsonDataService.instance.getTodaysMeditationTip();
  }

  /// Festival message suggestions (bilingual) built from upcoming festival data.
  /// count: number of suggestions to return.
  Future<List<Map<String, String>>> getFestivalMessageSuggestions({int count = 2}) async {
    if (!await isModelReady()) return [];
    try {
      final upcoming = await JsonDataService.instance.getUpcomingFestivals();
      if (upcoming.isEmpty) return [];
      final rngSeed = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
      final rnd = Random(rngSeed);
      // Shuffle copy and take count
      final shuffled = [...upcoming]..shuffle(rnd);
      return shuffled.take(count).map<Map<String, String>>((f) {
        final nameEn = f['festival_name']?.toString() ?? 'Festival';
        final nameHi = f['festival_name_hindi']?.toString() ?? nameEn;
        final greeting = f['greetingMessages'];
        String enMsg = 'May the joy of $nameEn strengthen your bonds today. Reach out with warmth & gratitude.';
        String hiMsg = '$nameHi की शुभकामनाएं! आज अपने प्रियजनों को प्यार और आभार के साथ संदेश भेजें।';
        if (greeting is Map) {
          enMsg = greeting['english']?.toString() ?? enMsg;
          hiMsg = greeting['hindi']?.toString() ?? hiMsg;
        }
        // Add AI flavored enhancement
        final enhancer = _festivalEnhancers[rnd.nextInt(_festivalEnhancers.length)];
        return {
          'festival_en': nameEn,
            'festival_hi': nameHi,
          'message_en': '$enMsg $enhancer',
          'message_hi': '$hiMsg $enhancer',
        };
      }).toList();
    } catch (e) {
      debugPrint('[OfflineAISuggestionService] festival suggestions error: $e');
      return [];
    }
  }

  /// Event (budget / planning) tip suggestion
  Future<String?> getEventPlanningSuggestion({bool hindi = false}) async {
    if (!await isModelReady()) return null;
    final pool = hindi ? _eventPlanningTipsHi : _eventPlanningTipsEn;
    final day = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return pool[day % pool.length];
  }

  // Static enhancement suffixes
  static const List<String> _festivalEnhancers = [
    '🌟 Strengthen emotional closeness.',
    '🪔 Share one mindful gratitude note.',
    '💞 Offer a small act of kindness.',
    '🎉 Celebrate with cultural authenticity.',
    '🤗 Reconnect through a meaningful memory.'
  ];

  static const List<String> _eventPlanningTipsEn = [
    'Allocate 60% budget to essentials (food, venue), 20% gifts, 20% emotional moments (photos / handwritten notes).',
    'Send festival / event reminders 3 days early; emotional impact peaks when outreach is proactive.',
    'Plan one culturally rooted ritual + one modern bonding activity for balance.',
    'Keep a gratitude log post-event to reinforce relational memory.',
    'Micro‑budget tip: Handwritten message + small token > large generic gift.'
  ];

  static const List<String> _eventPlanningTipsHi = [
    'अपने बजट का 60% ज़रूरी चीज़ों (भोजन/स्थान), 20% उपहार और 20% भावनात्मक पलों (फ़ोटो / हस्तलिखित नोट) पर रखें।',
    'इवेंट / त्योहार रिमाइंडर 3 दिन पहले भेजें; भावनात्मक प्रभाव समय पर पहल से बढ़ता है।',
    'एक पारंपरिक रिवाज़ + एक आधुनिक एक्टिविटी जोड़ें संतुलन के लिए।',
    'इवेंट के बाद आभार सूची लिखें ताकि रिश्तों की यादें मजबूत हों।',
    'माइक्रो बजट टिप: हस्तलिखित संदेश + छोटा व्यक्तिगत संकेत बड़े सामान्य उपहार से बेहतर होता है।'
  ];
}
