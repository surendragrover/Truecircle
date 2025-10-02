// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_ai_analysis.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineAIAnalysisAdapter extends TypeAdapter<OfflineAIAnalysis> {
  @override
  final int typeId = 18;

  @override
  OfflineAIAnalysis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineAIAnalysis(
      id: fields[0] as String,
      userId: fields[1] as String,
      analysisDate: fields[2] as DateTime,
      periodStart: fields[3] as DateTime,
      periodEnd: fields[4] as DateTime,
      relationshipInsight: fields[5] as RelationshipInsight,
      mentalHealthInsight: fields[6] as MentalHealthInsight,
      correlationAnalysis: fields[7] as CorrelationAnalysis,
      recommendations: (fields[8] as List).cast<AIRecommendation>(),
      confidenceScore: fields[9] as double,
      isPrivacyMode: fields[10] as bool,
      metadata: (fields[11] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, OfflineAIAnalysis obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.analysisDate)
      ..writeByte(3)
      ..write(obj.periodStart)
      ..writeByte(4)
      ..write(obj.periodEnd)
      ..writeByte(5)
      ..write(obj.relationshipInsight)
      ..writeByte(6)
      ..write(obj.mentalHealthInsight)
      ..writeByte(7)
      ..write(obj.correlationAnalysis)
      ..writeByte(8)
      ..write(obj.recommendations)
      ..writeByte(9)
      ..write(obj.confidenceScore)
      ..writeByte(10)
      ..write(obj.isPrivacyMode)
      ..writeByte(11)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineAIAnalysisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RelationshipInsightAdapter extends TypeAdapter<RelationshipInsight> {
  @override
  final int typeId = 22;

  @override
  RelationshipInsight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RelationshipInsight(
      averageCommunicationFrequency: fields[0] as double,
      averageIntimacyScore: fields[1] as double,
      currentPhase: fields[2] as RelationshipPhase,
      communicationBreakdown: (fields[3] as Map).cast<InteractionType, int>(),
      dominantThemes: (fields[4] as List).cast<String>(),
      responseTimePattern: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, RelationshipInsight obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.averageCommunicationFrequency)
      ..writeByte(1)
      ..write(obj.averageIntimacyScore)
      ..writeByte(2)
      ..write(obj.currentPhase)
      ..writeByte(3)
      ..write(obj.communicationBreakdown)
      ..writeByte(4)
      ..write(obj.dominantThemes)
      ..writeByte(5)
      ..write(obj.responseTimePattern);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelationshipInsightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MentalHealthInsightAdapter extends TypeAdapter<MentalHealthInsight> {
  @override
  final int typeId = 23;

  @override
  MentalHealthInsight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MentalHealthInsight(
      averageMoodScore: fields[0] as double,
      averageEnergyLevel: fields[1] as double,
      averageStressLevel: fields[2] as double,
      averageRelationshipSatisfaction: fields[3] as double,
      commonTriggers: (fields[4] as List).cast<TriggerEvent>(),
      effectiveCopingStrategies: (fields[5] as List).cast<CopingStrategy>(),
      moodTrend: fields[6] as MoodTrend,
    );
  }

  @override
  void write(BinaryWriter writer, MentalHealthInsight obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.averageMoodScore)
      ..writeByte(1)
      ..write(obj.averageEnergyLevel)
      ..writeByte(2)
      ..write(obj.averageStressLevel)
      ..writeByte(3)
      ..write(obj.averageRelationshipSatisfaction)
      ..writeByte(4)
      ..write(obj.commonTriggers)
      ..writeByte(5)
      ..write(obj.effectiveCopingStrategies)
      ..writeByte(6)
      ..write(obj.moodTrend);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MentalHealthInsightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CorrelationAnalysisAdapter extends TypeAdapter<CorrelationAnalysis> {
  @override
  final int typeId = 24;

  @override
  CorrelationAnalysis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CorrelationAnalysis(
      moodCommunicationCorrelation: fields[0] as double,
      stressIntimacyCorrelation: fields[1] as double,
      energyFrequencyCorrelation: fields[2] as double,
      significantPatterns: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, CorrelationAnalysis obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.moodCommunicationCorrelation)
      ..writeByte(1)
      ..write(obj.stressIntimacyCorrelation)
      ..writeByte(2)
      ..write(obj.energyFrequencyCorrelation)
      ..writeByte(3)
      ..write(obj.significantPatterns);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CorrelationAnalysisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AIRecommendationAdapter extends TypeAdapter<AIRecommendation> {
  @override
  final int typeId = 25;

  @override
  AIRecommendation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AIRecommendation(
      type: fields[0] as RecommendationType,
      priority: fields[1] as RecommendationPriority,
      title: fields[2] as String,
      description: fields[3] as String,
      actionSteps: (fields[4] as List).cast<String>(),
      confidenceScore: fields[5] as double,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AIRecommendation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.priority)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.actionSteps)
      ..writeByte(5)
      ..write(obj.confidenceScore)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIRecommendationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecommendationTypeAdapter extends TypeAdapter<RecommendationType> {
  @override
  final int typeId = 26;

  @override
  RecommendationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecommendationType.communication;
      case 1:
        return RecommendationType.intimacy;
      case 2:
        return RecommendationType.mentalHealth;
      case 3:
        return RecommendationType.stressManagement;
      case 4:
        return RecommendationType.conflictResolution;
      case 5:
        return RecommendationType.qualityTime;
      default:
        return RecommendationType.communication;
    }
  }

  @override
  void write(BinaryWriter writer, RecommendationType obj) {
    switch (obj) {
      case RecommendationType.communication:
        writer.writeByte(0);
        break;
      case RecommendationType.intimacy:
        writer.writeByte(1);
        break;
      case RecommendationType.mentalHealth:
        writer.writeByte(2);
        break;
      case RecommendationType.stressManagement:
        writer.writeByte(3);
        break;
      case RecommendationType.conflictResolution:
        writer.writeByte(4);
        break;
      case RecommendationType.qualityTime:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecommendationPriorityAdapter
    extends TypeAdapter<RecommendationPriority> {
  @override
  final int typeId = 27;

  @override
  RecommendationPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecommendationPriority.low;
      case 1:
        return RecommendationPriority.medium;
      case 2:
        return RecommendationPriority.high;
      case 3:
        return RecommendationPriority.urgent;
      default:
        return RecommendationPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, RecommendationPriority obj) {
    switch (obj) {
      case RecommendationPriority.low:
        writer.writeByte(0);
        break;
      case RecommendationPriority.medium:
        writer.writeByte(1);
        break;
      case RecommendationPriority.high:
        writer.writeByte(2);
        break;
      case RecommendationPriority.urgent:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodTrendAdapter extends TypeAdapter<MoodTrend> {
  @override
  final int typeId = 28;

  @override
  MoodTrend read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MoodTrend.improving;
      case 1:
        return MoodTrend.stable;
      case 2:
        return MoodTrend.declining;
      case 3:
        return MoodTrend.fluctuating;
      default:
        return MoodTrend.improving;
    }
  }

  @override
  void write(BinaryWriter writer, MoodTrend obj) {
    switch (obj) {
      case MoodTrend.improving:
        writer.writeByte(0);
        break;
      case MoodTrend.stable:
        writer.writeByte(1);
        break;
      case MoodTrend.declining:
        writer.writeByte(2);
        break;
      case MoodTrend.fluctuating:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodTrendAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
