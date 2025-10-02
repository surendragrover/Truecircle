// lib/models/mental_health_log.dart

import 'package:hive/hive.dart';

part 'mental_health_log.g.dart';

/// Mental health tracking log for emotional well-being analysis
/// 
/// Privacy-first design - only mood patterns and metadata stored
/// Used for on-device AI analysis and relationship correlation
@HiveType(typeId: 11)
class MentalHealthLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  MoodLevel primaryMood;

  @HiveField(3)
  List<EmotionTag> emotionTags;

  @HiveField(4)
  int energyLevel; // 1-10 scale

  @HiveField(5)
  int stressLevel; // 1-10 scale

  @HiveField(6)
  int socialAnxiety; // 1-10 scale

  @HiveField(7)
  SleepQuality sleepQuality;

  @HiveField(8)
  List<TriggerEvent> triggers;

  @HiveField(9)
  List<CopingStrategy> copingStrategies;

  @HiveField(10)
  int relationshipSatisfaction; // 1-10 scale

  @HiveField(11)
  String notes; // Privacy-safe user notes (encrypted locally)

  @HiveField(12)
  bool isPrivacyMode;

  @HiveField(13)
  Map<String, dynamic> aiAnalysisMetadata;

  MentalHealthLog({
    required this.id,
    required this.timestamp,
    required this.primaryMood,
    this.emotionTags = const [],
    this.energyLevel = 5,
    this.stressLevel = 5,
    this.socialAnxiety = 5,
    this.sleepQuality = SleepQuality.average,
    this.triggers = const [],
    this.copingStrategies = const [],
    this.relationshipSatisfaction = 5,
    this.notes = '',
    this.isPrivacyMode = true,
    this.aiAnalysisMetadata = const {},
  });

  /// Create from JSON (for data import/export)
  factory MentalHealthLog.fromJson(Map<String, dynamic> json) {
    return MentalHealthLog(
      id: json['id'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      primaryMood: MoodLevel.values.firstWhere(
        (e) => e.toString().split('.').last == json['primaryMood'],
        orElse: () => MoodLevel.neutral,
      ),
      emotionTags: (json['emotionTags'] as List<dynamic>?)
          ?.map((e) => EmotionTag.values.firstWhere(
                (tag) => tag.toString().split('.').last == e,
                orElse: () => EmotionTag.unknown,
              ))
          .toList() ?? [],
      energyLevel: json['energyLevel'] ?? 5,
      stressLevel: json['stressLevel'] ?? 5,
      socialAnxiety: json['socialAnxiety'] ?? 5,
      sleepQuality: SleepQuality.values.firstWhere(
        (e) => e.toString().split('.').last == json['sleepQuality'],
        orElse: () => SleepQuality.average,
      ),
      triggers: (json['triggers'] as List<dynamic>?)
          ?.map((e) => TriggerEvent.values.firstWhere(
                (trigger) => trigger.toString().split('.').last == e,
                orElse: () => TriggerEvent.unknown,
              ))
          .toList() ?? [],
      copingStrategies: (json['copingStrategies'] as List<dynamic>?)
          ?.map((e) => CopingStrategy.values.firstWhere(
                (strategy) => strategy.toString().split('.').last == e,
                orElse: () => CopingStrategy.unknown,
              ))
          .toList() ?? [],
      relationshipSatisfaction: json['relationshipSatisfaction'] ?? 5,
      notes: json['notes'] ?? '',
      isPrivacyMode: json['isPrivacyMode'] ?? true,
      aiAnalysisMetadata: Map<String, dynamic>.from(json['aiAnalysisMetadata'] ?? {}),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'primaryMood': primaryMood.toString().split('.').last,
      'emotionTags': emotionTags.map((e) => e.toString().split('.').last).toList(),
      'energyLevel': energyLevel,
      'stressLevel': stressLevel,
      'socialAnxiety': socialAnxiety,
      'sleepQuality': sleepQuality.toString().split('.').last,
      'triggers': triggers.map((e) => e.toString().split('.').last).toList(),
      'copingStrategies': copingStrategies.map((e) => e.toString().split('.').last).toList(),
      'relationshipSatisfaction': relationshipSatisfaction,
      'notes': notes,
      'isPrivacyMode': isPrivacyMode,
      'aiAnalysisMetadata': aiAnalysisMetadata,
    };
  }

  /// Generate privacy-safe summary for AI analysis
  String toAISummaryString() {
    final buffer = StringBuffer();
    
    // Primary mood and timestamp
    buffer.write('${primaryMood.name} mood on ${timestamp.day}/${timestamp.month}');
    
    // Energy and stress levels
    buffer.write(' (Energy: $energyLevel/10, Stress: $stressLevel/10)');
    
    // Social anxiety if significant
    if (socialAnxiety >= 7) {
      buffer.write(' [High social anxiety: $socialAnxiety/10]');
    }
    
    // Sleep quality
    if (sleepQuality != SleepQuality.average) {
      buffer.write(' [Sleep: ${sleepQuality.name}]');
    }
    
    // Triggers if any
    if (triggers.isNotEmpty) {
      buffer.write(' Triggers: ${triggers.map((t) => t.name).join(', ')}');
    }
    
    // Coping strategies used
    if (copingStrategies.isNotEmpty) {
      buffer.write(' Coping: ${copingStrategies.map((c) => c.name).join(', ')}');
    }
    
    // Relationship satisfaction
    buffer.write(' RelSat: $relationshipSatisfaction/10');
    
    return buffer.toString();
  }

  /// Generate demo data for privacy mode
  static List<MentalHealthLog> generateDemoData() {
    final now = DateTime.now();
    return [
      MentalHealthLog(
        id: 'mh_demo_1',
        timestamp: now.subtract(const Duration(hours: 3)),
        primaryMood: MoodLevel.good,
        emotionTags: [EmotionTag.grateful, EmotionTag.content],
        energyLevel: 7,
        stressLevel: 3,
        socialAnxiety: 4,
        sleepQuality: SleepQuality.good,
        copingStrategies: [CopingStrategy.meditation, CopingStrategy.exercise],
        relationshipSatisfaction: 8,
        notes: 'Good day with partner, feeling connected',
        isPrivacyMode: true,
        aiAnalysisMetadata: {'demo': true, 'pattern': 'positive_relationship'},
      ),
      MentalHealthLog(
        id: 'mh_demo_2',
        timestamp: now.subtract(const Duration(days: 1)),
        primaryMood: MoodLevel.anxious,
        emotionTags: [EmotionTag.worried, EmotionTag.overwhelmed],
        energyLevel: 4,
        stressLevel: 8,
        socialAnxiety: 7,
        sleepQuality: SleepQuality.poor,
        triggers: [TriggerEvent.workPressure, TriggerEvent.relationshipConflict],
        copingStrategies: [CopingStrategy.breathingExercises],
        relationshipSatisfaction: 5,
        notes: 'Had argument, feeling disconnected',
        isPrivacyMode: true,
        aiAnalysisMetadata: {'demo': true, 'pattern': 'relationship_stress'},
      ),
      MentalHealthLog(
        id: 'mh_demo_3',
        timestamp: now.subtract(const Duration(days: 2)),
        primaryMood: MoodLevel.neutral,
        emotionTags: [EmotionTag.calm, EmotionTag.focused],
        energyLevel: 6,
        stressLevel: 5,
        socialAnxiety: 3,
        sleepQuality: SleepQuality.average,
        copingStrategies: [CopingStrategy.journaling],
        relationshipSatisfaction: 7,
        notes: 'Regular day, stable mood',
        isPrivacyMode: true,
        aiAnalysisMetadata: {'demo': true, 'pattern': 'baseline'},
      ),
    ];
  }

  @override
  String toString() {
    return 'MentalHealthLog(id: $id, mood: $primaryMood, time: $timestamp)';
  }
}

/// Primary mood levels for mental health tracking
@HiveType(typeId: 12)
enum MoodLevel {
  @HiveField(0)
  excellent,
  
  @HiveField(1)
  good,
  
  @HiveField(2)
  neutral,
  
  @HiveField(3)
  low,
  
  @HiveField(4)
  depressed,
  
  @HiveField(5)
  anxious,
  
  @HiveField(6)
  angry,
  
  @HiveField(7)
  excited,
  
  @HiveField(8)
  unknown,
}

/// Detailed emotion tags for granular tracking
@HiveType(typeId: 13)
enum EmotionTag {
  @HiveField(0)
  happy,
  
  @HiveField(1)
  sad,
  
  @HiveField(2)
  angry,
  
  @HiveField(3)
  anxious,
  
  @HiveField(4)
  excited,
  
  @HiveField(5)
  grateful,
  
  @HiveField(6)
  lonely,
  
  @HiveField(7)
  content,
  
  @HiveField(8)
  frustrated,
  
  @HiveField(9)
  overwhelmed,
  
  @HiveField(10)
  calm,
  
  @HiveField(11)
  worried,
  
  @HiveField(12)
  hopeful,
  
  @HiveField(13)
  disappointed,
  
  @HiveField(14)
  confused,
  
  @HiveField(15)
  focused,
  
  @HiveField(16)
  unknown,
}

/// Sleep quality levels
@HiveType(typeId: 14)
enum SleepQuality {
  @HiveField(0)
  excellent,
  
  @HiveField(1)
  good,
  
  @HiveField(2)
  average,
  
  @HiveField(3)
  poor,
  
  @HiveField(4)
  terrible,
  
  @HiveField(5)
  unknown,
}

/// Trigger events that affect mental health
@HiveType(typeId: 15)
enum TriggerEvent {
  @HiveField(0)
  workPressure,
  
  @HiveField(1)
  relationshipConflict,
  
  @HiveField(2)
  financialStress,
  
  @HiveField(3)
  healthConcerns,
  
  @HiveField(4)
  familyIssues,
  
  @HiveField(5)
  socialPressure,
  
  @HiveField(6)
  lackOfCommunication,
  
  @HiveField(7)
  misunderstanding,
  
  @HiveField(8)
  loneliness,
  
  @HiveField(9)
  rejection,
  
  @HiveField(10)
  criticism,
  
  @HiveField(11)
  changeInRoutine,
  
  @HiveField(12)
  unknown,
}

/// Coping strategies used for mental health management
@HiveType(typeId: 16)
enum CopingStrategy {
  @HiveField(0)
  meditation,
  
  @HiveField(1)
  exercise,
  
  @HiveField(2)
  breathingExercises,
  
  @HiveField(3)
  journaling,
  
  @HiveField(4)
  talkingToFriends,
  
  @HiveField(5)
  professionalHelp,
  
  @HiveField(6)
  music,
  
  @HiveField(7)
  reading,
  
  @HiveField(8)
  natureWalk,
  
  @HiveField(9)
  creativeActivity,
  
  @HiveField(10)
  deepConversation,
  
  @HiveField(11)
  qualityTime,
  
  @HiveField(12)
  physicalAffection,
  
  @HiveField(13)
  problemSolving,
  
  @HiveField(14)
  unknown,
}

/// Mental health analytics and trends
@HiveType(typeId: 17)
class MentalHealthAnalytics extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  DateTime periodStart;

  @HiveField(2)
  DateTime periodEnd;

  @HiveField(3)
  double averageMoodScore; // 1-10 scale

  @HiveField(4)
  double averageEnergyLevel;

  @HiveField(5)
  double averageStressLevel;

  @HiveField(6)
  double averageSocialAnxiety;

  @HiveField(7)
  double averageRelationshipSatisfaction;

  @HiveField(8)
  Map<MoodLevel, int> moodDistribution;

  @HiveField(9)
  Map<TriggerEvent, int> commonTriggers;

  @HiveField(10)
  Map<CopingStrategy, int> effectiveCopingStrategies;

  @HiveField(11)
  List<String> aiInsights; // Generated insights

  @HiveField(12)
  bool isPrivacyMode;

  @HiveField(13)
  Map<String, dynamic> correlationData; // Relationship between communication and mood

  MentalHealthAnalytics({
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
    this.averageMoodScore = 5.0,
    this.averageEnergyLevel = 5.0,
    this.averageStressLevel = 5.0,
    this.averageSocialAnxiety = 5.0,
    this.averageRelationshipSatisfaction = 5.0,
    this.moodDistribution = const {},
    this.commonTriggers = const {},
    this.effectiveCopingStrategies = const {},
    this.aiInsights = const [],
    this.isPrivacyMode = true,
    this.correlationData = const {},
  });

  /// Calculate analytics from mental health logs
  factory MentalHealthAnalytics.fromLogs(
    String userId,
    List<MentalHealthLog> logs,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    if (logs.isEmpty) {
      return MentalHealthAnalytics(
        userId: userId,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
    }

    // Calculate averages
    final avgMood = logs.fold(0.0, (sum, log) => sum + _moodToScore(log.primaryMood)) / logs.length;
    final avgEnergy = logs.fold(0.0, (sum, log) => sum + log.energyLevel) / logs.length;
    final avgStress = logs.fold(0.0, (sum, log) => sum + log.stressLevel) / logs.length;
    final avgAnxiety = logs.fold(0.0, (sum, log) => sum + log.socialAnxiety) / logs.length;
    final avgRelSat = logs.fold(0.0, (sum, log) => sum + log.relationshipSatisfaction) / logs.length;

    // Mood distribution
    final moodDist = <MoodLevel, int>{};
    for (final log in logs) {
      moodDist[log.primaryMood] = (moodDist[log.primaryMood] ?? 0) + 1;
    }

    // Common triggers
    final triggerCounts = <TriggerEvent, int>{};
    for (final log in logs) {
      for (final trigger in log.triggers) {
        triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
      }
    }

    // Effective coping strategies
    final copingCounts = <CopingStrategy, int>{};
    for (final log in logs) {
      for (final strategy in log.copingStrategies) {
        copingCounts[strategy] = (copingCounts[strategy] ?? 0) + 1;
      }
    }

    return MentalHealthAnalytics(
      userId: userId,
      periodStart: periodStart,
      periodEnd: periodEnd,
      averageMoodScore: avgMood,
      averageEnergyLevel: avgEnergy,
      averageStressLevel: avgStress,
      averageSocialAnxiety: avgAnxiety,
      averageRelationshipSatisfaction: avgRelSat,
      moodDistribution: moodDist,
      commonTriggers: triggerCounts,
      effectiveCopingStrategies: copingCounts,
      isPrivacyMode: logs.first.isPrivacyMode,
    );
  }

  /// Convert mood level to numeric score for analysis
  static double _moodToScore(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.excellent:
        return 10.0;
      case MoodLevel.good:
        return 8.0;
      case MoodLevel.excited:
        return 7.0;
      case MoodLevel.neutral:
        return 5.0;
      case MoodLevel.low:
        return 3.0;
      case MoodLevel.anxious:
        return 3.0;
      case MoodLevel.angry:
        return 2.0;
      case MoodLevel.depressed:
        return 1.0;
      case MoodLevel.unknown:
        return 5.0;
    }
  }

  /// Generate comprehensive analysis summary for AI
  String toAnalysisString() {
    final buffer = StringBuffer();
    
    buffer.writeln('Mental Health Analytics Summary:');
    buffer.writeln('Period: ${periodStart.day}/${periodStart.month} - ${periodEnd.day}/${periodEnd.month}');
    buffer.writeln('Average Mood: ${averageMoodScore.toStringAsFixed(1)}/10');
    buffer.writeln('Average Energy: ${averageEnergyLevel.toStringAsFixed(1)}/10');
    buffer.writeln('Average Stress: ${averageStressLevel.toStringAsFixed(1)}/10');
    buffer.writeln('Social Anxiety: ${averageSocialAnxiety.toStringAsFixed(1)}/10');
    buffer.writeln('Relationship Satisfaction: ${averageRelationshipSatisfaction.toStringAsFixed(1)}/10');
    
    if (moodDistribution.isNotEmpty) {
      buffer.writeln('Mood Distribution:');
      moodDistribution.forEach((mood, count) {
        buffer.writeln('  ${mood.name}: $count times');
      });
    }
    
    if (commonTriggers.isNotEmpty) {
      final sortedTriggers = commonTriggers.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      buffer.writeln('Common Triggers: ${sortedTriggers.take(3).map((e) => '${e.key.name}(${e.value})').join(', ')}');
    }
    
    if (effectiveCopingStrategies.isNotEmpty) {
      final sortedCoping = effectiveCopingStrategies.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      buffer.writeln('Effective Coping: ${sortedCoping.take(3).map((e) => '${e.key.name}(${e.value})').join(', ')}');
    }
    
    return buffer.toString();
  }
}