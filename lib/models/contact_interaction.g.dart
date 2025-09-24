// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_interaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactInteractionAdapter extends TypeAdapter<ContactInteraction> {
  @override
  final int typeId = 3;

  @override
  ContactInteraction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContactInteraction(
      contactId: fields[0] as String,
      timestamp: fields[1] as DateTime,
      type: fields[2] as InteractionType,
      duration: fields[3] as int,
      initiatedByMe: fields[4] as bool,
      content: fields[5] as String?,
      sentimentScore: fields[6] as double?,
      metadata: (fields[7] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ContactInteraction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.contactId)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.initiatedByMe)
      ..writeByte(5)
      ..write(obj.content)
      ..writeByte(6)
      ..write(obj.sentimentScore)
      ..writeByte(7)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactInteractionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InteractionTypeAdapter extends TypeAdapter<InteractionType> {
  @override
  final int typeId = 4;

  @override
  InteractionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InteractionType.call;
      case 1:
        return InteractionType.message;
      case 2:
        return InteractionType.email;
      case 3:
        return InteractionType.whatsapp;
      case 4:
        return InteractionType.videoCall;
      case 5:
        return InteractionType.meeting;
      default:
        return InteractionType.call;
    }
  }

  @override
  void write(BinaryWriter writer, InteractionType obj) {
    switch (obj) {
      case InteractionType.call:
        writer.writeByte(0);
        break;
      case InteractionType.message:
        writer.writeByte(1);
        break;
      case InteractionType.email:
        writer.writeByte(2);
        break;
      case InteractionType.whatsapp:
        writer.writeByte(3);
        break;
      case InteractionType.videoCall:
        writer.writeByte(4);
        break;
      case InteractionType.meeting:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InteractionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmotionalScoreAdapter extends TypeAdapter<EmotionalScore> {
  @override
  final int typeId = 5;

  @override
  EmotionalScore read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EmotionalScore.veryWarm;
      case 1:
        return EmotionalScore.friendlyButFading;
      case 2:
        return EmotionalScore.cold;
      default:
        return EmotionalScore.veryWarm;
    }
  }

  @override
  void write(BinaryWriter writer, EmotionalScore obj) {
    switch (obj) {
      case EmotionalScore.veryWarm:
        writer.writeByte(0);
        break;
      case EmotionalScore.friendlyButFading:
        writer.writeByte(1);
        break;
      case EmotionalScore.cold:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmotionalScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
