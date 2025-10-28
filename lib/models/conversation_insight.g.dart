// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_insight.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationInsightAdapter extends TypeAdapter<ConversationInsight> {
  @override
  final int typeId = 14;

  @override
  ConversationInsight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationInsight(
      id: fields[0] as String,
      contactId: fields[1] as String,
      insightType: fields[2] as String,
      title: fields[3] as String,
      description: fields[4] as String,
      recommendations: (fields[5] as List).cast<String>(),
      priority: fields[6] as int,
      analysisData: (fields[7] as Map).cast<String, dynamic>(),
      relatedEntryIds: (fields[8] as List).cast<String>(),
      isRead: fields[9] as bool,
      createdAt: fields[10] as DateTime,
      resolvedAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationInsight obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.contactId)
      ..writeByte(2)
      ..write(obj.insightType)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.recommendations)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.analysisData)
      ..writeByte(8)
      ..write(obj.relatedEntryIds)
      ..writeByte(9)
      ..write(obj.isRead)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.resolvedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationInsightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
