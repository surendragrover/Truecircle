// lib/models/offline_ai_analysis.dart

import 'package:hive/hive.dart';
import 'relationship_log.dart';
import 'mental_health_log.dart';

part 'offline_ai_analysis.g.dart';

/// Offline AI analysis model for relationship and mental health insights
/// 
/// Combines communication patterns with mental health data for comprehensive analysis
/// All processing happens on-device for privacy protection
@HiveType(typeId: 18)
class OfflineAIAnalysis extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime analysisDate;

  @HiveField(3)
  DateTime periodStart;

  @HiveField(4)
  DateTime periodEnd;

  @HiveField(5)
  RelationshipInsight relationshipInsight;

  @HiveField(6)
  MentalHealthInsight mentalHealthInsight;

  @HiveField(7)
  CorrelationAnalysis correlationAnalysis;

  @HiveField(8)
  List<AIRecommendation> recommendations;

  @HiveField(9)
  double confidenceScore; // 0.0 to 1.0

  @HiveField(10)
  bool isPrivacyMode;

  @HiveField(11)
  Map<String, dynamic> metadata;

  OfflineAIAnalysis({
    required this.id,
    required this.userId,
    required this.analysisDate,
    required this.periodStart,
    required this.periodEnd,
    required this.relationshipInsight,
    required this.mentalHealthInsight,
    required this.correlationAnalysis,
    this.recommendations = const [],
    this.confidenceScore = 0.5,
    this.isPrivacyMode = true,
    this.metadata = const {},
  });

  /// Generate comprehensive AI analysis from logs
  factory OfflineAIAnalysis.fromLogs({
    required String userId,
    required List<RelationshipLog> relationshipLogs,
    required List<MentalHealthLog> mentalHealthLogs,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    final relationshipInsight = RelationshipInsight.fromLogs(relationshipLogs, periodStart, periodEnd);
    final mentalHealthInsight = MentalHealthInsight.fromLogs(mentalHealthLogs, periodStart, periodEnd);
    final correlationAnalysis = CorrelationAnalysis.analyze(relationshipLogs, mentalHealthLogs);
    
    final recommendations = _generateRecommendations(
      relationshipInsight,
      mentalHealthInsight,
      correlationAnalysis,
    );

    final confidence = _calculateConfidence(relationshipLogs, mentalHealthLogs);

    return OfflineAIAnalysis(
      id: 'ai_analysis_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      analysisDate: DateTime.now(),
      periodStart: periodStart,
      periodEnd: periodEnd,
      relationshipInsight: relationshipInsight,
      mentalHealthInsight: mentalHealthInsight,
      correlationAnalysis: correlationAnalysis,
      recommendations: recommendations,
      confidenceScore: confidence,
      isPrivacyMode: true,
    );
  }

  /// Generate AI recommendations based on analysis
  static List<AIRecommendation> _generateRecommendations(
    RelationshipInsight relationshipInsight,
    MentalHealthInsight mentalHealthInsight,
    CorrelationAnalysis correlationAnalysis,
  ) {
    final recommendations = <AIRecommendation>[];

    // Communication frequency recommendations
    if (relationshipInsight.averageCommunicationFrequency < 1.0) {
      recommendations.add(AIRecommendation(
        type: RecommendationType.communication,
        priority: RecommendationPriority.high,
        title: 'बातचीत बढ़ाएं',
        description: 'आपकी communication frequency कम है। दिन में कम से कम एक बार अपने प्रिय व्यक्ति से बात करने की कोशिश करें।',
        actionSteps: [
          'सुबह एक good morning message भेजें',
          'दिन में एक छोटा call करें',
          'शाम को दिन की घटनाओं को share करें',
        ],
        confidenceScore: 0.8,
      ));
    }

    // Mental health and relationship correlation
    if (correlationAnalysis.moodCommunicationCorrelation < -0.3) {
      recommendations.add(AIRecommendation(
        type: RecommendationType.mentalHealth,
        priority: RecommendationPriority.high,
        title: 'रिश्ते का मूड पर प्रभाव',
        description: 'आपके relationship communication patterns आपके mood को negatively affect कर रहे हैं।',
        actionSteps: [
          'Open communication practice करें',
          'Misunderstandings को जल्दी resolve करें',
          'Quality time spend करने की कोशिश करें',
        ],
        confidenceScore: 0.7,
      ));
    }

    // Intimacy improvement
    if (relationshipInsight.averageIntimacyScore < 0.5) {
      recommendations.add(AIRecommendation(
        type: RecommendationType.intimacy,
        priority: RecommendationPriority.medium,
        title: 'भावनात्मक निकटता बढ़ाएं',
        description: 'आपके रिश्ते में emotional intimacy को बेहतर बनाया जा सकता है।',
        actionSteps: [
          'Deep conversations करें',
          'Personal feelings share करें',
          'Active listening practice करें',
        ],
        confidenceScore: 0.6,
      ));
    }

    // Stress management
    if (mentalHealthInsight.averageStressLevel > 7.0) {
      recommendations.add(AIRecommendation(
        type: RecommendationType.stressManagement,
        priority: RecommendationPriority.high,
        title: 'तनाव प्रबंधन',
        description: 'आपका stress level अधिक है जो आपके रिश्ते को प्रभावित कर सकता है।',
        actionSteps: [
          'Daily meditation practice करें',
          'अपने partner के साथ stress share करें',
          'साथ में relaxing activities करें',
        ],
        confidenceScore: 0.8,
      ));
    }

    return recommendations;
  }

  /// Calculate confidence score based on data availability
  static double _calculateConfidence(
    List<RelationshipLog> relationshipLogs,
    List<MentalHealthLog> mentalHealthLogs,
  ) {
    double confidence = 0.0;
    
    // Data availability factor
    if (relationshipLogs.length >= 10) {
      confidence += 0.3;
    } else if (relationshipLogs.length >= 5) {
      confidence += 0.2;
    } else {
      confidence += 0.1;
    }
    
    if (mentalHealthLogs.length >= 7) {
      confidence += 0.3;
    } else if (mentalHealthLogs.length >= 3) {
      confidence += 0.2;
    } else {
      confidence += 0.1;
    }
    
    // Data recency factor
    final now = DateTime.now();
    final recentRelationshipLogs = relationshipLogs.where(
      (log) => now.difference(log.timestamp).inDays <= 7,
    ).length;
    final recentMentalHealthLogs = mentalHealthLogs.where(
      (log) => now.difference(log.timestamp).inDays <= 7,
    ).length;
    
    if (recentRelationshipLogs >= 3 && recentMentalHealthLogs >= 3) {
      confidence += 0.4;
    } else if (recentRelationshipLogs >= 1 || recentMentalHealthLogs >= 1) {
      confidence += 0.2;
    }
    
    return confidence.clamp(0.0, 1.0);
  }

  /// Generate comprehensive summary for user
  String toUserSummaryString() {
    final buffer = StringBuffer();
    
    buffer.writeln('🤖 AI विश्लेषण रिपोर्ट');
    buffer.writeln('📅 अवधि: ${periodStart.day}/${periodStart.month} - ${periodEnd.day}/${periodEnd.month}');
    buffer.writeln('🎯 विश्वसनीयता: ${(confidenceScore * 100).toStringAsFixed(0)}%\n');
    
    // Relationship insights
    buffer.writeln('💕 रिश्ता विश्लेषण:');
    buffer.writeln('• संपर्क आवृत्ति: ${relationshipInsight.averageCommunicationFrequency.toStringAsFixed(1)}/दिन');
    buffer.writeln('• भावनात्मक निकटता: ${(relationshipInsight.averageIntimacyScore * 100).toStringAsFixed(0)}%');
    buffer.writeln('• रिश्ते का चरण: ${relationshipInsight.currentPhase.name}\n');
    
    // Mental health insights
    buffer.writeln('🧠 मानसिक स्वास्थ्य:');
    buffer.writeln('• औसत मूड: ${mentalHealthInsight.averageMoodScore.toStringAsFixed(1)}/10');
    buffer.writeln('• तनाव स्तर: ${mentalHealthInsight.averageStressLevel.toStringAsFixed(1)}/10');
    buffer.writeln('• ऊर्जा स्तर: ${mentalHealthInsight.averageEnergyLevel.toStringAsFixed(1)}/10\n');
    
    // Correlation insights
    buffer.writeln('🔗 संबंध विश्लेषण:');
    if (correlationAnalysis.moodCommunicationCorrelation > 0.3) {
      buffer.writeln('• अधिक बातचीत से मूड बेहतर होता है');
    } else if (correlationAnalysis.moodCommunicationCorrelation < -0.3) {
      buffer.writeln('• बातचीत की कमी मूड को प्रभावित करती है');
    } else {
      buffer.writeln('• बातचीत और मूड में स्थिर संबंध');
    }
    
    // Top recommendations
    if (recommendations.isNotEmpty) {
      buffer.writeln('\n📋 सुझाव:');
      for (final rec in recommendations.take(3)) {
        buffer.writeln('• ${rec.title}');
      }
    }
    
    return buffer.toString();
  }
}

/// Relationship insights from communication patterns
@HiveType(typeId: 22)
class RelationshipInsight extends HiveObject {
  @HiveField(0)
  double averageCommunicationFrequency;

  @HiveField(1)
  double averageIntimacyScore;

  @HiveField(2)
  RelationshipPhase currentPhase;

  @HiveField(3)
  Map<InteractionType, int> communicationBreakdown;

  @HiveField(4)
  List<String> dominantThemes;

  @HiveField(5)
  double responseTimePattern; // average hours between interactions

  RelationshipInsight({
    this.averageCommunicationFrequency = 0.0,
    this.averageIntimacyScore = 0.5,
    this.currentPhase = RelationshipPhase.unknown,
    this.communicationBreakdown = const {},
    this.dominantThemes = const [],
    this.responseTimePattern = 24.0,
  });

  factory RelationshipInsight.fromLogs(
    List<RelationshipLog> logs,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    if (logs.isEmpty) {
      return RelationshipInsight();
    }

    final days = periodEnd.difference(periodStart).inDays;
    final frequency = days > 0 ? logs.length / days : 0.0;
    final avgIntimacy = logs.fold(0.0, (sum, log) => sum + log.intimacyScore) / logs.length;
    
    // Determine current phase based on patterns
    RelationshipPhase phase = RelationshipPhase.stable;
    if (frequency > 5.0 && avgIntimacy > 0.7) {
      phase = RelationshipPhase.deepening;
    } else if (frequency < 1.0 || avgIntimacy < 0.3) {
      phase = RelationshipPhase.distant;
    } else if (frequency > 3.0 && avgIntimacy > 0.5) {
      phase = RelationshipPhase.building;
    }

    // Communication breakdown
    final breakdown = <InteractionType, int>{};
    for (final log in logs) {
      breakdown[log.type] = (breakdown[log.type] ?? 0) + 1;
    }

    // Dominant themes from keywords
    final allKeywords = logs.expand((log) => log.keywords).toList();
    final keywordCounts = <String, int>{};
    for (final keyword in allKeywords) {
      keywordCounts[keyword] = (keywordCounts[keyword] ?? 0) + 1;
    }
    final dominantThemes = keywordCounts.entries
        .where((entry) => entry.value >= 2)
        .map((entry) => entry.key)
        .take(5)
        .toList();

    // Response time pattern
    double avgResponseTime = 24.0;
    if (logs.length > 1) {
      final gaps = logs.map((log) => log.interactionGap.inHours.toDouble()).toList();
      avgResponseTime = gaps.fold(0.0, (sum, gap) => sum + gap) / gaps.length;
    }

    return RelationshipInsight(
      averageCommunicationFrequency: frequency,
      averageIntimacyScore: avgIntimacy,
      currentPhase: phase,
      communicationBreakdown: breakdown,
      dominantThemes: dominantThemes,
      responseTimePattern: avgResponseTime,
    );
  }
}

/// Mental health insights from mood tracking
@HiveType(typeId: 23)
class MentalHealthInsight extends HiveObject {
  @HiveField(0)
  double averageMoodScore;

  @HiveField(1)
  double averageEnergyLevel;

  @HiveField(2)
  double averageStressLevel;

  @HiveField(3)
  double averageRelationshipSatisfaction;

  @HiveField(4)
  List<TriggerEvent> commonTriggers;

  @HiveField(5)
  List<CopingStrategy> effectiveCopingStrategies;

  @HiveField(6)
  MoodTrend moodTrend;

  MentalHealthInsight({
    this.averageMoodScore = 5.0,
    this.averageEnergyLevel = 5.0,
    this.averageStressLevel = 5.0,
    this.averageRelationshipSatisfaction = 5.0,
    this.commonTriggers = const [],
    this.effectiveCopingStrategies = const [],
    this.moodTrend = MoodTrend.stable,
  });

  factory MentalHealthInsight.fromLogs(
    List<MentalHealthLog> logs,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    if (logs.isEmpty) {
      return MentalHealthInsight();
    }

    // Calculate averages
    final avgMood = logs.fold(0.0, (sum, log) => sum + _moodToScore(log.primaryMood)) / logs.length;
    final avgEnergy = logs.fold(0.0, (sum, log) => sum + log.energyLevel) / logs.length;
    final avgStress = logs.fold(0.0, (sum, log) => sum + log.stressLevel) / logs.length;
    final avgRelSat = logs.fold(0.0, (sum, log) => sum + log.relationshipSatisfaction) / logs.length;

    // Common triggers
    final allTriggers = logs.expand((log) => log.triggers).toList();
    final triggerCounts = <TriggerEvent, int>{};
    for (final trigger in allTriggers) {
      triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
    }
    final commonTriggers = triggerCounts.entries
        .where((entry) => entry.value >= 2)
        .map((entry) => entry.key)
        .take(3)
        .toList();

    // Effective coping strategies
    final allCoping = logs.expand((log) => log.copingStrategies).toList();
    final copingCounts = <CopingStrategy, int>{};
    for (final coping in allCoping) {
      copingCounts[coping] = (copingCounts[coping] ?? 0) + 1;
    }
    final effectiveCoping = copingCounts.entries
        .where((entry) => entry.value >= 2)
        .map((entry) => entry.key)
        .take(3)
        .toList();

    // Mood trend analysis
    MoodTrend trend = MoodTrend.stable;
    if (logs.length >= 3) {
      final recentMood = logs.take(logs.length ~/ 2).fold(0.0, (sum, log) => sum + _moodToScore(log.primaryMood)) / (logs.length ~/ 2);
      final olderMood = logs.skip(logs.length ~/ 2).fold(0.0, (sum, log) => sum + _moodToScore(log.primaryMood)) / (logs.length - logs.length ~/ 2);
      
      if (recentMood > olderMood + 1.0) {
        trend = MoodTrend.improving;
      } else if (recentMood < olderMood - 1.0) {
        trend = MoodTrend.declining;
      }
    }

    return MentalHealthInsight(
      averageMoodScore: avgMood,
      averageEnergyLevel: avgEnergy,
      averageStressLevel: avgStress,
      averageRelationshipSatisfaction: avgRelSat,
      commonTriggers: commonTriggers,
      effectiveCopingStrategies: effectiveCoping,
      moodTrend: trend,
    );
  }

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
}

/// Correlation analysis between relationship patterns and mental health
@HiveType(typeId: 24)
class CorrelationAnalysis extends HiveObject {
  @HiveField(0)
  double moodCommunicationCorrelation; // -1.0 to 1.0

  @HiveField(1)
  double stressIntimacyCorrelation;

  @HiveField(2)
  double energyFrequencyCorrelation;

  @HiveField(3)
  List<String> significantPatterns;

  CorrelationAnalysis({
    this.moodCommunicationCorrelation = 0.0,
    this.stressIntimacyCorrelation = 0.0,
    this.energyFrequencyCorrelation = 0.0,
    this.significantPatterns = const [],
  });

  factory CorrelationAnalysis.analyze(
    List<RelationshipLog> relationshipLogs,
    List<MentalHealthLog> mentalHealthLogs,
  ) {
    if (relationshipLogs.isEmpty || mentalHealthLogs.isEmpty) {
      return CorrelationAnalysis();
    }

    // Simple correlation analysis (in a real app, this would be more sophisticated)
    double moodCommCorr = 0.0;
    double stressIntimacyCorr = 0.0;
    double energyFreqCorr = 0.0;
    final patterns = <String>[];

    // Sample correlation calculations (simplified)
    final avgMood = mentalHealthLogs.fold(0.0, (sum, log) => sum + MentalHealthInsight._moodToScore(log.primaryMood)) / mentalHealthLogs.length;
    final avgComm = relationshipLogs.fold(0.0, (sum, log) => sum + log.communicationFrequency) / relationshipLogs.length;
    
    if (avgMood > 6.0 && avgComm > 3.0) {
      moodCommCorr = 0.6;
      patterns.add('High communication correlates with better mood');
    } else if (avgMood < 4.0 && avgComm < 1.0) {
      moodCommCorr = -0.5;
      patterns.add('Low communication correlates with lower mood');
    }

    return CorrelationAnalysis(
      moodCommunicationCorrelation: moodCommCorr,
      stressIntimacyCorrelation: stressIntimacyCorr,
      energyFrequencyCorrelation: energyFreqCorr,
      significantPatterns: patterns,
    );
  }
}

/// AI-generated recommendations
@HiveType(typeId: 25)
class AIRecommendation extends HiveObject {
  @HiveField(0)
  RecommendationType type;

  @HiveField(1)
  RecommendationPriority priority;

  @HiveField(2)
  String title;

  @HiveField(3)
  String description;

  @HiveField(4)
  List<String> actionSteps;

  @HiveField(5)
  double confidenceScore;

  @HiveField(6)
  DateTime createdAt;

  AIRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    this.actionSteps = const [],
    this.confidenceScore = 0.5,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// Types of AI recommendations
@HiveType(typeId: 26)
enum RecommendationType {
  @HiveField(0)
  communication,
  
  @HiveField(1)
  intimacy,
  
  @HiveField(2)
  mentalHealth,
  
  @HiveField(3)
  stressManagement,
  
  @HiveField(4)
  conflictResolution,
  
  @HiveField(5)
  qualityTime,
}

/// Priority levels for recommendations
@HiveType(typeId: 27)
enum RecommendationPriority {
  @HiveField(0)
  low,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  high,
  
  @HiveField(3)
  urgent,
}

/// Mood trend analysis
@HiveType(typeId: 28)
enum MoodTrend {
  @HiveField(0)
  improving,
  
  @HiveField(1)
  stable,
  
  @HiveField(2)
  declining,
  
  @HiveField(3)
  fluctuating,
}