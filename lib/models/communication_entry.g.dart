// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'communication_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommunicationEntryAdapter extends TypeAdapter<CommunicationEntry> {
  @override
  final int typeId = 12;

  @override
  CommunicationEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommunicationEntry(
      id: fields[0] as String,
      contactId: fields[1] as String,
      conversationDate: fields[2] as DateTime,
      conversationType: fields[3] as String,
      conversationDuration: fields[4] as int,
      overallQuality: fields[5] as int,
      emotionalState: fields[6] as int,
      loveLevel: fields[7] as int,
      perceivedLoveLevel: fields[8] as int,
      hadConflict: fields[9] as bool,
      conflictReason: fields[10] as String?,
      conflictSeverity: fields[11] as int,
      hadSpecialMoment: fields[12] as bool,
      specialMomentDescription: fields[13] as String?,
      relationshipImpact: fields[14] as int,
      topicsDiscussed: (fields[15] as List).cast<String>(),
      conversationSummary: fields[16] as String,
      emotionsExperienced: (fields[17] as List).cast<String>(),
      trustLevel: fields[18] as int,
      intimacyLevel: fields[19] as int,
      concernsOrWorries: fields[20] as String?,
      positiveAspects: (fields[21] as List).cast<String>(),
      improvementAreas: (fields[22] as List).cast<String>(),
      createdAt: fields[23] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CommunicationEntry obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.contactId)
      ..writeByte(2)
      ..write(obj.conversationDate)
      ..writeByte(3)
      ..write(obj.conversationType)
      ..writeByte(4)
      ..write(obj.conversationDuration)
      ..writeByte(5)
      ..write(obj.overallQuality)
      ..writeByte(6)
      ..write(obj.emotionalState)
      ..writeByte(7)
      ..write(obj.loveLevel)
      ..writeByte(8)
      ..write(obj.perceivedLoveLevel)
      ..writeByte(9)
      ..write(obj.hadConflict)
      ..writeByte(10)
      ..write(obj.conflictReason)
      ..writeByte(11)
      ..write(obj.conflictSeverity)
      ..writeByte(12)
      ..write(obj.hadSpecialMoment)
      ..writeByte(13)
      ..write(obj.specialMomentDescription)
      ..writeByte(14)
      ..write(obj.relationshipImpact)
      ..writeByte(15)
      ..write(obj.topicsDiscussed)
      ..writeByte(16)
      ..write(obj.conversationSummary)
      ..writeByte(17)
      ..write(obj.emotionsExperienced)
      ..writeByte(18)
      ..write(obj.trustLevel)
      ..writeByte(19)
      ..write(obj.intimacyLevel)
      ..writeByte(20)
      ..write(obj.concernsOrWorries)
      ..writeByte(21)
      ..write(obj.positiveAspects)
      ..writeByte(22)
      ..write(obj.improvementAreas)
      ..writeByte(23)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunicationEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
