import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user_profile.dart';

/// Professional Analytics Service - Enterprise Level Intelligence
/// The analytics system users have been waiting for years
class TrueCircleAnalyticsService {
  static const String _analyticsBoxName = 'truecircle_analytics';
  static const String _userProfileKey = 'user_profile';

  Box<dynamic>? _analyticsBox;
  UserProfile? _currentProfile;

  // Singleton pattern for enterprise reliability
  static final TrueCircleAnalyticsService _instance =
      TrueCircleAnalyticsService._internal();
  factory TrueCircleAnalyticsService() => _instance;
  TrueCircleAnalyticsService._internal();

  /// Initialize Analytics Service
  Future<void> initialize() async {
    try {
      _analyticsBox = await Hive.openBox(_analyticsBoxName);
      await _loadUserProfile();
    } catch (e) {
      debugPrint('TrueCircle Analytics: Failed to initialize - $e');
    }
  }

  /// Load or Create User Profile
  Future<void> _loadUserProfile() async {
    try {
      final profileData = _analyticsBox?.get(_userProfileKey);
      if (profileData != null) {
        _currentProfile = UserProfile.fromJson(
          Map<String, dynamic>.from(profileData),
        );
      } else {
        // Create default profile for first-time users
        _currentProfile = UserProfile(
          userId: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'TrueCircle User',
          email: '',
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          preferences: {},
          wellnessMetrics: EmotionalWellnessMetrics(
            lastCalculated: DateTime.now(),
          ),
        );
        await _saveUserProfile();
      }
    } catch (e) {
      debugPrint('TrueCircle Analytics: Failed to load profile - $e');
    }
  }

  /// Save User Profile
  Future<void> _saveUserProfile() async {
    try {
      if (_currentProfile != null && _analyticsBox != null) {
        await _analyticsBox!.put(_userProfileKey, _currentProfile!.toJson());
      }
    } catch (e) {
      debugPrint('TrueCircle Analytics: Failed to save profile - $e');
    }
  }

  /// Get Current User Profile
  UserProfile? get currentProfile => _currentProfile;

  /// Update User Activity
  Future<void> trackUserActivity(
    String activity, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (_currentProfile == null) return;

      _currentProfile!.lastActiveAt = DateTime.now();

      // Update feature usage
      final currentUsage =
          _currentProfile!.wellnessMetrics.featureUsage[activity] ?? 0;
      _currentProfile!.wellnessMetrics.featureUsage[activity] =
          currentUsage + 1;

      await _saveUserProfile();
    } catch (e) {
      debugPrint('TrueCircle Analytics: Failed to track activity - $e');
    }
  }

  /// Add Mood Entry with Professional Analytics
  Future<void> addMoodEntry(
    String mood,
    int intensity, {
    List<String>? activities,
    String? notes,
    Map<String, dynamic>? context,
  }) async {
    try {
      if (_currentProfile == null) return;

      final moodEntry = DailyMoodEntry(
        date: DateTime.now(),
        mood: mood,
        intensity: intensity,
        activities: activities ?? [],
        notes: notes,
        context: context ?? {},
      );

      _currentProfile!.wellnessMetrics.moodHistory.add(moodEntry);

      // Update emotion frequency
      final currentFreq =
          _currentProfile!.wellnessMetrics.emotionFrequency[mood] ?? 0.0;
      _currentProfile!.wellnessMetrics.emotionFrequency[mood] =
          currentFreq + 1.0;

      // Recalculate wellness metrics
      await _recalculateWellnessMetrics();

      await _saveUserProfile();
    } catch (e) {
      debugPrint('TrueCircle Analytics: Failed to add mood entry - $e');
    }
  }

  /// Professional Wellness Score Calculation
  Future<void> _recalculateWellnessMetrics() async {
    try {
      if (_currentProfile == null) return;

      final metrics = _currentProfile!.wellnessMetrics;
      final moodHistory = metrics.moodHistory;

      if (moodHistory.isEmpty) return;

      // Calculate overall wellness score (0-100)
      final recentMoods = moodHistory
          .where((entry) => DateTime.now().difference(entry.date).inDays <= 30)
          .toList();

      if (recentMoods.isNotEmpty) {
        final averageIntensity =
            recentMoods
                .map((entry) => _getMoodScore(entry.mood, entry.intensity))
                .reduce((a, b) => a + b) /
            recentMoods.length;

        metrics.overallWellnessScore = (averageIntensity * 10).clamp(0, 100);
      }

      // Calculate weekly trends
      final weeklyTrends = <String, double>{};
      final now = DateTime.now();

      for (int i = 0; i < 4; i++) {
        final weekStart = now.subtract(Duration(days: (i + 1) * 7));
        final weekEnd = now.subtract(Duration(days: i * 7));

        final weekMoods = moodHistory
            .where(
              (entry) =>
                  entry.date.isAfter(weekStart) && entry.date.isBefore(weekEnd),
            )
            .toList();

        if (weekMoods.isNotEmpty) {
          final weekScore =
              weekMoods
                  .map((entry) => _getMoodScore(entry.mood, entry.intensity))
                  .reduce((a, b) => a + b) /
              weekMoods.length;

          weeklyTrends['week_${i + 1}'] = weekScore * 10;
        }
      }

      metrics.weeklyTrends = weeklyTrends;
      metrics.lastCalculated = DateTime.now();

      // Generate insights
      await _generateInsights();
    } catch (e) {
      debugPrint('TrueCircle Analytics: Failed to recalculate metrics - $e');
    }
  }

  /// Professional Mood Score Mapping
  double _getMoodScore(String mood, int intensity) {
    final baseMoodScores = {
      'happy': 9.0,
      'excited': 8.5,
      'calm': 8.0,
      'content': 7.5,
      'neutral': 5.0,
      'tired': 4.0,
      'stressed': 3.0,
      'sad': 2.0,
      'anxious': 2.5,
      'angry': 1.5,
    };

    final baseScore = baseMoodScores[mood.toLowerCase()] ?? 5.0;
    final intensityMultiplier = intensity / 10.0;

    return baseScore * intensityMultiplier;
  }

  /// AI-Powered Insight Generation
  Future<void> _generateInsights() async {
    try {
      if (_currentProfile == null) return;

      final metrics = _currentProfile!.wellnessMetrics;
      final insights = <WellnessInsight>[];

      // Mood Pattern Insights
      if (metrics.moodHistory.length >= 7) {
        final recentMoods = metrics.moodHistory
            .where((entry) => DateTime.now().difference(entry.date).inDays <= 7)
            .toList();

        final dominantMood = _getDominantMood(recentMoods);
        if (dominantMood != null) {
          insights.add(
            WellnessInsight(
              id: 'mood_pattern_${DateTime.now().millisecondsSinceEpoch}',
              title: 'Weekly Mood Pattern',
              description:
                  'You\'ve been feeling mostly $dominantMood this week.',
              type: InsightType.moodPattern,
              priority: InsightPriority.medium,
              createdAt: DateTime.now(),
              suggestedActions: _getSuggestedActions(dominantMood),
            ),
          );
        }
      }

      // Progress Celebration
      if (metrics.overallWellnessScore > 70) {
        insights.add(
          WellnessInsight(
            id: 'progress_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Great Progress! 🌟',
            description:
                'Your wellness score is ${metrics.overallWellnessScore.toInt()}/100. Keep up the excellent work!',
            type: InsightType.progressCelebration,
            priority: InsightPriority.medium,
            createdAt: DateTime.now(),
            suggestedActions: [
              'Continue current practices',
              'Share your success',
              'Set new goals',
            ],
          ),
        );
      }

      // Streak Milestone
      if (_currentProfile!.streakDays > 0 &&
          _currentProfile!.streakDays % 7 == 0) {
        insights.add(
          WellnessInsight(
            id: 'streak_${DateTime.now().millisecondsSinceEpoch}',
            title: '${_currentProfile!.streakDays} Day Streak! 🔥',
            description:
                'Amazing consistency! You\'ve been active for ${_currentProfile!.streakDays} days straight.',
            type: InsightType.streak,
            priority: InsightPriority.high,
            createdAt: DateTime.now(),
            suggestedActions: [
              'Celebrate your achievement',
              'Keep the momentum going',
            ],
          ),
        );
      }

      // Update insights (keep only recent 10)
      metrics.insights.addAll(insights);
      if (metrics.insights.length > 10) {
        metrics.insights.removeRange(0, metrics.insights.length - 10);
      }
    } catch (e) {
      debugPrint('TrueCircle Analytics: Failed to generate insights - $e');
    }
  }

  /// Get Dominant Mood
  String? _getDominantMood(List<DailyMoodEntry> moods) {
    if (moods.isEmpty) return null;

    final moodCounts = <String, int>{};
    for (final mood in moods) {
      moodCounts[mood.mood] = (moodCounts[mood.mood] ?? 0) + 1;
    }

    return moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get Suggested Actions for Mood
  List<String> _getSuggestedActions(String mood) {
    final suggestions = {
      'happy': [
        'Share your joy with others',
        'Practice gratitude',
        'Engage in creative activities',
      ],
      'sad': [
        'Talk to someone you trust',
        'Practice self-compassion',
        'Consider gentle exercise',
      ],
      'anxious': [
        'Try breathing exercises',
        'Use grounding techniques',
        'Limit caffeine',
      ],
      'angry': [
        'Take deep breaths',
        'Physical exercise',
        'Express feelings safely',
      ],
      'calm': [
        'Maintain current practices',
        'Practice mindfulness',
        'Help others feel calm',
      ],
    };

    return suggestions[mood.toLowerCase()] ??
        ['Take care of yourself', 'Stay connected', 'Be patient'];
  }

  /// Get Analytics Summary
  Map<String, dynamic> getAnalyticsSummary() {
    if (_currentProfile == null) return {};

    final metrics = _currentProfile!.wellnessMetrics;

    return {
      'wellnessScore': metrics.overallWellnessScore,
      'totalMoodEntries': metrics.moodHistory.length,
      'streakDays': _currentProfile!.streakDays,
      'mostUsedFeature': _getMostUsedFeature(),
      'recentInsights': metrics.insights.take(3).toList(),
      'weeklyTrend': _getWeeklyTrend(),
    };
  }

  String? _getMostUsedFeature() {
    if (_currentProfile == null) return null;

    final usage = _currentProfile!.wellnessMetrics.featureUsage;
    if (usage.isEmpty) return null;

    return usage.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _getWeeklyTrend() {
    if (_currentProfile == null) return 'stable';

    final trends = _currentProfile!.wellnessMetrics.weeklyTrends;
    if (trends.length < 2) return 'stable';

    final latest = trends['week_1'] ?? 50.0;
    final previous = trends['week_2'] ?? 50.0;

    if (latest > previous + 5) return 'improving';
    if (latest < previous - 5) return 'declining';
    return 'stable';
  }

  /// Dispose Service
  Future<void> dispose() async {
    await _analyticsBox?.close();
  }
}
