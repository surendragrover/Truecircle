// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship_contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RelationshipContactAdapter extends TypeAdapter<RelationshipContact> {
  @override
  final int typeId = 13;

  @override
  RelationshipContact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RelationshipContact(
      id: fields[0] as String,
      name: fields[1] as String,
      relationship: fields[2] as String,
      avatarPath: fields[3] as String?,
      phoneNumber: fields[4] as String?,
      importance: fields[5] as int,
      currentRelationshipStrength: fields[6] as int,
      personalityTraits: (fields[7] as List).cast<String>(),
      notes: fields[8] as String?,
      lastInteractionDate: fields[9] as DateTime?,
      interactionFrequency: fields[10] as int,
      commonInterests: (fields[11] as List).cast<String>(),
      communicationPreferences: (fields[12] as List).cast<String>(),
      relationshipHistory: (fields[13] as Map).cast<String, int>(),
      isPriority: fields[14] as bool,
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RelationshipContact obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.relationship)
      ..writeByte(3)
      ..write(obj.avatarPath)
      ..writeByte(4)
      ..write(obj.phoneNumber)
      ..writeByte(5)
      ..write(obj.importance)
      ..writeByte(6)
      ..write(obj.currentRelationshipStrength)
      ..writeByte(7)
      ..write(obj.personalityTraits)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.lastInteractionDate)
      ..writeByte(10)
      ..write(obj.interactionFrequency)
      ..writeByte(11)
      ..write(obj.commonInterests)
      ..writeByte(12)
      ..write(obj.communicationPreferences)
      ..writeByte(13)
      ..write(obj.relationshipHistory)
      ..writeByte(14)
      ..write(obj.isPriority)
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
      other is RelationshipContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}