// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RelationshipLogAdapter extends TypeAdapter<RelationshipLog> {
  @override
  final int typeId = 7;

  @override
  RelationshipLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RelationshipLog(
      id: fields[0] as String,
      contactId: fields[1] as String,
      contactName: fields[2] as String,
      timestamp: fields[3] as DateTime,
      lastInteraction: fields[4] as DateTime,
      interactionGap: fields[5] as Duration,
      type: fields[6] as InteractionType,
      duration: fields[7] as int,
      isIncoming: fields[8] as bool,
      messageLength: fields[9] as int,
      callDurationAverage: fields[10] as double,
      totalCallsInLastMonth: fields[11] as int,
      totalMessagesInLastMonth: fields[12] as int,
      tone: fields[13] as EmotionalTone,
      intimacyScore: fields[14] as double,
      keywords: (fields[15] as List).cast<String>(),
      isPrivacyMode: fields[16] as bool,
      metadata: (fields[17] as Map).cast<String, dynamic>(),
      communicationFrequency: fields[18] as double,
      currentPhase: fields[19] as RelationshipPhase,
    );
  }

  @override
  void write(BinaryWriter writer, RelationshipLog obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.contactId)
      ..writeByte(2)
      ..write(obj.contactName)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.lastInteraction)
      ..writeByte(5)
      ..write(obj.interactionGap)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.isIncoming)
      ..writeByte(9)
      ..write(obj.messageLength)
      ..writeByte(10)
      ..write(obj.callDurationAverage)
      ..writeByte(11)
      ..write(obj.totalCallsInLastMonth)
      ..writeByte(12)
      ..write(obj.totalMessagesInLastMonth)
      ..writeByte(13)
      ..write(obj.tone)
      ..writeByte(14)
      ..write(obj.intimacyScore)
      ..writeByte(15)
      ..write(obj.keywords)
      ..writeByte(16)
      ..write(obj.isPrivacyMode)
      ..writeByte(17)
      ..write(obj.metadata)
      ..writeByte(18)
      ..write(obj.communicationFrequency)
      ..writeByte(19)
      ..write(obj.currentPhase);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelationshipLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CommunicationStatsAdapter extends TypeAdapter<CommunicationStats> {
  @override
  final int typeId = 10;

  @override
  CommunicationStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommunicationStats(
      contactId: fields[0] as String,
      periodStart: fields[1] as DateTime,
      periodEnd: fields[2] as DateTime,
      totalCalls: fields[3] as int,
      totalMessages: fields[4] as int,
      totalCallDuration: fields[5] as int,
      averageIntimacyScore: fields[6] as double,
      emotionalToneDistribution: (fields[7] as Map).cast<EmotionalTone, int>(),
      communicationFrequency: fields[8] as double,
      topKeywords: (fields[9] as Map).cast<String, int>(),
      isPrivacyMode: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CommunicationStats obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.contactId)
      ..writeByte(1)
      ..write(obj.periodStart)
      ..writeByte(2)
      ..write(obj.periodEnd)
      ..writeByte(3)
      ..write(obj.totalCalls)
      ..writeByte(4)
      ..write(obj.totalMessages)
      ..writeByte(5)
      ..write(obj.totalCallDuration)
      ..writeByte(6)
      ..write(obj.averageIntimacyScore)
      ..writeByte(7)
      ..write(obj.emotionalToneDistribution)
      ..writeByte(8)
      ..write(obj.communicationFrequency)
      ..writeByte(9)
      ..write(obj.topKeywords)
      ..writeByte(10)
      ..write(obj.isPrivacyMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunicationStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InteractionTypeAdapter extends TypeAdapter<InteractionType> {
  @override
  final int typeId = 8;

  @override
  InteractionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InteractionType.call;
      case 1:
        return InteractionType.message;
      case 2:
        return InteractionType.chatApp;
      case 3:
        return InteractionType.videoCall;
      case 4:
        return InteractionType.voiceMessage;
      case 5:
        return InteractionType.unknown;
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
      case InteractionType.chatApp:
        writer.writeByte(2);
        break;
      case InteractionType.videoCall:
        writer.writeByte(3);
        break;
      case InteractionType.voiceMessage:
        writer.writeByte(4);
        break;
      case InteractionType.unknown:
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

class CommunicationTypeAdapter extends TypeAdapter<CommunicationType> {
  @override
  final int typeId = 21;

  @override
  CommunicationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CommunicationType.call;
      case 1:
        return CommunicationType.message;
      case 2:
        return CommunicationType.videoCall;
      case 3:
        return CommunicationType.voiceMessage;
      case 4:
        return CommunicationType.unknown;
      default:
        return CommunicationType.call;
    }
  }

  @override
  void write(BinaryWriter writer, CommunicationType obj) {
    switch (obj) {
      case CommunicationType.call:
        writer.writeByte(0);
        break;
      case CommunicationType.message:
        writer.writeByte(1);
        break;
      case CommunicationType.videoCall:
        writer.writeByte(2);
        break;
      case CommunicationType.voiceMessage:
        writer.writeByte(3);
        break;
      case CommunicationType.unknown:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunicationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RelationshipPhaseAdapter extends TypeAdapter<RelationshipPhase> {
  @override
  final int typeId = 20;

  @override
  RelationshipPhase read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RelationshipPhase.initial;
      case 1:
        return RelationshipPhase.building;
      case 2:
        return RelationshipPhase.stable;
      case 3:
        return RelationshipPhase.deepening;
      case 4:
        return RelationshipPhase.distant;
      case 5:
        return RelationshipPhase.reconnecting;
      case 6:
        return RelationshipPhase.unknown;
      default:
        return RelationshipPhase.initial;
    }
  }

  @override
  void write(BinaryWriter writer, RelationshipPhase obj) {
    switch (obj) {
      case RelationshipPhase.initial:
        writer.writeByte(0);
        break;
      case RelationshipPhase.building:
        writer.writeByte(1);
        break;
      case RelationshipPhase.stable:
        writer.writeByte(2);
        break;
      case RelationshipPhase.deepening:
        writer.writeByte(3);
        break;
      case RelationshipPhase.distant:
        writer.writeByte(4);
        break;
      case RelationshipPhase.reconnecting:
        writer.writeByte(5);
        break;
      case RelationshipPhase.unknown:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelationshipPhaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmotionalToneAdapter extends TypeAdapter<EmotionalTone> {
  @override
  final int typeId = 9;

  @override
  EmotionalTone read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EmotionalTone.positive;
      case 1:
        return EmotionalTone.negative;
      case 2:
        return EmotionalTone.neutral;
      case 3:
        return EmotionalTone.concern;
      case 4:
        return EmotionalTone.excitement;
      case 5:
        return EmotionalTone.sadness;
      case 6:
        return EmotionalTone.anger;
      case 7:
        return EmotionalTone.love;
      case 8:
        return EmotionalTone.unknown;
      default:
        return EmotionalTone.positive;
    }
  }

  @override
  void write(BinaryWriter writer, EmotionalTone obj) {
    switch (obj) {
      case EmotionalTone.positive:
        writer.writeByte(0);
        break;
      case EmotionalTone.negative:
        writer.writeByte(1);
        break;
      case EmotionalTone.neutral:
        writer.writeByte(2);
        break;
      case EmotionalTone.concern:
        writer.writeByte(3);
        break;
      case EmotionalTone.excitement:
        writer.writeByte(4);
        break;
      case EmotionalTone.sadness:
        writer.writeByte(5);
        break;
      case EmotionalTone.anger:
        writer.writeByte(6);
        break;
      case EmotionalTone.love:
        writer.writeByte(7);
        break;
      case EmotionalTone.unknown:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmotionalToneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
