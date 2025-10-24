import 'package:hive/hive.dart';

@HiveType(typeId: 70)
enum EAOccurrenceType { regular, specific }

@HiveType(typeId: 71)
class EmotionalAwarenessSelection extends HiveObject {
  @HiveField(0)
  String id; // stable key (hash of question text or provided id+index)

  @HiveField(1)
  String question;

  @HiveField(2)
  EAOccurrenceType occurrence;

  @HiveField(3)
  DateTime updatedAt;

  EmotionalAwarenessSelection({
    required this.id,
    required this.question,
    required this.occurrence,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();
}

// Manual Hive adapters (to avoid build_runner)
class EAOccurrenceTypeAdapter extends TypeAdapter<EAOccurrenceType> {
  @override
  final int typeId = 70;

  @override
  EAOccurrenceType read(BinaryReader reader) {
    final value = reader.readByte();
    switch (value) {
      case 0:
        return EAOccurrenceType.regular;
      case 1:
        return EAOccurrenceType.specific;
      default:
        return EAOccurrenceType.regular;
    }
  }

  @override
  void write(BinaryWriter writer, EAOccurrenceType obj) {
    switch (obj) {
      case EAOccurrenceType.regular:
        writer.writeByte(0);
        break;
      case EAOccurrenceType.specific:
        writer.writeByte(1);
        break;
    }
  }
}

class EmotionalAwarenessSelectionAdapter
    extends TypeAdapter<EmotionalAwarenessSelection> {
  @override
  final int typeId = 71;

  @override
  EmotionalAwarenessSelection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return EmotionalAwarenessSelection(
      id: fields[0] as String,
      question: fields[1] as String,
      occurrence: fields[2] as EAOccurrenceType,
      updatedAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, EmotionalAwarenessSelection obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.occurrence)
      ..writeByte(3)
      ..write(obj.updatedAt);
  }
}
