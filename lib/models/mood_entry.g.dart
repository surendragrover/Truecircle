// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MoodEntryAdapter extends TypeAdapter<MoodEntry> {
  @override
  final int typeId = 29;

  @override
  MoodEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodEntry(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      userText: fields[2] as String,
      identifiedMood: fields[3] as String,
      stressLevel: fields[4] as String,
      relatedContactId: fields[5] as String,
      category: fields[6] as MoodCategory,
      sentimentScore: fields[7] as double,
      stressScore: fields[8] as double,
      extractedKeywords: (fields[9] as List).cast<String>(),
      detectedEmotions: (fields[10] as List).cast<EmotionIntensity>(),
      isPrivacyMode: fields[11] as bool,
      nlpMetadata: (fields[12] as Map).cast<String, dynamic>(),
      createdAt: fields[13] as DateTime?,
      lastAnalyzed: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MoodEntry obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.userText)
      ..writeByte(3)
      ..write(obj.identifiedMood)
      ..writeByte(4)
      ..write(obj.stressLevel)
      ..writeByte(5)
      ..write(obj.relatedContactId)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.sentimentScore)
      ..writeByte(8)
      ..write(obj.stressScore)
      ..writeByte(9)
      ..write(obj.extractedKeywords)
      ..writeByte(10)
      ..write(obj.detectedEmotions)
      ..writeByte(11)
      ..write(obj.isPrivacyMode)
      ..writeByte(12)
      ..write(obj.nlpMetadata)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.lastAnalyzed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmotionIntensityAdapter extends TypeAdapter<EmotionIntensity> {
  @override
  final int typeId = 31;

  @override
  EmotionIntensity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmotionIntensity(
      emotion: fields[0] as String,
      intensity: fields[1] as double,
      detectedAt: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, EmotionIntensity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.emotion)
      ..writeByte(1)
      ..write(obj.intensity)
      ..writeByte(2)
      ..write(obj.detectedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmotionIntensityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodCategoryAdapter extends TypeAdapter<MoodCategory> {
  @override
  final int typeId = 30;

  @override
  MoodCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MoodCategory.positive;
      case 1:
        return MoodCategory.negative;
      case 2:
        return MoodCategory.neutral;
      case 3:
        return MoodCategory.angry;
      case 4:
        return MoodCategory.sad;
      case 5:
        return MoodCategory.anxious;
      case 6:
        return MoodCategory.confused;
      case 7:
        return MoodCategory.pending;
      default:
        return MoodCategory.positive;
    }
  }

  @override
  void write(BinaryWriter writer, MoodCategory obj) {
    switch (obj) {
      case MoodCategory.positive:
        writer.writeByte(0);
        break;
      case MoodCategory.negative:
        writer.writeByte(1);
        break;
      case MoodCategory.neutral:
        writer.writeByte(2);
        break;
      case MoodCategory.angry:
        writer.writeByte(3);
        break;
      case MoodCategory.sad:
        writer.writeByte(4);
        break;
      case MoodCategory.anxious:
        writer.writeByte(5);
        break;
      case MoodCategory.confused:
        writer.writeByte(6);
        break;
      case MoodCategory.pending:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
