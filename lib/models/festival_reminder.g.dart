// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'festival_reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FestivalReminderAdapter extends TypeAdapter<FestivalReminder> {
  @override
  final int typeId = 10;

  @override
  FestivalReminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FestivalReminder(
      id: fields[0] as String,
      festivalName: fields[1] as String,
      festivalNameHindi: fields[2] as String,
      date: fields[3] as DateTime,
      description: fields[4] as String,
      culturalSignificance: fields[5] as String,
      traditions: (fields[6] as List).cast<String>(),
      isEnabled: fields[7] as bool,
      lastNotified: fields[8] as DateTime?,
      emoji: fields[9] as String,
      region: fields[10] as String,
      priority: fields[11] as int,
      customSettings: (fields[12] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, FestivalReminder obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.festivalName)
      ..writeByte(2)
      ..write(obj.festivalNameHindi)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.culturalSignificance)
      ..writeByte(6)
      ..write(obj.traditions)
      ..writeByte(7)
      ..write(obj.isEnabled)
      ..writeByte(8)
      ..write(obj.lastNotified)
      ..writeByte(9)
      ..write(obj.emoji)
      ..writeByte(10)
      ..write(obj.region)
      ..writeByte(11)
      ..write(obj.priority)
      ..writeByte(12)
      ..write(obj.customSettings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FestivalReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
