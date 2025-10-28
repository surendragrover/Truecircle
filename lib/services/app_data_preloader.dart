import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Comprehensive Data Preloader Service
/// Loads all JSON files at app startup for instant feature access
class AppDataPreloader {
  static final AppDataPreloader _instance = AppDataPreloader._internal();
  static AppDataPreloader get instance => _instance;
  AppDataPreloader._internal();

  // Preloaded data storage
  final Map<String, dynamic> _preloadedData = {};
  bool _isPreloaded = false;

  /// Check if data is already preloaded
  bool get isPreloaded => _isPreloaded;

  /// Preload all JSON files at app startup
  Future<void> preloadAllData() async {
    if (_isPreloaded) return;

    try {
      await Future.wait([
        _loadCBTData(),
        _loadEmotionalAwarenessData(),
        _loadMeditationData(),
        _loadSleepData(),
        _loadPsychologyData(),
        _loadFestivalData(),
        _loadRelationshipData(),
        _loadMoodData(),
        _loadBreathingData(),
        _loadDemoData(),
      ]);

      _isPreloaded = true;
      if (kDebugMode) {
        debugPrint('✅ All app data preloaded successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error preloading app data: $e');
      }
      _isPreloaded = false;
    }
  }

  /// Get preloaded data by key
  dynamic getData(String key) {
    return _preloadedData[key];
  }

  /// Load CBT (Cognitive Behavioral Therapy) data
  Future<void> _loadCBTData() async {
    try {
      // CBT Techniques
      final cbtTechniques = await rootBundle.loadString(
        'assets/CBT_Techniques_En.json',
      );
      _preloadedData['cbt_techniques'] = jsonDecode(cbtTechniques);

      // CBT Thoughts
      final cbtThoughts = await rootBundle.loadString(
        'assets/CBT_Thoughts_En.json',
      );
      _preloadedData['cbt_thoughts'] = jsonDecode(cbtThoughts);

      // Coping Cards
      final copingCards = await rootBundle.loadString(
        'assets/Coping_cards_En.json',
      );
      _preloadedData['coping_cards'] = jsonDecode(copingCards);

      // CBT Micro Lessons
      final microLessons = await rootBundle.loadString(
        'data/CBT_Micro_Lessons_en.json',
      );
      _preloadedData['cbt_micro_lessons'] = jsonDecode(microLessons);

      if (kDebugMode) {
        debugPrint('✅ CBT data loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading CBT data: $e');
      }
      _preloadedData['cbt_techniques'] = [];
      _preloadedData['cbt_thoughts'] = [];
      _preloadedData['coping_cards'] = [];
      _preloadedData['cbt_micro_lessons'] = [];
    }
  }

  /// Load Emotional Awareness data
  Future<void> _loadEmotionalAwarenessData() async {
    try {
      final emotionalAwareness = await rootBundle.loadString(
        'assets/Emotional_Awareness.JSON',
      );
      _preloadedData['emotional_awareness'] = jsonDecode(emotionalAwareness);

      final emotionalCheckin = await rootBundle.loadString(
        'data/TrueCircle_Emotional_Checkin_Demo_Data.json',
      );
      _preloadedData['emotional_checkin'] = jsonDecode(emotionalCheckin);

      if (kDebugMode) {
        debugPrint('✅ Emotional Awareness data loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading Emotional Awareness data: $e');
      }
      _preloadedData['emotional_awareness'] = [];
      _preloadedData['emotional_checkin'] = [];
    }
  }

  /// Load Meditation data
  Future<void> _loadMeditationData() async {
    try {
      final meditationGuide = await rootBundle.loadString(
        'data/Meditation_Guide_Demo_Data.json',
      );
      _preloadedData['meditation_guide'] = jsonDecode(meditationGuide);

      if (kDebugMode) {
        debugPrint('✅ Meditation data loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading Meditation data: $e');
      }
      _preloadedData['meditation_guide'] = [];
    }
  }

  /// Load Sleep data
  Future<void> _loadSleepData() async {
    try {
      final sleepTricks = await rootBundle.loadString(
        'assets/Sleep_Tricks.json',
      );
      _preloadedData['sleep_tricks'] = jsonDecode(sleepTricks);

      final sleepTracker = await rootBundle.loadString(
        'data/Sleep_Tracker.json',
      );
      _preloadedData['sleep_tracker'] = jsonDecode(sleepTracker);

      if (kDebugMode) {
        debugPrint('✅ Sleep data loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading Sleep data: $e');
      }
      _preloadedData['sleep_tricks'] = [];
      _preloadedData['sleep_tracker'] = [];
    }
  }

  /// Load Psychology Articles data
  Future<void> _loadPsychologyData() async {
    try {
      final psychologyArticles = await rootBundle.loadString(
        'assets/Psychology_Articles_En.json',
      );
      final decoded = jsonDecode(psychologyArticles);

      // Safe extraction of psychology articles array
      if (decoded is Map<String, dynamic>) {
        _preloadedData['psychology_articles'] =
            decoded['psychology_articles'] ?? [];
      } else if (decoded is List) {
        _preloadedData['psychology_articles'] = decoded;
      } else {
        _preloadedData['psychology_articles'] = [];
      }

      if (kDebugMode) {
        debugPrint('✅ Psychology Articles data loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading Psychology Articles data: $e');
      }
      _preloadedData['psychology_articles'] = [];
    }
  }

  /// Load Festival data
  Future<void> _loadFestivalData() async {
    try {
      final festivalsData = await rootBundle.loadString(
        'data/TrueCircle_Festivals_Data.json',
      );
      final decoded = jsonDecode(festivalsData);

      // Safe extraction of festivals array
      if (decoded is Map<String, dynamic>) {
        _preloadedData['festivals'] = decoded['festivals'] ?? [];
      } else if (decoded is List) {
        _preloadedData['festivals'] = decoded;
      } else {
        _preloadedData['festivals'] = [];
      }

      if (kDebugMode) {
        debugPrint('✅ Festival data loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading Festival data: $e');
      }
      _preloadedData['festivals'] = [];
    }
  }

  /// Load Relationship data
  Future<void> _loadRelationshipData() async {
    try {
      final relationshipInsights = await rootBundle.loadString(
        'assets/Relationship_Insight_Questions.json',
      );
      _preloadedData['relationship_insights'] = jsonDecode(
        relationshipInsights,
      );

      final relationshipInteractions = await rootBundle.loadString(
        'data/Relations_Insights_Feature.json',
      );
      _preloadedData['relationship_interactions'] = jsonDecode(
        relationshipInteractions,
      );

      if (kDebugMode) {
        debugPrint('✅ Relationship data loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading Relationship data: $e');
      }
      _preloadedData['relationship_insights'] = [];
      _preloadedData['relationship_interactions'] = [];
    }
  }

  /// Load Mood data
  Future<void> _loadMoodData() async {
    try {
      final moodJournal = await rootBundle.loadString(
        'data/Mood_Journal_Demo_Data.json',
      );
      _preloadedData['mood_journal'] = jsonDecode(moodJournal);

      if (kDebugMode) {
        debugPrint('✅ Mood data loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading Mood data: $e');
      }
      _preloadedData['mood_journal'] = [];
    }
  }

  /// Load Breathing Exercises data
  Future<void> _loadBreathingData() async {
    try {
      final breathingExercises = await rootBundle.loadString(
        'data/Breathing_+Exercises_Demo_Data.json',
      );
      _preloadedData['breathing_exercises'] = jsonDecode(breathingExercises);

      if (kDebugMode) {
        debugPrint('✅ Breathing Exercises data loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading Breathing Exercises data: $e');
      }
      _preloadedData['breathing_exercises'] = [];
    }
  }

  /// Load additional demo data
  Future<void> _loadDemoData() async {
    try {
      // Cultural data
      final culturalData = await rootBundle.loadString(
        'assets/cultural_data.json',
      );
      _preloadedData['cultural_data'] = jsonDecode(culturalData);

      // FAQ data
      final faqData = await rootBundle.loadString('assets/FAQ.JSON');
      _preloadedData['faq'] = jsonDecode(faqData);

      // Privacy Policy
      final privacyPolicy = await rootBundle.loadString(
        'assets/Privacy_Policy.JSON',
      );
      _preloadedData['privacy_policy'] = jsonDecode(privacyPolicy);

      // Terms and Conditions
      final termsConditions = await rootBundle.loadString(
        'assets/Terms and Conditions.JSON',
      );
      _preloadedData['terms_conditions'] = jsonDecode(termsConditions);

      if (kDebugMode) {
        debugPrint('✅ Demo and additional data loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading demo data: $e');
      }
      _preloadedData['cultural_data'] = [];
      _preloadedData['faq'] = [];
      _preloadedData['privacy_policy'] = {};
      _preloadedData['terms_conditions'] = {};
    }
  }

  /// Get CBT Techniques
  List<dynamic> getCBTTechniques() {
    return _preloadedData['cbt_techniques'] ?? [];
  }

  /// Get CBT Thoughts
  List<dynamic> getCBTThoughts() {
    return _preloadedData['cbt_thoughts'] ?? [];
  }

  /// Get Coping Cards
  List<dynamic> getCopingCards() {
    return _preloadedData['coping_cards'] ?? [];
  }

  /// Get CBT Micro Lessons
  List<dynamic> getCBTMicroLessons() {
    return _preloadedData['cbt_micro_lessons'] ?? [];
  }

  /// Get Emotional Awareness categories
  List<dynamic> getEmotionalAwarenessCategories() {
    return _preloadedData['emotional_awareness'] ?? [];
  }

  /// Get Emotional Check-in data
  Map<String, dynamic> getEmotionalCheckinData() {
    return _preloadedData['emotional_checkin'] ?? {};
  }

  /// Get Meditation Guide data
  List<dynamic> getMeditationGuide() {
    return _preloadedData['meditation_guide'] ?? [];
  }

  /// Get Sleep Tricks
  List<dynamic> getSleepTricks() {
    return _preloadedData['sleep_tricks'] ?? [];
  }

  /// Get Sleep Tracker data
  Map<String, dynamic> getSleepTrackerData() {
    return _preloadedData['sleep_tracker'] ?? {};
  }

  /// Get Psychology Articles
  List<dynamic> getPsychologyArticles() {
    return _preloadedData['psychology_articles'] ?? [];
  }

  /// Get Festival data
  List<dynamic> getFestivals() {
    return _preloadedData['festivals'] ?? [];
  }

  /// Get Relationship Insights
  List<dynamic> getRelationshipInsights() {
    return _preloadedData['relationship_insights'] ?? [];
  }

  /// Get Relationship Interactions
  Map<String, dynamic> getRelationshipInteractions() {
    return _preloadedData['relationship_interactions'] ?? {};
  }

  /// Get Mood Journal data
  List<dynamic> getMoodJournalData() {
    return _preloadedData['mood_journal'] ?? [];
  }

  /// Get Breathing Exercises
  List<dynamic> getBreathingExercises() {
    return _preloadedData['breathing_exercises'] ?? [];
  }

  /// Get Cultural data
  Map<String, dynamic> getCulturalData() {
    return _preloadedData['cultural_data'] ?? {};
  }

  /// Get FAQ data
  List<dynamic> getFAQ() {
    return _preloadedData['faq'] ?? [];
  }

  /// Get Privacy Policy
  Map<String, dynamic> getPrivacyPolicy() {
    return _preloadedData['privacy_policy'] ?? {};
  }

  /// Get Terms and Conditions
  Map<String, dynamic> getTermsConditions() {
    return _preloadedData['terms_conditions'] ?? {};
  }

  /// Clear all preloaded data (for memory management)
  void clearData() {
    _preloadedData.clear();
    _isPreloaded = false;
  }

  /// Get data loading status summary
  Map<String, bool> getLoadingStatus() {
    return {
      'cbt_data': _preloadedData.containsKey('cbt_techniques'),
      'emotional_awareness': _preloadedData.containsKey('emotional_awareness'),
      'meditation': _preloadedData.containsKey('meditation_guide'),
      'sleep': _preloadedData.containsKey('sleep_tricks'),
      'psychology': _preloadedData.containsKey('psychology_articles'),
      'festivals': _preloadedData.containsKey('festivals'),
      'relationships': _preloadedData.containsKey('relationship_insights'),
      'mood': _preloadedData.containsKey('mood_journal'),
      'breathing': _preloadedData.containsKey('breathing_exercises'),
      'additional': _preloadedData.containsKey('cultural_data'),
    };
  }
}
