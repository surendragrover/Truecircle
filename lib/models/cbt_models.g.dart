// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cbt_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CBTAssessmentResultAdapter extends TypeAdapter<CBTAssessmentResult> {
  @override
  final int typeId = 40;

  @override
  CBTAssessmentResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CBTAssessmentResult(
      id: fields[0] as String,
      assessmentKey: fields[1] as String,
      answers: (fields[2] as Map).cast<String, int>(),
      totalScore: fields[3] as int,
      timestamp: fields[4] as DateTime,
      severityBand: fields[5] as String,
      localizedSummaryEn: fields[6] as String,
      localizedSummaryHi: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CBTAssessmentResult obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.assessmentKey)
      ..writeByte(2)
      ..write(obj.answers)
      ..writeByte(3)
      ..write(obj.totalScore)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.severityBand)
      ..writeByte(6)
      ..write(obj.localizedSummaryEn)
      ..writeByte(7)
      ..write(obj.localizedSummaryHi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CBTAssessmentResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CBTThoughtRecordAdapter extends TypeAdapter<CBTThoughtRecord> {
  @override
  final int typeId = 41;

  @override
  CBTThoughtRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CBTThoughtRecord(
      id: fields[0] as String,
      createdAt: fields[1] as DateTime,
      situation: fields[2] as String,
      automaticThought: fields[3] as String,
      emotion: fields[4] as String,
      emotionIntensityBefore: fields[5] as int,
      cognitiveDistortion: fields[6] as String,
      rationalResponse: fields[7] as String,
      emotionIntensityAfter: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CBTThoughtRecord obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.situation)
      ..writeByte(3)
      ..write(obj.automaticThought)
      ..writeByte(4)
      ..write(obj.emotion)
      ..writeByte(5)
      ..write(obj.emotionIntensityBefore)
      ..writeByte(6)
      ..write(obj.cognitiveDistortion)
      ..writeByte(7)
      ..write(obj.rationalResponse)
      ..writeByte(8)
      ..write(obj.emotionIntensityAfter);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CBTThoughtRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CopingCardAdapter extends TypeAdapter<CopingCard> {
  @override
  final int typeId = 42;

  @override
  CopingCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CopingCard(
      id: fields[0] as String,
      unhelpfulBelief: fields[1] as String,
      adaptiveBelief: fields[2] as String,
      evidenceFor: (fields[3] as List).cast<String>(),
      evidenceAgainst: (fields[4] as List).cast<String>(),
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CopingCard obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.unhelpfulBelief)
      ..writeByte(2)
      ..write(obj.adaptiveBelief)
      ..writeByte(3)
      ..write(obj.evidenceFor)
      ..writeByte(4)
      ..write(obj.evidenceAgainst)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CopingCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CBTMicroLessonProgressAdapter
    extends TypeAdapter<CBTMicroLessonProgress> {
  @override
  final int typeId = 43;

  @override
  CBTMicroLessonProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CBTMicroLessonProgress(
      lessonId: fields[0] as String,
      completed: fields[1] as bool,
      updatedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CBTMicroLessonProgress obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.lessonId)
      ..writeByte(1)
      ..write(obj.completed)
      ..writeByte(2)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CBTMicroLessonProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HypnotherapySessionLogAdapter
    extends TypeAdapter<HypnotherapySessionLog> {
  @override
  final int typeId = 44;

  @override
  HypnotherapySessionLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HypnotherapySessionLog(
      id: fields[0] as String,
      startedAt: fields[1] as DateTime,
      completedAt: fields[2] as DateTime?,
      scriptKey: fields[3] as String,
      relaxationRatingBefore: fields[4] as int,
      relaxationRatingAfter: fields[5] as int,
      focusIntent: fields[6] as String,
      notes: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HypnotherapySessionLog obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startedAt)
      ..writeByte(2)
      ..write(obj.completedAt)
      ..writeByte(3)
      ..write(obj.scriptKey)
      ..writeByte(4)
      ..write(obj.relaxationRatingBefore)
      ..writeByte(5)
      ..write(obj.relaxationRatingAfter)
      ..writeByte(6)
      ..write(obj.focusIntent)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HypnotherapySessionLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SharedArticleAdapter extends TypeAdapter<SharedArticle> {
  @override
  final int typeId = 45;

  @override
  SharedArticle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SharedArticle(
      id: fields[0] as String,
      title: fields[1] as String,
      author: fields[2] as String,
      body: fields[3] as String,
      createdAt: fields[4] as DateTime,
      imported: fields[5] as bool,
      sourceEmail: fields[6] as String,
      favorite: fields[7] as bool,
      bodyHi: fields[8] as String?,
      tags: (fields[9] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SharedArticle obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.body)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.imported)
      ..writeByte(6)
      ..write(obj.sourceEmail)
      ..writeByte(7)
      ..write(obj.favorite)
      ..writeByte(8)
      ..write(obj.bodyHi)
      ..writeByte(9)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedArticleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
