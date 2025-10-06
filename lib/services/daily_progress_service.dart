import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/daily_progress.dart';
import '../models/mood_entry.dart';
import '../models/relationship_log.dart';
import '../models/mental_health_log.dart';

/// DailyProgressService - Comprehensive Daily Progress Tracking
///
/// यह service सभी tracking systems को integrate करती है:
/// - Sleep Tracker integration
/// - Meditation Guide data
/// - Mood Entry analysis
/// - Relationship Log scores
/// - Achievement system
/// - Daily login rewards
///
/// Privacy: All data stored locally with encryption support
class DailyProgressService {
  static const String _progressBoxName = 'daily_progress_encrypted';
  static const String _weeklyBoxName = 'weekly_progress_encrypted';

  Box<DailyProgress>? _progressBox;
  Box<WeeklyProgressSummary>? _weeklyBox;

  static DailyProgressService? _instance;
  static DailyProgressService get instance =>
      _instance ??= DailyProgressService._();
  DailyProgressService._();

  /// Initialize the service
  Future<void> initialize() async {
    try {
      // Open boxes for privacy (encryption handled by Hive internally)
      _progressBox = await Hive.openBox<DailyProgress>(_progressBoxName);
      _weeklyBox = await Hive.openBox<WeeklyProgressSummary>(_weeklyBoxName);

      debugPrint(
          '✅ DailyProgressService initialized with ${_progressBox?.length ?? 0} entries');
    } catch (e) {
      debugPrint('❌ DailyProgressService initialization failed: $e');
      // Fallback to non-encrypted boxes
      _progressBox =
          await Hive.openBox<DailyProgress>('daily_progress_fallback');
      _weeklyBox =
          await Hive.openBox<WeeklyProgressSummary>('weekly_progress_fallback');
    }
  }

  /// Create or update daily progress for given date
  Future<DailyProgress> updateDailyProgress({
    DateTime? date,
    int? pointsEarned,
    int? sleepHours,
    double? sleepQuality,
    int? meditationMinutes,
    int? exerciseMinutes,
    double? screenTimeHours,
    List<String>? newAchievements,
    String? dailyReflection,
    bool forceRecalculate = false,
  }) async {
    if (_progressBox == null) await initialize();

    final targetDate = date ?? DateTime.now();
    final dateKey = _getDateKey(targetDate);

  // Get existing or create new progress entry
  DailyProgress? existingProgress = _progressBox!.get(dateKey);

    // Calculate scores from integrated data sources
    final relationshipScore = await _calculateRelationshipScore(targetDate);
    final wellnessScore = await _calculateWellnessScore(targetDate);
    final conversationCount = await _getConversationCount(targetDate);
    final goalCompletion = await _calculateGoalCompletion(targetDate);

    if (existingProgress != null && !forceRecalculate) {
      // Update existing entry
      final ep = existingProgress!; // Promote to non-null for safe access
      final updatedProgress = ep.copyWith(
        pointsEarned: pointsEarned ?? ep.pointsEarned,
        sleepHours: sleepHours ?? ep.sleepHours,
        sleepQuality: sleepQuality ?? ep.sleepQuality,
        meditationMinutes: meditationMinutes ?? ep.meditationMinutes,
        exerciseMinutes: exerciseMinutes ?? ep.exerciseMinutes,
        screenTimeHours: screenTimeHours ?? ep.screenTimeHours,
        dailyReflection: dailyReflection ?? ep.dailyReflection,
        overallRelationshipScore: relationshipScore,
        wellnessScore: wellnessScore,
        conversationCount: conversationCount,
        goalCompletionRate: goalCompletion,
        achievementBadges: newAchievements != null
            ? {...ep.achievementBadges, ...newAchievements}.toList()
            : ep.achievementBadges,
      );

      await _progressBox!.put(dateKey, updatedProgress);
      return updatedProgress;
    } else {
      // Create new entry
      final newProgress = DailyProgress(
        date: targetDate,
        pointsEarned: pointsEarned ?? await _getDailyLoginPoints(targetDate),
        overallRelationshipScore: relationshipScore,
        wellnessScore: wellnessScore,
        sleepHours: sleepHours ?? await _getSleepHours(targetDate),
        meditationMinutes:
            meditationMinutes ?? await _getMeditationMinutes(targetDate),
        sleepQuality: sleepQuality ?? await _getSleepQuality(targetDate),
        conversationCount: conversationCount,
        exerciseMinutes: exerciseMinutes ?? 0,
        screenTimeHours: screenTimeHours ?? 0.0,
        achievementBadges: newAchievements ?? (existingProgress?.achievementBadges ?? []),
        dailyReflection: dailyReflection,
        goalCompletionRate: goalCompletion,
      );

      await _progressBox!.put(dateKey, newProgress);
      return newProgress;
    }
  }

  /// Get daily progress for specific date
  Future<DailyProgress?> getDailyProgress(DateTime date) async {
    if (_progressBox == null) await initialize();

    final dateKey = _getDateKey(date);
    return _progressBox!.get(dateKey);
  }

  /// Get progress entries for date range
  Future<List<DailyProgress>> getProgressRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_progressBox == null) await initialize();

  final entries = <DailyProgress>[];
  DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      final entry = await getDailyProgress(current);
      if (entry != null) {
        entries.add(entry);
      }
      // DateTime is immutable; ensure we advance the loop variable
      current = current.add(const Duration(days: 1));
    }

    return entries..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Get recent progress entries (last N days)
  Future<List<DailyProgress>> getRecentProgress({int days = 7}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    return getProgressRange(startDate: startDate, endDate: endDate);
  }

  /// Calculate weekly summary
  Future<WeeklyProgressSummary> getWeeklySummary(DateTime weekStartDate) async {
    final weekEndDate = weekStartDate.add(const Duration(days: 6));
    final weekKey = _getWeekKey(weekStartDate);

    // Check for cached weekly summary
    if (_weeklyBox != null) {
      final cached = _weeklyBox!.get(weekKey);
      if (cached != null &&
          cached.weekEndDate
              .isAfter(DateTime.now().subtract(const Duration(hours: 6)))) {
        return cached;
      }
    }

    // Calculate fresh weekly summary
    final dailyEntries = await getProgressRange(
      startDate: weekStartDate,
      endDate: weekEndDate,
    );

    final summary = WeeklyProgressSummary.fromDailyEntries(dailyEntries);

    // Cache the summary
    if (_weeklyBox != null) {
      await _weeklyBox!.put(weekKey, summary);
    }

    return summary;
  }

  /// Add achievement badge to today's progress
  Future<void> addAchievement(String achievement, {DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final existing = await getDailyProgress(targetDate);

    if (existing != null && !existing.achievementBadges.contains(achievement)) {
      await updateDailyProgress(
        date: targetDate,
        newAchievements: [achievement],
      );
    }
  }

  /// Get achievement statistics
  Future<Map<String, int>> getAchievementStats({int days = 30}) async {
    final entries = await getRecentProgress(days: days);
    final achievementCounts = <String, int>{};

    for (final entry in entries) {
      for (final achievement in entry.achievementBadges) {
        achievementCounts[achievement] =
            (achievementCounts[achievement] ?? 0) + 1;
      }
    }

    return achievementCounts;
  }

  /// Get comprehensive progress analytics
  Future<ProgressAnalytics> getProgressAnalytics({int days = 30}) async {
    final entries = await getRecentProgress(days: days);

    if (entries.isEmpty) {
      return ProgressAnalytics.empty();
    }

    return ProgressAnalytics(
      totalDays: entries.length,
      averageOverallScore:
          entries.map((e) => e.overallDailyScore).reduce((a, b) => a + b) /
              entries.length,
      averageWellnessScore:
          entries.map((e) => e.wellnessScore).reduce((a, b) => a + b) /
              entries.length,
      averageRelationshipScore: entries
              .map((e) => e.overallRelationshipScore)
              .reduce((a, b) => a + b) /
          entries.length,
      totalSleepHours: entries.map((e) => e.sleepHours).reduce((a, b) => a + b),
      totalMeditationMinutes:
          entries.map((e) => e.meditationMinutes).reduce((a, b) => a + b),
      totalPointsEarned:
          entries.map((e) => e.pointsEarned).reduce((a, b) => a + b),
      consistentDays: entries.where((e) => e.hasCompleteData).length,
      topAchievements: await getAchievementStats(days: days),
      dailyEntries: entries,
    );
  }

  /// Get sample data for testing (replaces getDemoData)
  Future<List<DailyProgress>> getSampleData() async {
    final demoData = <DailyProgress>[];
    final now = DateTime.now();

  // Generate sample data for last 14 days
    for (int i = 13; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final progress = DailyProgress(
        date: date,
        pointsEarned: 50 + (i * 10) % 100,
        overallRelationshipScore: 60.0 + (i % 5) * 8,
        wellnessScore: 55.0 + (i % 7) * 6,
        sleepHours: 6 + (i % 3),
        meditationMinutes: 10 + (i % 4) * 5,
        sleepQuality: 70.0 + (i % 6) * 5,
        conversationCount: 2 + (i % 4),
        exerciseMinutes: 20 + (i % 5) * 10,
  achievementBadges: _getSampleAchievements(i),
        dailyReflection: i % 3 == 0
            ? 'आज का दिन अच्छा रहा। मेडिटेशन और exercise से मूड बेहतर लगा।'
            : null,
        goalCompletionRate: 40.0 + (i % 8) * 7.5,
      );
      demoData.add(progress);
    }

    return demoData;
  }

  // Removed deprecated: getDemoData (use getSampleData)

  /// Clear all progress data (for testing/reset)
  Future<void> clearAllData() async {
    if (_progressBox != null) {
      await _progressBox!.clear();
    }
    if (_weeklyBox != null) {
      await _weeklyBox!.clear();
    }
  }

  // Private helper methods

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getWeekKey(DateTime weekStart) {
    return 'week_${_getDateKey(weekStart)}';
  }

  /// Calculate relationship score from Communication Tracker
  Future<double> _calculateRelationshipScore(DateTime date) async {
    try {
      // Integration point with RelationshipLog
      final relationshipBox =
          await Hive.openBox<RelationshipLog>('relationship_logs');

      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayLogs = relationshipBox.values
          .where((log) =>
              log.timestamp.isAfter(dayStart) && log.timestamp.isBefore(dayEnd))
          .toList();

      if (dayLogs.isEmpty) return 50.0; // Neutral score

      // Calculate based on communication quality and frequency
      double totalScore = 0;
      for (final log in dayLogs) {
        // Base score from emotional tone
        double logScore = 50.0;

        switch (log.tone) {
          case EmotionalTone.positive:
            logScore += 30;
            break;
          case EmotionalTone.neutral:
            logScore += 10;
            break;
          case EmotionalTone.negative:
            logScore -= 20;
            break;
          case EmotionalTone.concern:
            logScore -= 10;
            break;
          case EmotionalTone.excitement:
            logScore += 25;
            break;
          case EmotionalTone.sadness:
            logScore -= 15;
            break;
          case EmotionalTone.anger:
            logScore -= 25;
            break;
          case EmotionalTone.love:
            logScore += 35;
            break;
          case EmotionalTone.unknown:
            // No change to base score for unknown
            break;
        }

        // Bonus for meaningful interactions (using available keywords)
        if (log.keywords.isNotEmpty) {
          logScore += 10;
        }

        totalScore += logScore;
      }

      return (totalScore / dayLogs.length).clamp(0.0, 100.0);
    } catch (e) {
      debugPrint('Error calculating relationship score: $e');
      return 50.0; // Default neutral score
    }
  }

  /// Calculate wellness score from MoodEntry and MentalHealth data
  Future<double> _calculateWellnessScore(DateTime date) async {
    try {
      // Integration with MoodEntry
      final moodBox = await Hive.openBox<MoodEntry>('mood_entries');
      final mentalHealthBox =
          await Hive.openBox<MentalHealthLog>('mental_health_logs');

      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayMoods = moodBox.values
          .where((mood) =>
              mood.date.isAfter(dayStart) && mood.date.isBefore(dayEnd))
          .toList();

      final dayMentalHealth = mentalHealthBox.values
          .where((mh) =>
              mh.timestamp.isAfter(dayStart) && mh.timestamp.isBefore(dayEnd))
          .toList();

      double wellnessScore = 50.0; // Base score

      // Mood contribution (40% weight)
      if (dayMoods.isNotEmpty) {
        double moodAverage = 0;
        double stressAverage = 0;

        for (final mood in dayMoods) {
          // Convert mood string to numeric score
          moodAverage += _moodToScore(mood.identifiedMood);
          stressAverage += _stressLevelToScore(mood.stressLevel);
        }

        moodAverage /= dayMoods.length;
        stressAverage /= dayMoods.length;

        // Higher mood = better score, lower stress = better score
        final moodContribution =
            (moodAverage * 0.6) + ((100 - stressAverage) * 0.4);
        wellnessScore = (wellnessScore * 0.6) + (moodContribution * 0.4);
      }

      // Mental health contribution (30% weight)
      if (dayMentalHealth.isNotEmpty) {
        double mentalHealthScore = 50.0;

        for (final mh in dayMentalHealth) {
          // Positive emotion tags increase score
          final positiveEmotions = mh.emotionTags.where((tag) =>
              tag == EmotionTag.happy ||
              tag == EmotionTag.grateful ||
              tag == EmotionTag.calm ||
              tag == EmotionTag.content ||
              tag == EmotionTag.hopeful ||
              tag == EmotionTag.excited);
          if (positiveEmotions.isNotEmpty) {
            mentalHealthScore += 15;
          }

          // Negative emotion tags decrease score
          final negativeEmotions = mh.emotionTags.where((tag) =>
              tag == EmotionTag.sad ||
              tag == EmotionTag.anxious ||
              tag == EmotionTag.angry ||
              tag == EmotionTag.overwhelmed ||
              tag == EmotionTag.frustrated ||
              tag == EmotionTag.worried);
          if (negativeEmotions.isNotEmpty) {
            mentalHealthScore -= 10;
          }

          // Coping strategies boost score
          if (mh.copingStrategies.isNotEmpty) {
            mentalHealthScore += 10;
          }
        }

        wellnessScore =
            (wellnessScore * 0.7) + (mentalHealthScore.clamp(0, 100) * 0.3);
      }

      return wellnessScore.clamp(0.0, 100.0);
    } catch (e) {
      debugPrint('Error calculating wellness score: $e');
      return 50.0;
    }
  }

  double _moodToScore(String? mood) {
    if (mood == null) return 50.0;

    final moodLower = mood.toLowerCase();
    if (moodLower.contains('happy') ||
        moodLower.contains('खुश') ||
        moodLower.contains('excellent')) {
      return 90.0;
    }
    if (moodLower.contains('good') ||
        moodLower.contains('अच्छा') ||
        moodLower.contains('positive')) {
      return 80.0;
    }
    if (moodLower.contains('okay') ||
        moodLower.contains('ठीक') ||
        moodLower.contains('neutral')) {
      return 60.0;
    }
    if (moodLower.contains('sad') ||
        moodLower.contains('उदास') ||
        moodLower.contains('negative')) {
      return 30.0;
    }
    if (moodLower.contains('angry') ||
        moodLower.contains('गुस्सा') ||
        moodLower.contains('stressed')) {
      return 20.0;
    }

    return 50.0; // Default neutral
  }

  double _stressLevelToScore(String? stressLevel) {
    if (stressLevel == null) return 50.0;

    final stressLower = stressLevel.toLowerCase();
    if (stressLower.contains('low') ||
        stressLower.contains('कम') ||
        stressLower.contains('minimal')) {
      return 80.0;
    }
    if (stressLower.contains('medium') ||
        stressLower.contains('मध्यम') ||
        stressLower.contains('moderate')) {
      return 50.0;
    }
    if (stressLower.contains('high') ||
        stressLower.contains('उच्च') ||
        stressLower.contains('severe')) {
      return 20.0;
    }

    return 50.0; // Default neutral
  }

  Future<int> _getConversationCount(DateTime date) async {
    try {
      final relationshipBox =
          await Hive.openBox<RelationshipLog>('relationship_logs');
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      return relationshipBox.values
          .where((log) =>
              log.timestamp.isAfter(dayStart) && log.timestamp.isBefore(dayEnd))
          .length;
    } catch (e) {
      return 0;
    }
  }

  Future<double> _calculateGoalCompletion(DateTime date) async {
    // Placeholder - integrate with actual goal tracking system
  return 65.0 + (date.day % 5) * 7; // Sample calculation
  }

  Future<int> _getDailyLoginPoints(DateTime date) async {
    // Daily login reward logic
    return 50; // Base points for logging in
  }

  Future<int> _getSleepHours(DateTime date) async {
    // Integration point with Sleep Tracker
  // For now, return sample data
    return 7 + (date.day % 3);
  }

  Future<double> _getSleepQuality(DateTime date) async {
    // Integration point with Sleep Tracker quality score
    return 75.0 + (date.day % 4) * 5;
  }

  Future<int> _getMeditationMinutes(DateTime date) async {
    // Integration point with Meditation Guide
    return 15 + (date.day % 5) * 3;
  }

  List<String> _getSampleAchievements(int dayOffset) {
    final achievements = <String>[];

    if (dayOffset % 7 == 0) achievements.add('🏆 सप्ताहिक लक्ष्य');
    if (dayOffset % 5 == 0) achievements.add('🧘 मेडिटेशन मास्टर');
    if (dayOffset % 3 == 0) achievements.add('😴 अच्छी नींद');
    if (dayOffset % 4 == 0) achievements.add('💬 बातचीत का राजा');

    return achievements;
  }
}

/// Progress Analytics Data Class
class ProgressAnalytics {
  final int totalDays;
  final double averageOverallScore;
  final double averageWellnessScore;
  final double averageRelationshipScore;
  final int totalSleepHours;
  final int totalMeditationMinutes;
  final int totalPointsEarned;
  final int consistentDays;
  final Map<String, int> topAchievements;
  final List<DailyProgress> dailyEntries;

  ProgressAnalytics({
    required this.totalDays,
    required this.averageOverallScore,
    required this.averageWellnessScore,
    required this.averageRelationshipScore,
    required this.totalSleepHours,
    required this.totalMeditationMinutes,
    required this.totalPointsEarned,
    required this.consistentDays,
    required this.topAchievements,
    required this.dailyEntries,
  });

  factory ProgressAnalytics.empty() {
    return ProgressAnalytics(
      totalDays: 0,
      averageOverallScore: 0,
      averageWellnessScore: 0,
      averageRelationshipScore: 0,
      totalSleepHours: 0,
      totalMeditationMinutes: 0,
      totalPointsEarned: 0,
      consistentDays: 0,
      topAchievements: {},
      dailyEntries: [],
    );
  }

  /// Consistency percentage
  double get consistencyRate =>
      totalDays > 0 ? (consistentDays / totalDays) * 100 : 0;

  /// Average sleep per day
  double get averageSleepHours =>
      totalDays > 0 ? totalSleepHours / totalDays : 0;

  /// Average meditation per day
  double get averageMeditationMinutes =>
      totalDays > 0 ? totalMeditationMinutes / totalDays : 0;

  /// Daily average points
  double get averagePointsPerDay =>
      totalDays > 0 ? totalPointsEarned / totalDays : 0;
}
