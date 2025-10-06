// lib/models/contact_interaction.dart
import 'package:hive/hive.dart';

part 'contact_interaction.g.dart';

@HiveType(typeId: 3)
class ContactInteraction extends HiveObject {
  @HiveField(0)
  String contactId;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  InteractionType type;

  @HiveField(3)
  int duration; // in seconds for calls, 0 for messages

  @HiveField(4)
  bool initiatedByMe;

  @HiveField(5)
  String? content; // message content (for sentiment analysis)

  @HiveField(6)
  double? sentimentScore; // -1 to 1 (negative to positive)

  @HiveField(7)
  Map<String, dynamic> metadata;

  ContactInteraction({
    required this.contactId,
    required this.timestamp,
    required this.type,
    this.duration = 0,
    this.initiatedByMe = false,
    this.content,
    this.sentimentScore,
    this.metadata = const <String, dynamic>{},
  });

  Map<String, dynamic> toJson() => {
        'contactId': contactId,
        'timestamp': timestamp.toIso8601String(),
        'type': type.toString(),
        'duration': duration,
        'initiatedByMe': initiatedByMe,
        'content': content,
        'sentimentScore': sentimentScore,
        'metadata': metadata,
      };
}

@HiveType(typeId: 4)
enum InteractionType {
  @HiveField(0)
  call,

  @HiveField(1)
  message,

  @HiveField(2)
  email,

  @HiveField(3)
  whatsapp,

  @HiveField(4)
  videoCall,

  @HiveField(5)
  meeting,
}

@HiveType(typeId: 5)
enum EmotionalScore {
  @HiveField(0)
  veryWarm,

  @HiveField(1)
  friendlyButFading,

  @HiveField(2)
  cold,
}
