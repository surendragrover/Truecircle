import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// ComprehensiveSampleDataService
/// Loads and analyzes offline sample JSON datasets for multiple wellness features.
/// Terminology: "Sample" replaces legacy "Demo" while keeping asset folder names unchanged.
class ComprehensiveSampleDataService {
  // Cache for loaded data
  static final Map<String, List<Map<String, dynamic>>> _dataCache = {};

  // Load data for different features
  static Future<List<Map<String, dynamic>>> loadFeatureData(
      String feature) async {
    debugPrint('🔍 Loading data for feature: $feature');

    if (_dataCache.containsKey(feature)) {
      debugPrint(
          '📦 Cache hit for $feature: ${_dataCache[feature]!.length} items');
      return _dataCache[feature]!;
    }

    try {
      String fileName = '';
      switch (feature) {
        case 'breathing_exercises':
          fileName = 'Demo_data/Breathing_+Exercises_Demo_Data.json';
          break;
        case 'meditation_guide':
          fileName = 'Demo_data/Meditation_Guide_Demo_Data.json';
          break;
        case 'mood_journal':
          fileName = 'Demo_data/Mood_Journal_Demo_Data.json';
          break;
        case 'emotional_checkin':
          fileName = 'Demo_data/TrueCircle_Emotional_Checkin_Demo_Data.json';
          break;
        case 'relationship_insights':
          fileName = 'Demo_data/Relationship_Insights_Feature.json';
          break;
        case 'relationship_interactions':
          fileName = 'Demo_data/Relationship Interactions Feature.JSON';
          break;
        case 'sleep_tracker':
          fileName = 'Demo_data/Sleep_Tracker.json';
          break;
        case 'festivals':
          fileName = 'Demo_data/TrueCircle_Festivals_Data.json';
          break;
        default:
          return [];
      }

      debugPrint('📂 Loading file: $fileName');
      final String jsonString = await rootBundle.loadString(fileName);
      debugPrint('📄 File loaded, size: ${jsonString.length} characters');
      final dynamic jsonData = json.decode(jsonString);
      debugPrint('🔍 JSON parsed successfully');

      List<Map<String, dynamic>> processedData = [];
      if (jsonData is List) {
        processedData = jsonData.cast<Map<String, dynamic>>();
      } else if (jsonData is Map) {
        // Handle different JSON structures
        if (jsonData.containsKey('sleepTracking')) {
          processedData =
              (jsonData['sleepTracking'] as List).cast<Map<String, dynamic>>();
        } else if (jsonData.containsKey('emotional_checkins')) {
          processedData = (jsonData['emotional_checkins'] as List)
              .cast<Map<String, dynamic>>();
        } else if (jsonData.containsKey('festivals')) {
          processedData =
              (jsonData['festivals'] as List).cast<Map<String, dynamic>>();
        } else {
          // Convert single object to list
          processedData = [jsonData.cast<String, dynamic>()];
        }
      }

      debugPrint('✅ Processed ${processedData.length} items for $feature');
      _dataCache[feature] = processedData;
      return processedData;
    } catch (e) {
      debugPrint('❌ Error loading $feature data: $e');
      final defaultData = _getDefaultData(feature);
      debugPrint('🔄 Using default data: ${defaultData.length} items');
      return defaultData;
    }
  }

  // Analytics calculations for any feature
  static Map<String, dynamic> calculateAnalytics(
      List<Map<String, dynamic>> data, String feature) {
    if (data.isEmpty) return {};

    switch (feature) {
      case 'breathing_exercises':
        return _calculateBreathingAnalytics(data);
      case 'meditation_guide':
        return _calculateMeditationAnalytics(data);
      case 'mood_journal':
        return _calculateMoodAnalytics(data);
      case 'emotional_checkin':
        return _calculateEmotionalAnalytics(data);
      case 'sleep_tracker':
        return _calculateSleepAnalytics(data);
      default:
        return {'totalEntries': data.length};
    }
  }

  static Map<String, dynamic> _calculateBreathingAnalytics(
      List<Map<String, dynamic>> data) {
    final totalSessions = data.length;
    final totalMinutes = data.fold<int>(
        0, (sum, session) => sum + (session['duration_minutes'] as int? ?? 0));
    final avgStressBefore = data.fold<double>(0,
            (sum, session) => sum + (session['stress_before'] as int? ?? 0)) /
        totalSessions;
    final avgStressAfter = data.fold<double>(
            0, (sum, session) => sum + (session['stress_after'] as int? ?? 0)) /
        totalSessions;
    final avgEffectiveness = data.fold<double>(0,
            (sum, session) => sum + (session['effectiveness'] as int? ?? 0)) /
        totalSessions;

    return {
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'avgStressBefore': avgStressBefore,
      'avgStressAfter': avgStressAfter,
      'avgEffectiveness': avgEffectiveness,
      'stressReduction': avgStressBefore - avgStressAfter,
    };
  }

  static Map<String, dynamic> _calculateMeditationAnalytics(
      List<Map<String, dynamic>> data) {
    final totalSessions = data.length;
    final totalMinutes = data.fold<int>(
        0, (sum, session) => sum + (session['duration_minutes'] as int? ?? 0));
    final avgCalmness = data.fold<double>(0,
            (sum, session) => sum + (session['calmness_after'] as int? ?? 0)) /
        totalSessions;
    final avgFocus = data.fold<double>(
            0,
            (sum, session) =>
                sum + (session['focus_improvement'] as int? ?? 0)) /
        totalSessions;

    return {
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'avgCalmness': avgCalmness,
      'avgFocus': avgFocus,
    };
  }

  static Map<String, dynamic> _calculateMoodAnalytics(
      List<Map<String, dynamic>> data) {
    final totalEntries = data.length;
    final avgMoodScore = data.fold<double>(
            0, (sum, entry) => sum + (entry['mood_score'] as int? ?? 0)) /
        totalEntries;
    final positiveEntries =
        data.where((entry) => (entry['mood_score'] as int? ?? 0) >= 7).length;

    return {
      'totalEntries': totalEntries,
      'avgMoodScore': avgMoodScore,
      'positiveEntries': positiveEntries,
      'positivePercentage': (positiveEntries / totalEntries) * 100,
    };
  }

  static Map<String, dynamic> _calculateEmotionalAnalytics(
      List<Map<String, dynamic>> data) {
    final totalCheckins = data.length;
    final avgIntensity = data.fold<double>(
            0, (sum, entry) => sum + (entry['intensity'] as int? ?? 0)) /
        totalCheckins;
    final mostCommonEmotion = _findMostCommonValue(data, 'emotion');

    return {
      'totalCheckins': totalCheckins,
      'avgIntensity': avgIntensity,
      'mostCommonEmotion': mostCommonEmotion,
    };
  }

  static Map<String, dynamic> _calculateSleepAnalytics(
      List<Map<String, dynamic>> data) {
    final totalNights = data.length;
    final avgDuration = _parseAverageTime(
        data.map((entry) => entry['duration'] as String? ?? '0h 0m').toList());
    final avgQuality = data.fold<double>(
            0, (sum, entry) => sum + (entry['quality'] as int? ?? 0)) /
        totalNights;

    return {
      'totalNights': totalNights,
      'avgDuration': avgDuration,
      'avgQuality': avgQuality,
    };
  }

  static String _findMostCommonValue(
      List<Map<String, dynamic>> data, String key) {
    final counts = <String, int>{};
    for (final entry in data) {
      final value = entry[key] as String? ?? '';
      counts[value] = (counts[value] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static String _parseAverageTime(List<String> durations) {
    int totalMinutes = 0;
    for (final duration in durations) {
      final parts = duration.split(' ');
      int hours = 0, minutes = 0;
      for (final part in parts) {
        if (part.contains('h')) {
          hours = int.tryParse(part.replaceAll('h', '')) ?? 0;
        } else if (part.contains('m')) {
          minutes = int.tryParse(part.replaceAll('m', '')) ?? 0;
        }
      }
      totalMinutes += (hours * 60) + minutes;
    }
    final avgMinutes = totalMinutes / durations.length;
    final avgHours = (avgMinutes / 60).floor();
    final remainingMinutes = (avgMinutes % 60).round();
    return '${avgHours}h ${remainingMinutes}m';
  }

  // Get recent entries for any feature
  static List<Map<String, dynamic>> getRecentEntries(
      List<Map<String, dynamic>> data,
      [int count = 7]) {
    return data.take(count).toList();
  }

  // Default data fallbacks
  static List<Map<String, dynamic>> _getDefaultData(String feature) {
    switch (feature) {
      case 'breathing_exercises':
        return [
          {
            "session_id": 1,
            "technique": "Anulom-Vilom",
            "technique_hindi": "अनुलोम-विलोम",
            "duration_minutes": 10,
            "stress_before": 7,
            "stress_after": 3,
            "effectiveness": 9
          }
        ];
      case 'mood_journal':
        return [
          {
            "day": 1,
            "mood_score": 7,
            "emotion": "Happy",
            "emotion_hindi": "खुश",
            "note": "Good day overall"
          }
        ];
      default:
        return [];
    }
  }
}
