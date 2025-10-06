// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactAdapter extends TypeAdapter<Contact> {
  @override
  final int typeId = 1;

  @override
  Contact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Contact(
      id: fields[0] as String,
      displayName: fields[1] as String,
      phoneNumbers: (fields[2] as List).cast<String>(),
      emails: (fields[3] as List).cast<String>(),
      profilePicture: fields[4] as String?,
      lastContacted: fields[5] as DateTime?,
      firstMet: fields[6] as DateTime?,
      totalCalls: fields[7] as int,
      totalMessages: fields[8] as int,
      callsInitiatedByMe: fields[9] as int,
      messagesInitiatedByMe: fields[10] as int,
      averageResponseTime: fields[11] as double,
      specialDates: (fields[12] as List).cast<DateTime>(),
      emotionalScore: fields[13] as EmotionalScore,
      emotionalScoreValue: fields[14] as double,
      lastAnalyzed: fields[15] as DateTime?,
      metadata: (fields[16] as Map).cast<String, dynamic>(),
      tags: (fields[17] as List).cast<String>(),
      notes: fields[18] as String?,
      isFavorite: fields[19] as bool,
      status: fields[20] as ContactStatus,
    );
  }

  @override
  void write(BinaryWriter writer, Contact obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.phoneNumbers)
      ..writeByte(3)
      ..write(obj.emails)
      ..writeByte(4)
      ..write(obj.profilePicture)
      ..writeByte(5)
      ..write(obj.lastContacted)
      ..writeByte(6)
      ..write(obj.firstMet)
      ..writeByte(7)
      ..write(obj.totalCalls)
      ..writeByte(8)
      ..write(obj.totalMessages)
      ..writeByte(9)
      ..write(obj.callsInitiatedByMe)
      ..writeByte(10)
      ..write(obj.messagesInitiatedByMe)
      ..writeByte(11)
      ..write(obj.averageResponseTime)
      ..writeByte(12)
      ..write(obj.specialDates)
      ..writeByte(13)
      ..write(obj.emotionalScore)
      ..writeByte(14)
      ..write(obj.emotionalScoreValue)
      ..writeByte(15)
      ..write(obj.lastAnalyzed)
      ..writeByte(16)
      ..write(obj.metadata)
      ..writeByte(17)
      ..write(obj.tags)
      ..writeByte(18)
      ..write(obj.notes)
      ..writeByte(19)
      ..write(obj.isFavorite)
      ..writeByte(20)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ContactStatusAdapter extends TypeAdapter<ContactStatus> {
  @override
  final int typeId = 2;

  @override
  ContactStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ContactStatus.active;
      case 1:
        return ContactStatus.inactive;
      case 2:
        return ContactStatus.blocked;
      case 3:
        return ContactStatus.archived;
      default:
        return ContactStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, ContactStatus obj) {
    switch (obj) {
      case ContactStatus.active:
        writer.writeByte(0);
        break;
      case ContactStatus.inactive:
        writer.writeByte(1);
        break;
      case ContactStatus.blocked:
        writer.writeByte(2);
        break;
      case ContactStatus.archived:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
