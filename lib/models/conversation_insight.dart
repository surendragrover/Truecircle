import 'package:hive/hive.dart';

part 'conversation_insight.g.dart';

@HiveType(typeId: 14)
class ConversationInsight extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String contactId;

  @HiveField(2)
  final String insightType; // 'warning', 'improvement', 'celebration', 'suggestion'

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final List<String> recommendations;

  @HiveField(6)
  final int priority; // 1-10 scale (10 = urgent attention needed)

  @HiveField(7)
  final Map<String, dynamic> analysisData;

  @HiveField(8)
  final List<String> relatedEntryIds;

  @HiveField(9)
  final bool isRead;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime? resolvedAt;

  ConversationInsight({
    required this.id,
    required this.contactId,
    required this.insightType,
    required this.title,
    required this.description,
    required this.recommendations,
    required this.priority,
    required this.analysisData,
    required this.relatedEntryIds,
    required this.isRead,
    required this.createdAt,
    this.resolvedAt,
  });

  factory ConversationInsight.fromJson(Map<String, dynamic> json) {
    return ConversationInsight(
      id: json['id'] ?? '',
      contactId: json['contactId'] ?? '',
      insightType: json['insightType'] ?? 'suggestion',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
      priority: json['priority'] ?? 1,
      analysisData: Map<String, dynamic>.from(json['analysisData'] ?? {}),
      relatedEntryIds: List<String>.from(json['relatedEntryIds'] ?? []),
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactId': contactId,
      'insightType': insightType,
      'title': title,
      'description': description,
      'recommendations': recommendations,
      'priority': priority,
      'analysisData': analysisData,
      'relatedEntryIds': relatedEntryIds,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  ConversationInsight copyWith({
    String? insightType,
    String? title,
    String? description,
    List<String>? recommendations,
    int? priority,
    Map<String, dynamic>? analysisData,
    List<String>? relatedEntryIds,
    bool? isRead,
    DateTime? resolvedAt,
  }) {
    return ConversationInsight(
      id: id,
      contactId: contactId,
      insightType: insightType ?? this.insightType,
      title: title ?? this.title,
      description: description ?? this.description,
      recommendations: recommendations ?? this.recommendations,
      priority: priority ?? this.priority,
      analysisData: analysisData ?? this.analysisData,
      relatedEntryIds: relatedEntryIds ?? this.relatedEntryIds,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
