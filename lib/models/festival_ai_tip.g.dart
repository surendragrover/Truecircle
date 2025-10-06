// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'festival_ai_tip.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FestivalAITipAdapter extends TypeAdapter<FestivalAITip> {
  @override
  final int typeId = 11;

  @override
  FestivalAITip read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FestivalAITip(
      id: fields[0] as String,
      festivalId: fields[1] as String,
      festivalName: fields[2] as String,
      tipType: fields[3] as FestivalTipType,
      title: fields[4] as String,
      titleHindi: fields[5] as String,
      content: fields[6] as String,
      contentHindi: fields[7] as String,
      emoji: fields[8] as String?,
      createdAt: fields[9] as DateTime?,
      isEnabled: fields[10] as bool,
      priority: fields[11] as int,
      tags: (fields[12] as List?)?.cast<String>(),
      category: fields[13] as String?,
      price: fields[14] as double?,
      culturalContext: fields[15] as String?,
      metadata: (fields[16] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, FestivalAITip obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.festivalId)
      ..writeByte(2)
      ..write(obj.festivalName)
      ..writeByte(3)
      ..write(obj.tipType)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.titleHindi)
      ..writeByte(6)
      ..write(obj.content)
      ..writeByte(7)
      ..write(obj.contentHindi)
      ..writeByte(8)
      ..write(obj.emoji)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.isEnabled)
      ..writeByte(11)
      ..write(obj.priority)
      ..writeByte(12)
      ..write(obj.tags)
      ..writeByte(13)
      ..write(obj.category)
      ..writeByte(14)
      ..write(obj.price)
      ..writeByte(15)
      ..write(obj.culturalContext)
      ..writeByte(16)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FestivalAITipAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FestivalTipTypeAdapterAdapter
    extends TypeAdapter<FestivalTipTypeAdapter> {
  @override
  final int typeId = 12;

  @override
  FestivalTipTypeAdapter read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FestivalTipTypeAdapter.message;
      case 1:
        return FestivalTipTypeAdapter.gift;
      case 2:
        return FestivalTipTypeAdapter.decoration;
      case 3:
        return FestivalTipTypeAdapter.food;
      case 4:
        return FestivalTipTypeAdapter.ritual;
      case 5:
        return FestivalTipTypeAdapter.general;
      default:
        return FestivalTipTypeAdapter.message;
    }
  }

  @override
  void write(BinaryWriter writer, FestivalTipTypeAdapter obj) {
    switch (obj) {
      case FestivalTipTypeAdapter.message:
        writer.writeByte(0);
        break;
      case FestivalTipTypeAdapter.gift:
        writer.writeByte(1);
        break;
      case FestivalTipTypeAdapter.decoration:
        writer.writeByte(2);
        break;
      case FestivalTipTypeAdapter.food:
        writer.writeByte(3);
        break;
      case FestivalTipTypeAdapter.ritual:
        writer.writeByte(4);
        break;
      case FestivalTipTypeAdapter.general:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FestivalTipTypeAdapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
