// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyProgressAdapter extends TypeAdapter<DailyProgress> {
  @override
  final int typeId = 30;

  @override
  DailyProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyProgress(
      date: fields[0] as DateTime,
      pointsEarned: fields[1] as int,
      overallRelationshipScore: fields[2] as double,
      wellnessScore: fields[3] as double,
      sleepHours: fields[4] as int,
      meditationMinutes: fields[5] as int,
      sleepQuality: fields[6] as double,
      averageMood: fields[7] as double?,
      averageStress: fields[8] as double?,
      conversationCount: fields[9] as int,
      exerciseMinutes: fields[10] as int,
      screenTimeHours: fields[11] as double,
      achievementBadges: (fields[12] as List?)?.cast<String>(),
      dailyReflection: fields[13] as String?,
      goalCompletionRate: fields[14] as double,
      createdAt: fields[15] as DateTime?,
      updatedAt: fields[16] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyProgress obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.pointsEarned)
      ..writeByte(2)
      ..write(obj.overallRelationshipScore)
      ..writeByte(3)
      ..write(obj.wellnessScore)
      ..writeByte(4)
      ..write(obj.sleepHours)
      ..writeByte(5)
      ..write(obj.meditationMinutes)
      ..writeByte(6)
      ..write(obj.sleepQuality)
      ..writeByte(7)
      ..write(obj.averageMood)
      ..writeByte(8)
      ..write(obj.averageStress)
      ..writeByte(9)
      ..write(obj.conversationCount)
      ..writeByte(10)
      ..write(obj.exerciseMinutes)
      ..writeByte(11)
      ..write(obj.screenTimeHours)
      ..writeByte(12)
      ..write(obj.achievementBadges)
      ..writeByte(13)
      ..write(obj.dailyReflection)
      ..writeByte(14)
      ..write(obj.goalCompletionRate)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeeklyProgressSummaryAdapter extends TypeAdapter<WeeklyProgressSummary> {
  @override
  final int typeId = 32;

  @override
  WeeklyProgressSummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyProgressSummary(
      weekStartDate: fields[0] as DateTime,
      weekEndDate: fields[1] as DateTime,
      dailyEntries: (fields[2] as List).cast<DailyProgress>(),
      averageWellnessScore: fields[3] as double,
      averageRelationshipScore: fields[4] as double,
      totalPointsEarned: fields[5] as int,
      totalSleepHours: fields[6] as int,
      totalMeditationMinutes: fields[7] as int,
      weeklyAchievements: (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyProgressSummary obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.weekStartDate)
      ..writeByte(1)
      ..write(obj.weekEndDate)
      ..writeByte(2)
      ..write(obj.dailyEntries)
      ..writeByte(3)
      ..write(obj.averageWellnessScore)
      ..writeByte(4)
      ..write(obj.averageRelationshipScore)
      ..writeByte(5)
      ..write(obj.totalPointsEarned)
      ..writeByte(6)
      ..write(obj.totalSleepHours)
      ..writeByte(7)
      ..write(obj.totalMeditationMinutes)
      ..writeByte(8)
      ..write(obj.weeklyAchievements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyProgressSummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WellnessCategoryAdapter extends TypeAdapter<WellnessCategory> {
  @override
  final int typeId = 31;

  @override
  WellnessCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WellnessCategory.excellent;
      case 1:
        return WellnessCategory.good;
      case 2:
        return WellnessCategory.fair;
      case 3:
        return WellnessCategory.poor;
      case 4:
        return WellnessCategory.needsImprovement;
      default:
        return WellnessCategory.excellent;
    }
  }

  @override
  void write(BinaryWriter writer, WellnessCategory obj) {
    switch (obj) {
      case WellnessCategory.excellent:
        writer.writeByte(0);
        break;
      case WellnessCategory.good:
        writer.writeByte(1);
        break;
      case WellnessCategory.fair:
        writer.writeByte(2);
        break;
      case WellnessCategory.poor:
        writer.writeByte(3);
        break;
      case WellnessCategory.needsImprovement:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WellnessCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
