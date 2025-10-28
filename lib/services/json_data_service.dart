import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/cbt_micro_lesson.dart';
import 'app_data_preloader.dart';

class JsonDataService {
  JsonDataService._();
  static final JsonDataService instance = JsonDataService._();

  List<CBTMicroLesson>? _cachedLessons;
  List<Map<String, dynamic>>? _cachedEmotionalAwarenessCategories;
  List<String>? _cachedCopingCards;

  Future<List<CBTMicroLesson>> getCbtMicroLessons() async {
    if (_cachedLessons != null) return _cachedLessons!;

    try {
      // Use preloaded data if available
      if (AppDataPreloader.instance.isPreloaded) {
        final preloadedData = AppDataPreloader.instance.getCBTMicroLessons();
        final list = preloadedData
            .map((e) => CBTMicroLesson.fromJson(e as Map<String, dynamic>))
            .toList();
        _cachedLessons = list;
        return list;
      }

      // Fallback to direct loading
      final raw = await rootBundle.loadString('data/CBT_Micro_Lessons_en.json');
      final decoded = json.decode(raw);

      // Safe type checking for CBT lessons
      if (decoded is List) {
        final list = decoded
            .map((e) => CBTMicroLesson.fromJson(e as Map<String, dynamic>))
            .toList();
        _cachedLessons = list;
        return list;
      } else if (decoded is Map<String, dynamic>) {
        final lessons = decoded['lessons'] ?? decoded['data'] ?? [];
        if (lessons is List) {
          final list = lessons
              .map((e) => CBTMicroLesson.fromJson(e as Map<String, dynamic>))
              .toList();
          _cachedLessons = list;
          return list;
        }
      }

      _cachedLessons = const [];
      return _cachedLessons!;
    } catch (e) {
      debugPrint('Error loading CBT lessons: $e');
      // Fail-safe: return empty list if asset missing or invalid.
      _cachedLessons = const [];
      return _cachedLessons!;
    }
  }

  Future<List<Map<String, dynamic>>> getBreathingSessions() async {
    try {
      // Use preloaded data if available
      if (AppDataPreloader.instance.isPreloaded) {
        return AppDataPreloader.instance
            .getBreathingExercises()
            .cast<Map<String, dynamic>>();
      }

      // Fallback to direct loading
      final raw = await rootBundle.loadString(
        'data/Breathing_+Exercises_Demo_Data.json',
      );
      final decoded = json.decode(raw);

      // Safe type checking
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      } else if (decoded is Map<String, dynamic>) {
        final exercises = decoded['exercises'] ?? decoded['data'] ?? [];
        if (exercises is List) {
          return exercises.cast<Map<String, dynamic>>();
        }
      }

      return const [];
    } catch (e) {
      debugPrint('Error loading breathing exercises: $e');
      return const [];
    }
  }

  Future<List<Map<String, dynamic>>> getMoodJournalEntries() async {
    try {
      final raw = await rootBundle.loadString(
        'data/Mood_Journal_Demo_Data.json',
      );
      final decoded = json.decode(raw);

      // Safe type checking and casting
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      } else if (decoded is Map<String, dynamic>) {
        // If it's wrapped in an object, try to extract array
        final entries = decoded['entries'] ?? decoded['data'] ?? [];
        if (entries is List) {
          return entries.cast<Map<String, dynamic>>();
        }
      }

      return const [];
    } catch (e) {
      debugPrint('Error loading mood journal entries: $e');
      return const [];
    }
  }

  Future<List<Map<String, dynamic>>> getEmotionalCheckins() async {
    try {
      final raw = await rootBundle.loadString(
        'data/TrueCircle_Emotional_Checkin_Demo_Data.json',
      );
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final list = (decoded['daily_entries'] as List?) ?? const [];
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return const [];
    }
  }

  Future<Map<String, String>?> getNextFestivalBrief(DateTime now) async {
    try {
      final raw = await rootBundle.loadString(
        'data/TrueCircle_Festivals_Data.json',
      );
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final list =
          (decoded['festivals'] as List?)?.cast<Map<String, dynamic>>() ??
          const [];
      if (list.isEmpty) return null;
      const months = [
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
        'December',
      ];
      int m = now.month; // 1..12
      for (int step = 0; step < 12; step++) {
        final monthName = months[(m - 1 + step) % 12];
        final same = list
            .where((e) => (e['month'] ?? '') == monthName)
            .toList();
        if (same.isNotEmpty) {
          final e = same.first;
          final name = (e['name'] ?? '').toString();
          final type = (e['type'] ?? '').toString();
          return {'name': name, 'month': monthName, 'type': type};
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, String>>> getFestivalsList() async {
    try {
      final raw = await rootBundle.loadString(
        'data/TrueCircle_Festivals_Data.json',
      );
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final list =
          (decoded['festivals'] as List?)?.cast<Map<String, dynamic>>() ??
          const [];
      return list
          .map(
            (e) => {
              'name': (e['name'] ?? '').toString(),
              'month': (e['month'] ?? '').toString(),
              'type': (e['type'] ?? '').toString(),
            },
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<List<String>> getCbtTechniques() async {
    try {
      // Use preloaded data if available
      if (AppDataPreloader.instance.isPreloaded) {
        return AppDataPreloader.instance
            .getCBTTechniques()
            .map((e) => e.toString())
            .toList();
      }

      // Fallback to direct loading
      final raw = await rootBundle.loadString('assets/CBT_Techniques_En.json');
      final decoded = json.decode(raw);

      // Safe type checking for CBT techniques
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList(growable: false);
      } else if (decoded is Map<String, dynamic>) {
        final techniques = decoded['techniques'] ?? decoded['data'] ?? [];
        if (techniques is List) {
          return techniques.map((e) => e.toString()).toList(growable: false);
        }
      }

      return const [];
    } catch (e) {
      debugPrint('Error loading CBT techniques: $e');
      return const [];
    }
  }

  Future<List<String>> getCbtThoughts() async {
    try {
      // Use preloaded data if available
      if (AppDataPreloader.instance.isPreloaded) {
        return AppDataPreloader.instance
            .getCBTThoughts()
            .map((e) => e.toString())
            .toList();
      }

      // Fallback to direct loading
      final raw = await rootBundle.loadString('assets/CBT_Thoughts_En.json');
      final decoded = json.decode(raw);

      // Safe type checking for CBT thoughts
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList(growable: false);
      } else if (decoded is Map<String, dynamic>) {
        final thoughts = decoded['thoughts'] ?? decoded['data'] ?? [];
        if (thoughts is List) {
          return thoughts.map((e) => e.toString()).toList(growable: false);
        }
      }

      return const [];
    } catch (e) {
      debugPrint('Error loading CBT thoughts: $e');
      return const [];
    }
  }

  Future<List<String>> getCopingCards() async {
    if (_cachedCopingCards != null) return _cachedCopingCards!;
    try {
      // Use preloaded data if available
      if (AppDataPreloader.instance.isPreloaded) {
        _cachedCopingCards = AppDataPreloader.instance
            .getCopingCards()
            .map((e) => e.toString())
            .toList();
        return _cachedCopingCards!;
      }

      // Fallback to direct loading
      final raw = await rootBundle.loadString('assets/Coping_cards_En.json');
      final decoded = json.decode(raw);

      // Safe type checking for coping cards
      if (decoded is List) {
        _cachedCopingCards = decoded
            .map((e) => e.toString())
            .toList(growable: false);
        return _cachedCopingCards!;
      } else if (decoded is Map<String, dynamic>) {
        final cards = decoded['cards'] ?? decoded['data'] ?? [];
        if (cards is List) {
          _cachedCopingCards = cards
              .map((e) => e.toString())
              .toList(growable: false);
          return _cachedCopingCards!;
        }
      }

      _cachedCopingCards = const [];
      return _cachedCopingCards!;
    } catch (e) {
      debugPrint('Error loading coping cards: $e');
      _cachedCopingCards = const [];
      return _cachedCopingCards!;
    }
  }

  Future<List<Map<String, String>>> getPsychologyArticles() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/Psychology_Articles_En.json',
      );
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final list =
          (decoded['psychology_articles'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          const [];
      return list
          .map(
            (e) => {
              'id': (e['id'] ?? '').toString(),
              'title': (e['title'] ?? '').toString(),
              'summary': (e['summary'] ?? '').toString(),
              'body': (e['body'] ?? '').toString(),
            },
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  // Relationship Insights (list of objects)
  Future<List<Map<String, dynamic>>> getRelationshipInsights() async {
    try {
      final raw = await rootBundle.loadString(
        'data/Relations_Insights_Feature.json',
      );
      final decoded = json.decode(raw);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  // Relationship Interactions (alternate dataset with a space in file name)
  Future<List<Map<String, dynamic>>> getRelationshipInteractions() async {
    try {
      final raw = await rootBundle.loadString(
        'data/Relations Interactions_Feature.JSON',
      );
      final decoded = json.decode(raw);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  // Sleep tracker entries
  Future<List<Map<String, dynamic>>> getSleepTrackerEntries() async {
    try {
      final raw = await rootBundle.loadString('data/Sleep_Tracker.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final list =
          (decoded['sleepTracking'] as List?)?.cast<Map<String, dynamic>>() ??
          const [];
      return list;
    } catch (_) {
      return const [];
    }
  }

  // Meditation guides list
  Future<List<Map<String, dynamic>>> getMeditationGuides() async {
    try {
      final raw = await rootBundle.loadString(
        'data/Meditation_Guide_Demo_Data.json',
      );
      final decoded = json.decode(raw);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  /// Emotional Awareness categories with questions
  /// Source: TC/assets/Emotional_Awareness.JSON
  Future<List<Map<String, dynamic>>> getEmotionalAwarenessCategories() async {
    if (_cachedEmotionalAwarenessCategories != null) {
      return _cachedEmotionalAwarenessCategories!;
    }
    try {
      final raw = await rootBundle.loadString(
        'assets/Emotional_Awareness.JSON',
      );
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final cats =
          (decoded['categories'] as List?)?.cast<Map<String, dynamic>>() ??
          const [];
      final normalized = cats
          .map(
            (e) => {
              'id': (e['id'] ?? '').toString(),
              'title': (e['title'] ?? '').toString(),
              'questions': ((e['questions'] as List?) ?? const [])
                  .map((q) => q.toString())
                  .toList(),
            },
          )
          .toList(growable: false);
      _cachedEmotionalAwarenessCategories = normalized;
      return normalized;
    } catch (_) {
      _cachedEmotionalAwarenessCategories = const [];
      return _cachedEmotionalAwarenessCategories!;
    }
  }
}
