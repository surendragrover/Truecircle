import 'dart:convert';
import 'package:flutter/services.dart';

class BreathingSampleDataService {
  static List<Map<String, dynamic>>? _breathingData;

  static Future<List<Map<String, dynamic>>> getBreathingData() async {
    if (_breathingData != null) {
      return _breathingData!;
    }

    try {
      // Load from JSON file in Demo_data folder
      final String jsonString = await rootBundle
          .loadString('Demo_data/Breathing_+Exercises_Demo_Data.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _breathingData = jsonData.cast<Map<String, dynamic>>();
      return _breathingData!;
    } catch (e) {
      // Fallback data if file loading fails
      return _getDefaultBreathingData();
    }
  }

  static List<Map<String, dynamic>> _getDefaultBreathingData() {
    return [
      {
        "session_id": 1,
        "technique": "Anulom-Vilom",
        "technique_hindi": "अनुलोम-विलोम",
        "duration_minutes": 10,
        "stress_before": 7,
        "stress_after": 3,
        "effectiveness": 9,
        "physical_sensation": "Calm breathing, lightness in chest",
        "physical_sensation_hindi": "शांत साँस, छाती में हलकापन",
        "mental_clarity": "Focused and centered",
        "mental_clarity_hindi": "एकाग्र और केंद्रित",
        "energy_level": "Moderate",
        "energy_level_hindi": "मध्यम"
      },
      {
        "session_id": 2,
        "technique": "4-7-8 Breathing",
        "technique_hindi": "4-7-8 साँस लेने की तकनीक",
        "duration_minutes": 5,
        "stress_before": 6,
        "stress_after": 2,
        "effectiveness": 9,
        "physical_sensation": "Slow relaxed breathing",
        "physical_sensation_hindi": "धीमी और आरामदायक साँसें",
        "mental_clarity": "Calm mind",
        "mental_clarity_hindi": "शांत मन",
        "energy_level": "Low but relaxed",
        "energy_level_hindi": "कम लेकिन आरामदायक"
      },
      {
        "session_id": 3,
        "technique": "Kapalbhati",
        "technique_hindi": "कपालभाति",
        "duration_minutes": 10,
        "stress_before": 5,
        "stress_after": 3,
        "effectiveness": 9,
        "physical_sensation": "Warm abdominal area, energetic",
        "physical_sensation_hindi": "पेट गर्म और ऊर्जा भरा",
        "mental_clarity": "Alert and sharp",
        "mental_clarity_hindi": "सतर्क और तेज",
        "energy_level": "High",
        "energy_level_hindi": "उच्च"
      }
    ];
  }

  // Calculate analytics from the data
  static Map<String, dynamic> getAnalytics(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return {};

    final totalSessions = data.length;
    final totalMinutes = data.fold<int>(
        0, (sum, session) => sum + (session['duration_minutes'] as int));
    final avgStressBefore = data.fold<double>(
            0, (sum, session) => sum + (session['stress_before'] as int)) /
        totalSessions;
    final avgStressAfter = data.fold<double>(
            0, (sum, session) => sum + (session['stress_after'] as int)) /
        totalSessions;
    final avgEffectiveness = data.fold<double>(
            0, (sum, session) => sum + (session['effectiveness'] as int)) /
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

  // Get recent sessions (last 7 days)
  static List<Map<String, dynamic>> getRecentSessions(
      List<Map<String, dynamic>> data) {
    return data.take(7).toList();
  }

  // Get technique distribution
  static Map<String, int> getTechniqueDistribution(
      List<Map<String, dynamic>> data) {
    final Map<String, int> distribution = {};
    for (final session in data) {
      final technique = session['technique'] as String;
      distribution[technique] = (distribution[technique] ?? 0) + 1;
    }
    return distribution;
  }
}
