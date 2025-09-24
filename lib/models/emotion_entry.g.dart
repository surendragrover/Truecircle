// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emotion_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmotionEntryAdapter extends TypeAdapter<EmotionEntry> {
  @override
  final int typeId = 0;

  @override
  EmotionEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmotionEntry(
      timestamp: fields[0] as DateTime,
      emotion: fields[1] as String,
      intensity: fields[2] as int,
      note: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EmotionEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.emotion)
      ..writeByte(2)
      ..write(obj.intensity)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmotionEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
