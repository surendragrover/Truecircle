// ignore_for_file: constant_identifier_names

import 'package:hive/hive.dart';

part 'daily_progress.g.dart';

/// DailyProgress (दैनिक प्रगति) Model
/// 
/// यह मॉडल Progress Tracker के लिए दैनिक स्कोर और डेटा को संग्रहीत करता है।
/// Data Sources:
/// - Sleep Tracker: sleepHours, sleepQuality
/// - Meditation Guide: meditationMinutes
/// - Communication Tracker: overallRelationshipScore (AI calculated)
/// - Mood Entry: wellnessScore calculation
/// - Daily Login: pointsEarned rewards
/// 
/// Privacy: सभी डेटा locally stored, no external sharing
@HiveType(typeId: 30)
class DailyProgress extends HiveObject {
  /// Date for this progress entry
  @HiveField(0)
  DateTime date;

  /// Daily Login Rewards points earned
  @HiveField(1)
  int pointsEarned;

  /// Communication Tracker से AI द्वारा गणना - relationship health score
  @HiveField(2)
  double overallRelationshipScore;

  /// Mood, Sleep, Meditation से गणना - overall wellness
  @HiveField(3)
  double wellnessScore;

  /// Sleep Tracker data - hours of sleep
  @HiveField(4)
  int sleepHours;

  /// Meditation Guide data - minutes practiced
  @HiveField(5)
  int meditationMinutes;

  /// Sleep quality score (0-100)
  @HiveField(6)
  double sleepQuality;

  /// Mood average for the day (1-10 scale)
  @HiveField(7)
  double? averageMood;

  /// Stress level average (0-100)
  @HiveField(8)
  double? averageStress;

  /// Number of meaningful conversations
  @HiveField(9)
  int conversationCount;

  /// Physical activity minutes
  @HiveField(10)
  int exerciseMinutes;

  /// Total screen time hours
  @HiveField(11)
  double screenTimeHours;

  /// Achievement badges earned today
  @HiveField(12)
  List<String> achievementBadges;

  /// Personal notes/reflection
  @HiveField(13)
  String? dailyReflection;

  /// Goal completion percentage (0-100)
  @HiveField(14)
  double goalCompletionRate;

  /// Created timestamp
  @HiveField(15)
  DateTime createdAt;

  /// Last updated timestamp  
  @HiveField(16)
  DateTime updatedAt;

  DailyProgress({
    required this.date,
    required this.pointsEarned,
    required this.overallRelationshipScore,
    required this.wellnessScore,
    required this.sleepHours,
    required this.meditationMinutes,
    this.sleepQuality = 0.0,
    this.averageMood,
    this.averageStress,
    this.conversationCount = 0,
    this.exerciseMinutes = 0,
    this.screenTimeHours = 0.0,
    List<String>? achievementBadges,
    this.dailyReflection,
    this.goalCompletionRate = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : achievementBadges = achievementBadges ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// JSON से मॉडल बनाने के लिए फ़ैक्टरी (Factory)
  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      date: DateTime.parse(json['date']),
      pointsEarned: json['pointsEarned'] ?? 0,
      overallRelationshipScore: (json['overallRelationshipScore'] ?? 0.0).toDouble(),
      wellnessScore: (json['wellnessScore'] ?? 0.0).toDouble(),
      sleepHours: json['sleepHours'] ?? 0,
      meditationMinutes: json['meditationMinutes'] ?? 0,
      sleepQuality: (json['sleepQuality'] ?? 0.0).toDouble(),
      averageMood: json['averageMood']?.toDouble(),
      averageStress: json['averageStress']?.toDouble(),
      conversationCount: json['conversationCount'] ?? 0,
      exerciseMinutes: json['exerciseMinutes'] ?? 0,
      screenTimeHours: (json['screenTimeHours'] ?? 0.0).toDouble(),
      achievementBadges: List<String>.from(json['achievementBadges'] ?? []),
      dailyReflection: json['dailyReflection'],
      goalCompletionRate: (json['goalCompletionRate'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  /// मॉडल को JSON Map में बदलने के लिए
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'pointsEarned': pointsEarned,
      'overallRelationshipScore': overallRelationshipScore,
      'wellnessScore': wellnessScore,
      'sleepHours': sleepHours,
      'meditationMinutes': meditationMinutes,
      'sleepQuality': sleepQuality,
      'averageMood': averageMood,
      'averageStress': averageStress,
      'conversationCount': conversationCount,
      'exerciseMinutes': exerciseMinutes,
      'screenTimeHours': screenTimeHours,
      'achievementBadges': achievementBadges,
      'dailyReflection': dailyReflection,
      'goalCompletionRate': goalCompletionRate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Copy with method for updating specific fields
  DailyProgress copyWith({
    DateTime? date,
    int? pointsEarned,
    double? overallRelationshipScore,
    double? wellnessScore,
    int? sleepHours,
    int? meditationMinutes,
    double? sleepQuality,
    double? averageMood,
    double? averageStress,
    int? conversationCount,
    int? exerciseMinutes,
    double? screenTimeHours,
    List<String>? achievementBadges,
    String? dailyReflection,
    double? goalCompletionRate,
  }) {
    return DailyProgress(
      date: date ?? this.date,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      overallRelationshipScore: overallRelationshipScore ?? this.overallRelationshipScore,
      wellnessScore: wellnessScore ?? this.wellnessScore,
      sleepHours: sleepHours ?? this.sleepHours,
      meditationMinutes: meditationMinutes ?? this.meditationMinutes,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      averageMood: averageMood ?? this.averageMood,
      averageStress: averageStress ?? this.averageStress,
      conversationCount: conversationCount ?? this.conversationCount,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      screenTimeHours: screenTimeHours ?? this.screenTimeHours,
      achievementBadges: achievementBadges ?? this.achievementBadges,
      dailyReflection: dailyReflection ?? this.dailyReflection,
      goalCompletionRate: goalCompletionRate ?? this.goalCompletionRate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Calculate overall daily score (0-100)  
  double get overallDailyScore {
    double totalScore = 0.0;
    int factorCount = 0;

    // Wellness Score (25% weight)
    if (wellnessScore > 0) {
      totalScore += wellnessScore * 0.25;
      factorCount++;
    }

    // Relationship Score (25% weight)
    if (overallRelationshipScore > 0) {
      totalScore += overallRelationshipScore * 0.25;
      factorCount++;
    }

    // Sleep Score (20% weight) - normalized from hours
    if (sleepHours > 0) {
      double sleepScore = ((sleepHours / 8.0).clamp(0.0, 1.25) * 80).clamp(0.0, 100.0);
      totalScore += sleepScore * 0.20;
      factorCount++;
    }

    // Meditation Score (15% weight) - normalized from minutes
    if (meditationMinutes > 0) {
      double meditationScore = ((meditationMinutes / 20.0).clamp(0.0, 1.5) * 80).clamp(0.0, 100.0);
      totalScore += meditationScore * 0.15;
      factorCount++;
    }

    // Goal Completion (15% weight)
    if (goalCompletionRate > 0) {
      totalScore += goalCompletionRate * 0.15;
      factorCount++;
    }

    return factorCount > 0 ? totalScore : 0.0;
  }

  /// Get wellness category based on overall score
  WellnessCategory get wellnessCategory {
    final score = overallDailyScore;
    if (score >= 80) return WellnessCategory.excellent;
    if (score >= 60) return WellnessCategory.good;
    if (score >= 40) return WellnessCategory.fair;
    if (score >= 20) return WellnessCategory.poor;
    return WellnessCategory.needsImprovement;
  }

  /// Check if all core metrics are tracked
  bool get hasCompleteData {
    return sleepHours > 0 && 
           meditationMinutes >= 0 && 
           wellnessScore > 0 &&
           overallRelationshipScore > 0;
  }

  /// Get achievement count for today
  int get achievementCount => achievementBadges.length;

  /// Format date for display
  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Hindi formatted date
  String get hindiFormattedDate {
    final hindiMonths = [
      'जन', 'फर', 'मार', 'अप्र', 'मई', 'जून',
      'जुल', 'अग', 'सित', 'अक्ट', 'नव', 'दिस'
    ];
    return '${date.day} ${hindiMonths[date.month - 1]} ${date.year}';
  }

  @override
  String toString() {
    return 'DailyProgress(date: $formattedDate, score: ${overallDailyScore.toStringAsFixed(1)}, '
           'sleep: ${sleepHours}h, meditation: ${meditationMinutes}m, points: $pointsEarned)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyProgress && 
           other.date.day == date.day &&
           other.date.month == date.month &&
           other.date.year == date.year;
  }

  @override
  int get hashCode => date.hashCode;
}

/// Wellness categories for daily progress assessment
@HiveType(typeId: 31)
enum WellnessCategory {
  @HiveField(0)
  excellent,      // 80-100: उत्कृष्ट

  @HiveField(1)
  good,          // 60-79: अच्छा

  @HiveField(2)
  fair,          // 40-59: ठीक-ठाक

  @HiveField(3)
  poor,          // 20-39: खराब

  @HiveField(4)
  needsImprovement; // 0-19: सुधार की आवश्यकता

  /// Get localized category name
  String get displayName {
    switch (this) {
      case WellnessCategory.excellent:
        return 'उत्कृष्ट (Excellent)';
      case WellnessCategory.good:
        return 'अच्छा (Good)';
      case WellnessCategory.fair:
        return 'ठीक-ठाक (Fair)';
      case WellnessCategory.poor:
        return 'खराब (Poor)';
      case WellnessCategory.needsImprovement:
        return 'सुधार चाहिए (Needs Improvement)';
    }
  }

  /// Get category color
  String get colorHex {
    switch (this) {
      case WellnessCategory.excellent:
        return '#4CAF50'; // Green
      case WellnessCategory.good:
        return '#8BC34A'; // Light Green
      case WellnessCategory.fair:
        return '#FFC107'; // Amber
      case WellnessCategory.poor:
        return '#FF9800'; // Orange
      case WellnessCategory.needsImprovement:
        return '#F44336'; // Red
    }
  }

  /// Get motivational message
  String get motivationalMessage {
    switch (this) {
      case WellnessCategory.excellent:
        return '🌟 शानदार! आप बहुत अच्छा कर रहे हैं!';
      case WellnessCategory.good:
        return '😊 बढ़िया! अच्छी प्रगति जारी रखें!';
      case WellnessCategory.fair:  
        return '💪 ठीक है! कुछ सुधार की गुंजाइश है।';
      case WellnessCategory.poor:
        return '🤗 कोई बात नहीं! कल बेहतर करने की कोशिश करें।';
      case WellnessCategory.needsImprovement:
        return '🌱 नई शुरुआत! छोटे कदम बड़े बदलाव लाते हैं।';
    }
  }
}

/// Weekly progress summary
@HiveType(typeId: 32)
class WeeklyProgressSummary extends HiveObject {
  @HiveField(0)
  DateTime weekStartDate;

  @HiveField(1)
  DateTime weekEndDate;

  @HiveField(2)
  List<DailyProgress> dailyEntries;

  @HiveField(3)
  double averageWellnessScore;

  @HiveField(4)
  double averageRelationshipScore;

  @HiveField(5)
  int totalPointsEarned;

  @HiveField(6)
  int totalSleepHours;

  @HiveField(7)
  int totalMeditationMinutes;

  @HiveField(8)
  List<String> weeklyAchievements;

  WeeklyProgressSummary({
    required this.weekStartDate,
    required this.weekEndDate,
    required this.dailyEntries,
    required this.averageWellnessScore,
    required this.averageRelationshipScore,
    required this.totalPointsEarned,
    required this.totalSleepHours,
    required this.totalMeditationMinutes,
    required this.weeklyAchievements,
  });

  /// Calculate from daily entries
  factory WeeklyProgressSummary.fromDailyEntries(List<DailyProgress> entries) {
    if (entries.isEmpty) {
      final now = DateTime.now();
      return WeeklyProgressSummary(
        weekStartDate: now,
        weekEndDate: now,
        dailyEntries: [],
        averageWellnessScore: 0,
        averageRelationshipScore: 0,
        totalPointsEarned: 0,
        totalSleepHours: 0,
        totalMeditationMinutes: 0,
        weeklyAchievements: [],
      );
    }

    entries.sort((a, b) => a.date.compareTo(b.date));
    
    return WeeklyProgressSummary(
      weekStartDate: entries.first.date,
      weekEndDate: entries.last.date,
      dailyEntries: entries,
      averageWellnessScore: entries.map((e) => e.wellnessScore).reduce((a, b) => a + b) / entries.length,
      averageRelationshipScore: entries.map((e) => e.overallRelationshipScore).reduce((a, b) => a + b) / entries.length,
      totalPointsEarned: entries.map((e) => e.pointsEarned).reduce((a, b) => a + b),
      totalSleepHours: entries.map((e) => e.sleepHours).reduce((a, b) => a + b),
      totalMeditationMinutes: entries.map((e) => e.meditationMinutes).reduce((a, b) => a + b),
      weeklyAchievements: entries.expand((e) => e.achievementBadges).toSet().toList(),
    );
  }

  /// Get weekly wellness category
  WellnessCategory get weeklyWellnessCategory {
    if (averageWellnessScore >= 80) return WellnessCategory.excellent;
    if (averageWellnessScore >= 60) return WellnessCategory.good;
    if (averageWellnessScore >= 40) return WellnessCategory.fair;
    if (averageWellnessScore >= 20) return WellnessCategory.poor;
    return WellnessCategory.needsImprovement;
  }

  /// Get consistency score (how many days have complete data)  
  double get consistencyScore {
    if (dailyEntries.isEmpty) return 0.0;
    final completeDays = dailyEntries.where((e) => e.hasCompleteData).length;
    return (completeDays / dailyEntries.length) * 100;
  }
}