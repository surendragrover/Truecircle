import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/service_locator.dart';
import 'on_device_ai_service.dart';
import 'festival_data_service.dart';

/// AIOrchestratorService
/// Once on‑device models are downloaded, this service auto-starts and prepares
/// lightweight, privacy-safe insights for different feature modules so the
/// experience feels instantly "alive" (no manual trigger delay).
class AIOrchestratorService {
  static final AIOrchestratorService _instance =
      AIOrchestratorService._internal();
  AIOrchestratorService._internal();
  factory AIOrchestratorService() => _instance;

  bool _started = false;
  bool get isStarted => _started;

  final ValueNotifier<Map<String, String>> featureInsights =
      ValueNotifier<Map<String, String>>({});

  DateTime? _lastRefreshed;
  DateTime? get lastRefreshed => _lastRefreshed;

  OnDeviceAIService? _ai;

  /// Attempt to start orchestrator if models downloaded.
  Future<void> startIfPossible() async {
    if (_started) return;
    try {
      final settings = await Hive.openBox('truecircle_settings');
      final phone = settings.get('current_phone_number') as String?;
      final downloaded = phone != null
          ? settings.get('${phone}_models_downloaded', defaultValue: false)
              as bool
          : settings.get('models_downloaded', defaultValue: false) as bool;
      if (!downloaded) {
        debugPrint('AIOrchestrator: models not ready yet.');
        return;
      }
      // Acquire AI service if registered
      final sl = ServiceLocator.instance;
      if (sl.hasAIService) {
        try {
          _ai = sl.aiService;
        } catch (_) {}
      }
      _started = true;
      debugPrint('✅ AIOrchestrator started');
      await _produceInitialInsights();
    } catch (e) {
      debugPrint('AIOrchestrator start error: $e');
    }
  }

  /// Force refresh of insights (e.g., after new mood entry)
  Future<void> refresh() async {
    if (!_started) return;
    await _produceInitialInsights();
  }

  Future<void> _produceInitialInsights() async {
    final Map<String, String> insights = {};
    try {
      // Load recent emotional entries for context (if available)
      List<Map<String, dynamic>> recent = [];
      try {
        final box = await Hive.openBox('truecircle_emotional_entries');
        final raw = box.get('entries', defaultValue: <dynamic>[]) as List;
        recent = raw.cast<Map>().cast<Map<String, dynamic>>().take(10).toList();
      } catch (_) {}

      double avgMood = 0;
      if (recent.isNotEmpty) {
        final moods = recent
            .map((e) => (e['mood_score'] ?? 0).toDouble())
            .where((v) => v > 0)
            .toList();
        if (moods.isNotEmpty) {
          avgMood = moods.reduce((a, b) => a + b) / moods.length;
        }
      }

      // Use AI service if available for a richer mood summary
      String moodText;
      if (_ai != null) {
        try {
          moodText = await _ai!.generateDrIrisResponse(
              'Summarize user emotional state in one short supportive sentence. Average mood=$avgMood');
        } catch (_) {
          moodText = _fallbackMood(avgMood);
        }
      } else {
        moodText = _fallbackMood(avgMood);
      }
      insights['mood'] = moodText;

      insights['breathing'] = avgMood < 5
          ? 'Try 4-7-8 breathing for calm—inhale 4, hold 7, exhale 8.'
          : 'Maintain balance with a 2‑minute mindful breathing break.';

      insights['meditation'] = avgMood < 6
          ? 'A short grounding meditation can stabilize emotions now.'
          : 'Consistent calm—consider a gratitude meditation today.';

      insights['relationship'] = recent.isNotEmpty
          ? 'Reflect on one positive interaction—reinforce supportive bonds.'
          : 'Log emotional check‑ins to enable deeper relationship guidance.';

      // Festival prioritization: list up to 3 upcoming in current + next month
      try {
        final festService = FestivalDataService.instance;
        if (!festService.isInitialized) {
          await festService.initialize();
        }
        final now = DateTime.now();
        final monthNames = [
          '',
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        final currentMonthName = monthNames[now.month];
        final nextMonthName = monthNames[(now.month % 12) + 1];
        final current = festService.getFestivalsByMonth(currentMonthName);
        final next = festService.getFestivalsByMonth(nextMonthName);
        final combined = [...current, ...next];
        if (combined.isNotEmpty) {
          final names = combined.take(3).map((f) => f.name).join(', ');
          insights['festival'] =
              'Upcoming: $names — send warm culturally aware greetings.';
        } else {
          insights['festival'] =
              'Explore festivals section for cultural connection ideas.';
        }
      } catch (_) {
        insights['festival'] =
            'Upcoming festivals: open Festivals section for greetings.';
      }
      insights['sleep'] =
          'Track sleep quality tonight—rest shapes emotional resilience.';

      // Gifting frequency insight (offline virtual gifts activity)
      try {
        final giftBox = await Hive.openBox('virtual_gift_purchases');
        final history =
            (giftBox.get('history', defaultValue: <dynamic>[]) as List)
                .cast<Map?>();
        final now = DateTime.now();
        final last30 = history.where((e) {
          if (e == null) return false;
          final ts = DateTime.tryParse(e['ts'] ?? '');
          if (ts == null) return false;
          return now.difference(ts).inDays <= 30;
        }).toList();
        final count = last30.length;
        if (count == 0) {
          insights['relationship'] =
              '${insights['relationship'] ?? ''} Consider sending a thoughtful virtual gift to nurture bonds.';
        } else if (count < 3) {
          insights['relationship'] =
              '${insights['relationship'] ?? ''} Light gifting pattern—occasional gestures help maintain warmth.';
        } else {
          insights['relationship'] =
              '${insights['relationship'] ?? ''} Consistent gifting shows care—balance with authentic conversations.';
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('AIOrchestrator insight build error: $e');
    }
    featureInsights.value = insights;
    _lastRefreshed = DateTime.now();
  }

  String _fallbackMood(double avgMood) {
    if (avgMood == 0) {
      return 'Start your first emotional check‑in to activate deeper insights.';
    }
    if (avgMood >= 7.5) {
      return 'Emotional state appears strong—sustain with mindful micro-breaks.';
    }
    if (avgMood >= 5.0) {
      return 'Mood moderate—light reflection or breathing can elevate clarity.';
    }
    return 'Low mood trend—gentle self‑compassion and paced breathing recommended.';
  }
}
