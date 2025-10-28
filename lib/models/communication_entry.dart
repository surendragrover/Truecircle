import 'package:hive/hive.dart';

part 'communication_entry.g.dart';

@HiveType(typeId: 12)
class CommunicationEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String contactId;

  @HiveField(2)
  final DateTime conversationDate;

  @HiveField(3)
  final String conversationType; // 'in_person', 'phone_call', 'text_message', 'video_call'

  @HiveField(4)
  final int conversationDuration; // in minutes

  @HiveField(5)
  final int overallQuality; // 1-10 scale

  @HiveField(6)
  final int emotionalState; // 1-10 scale (1=very negative, 10=very positive)

  @HiveField(7)
  final int loveLevel; // 1-10 how much you care about them

  @HiveField(8)
  final int perceivedLoveLevel; // 1-10 how much they care about you

  @HiveField(9)
  final bool hadConflict;

  @HiveField(10)
  final String? conflictReason;

  @HiveField(11)
  final int conflictSeverity; // 1-10 scale if had conflict

  @HiveField(12)
  final bool hadSpecialMoment;

  @HiveField(13)
  final String? specialMomentDescription;

  @HiveField(14)
  final int relationshipImpact; // -5 to +5 (-5=very negative impact, +5=very positive)

  @HiveField(15)
  final List<String> topicsDiscussed;

  @HiveField(16)
  final String conversationSummary;

  @HiveField(17)
  final List<String> emotionsExperienced;

  @HiveField(18)
  final int trustLevel; // 1-10 current trust level

  @HiveField(19)
  final int intimacyLevel; // 1-10 emotional closeness

  @HiveField(20)
  final String? concernsOrWorries;

  @HiveField(21)
  final List<String> positiveAspects;

  @HiveField(22)
  final List<String> improvementAreas;

  @HiveField(23)
  final DateTime createdAt;

  CommunicationEntry({
    required this.id,
    required this.contactId,
    required this.conversationDate,
    required this.conversationType,
    required this.conversationDuration,
    required this.overallQuality,
    required this.emotionalState,
    required this.loveLevel,
    required this.perceivedLoveLevel,
    required this.hadConflict,
    this.conflictReason,
    required this.conflictSeverity,
    required this.hadSpecialMoment,
    this.specialMomentDescription,
    required this.relationshipImpact,
    required this.topicsDiscussed,
    required this.conversationSummary,
    required this.emotionsExperienced,
    required this.trustLevel,
    required this.intimacyLevel,
    this.concernsOrWorries,
    required this.positiveAspects,
    required this.improvementAreas,
    required this.createdAt,
  });

  factory CommunicationEntry.fromJson(Map<String, dynamic> json) {
    return CommunicationEntry(
      id: json['id'] ?? '',
      contactId: json['contactId'] ?? '',
      conversationDate:
          DateTime.tryParse(json['conversationDate'] ?? '') ?? DateTime.now(),
      conversationType: json['conversationType'] ?? 'in_person',
      conversationDuration: json['conversationDuration'] ?? 0,
      overallQuality: json['overallQuality'] ?? 5,
      emotionalState: json['emotionalState'] ?? 5,
      loveLevel: json['loveLevel'] ?? 5,
      perceivedLoveLevel: json['perceivedLoveLevel'] ?? 5,
      hadConflict: json['hadConflict'] ?? false,
      conflictReason: json['conflictReason'],
      conflictSeverity: json['conflictSeverity'] ?? 0,
      hadSpecialMoment: json['hadSpecialMoment'] ?? false,
      specialMomentDescription: json['specialMomentDescription'],
      relationshipImpact: json['relationshipImpact'] ?? 0,
      topicsDiscussed: List<String>.from(json['topicsDiscussed'] ?? []),
      conversationSummary: json['conversationSummary'] ?? '',
      emotionsExperienced: List<String>.from(json['emotionsExperienced'] ?? []),
      trustLevel: json['trustLevel'] ?? 5,
      intimacyLevel: json['intimacyLevel'] ?? 5,
      concernsOrWorries: json['concernsOrWorries'],
      positiveAspects: List<String>.from(json['positiveAspects'] ?? []),
      improvementAreas: List<String>.from(json['improvementAreas'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactId': contactId,
      'conversationDate': conversationDate.toIso8601String(),
      'conversationType': conversationType,
      'conversationDuration': conversationDuration,
      'overallQuality': overallQuality,
      'emotionalState': emotionalState,
      'loveLevel': loveLevel,
      'perceivedLoveLevel': perceivedLoveLevel,
      'hadConflict': hadConflict,
      'conflictReason': conflictReason,
      'conflictSeverity': conflictSeverity,
      'hadSpecialMoment': hadSpecialMoment,
      'specialMomentDescription': specialMomentDescription,
      'relationshipImpact': relationshipImpact,
      'topicsDiscussed': topicsDiscussed,
      'conversationSummary': conversationSummary,
      'emotionsExperienced': emotionsExperienced,
      'trustLevel': trustLevel,
      'intimacyLevel': intimacyLevel,
      'concernsOrWorries': concernsOrWorries,
      'positiveAspects': positiveAspects,
      'improvementAreas': improvementAreas,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
