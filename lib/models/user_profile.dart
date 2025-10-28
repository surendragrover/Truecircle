import 'package:hive/hive.dart';

/// Professional Data Models - Enterprise Level Architecture
/// The data structure users have been waiting for years

/// User Profile Model - Complete emotional wellness profile
@HiveType(typeId: 10)
class UserProfile extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime lastActiveAt;

  @HiveField(5)
  Map<String, dynamic> preferences;

  @HiveField(6)
  EmotionalWellnessMetrics wellnessMetrics;

  @HiveField(7)
  List<String> completedFeatures;

  @HiveField(8)
  int streakDays;

  @HiveField(9)
  UserThemePreference themePreference;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.lastActiveAt,
    required this.preferences,
    required this.wellnessMetrics,
    this.completedFeatures = const [],
    this.streakDays = 0,
    this.themePreference = UserThemePreference.auto,
  });

  // Professional JSON serialization
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'email': email,
    'createdAt': createdAt.toIso8601String(),
    'lastActiveAt': lastActiveAt.toIso8601String(),
    'preferences': preferences,
    'wellnessMetrics': wellnessMetrics.toJson(),
    'completedFeatures': completedFeatures,
    'streakDays': streakDays,
    'themePreference': themePreference.name,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    userId: json['userId'],
    name: json['name'],
    email: json['email'],
    createdAt: DateTime.parse(json['createdAt']),
    lastActiveAt: DateTime.parse(json['lastActiveAt']),
    preferences: Map<String, dynamic>.from(json['preferences']),
    wellnessMetrics: EmotionalWellnessMetrics.fromJson(json['wellnessMetrics']),
    completedFeatures: List<String>.from(json['completedFeatures'] ?? []),
    streakDays: json['streakDays'] ?? 0,
    themePreference: UserThemePreference.values.firstWhere(
      (e) => e.name == json['themePreference'],
      orElse: () => UserThemePreference.auto,
    ),
  );
}

/// Emotional Wellness Metrics - Advanced analytics
@HiveType(typeId: 11)
class EmotionalWellnessMetrics extends HiveObject {
  @HiveField(0)
  double overallWellnessScore; // 0-100

  @HiveField(1)
  Map<String, double> emotionFrequency; // emotion -> frequency

  @HiveField(2)
  List<DailyMoodEntry> moodHistory;

  @HiveField(3)
  Map<String, int> featureUsage; // feature -> usage count

  @HiveField(4)
  DateTime lastCalculated;

  @HiveField(5)
  List<WellnessInsight> insights;

  @HiveField(6)
  Map<String, double> weeklyTrends; // week -> average score

  EmotionalWellnessMetrics({
    this.overallWellnessScore = 50.0,
    this.emotionFrequency = const {},
    this.moodHistory = const [],
    this.featureUsage = const {},
    required this.lastCalculated,
    this.insights = const [],
    this.weeklyTrends = const {},
  });

  Map<String, dynamic> toJson() => {
    'overallWellnessScore': overallWellnessScore,
    'emotionFrequency': emotionFrequency,
    'moodHistory': moodHistory.map((e) => e.toJson()).toList(),
    'featureUsage': featureUsage,
    'lastCalculated': lastCalculated.toIso8601String(),
    'insights': insights.map((e) => e.toJson()).toList(),
    'weeklyTrends': weeklyTrends,
  };

  factory EmotionalWellnessMetrics.fromJson(Map<String, dynamic> json) =>
      EmotionalWellnessMetrics(
        overallWellnessScore: json['overallWellnessScore']?.toDouble() ?? 50.0,
        emotionFrequency: Map<String, double>.from(
          json['emotionFrequency'] ?? {},
        ),
        moodHistory:
            (json['moodHistory'] as List?)
                ?.map((e) => DailyMoodEntry.fromJson(e))
                .toList() ??
            [],
        featureUsage: Map<String, int>.from(json['featureUsage'] ?? {}),
        lastCalculated: DateTime.parse(json['lastCalculated']),
        insights:
            (json['insights'] as List?)
                ?.map((e) => WellnessInsight.fromJson(e))
                .toList() ??
            [],
        weeklyTrends: Map<String, double>.from(json['weeklyTrends'] ?? {}),
      );
}

/// Daily Mood Entry - Professional mood tracking
@HiveType(typeId: 12)
class DailyMoodEntry extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String mood; // happy, sad, anxious, calm, etc.

  @HiveField(2)
  int intensity; // 1-10

  @HiveField(3)
  List<String> activities; // what they did

  @HiveField(4)
  String? notes;

  @HiveField(5)
  Map<String, dynamic> context; // weather, location, etc.

  DailyMoodEntry({
    required this.date,
    required this.mood,
    required this.intensity,
    this.activities = const [],
    this.notes,
    this.context = const {},
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'mood': mood,
    'intensity': intensity,
    'activities': activities,
    'notes': notes,
    'context': context,
  };

  factory DailyMoodEntry.fromJson(Map<String, dynamic> json) => DailyMoodEntry(
    date: DateTime.parse(json['date']),
    mood: json['mood'],
    intensity: json['intensity'],
    activities: List<String>.from(json['activities'] ?? []),
    notes: json['notes'],
    context: Map<String, dynamic>.from(json['context'] ?? {}),
  );
}

/// Wellness Insight - AI-powered insights
@HiveType(typeId: 13)
class WellnessInsight extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  InsightType type;

  @HiveField(4)
  InsightPriority priority;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  bool isRead;

  @HiveField(7)
  Map<String, dynamic> data; // additional insight data

  @HiveField(8)
  List<String> suggestedActions;

  WellnessInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.isRead = false,
    this.data = const {},
    this.suggestedActions = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.name,
    'priority': priority.name,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
    'data': data,
    'suggestedActions': suggestedActions,
  };

  factory WellnessInsight.fromJson(Map<String, dynamic> json) =>
      WellnessInsight(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        type: InsightType.values.firstWhere((e) => e.name == json['type']),
        priority: InsightPriority.values.firstWhere(
          (e) => e.name == json['priority'],
        ),
        createdAt: DateTime.parse(json['createdAt']),
        isRead: json['isRead'] ?? false,
        data: Map<String, dynamic>.from(json['data'] ?? {}),
        suggestedActions: List<String>.from(json['suggestedActions'] ?? []),
      );
}

/// Enums for Professional Classification
@HiveType(typeId: 14)
enum UserThemePreference {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
  @HiveField(2)
  auto,
}

@HiveType(typeId: 15)
enum InsightType {
  @HiveField(0)
  moodPattern,
  @HiveField(1)
  progressCelebration,
  @HiveField(2)
  concernAlert,
  @HiveField(3)
  recommendation,
  @HiveField(4)
  streak,
  @HiveField(5)
  milestone,
}

@HiveType(typeId: 16)
enum InsightPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
  @HiveField(3)
  critical,
}

/// Professional Data Validation
class ProfileValidator {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidName(String name) {
    return name.trim().length >= 2 && name.trim().length <= 50;
  }

  static bool isValidMoodIntensity(int intensity) {
    return intensity >= 1 && intensity <= 10;
  }

  static String? validateProfile(UserProfile profile) {
    if (!isValidName(profile.name)) {
      return 'Name must be between 2 and 50 characters';
    }
    if (!isValidEmail(profile.email)) {
      return 'Please enter a valid email address';
    }
    return null; // Valid
  }
}
