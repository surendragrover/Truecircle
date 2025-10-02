// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mental_health_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MentalHealthLogAdapter extends TypeAdapter<MentalHealthLog> {
  @override
  final int typeId = 11;

  @override
  MentalHealthLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MentalHealthLog(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      primaryMood: fields[2] as MoodLevel,
      emotionTags: (fields[3] as List).cast<EmotionTag>(),
      energyLevel: fields[4] as int,
      stressLevel: fields[5] as int,
      socialAnxiety: fields[6] as int,
      sleepQuality: fields[7] as SleepQuality,
      triggers: (fields[8] as List).cast<TriggerEvent>(),
      copingStrategies: (fields[9] as List).cast<CopingStrategy>(),
      relationshipSatisfaction: fields[10] as int,
      notes: fields[11] as String,
      isPrivacyMode: fields[12] as bool,
      aiAnalysisMetadata: (fields[13] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, MentalHealthLog obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.primaryMood)
      ..writeByte(3)
      ..write(obj.emotionTags)
      ..writeByte(4)
      ..write(obj.energyLevel)
      ..writeByte(5)
      ..write(obj.stressLevel)
      ..writeByte(6)
      ..write(obj.socialAnxiety)
      ..writeByte(7)
      ..write(obj.sleepQuality)
      ..writeByte(8)
      ..write(obj.triggers)
      ..writeByte(9)
      ..write(obj.copingStrategies)
      ..writeByte(10)
      ..write(obj.relationshipSatisfaction)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.isPrivacyMode)
      ..writeByte(13)
      ..write(obj.aiAnalysisMetadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MentalHealthLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MentalHealthAnalyticsAdapter extends TypeAdapter<MentalHealthAnalytics> {
  @override
  final int typeId = 17;

  @override
  MentalHealthAnalytics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MentalHealthAnalytics(
      userId: fields[0] as String,
      periodStart: fields[1] as DateTime,
      periodEnd: fields[2] as DateTime,
      averageMoodScore: fields[3] as double,
      averageEnergyLevel: fields[4] as double,
      averageStressLevel: fields[5] as double,
      averageSocialAnxiety: fields[6] as double,
      averageRelationshipSatisfaction: fields[7] as double,
      moodDistribution: (fields[8] as Map).cast<MoodLevel, int>(),
      commonTriggers: (fields[9] as Map).cast<TriggerEvent, int>(),
      effectiveCopingStrategies:
          (fields[10] as Map).cast<CopingStrategy, int>(),
      aiInsights: (fields[11] as List).cast<String>(),
      isPrivacyMode: fields[12] as bool,
      correlationData: (fields[13] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, MentalHealthAnalytics obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.periodStart)
      ..writeByte(2)
      ..write(obj.periodEnd)
      ..writeByte(3)
      ..write(obj.averageMoodScore)
      ..writeByte(4)
      ..write(obj.averageEnergyLevel)
      ..writeByte(5)
      ..write(obj.averageStressLevel)
      ..writeByte(6)
      ..write(obj.averageSocialAnxiety)
      ..writeByte(7)
      ..write(obj.averageRelationshipSatisfaction)
      ..writeByte(8)
      ..write(obj.moodDistribution)
      ..writeByte(9)
      ..write(obj.commonTriggers)
      ..writeByte(10)
      ..write(obj.effectiveCopingStrategies)
      ..writeByte(11)
      ..write(obj.aiInsights)
      ..writeByte(12)
      ..write(obj.isPrivacyMode)
      ..writeByte(13)
      ..write(obj.correlationData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MentalHealthAnalyticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodLevelAdapter extends TypeAdapter<MoodLevel> {
  @override
  final int typeId = 12;

  @override
  MoodLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MoodLevel.excellent;
      case 1:
        return MoodLevel.good;
      case 2:
        return MoodLevel.neutral;
      case 3:
        return MoodLevel.low;
      case 4:
        return MoodLevel.depressed;
      case 5:
        return MoodLevel.anxious;
      case 6:
        return MoodLevel.angry;
      case 7:
        return MoodLevel.excited;
      case 8:
        return MoodLevel.unknown;
      default:
        return MoodLevel.excellent;
    }
  }

  @override
  void write(BinaryWriter writer, MoodLevel obj) {
    switch (obj) {
      case MoodLevel.excellent:
        writer.writeByte(0);
        break;
      case MoodLevel.good:
        writer.writeByte(1);
        break;
      case MoodLevel.neutral:
        writer.writeByte(2);
        break;
      case MoodLevel.low:
        writer.writeByte(3);
        break;
      case MoodLevel.depressed:
        writer.writeByte(4);
        break;
      case MoodLevel.anxious:
        writer.writeByte(5);
        break;
      case MoodLevel.angry:
        writer.writeByte(6);
        break;
      case MoodLevel.excited:
        writer.writeByte(7);
        break;
      case MoodLevel.unknown:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmotionTagAdapter extends TypeAdapter<EmotionTag> {
  @override
  final int typeId = 13;

  @override
  EmotionTag read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EmotionTag.happy;
      case 1:
        return EmotionTag.sad;
      case 2:
        return EmotionTag.angry;
      case 3:
        return EmotionTag.anxious;
      case 4:
        return EmotionTag.excited;
      case 5:
        return EmotionTag.grateful;
      case 6:
        return EmotionTag.lonely;
      case 7:
        return EmotionTag.content;
      case 8:
        return EmotionTag.frustrated;
      case 9:
        return EmotionTag.overwhelmed;
      case 10:
        return EmotionTag.calm;
      case 11:
        return EmotionTag.worried;
      case 12:
        return EmotionTag.hopeful;
      case 13:
        return EmotionTag.disappointed;
      case 14:
        return EmotionTag.confused;
      case 15:
        return EmotionTag.focused;
      case 16:
        return EmotionTag.unknown;
      default:
        return EmotionTag.happy;
    }
  }

  @override
  void write(BinaryWriter writer, EmotionTag obj) {
    switch (obj) {
      case EmotionTag.happy:
        writer.writeByte(0);
        break;
      case EmotionTag.sad:
        writer.writeByte(1);
        break;
      case EmotionTag.angry:
        writer.writeByte(2);
        break;
      case EmotionTag.anxious:
        writer.writeByte(3);
        break;
      case EmotionTag.excited:
        writer.writeByte(4);
        break;
      case EmotionTag.grateful:
        writer.writeByte(5);
        break;
      case EmotionTag.lonely:
        writer.writeByte(6);
        break;
      case EmotionTag.content:
        writer.writeByte(7);
        break;
      case EmotionTag.frustrated:
        writer.writeByte(8);
        break;
      case EmotionTag.overwhelmed:
        writer.writeByte(9);
        break;
      case EmotionTag.calm:
        writer.writeByte(10);
        break;
      case EmotionTag.worried:
        writer.writeByte(11);
        break;
      case EmotionTag.hopeful:
        writer.writeByte(12);
        break;
      case EmotionTag.disappointed:
        writer.writeByte(13);
        break;
      case EmotionTag.confused:
        writer.writeByte(14);
        break;
      case EmotionTag.focused:
        writer.writeByte(15);
        break;
      case EmotionTag.unknown:
        writer.writeByte(16);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmotionTagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SleepQualityAdapter extends TypeAdapter<SleepQuality> {
  @override
  final int typeId = 14;

  @override
  SleepQuality read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SleepQuality.excellent;
      case 1:
        return SleepQuality.good;
      case 2:
        return SleepQuality.average;
      case 3:
        return SleepQuality.poor;
      case 4:
        return SleepQuality.terrible;
      case 5:
        return SleepQuality.unknown;
      default:
        return SleepQuality.excellent;
    }
  }

  @override
  void write(BinaryWriter writer, SleepQuality obj) {
    switch (obj) {
      case SleepQuality.excellent:
        writer.writeByte(0);
        break;
      case SleepQuality.good:
        writer.writeByte(1);
        break;
      case SleepQuality.average:
        writer.writeByte(2);
        break;
      case SleepQuality.poor:
        writer.writeByte(3);
        break;
      case SleepQuality.terrible:
        writer.writeByte(4);
        break;
      case SleepQuality.unknown:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepQualityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TriggerEventAdapter extends TypeAdapter<TriggerEvent> {
  @override
  final int typeId = 15;

  @override
  TriggerEvent read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TriggerEvent.workPressure;
      case 1:
        return TriggerEvent.relationshipConflict;
      case 2:
        return TriggerEvent.financialStress;
      case 3:
        return TriggerEvent.healthConcerns;
      case 4:
        return TriggerEvent.familyIssues;
      case 5:
        return TriggerEvent.socialPressure;
      case 6:
        return TriggerEvent.lackOfCommunication;
      case 7:
        return TriggerEvent.misunderstanding;
      case 8:
        return TriggerEvent.loneliness;
      case 9:
        return TriggerEvent.rejection;
      case 10:
        return TriggerEvent.criticism;
      case 11:
        return TriggerEvent.changeInRoutine;
      case 12:
        return TriggerEvent.unknown;
      default:
        return TriggerEvent.workPressure;
    }
  }

  @override
  void write(BinaryWriter writer, TriggerEvent obj) {
    switch (obj) {
      case TriggerEvent.workPressure:
        writer.writeByte(0);
        break;
      case TriggerEvent.relationshipConflict:
        writer.writeByte(1);
        break;
      case TriggerEvent.financialStress:
        writer.writeByte(2);
        break;
      case TriggerEvent.healthConcerns:
        writer.writeByte(3);
        break;
      case TriggerEvent.familyIssues:
        writer.writeByte(4);
        break;
      case TriggerEvent.socialPressure:
        writer.writeByte(5);
        break;
      case TriggerEvent.lackOfCommunication:
        writer.writeByte(6);
        break;
      case TriggerEvent.misunderstanding:
        writer.writeByte(7);
        break;
      case TriggerEvent.loneliness:
        writer.writeByte(8);
        break;
      case TriggerEvent.rejection:
        writer.writeByte(9);
        break;
      case TriggerEvent.criticism:
        writer.writeByte(10);
        break;
      case TriggerEvent.changeInRoutine:
        writer.writeByte(11);
        break;
      case TriggerEvent.unknown:
        writer.writeByte(12);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TriggerEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CopingStrategyAdapter extends TypeAdapter<CopingStrategy> {
  @override
  final int typeId = 16;

  @override
  CopingStrategy read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CopingStrategy.meditation;
      case 1:
        return CopingStrategy.exercise;
      case 2:
        return CopingStrategy.breathingExercises;
      case 3:
        return CopingStrategy.journaling;
      case 4:
        return CopingStrategy.talkingToFriends;
      case 5:
        return CopingStrategy.professionalHelp;
      case 6:
        return CopingStrategy.music;
      case 7:
        return CopingStrategy.reading;
      case 8:
        return CopingStrategy.natureWalk;
      case 9:
        return CopingStrategy.creativeActivity;
      case 10:
        return CopingStrategy.deepConversation;
      case 11:
        return CopingStrategy.qualityTime;
      case 12:
        return CopingStrategy.physicalAffection;
      case 13:
        return CopingStrategy.problemSolving;
      case 14:
        return CopingStrategy.unknown;
      default:
        return CopingStrategy.meditation;
    }
  }

  @override
  void write(BinaryWriter writer, CopingStrategy obj) {
    switch (obj) {
      case CopingStrategy.meditation:
        writer.writeByte(0);
        break;
      case CopingStrategy.exercise:
        writer.writeByte(1);
        break;
      case CopingStrategy.breathingExercises:
        writer.writeByte(2);
        break;
      case CopingStrategy.journaling:
        writer.writeByte(3);
        break;
      case CopingStrategy.talkingToFriends:
        writer.writeByte(4);
        break;
      case CopingStrategy.professionalHelp:
        writer.writeByte(5);
        break;
      case CopingStrategy.music:
        writer.writeByte(6);
        break;
      case CopingStrategy.reading:
        writer.writeByte(7);
        break;
      case CopingStrategy.natureWalk:
        writer.writeByte(8);
        break;
      case CopingStrategy.creativeActivity:
        writer.writeByte(9);
        break;
      case CopingStrategy.deepConversation:
        writer.writeByte(10);
        break;
      case CopingStrategy.qualityTime:
        writer.writeByte(11);
        break;
      case CopingStrategy.physicalAffection:
        writer.writeByte(12);
        break;
      case CopingStrategy.problemSolving:
        writer.writeByte(13);
        break;
      case CopingStrategy.unknown:
        writer.writeByte(14);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CopingStrategyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
