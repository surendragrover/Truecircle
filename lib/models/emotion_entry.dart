import 'package:hive/hive.dart';

part 'emotion_entry.g.dart';

@HiveType(typeId: 0)
class EmotionEntry extends HiveObject {
  @HiveField(0)
  DateTime timestamp;

  @HiveField(1)
  String emotion;

  @HiveField(2)
  int intensity;

  @HiveField(3)
  String? note;

  EmotionEntry({
    required this.timestamp,
    required this.emotion,
    required this.intensity,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'emotion': emotion,
        'intensity': intensity,
        'note': note,
      };
}
