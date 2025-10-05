import 'dart:convert';
import 'package:flutter/services.dart';

import 'logging_service.dart';

/// Service to load and parse JSON data from Demo_data folder
class JsonDataService {
  static JsonDataService? _instance;
  static JsonDataService get instance => _instance ??= JsonDataService._();
  JsonDataService._();

  Map<String, dynamic>? _festivalsData;
  List<Map<String, dynamic>>? _relationshipData;
  List<Map<String, dynamic>>? _emotionalCheckInData;
  Map<String, dynamic>? _moodJournalData;

  /// Load festivals data from JSON file
  Future<Map<String, dynamic>> getFestivalsData() async {
    if (_festivalsData != null) return _festivalsData!;

    try {
      final String jsonString = await rootBundle
          .loadString('Demo_data/TrueCircle_Festivals_Data.json');
      _festivalsData = json.decode(jsonString);
      LoggingService.success(
        'Festivals data loaded (${_festivalsData!['festivals'].length} items)',
        messageHi:
            'त्योहार डेटा लोड हुआ (${_festivalsData!['festivals'].length} प्रविष्टियाँ)',
      );
      return _festivalsData!;
    } catch (e) {
      LoggingService.error(
        'Error loading festivals data: $e',
        messageHi: 'त्योहार डेटा लोड करने में त्रुटि: $e',
      );
      return {
        'festivals': [],
        'metadata': {
          'totalFestivals': 0,
          'lastUpdated': DateTime.now().toIso8601String(),
          'version': '1.0',
          'error': 'Failed to load festivals data'
        }
      };
    }
  }

  /// Load relationship interactions data from JSON file
  Future<List<Map<String, dynamic>>> getRelationshipData() async {
    if (_relationshipData != null) return _relationshipData!;

    try {
      final String jsonString = await rootBundle
          .loadString('Demo_data/Relationship Interactions Feature.JSON');
      _relationshipData =
          List<Map<String, dynamic>>.from(json.decode(jsonString));
      LoggingService.success(
        'Relationship data loaded (${_relationshipData!.length} entries)',
        messageHi:
            'रिश्तों का डेटा लोड हुआ (${_relationshipData!.length} प्रविष्टियाँ)',
      );
      return _relationshipData!;
    } catch (e) {
      LoggingService.error(
        'Error loading relationship data: $e',
        messageHi: 'रिश्ता डेटा लोड करने में त्रुटि: $e',
      );
      return [];
    }
  }

  /// Load emotional check-in data from JSON file
  Future<List<Map<String, dynamic>>> getEmotionalCheckInData() async {
    if (_emotionalCheckInData != null) return _emotionalCheckInData!;

    try {
      final String jsonString = await rootBundle
          .loadString('Demo_data/TrueCircle_Emotional_Checkin_Demo_Data.json');
      _emotionalCheckInData =
          List<Map<String, dynamic>>.from(json.decode(jsonString));
      LoggingService.success(
        'Emotional check-in data loaded (${_emotionalCheckInData!.length} entries)',
        messageHi:
            'इमोशनल चेक-इन डेटा लोड हुआ (${_emotionalCheckInData!.length} प्रविष्टियाँ)',
      );
      return _emotionalCheckInData!;
    } catch (e) {
      LoggingService.error(
        'Error loading emotional check-in data: $e',
        messageHi: 'इमोशनल चेक-इन डेटा लोड करने में त्रुटि: $e',
      );
      return [];
    }
  }

  /// Load mood journal data from JSON file
  Future<Map<String, dynamic>> getMoodJournalData() async {
    if (_moodJournalData != null) return _moodJournalData!;

    try {
      final String jsonString =
          await rootBundle.loadString('Demo_data/Mood_Journal_Demo_Data.json');
      final List<dynamic> rawData = json.decode(jsonString);
      _moodJournalData = {
        'entries': rawData,
        'summary': 'Loaded ${rawData.length} mood journal entries'
      };
      LoggingService.success(
        'Mood journal data loaded (${rawData.length} entries)',
        messageHi: 'मूड जर्नल डेटा लोड हुआ (${rawData.length} प्रविष्टियाँ)',
      );
      return _moodJournalData!;
    } catch (e) {
      LoggingService.error(
        'Error loading mood journal data: $e',
        messageHi: 'मूड जर्नल डेटा लोड करने में त्रुटि: $e',
      );
      return {'entries': [], 'summary': 'No data available'};
    }
  }

  /// Get upcoming festivals (next 30 days)
  Future<List<Map<String, dynamic>>> getUpcomingFestivals() async {
    final festivalsData = await getFestivalsData();
    final festivals = festivalsData['festivals'] as List<dynamic>;

    // For sample preview, return first 5 festivals
    // In a real app, you'd filter by actual dates
    return festivals.take(5).map((f) => Map<String, dynamic>.from(f)).toList();
  }

  /// Get recent relationship interactions (last 7 days)
  Future<List<Map<String, dynamic>>> getRecentRelationshipInsights() async {
    final relationshipData = await getRelationshipData();

    // For sample preview, return last 5 entries
    // In a real app, you'd filter by actual dates
    return relationshipData.take(5).toList();
  }

  /// Get festival greeting for a specific festival
  Future<Map<String, String>?> getFestivalGreeting(String festivalId) async {
    final festivalsData = await getFestivalsData();
    final festivals = festivalsData['festivals'] as List<dynamic>;

    try {
      final festival = festivals.firstWhere(
        (f) => f['id'] == festivalId,
      );
      return Map<String, String>.from(festival['greetingMessages']);
    } catch (e) {
      LoggingService.warn(
        'Festival not found: $festivalId',
        messageHi: 'त्योहार नहीं मिला: $festivalId',
      );
      return null;
    }
  }

  // Cache for new services
  List<Map<String, dynamic>>? _meditationData;
  List<Map<String, dynamic>>? _breathingData;

  /// Load meditation guide data from JSON file
  Future<List<Map<String, dynamic>>> getMeditationData() async {
    if (_meditationData != null) return _meditationData!;

    try {
      final String jsonString = await rootBundle
          .loadString('Demo_data/Meditation_Guide_Demo_Data.json');
      _meditationData =
          List<Map<String, dynamic>>.from(json.decode(jsonString));
      LoggingService.success(
        'Meditation data loaded (${_meditationData!.length} entries)',
        messageHi:
            'मेडिटेशन डेटा लोड हुआ (${_meditationData!.length} प्रविष्टियाँ)',
      );
      return _meditationData!;
    } catch (e) {
      LoggingService.error(
        'Error loading meditation data: $e',
        messageHi: 'मेडिटेशन डेटा लोड करने में त्रुटि: $e',
      );
      return [];
    }
  }

  /// Load breathing exercises data from JSON file
  Future<List<Map<String, dynamic>>> getBreathingData() async {
    if (_breathingData != null) return _breathingData!;

    try {
      final String jsonString = await rootBundle
          .loadString('Demo_data/Breathing_+Exercises_Demo_Data.json');
      _breathingData = List<Map<String, dynamic>>.from(json.decode(jsonString));
      LoggingService.success(
        'Breathing exercise data loaded (${_breathingData!.length} entries)',
        messageHi:
            'श्वास अभ्यास डेटा लोड हुआ (${_breathingData!.length} प्रविष्टियाँ)',
      );
      return _breathingData!;
    } catch (e) {
      LoggingService.error(
        'Error loading breathing exercises data: $e',
        messageHi: 'श्वास अभ्यास डेटा लोड करने में त्रुटि: $e',
      );
      return [];
    }
  }

  /// Get today's meditation tip (daily rotation)
  Future<Map<String, dynamic>?> getTodaysMeditationTip() async {
    try {
      final meditations = await getMeditationData();
      if (meditations.isEmpty) return null;

      final dayOfYear =
          DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
      final tipIndex = dayOfYear % meditations.length;
      return meditations[tipIndex];
    } catch (e) {
      LoggingService.error(
        'Error getting today\'s meditation tip: $e',
        messageHi: 'आज का मेडिटेशन टिप प्राप्त करने में त्रुटि: $e',
      );
      return null;
    }
  }

  /// Get today's breathing exercise tip (daily rotation)
  Future<Map<String, dynamic>?> getTodaysBreathingTip() async {
    try {
      final exercises = await getBreathingData();
      if (exercises.isEmpty) return null;

      final dayOfYear =
          DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
      final tipIndex = dayOfYear % exercises.length;
      return exercises[tipIndex];
    } catch (e) {
      LoggingService.error(
        'Error getting today\'s breathing tip: $e',
        messageHi: 'आज का श्वास टिप प्राप्त करने में त्रुटि: $e',
      );
      return null;
    }
  }

  /// Clear cached data to force reload
  void clearCache() {
    _festivalsData = null;
    _relationshipData = null;
    _emotionalCheckInData = null;
    _moodJournalData = null;
    _meditationData = null;
    _breathingData = null;
    LoggingService.info(
      'JSON data cache cleared',
      messageHi: 'JSON डेटा कैश साफ किया गया',
    );
  }
}
