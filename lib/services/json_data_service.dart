import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
      final String jsonString = await rootBundle.loadString('Demo_data/TrueCircle_Festivals_Data.json');
      _festivalsData = json.decode(jsonString);
      debugPrint('Successfully loaded festivals data: ${_festivalsData!['festivals'].length} festivals');
      return _festivalsData!;
    } catch (e) {
      debugPrint('Error loading festivals data: $e');
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
      final String jsonString = await rootBundle.loadString('Demo_data/Relationship Interactions Feature.JSON');
      _relationshipData = List<Map<String, dynamic>>.from(json.decode(jsonString));
      debugPrint('Successfully loaded relationship data: ${_relationshipData!.length} entries');
      return _relationshipData!;
    } catch (e) {
      debugPrint('Error loading relationship data: $e');
      return [];
    }
  }

  /// Load emotional check-in data from JSON file  
  Future<List<Map<String, dynamic>>> getEmotionalCheckInData() async {
    if (_emotionalCheckInData != null) return _emotionalCheckInData!;

    try {
      final String jsonString = await rootBundle.loadString('Demo_data/TrueCircle_Emotional_Checkin_Demo_Data.json');
      _emotionalCheckInData = List<Map<String, dynamic>>.from(json.decode(jsonString));
      debugPrint('Successfully loaded emotional check-in data: ${_emotionalCheckInData!.length} entries');
      return _emotionalCheckInData!;
    } catch (e) {
      debugPrint('Error loading emotional check-in data: $e');
      return [];
    }
  }

  /// Load mood journal data from JSON file
  Future<Map<String, dynamic>> getMoodJournalData() async {
    if (_moodJournalData != null) return _moodJournalData!;

    try {
      final String jsonString = await rootBundle.loadString('Demo_data/Mood_Journal_Demo_Data.json');
      final List<dynamic> rawData = json.decode(jsonString);
      _moodJournalData = {
        'entries': rawData,
        'summary': 'Loaded ${rawData.length} mood journal entries'
      };
      debugPrint('Successfully loaded mood journal data: ${rawData.length} entries');
      return _moodJournalData!;
    } catch (e) {
      debugPrint('Error loading mood journal data: $e');
      return {
        'entries': [],
        'summary': 'No data available'
      };
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
      debugPrint('Festival not found: $festivalId');
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
      final String jsonString = await rootBundle.loadString('Demo_data/Meditation_Guide_Demo_Data.json');
      _meditationData = List<Map<String, dynamic>>.from(json.decode(jsonString));
      debugPrint('Successfully loaded meditation data: ${_meditationData!.length} entries');
      return _meditationData!;
    } catch (e) {
      debugPrint('Error loading meditation data: $e');
      return [];
    }
  }

  /// Load breathing exercises data from JSON file
  Future<List<Map<String, dynamic>>> getBreathingData() async {
    if (_breathingData != null) return _breathingData!;

    try {
      final String jsonString = await rootBundle.loadString('Demo_data/Breathing_+Exercises_Demo_Data.json');
      _breathingData = List<Map<String, dynamic>>.from(json.decode(jsonString));
      debugPrint('Successfully loaded breathing exercises data: ${_breathingData!.length} entries');
      return _breathingData!;
    } catch (e) {
      debugPrint('Error loading breathing exercises data: $e');
      return [];
    }
  }

  /// Get today's meditation tip (daily rotation)
  Future<Map<String, dynamic>?> getTodaysMeditationTip() async {
    try {
      final meditations = await getMeditationData();
      if (meditations.isEmpty) return null;
      
      final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
      final tipIndex = dayOfYear % meditations.length;
      return meditations[tipIndex];
    } catch (e) {
      debugPrint('Error getting today\'s meditation tip: $e');
      return null;
    }
  }

  /// Get today's breathing exercise tip (daily rotation)
  Future<Map<String, dynamic>?> getTodaysBreathingTip() async {
    try {
      final exercises = await getBreathingData();
      if (exercises.isEmpty) return null;
      
      final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
      final tipIndex = dayOfYear % exercises.length;
      return exercises[tipIndex];
    } catch (e) {
      debugPrint('Error getting today\'s breathing tip: $e');
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
    debugPrint('JSON data cache cleared');
  }
}
