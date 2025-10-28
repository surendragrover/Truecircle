import 'package:hive/hive.dart';

part 'relationship_contact.g.dart';

@HiveType(typeId: 13)
class RelationshipContact extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String relationship; // 'family', 'friend', 'romantic_partner', 'neighbor', 'relative', 'colleague'

  @HiveField(3)
  final String? avatarPath;

  @HiveField(4)
  final String? phoneNumber;

  @HiveField(5)
  final int importance; // 1-10 scale of importance in your life

  @HiveField(6)
  final int currentRelationshipStrength; // 1-10 scale

  @HiveField(7)
  final List<String> personalityTraits;

  @HiveField(8)
  final String? notes;

  @HiveField(9)
  final DateTime? lastInteractionDate;

  @HiveField(10)
  final int interactionFrequency; // days between typical interactions

  @HiveField(11)
  final List<String> commonInterests;

  @HiveField(12)
  final List<String> communicationPreferences; // 'text', 'call', 'in_person', 'video_call'

  @HiveField(13)
  final Map<String, int> relationshipHistory; // date -> strength rating

  @HiveField(14)
  final bool isPriority; // for close family/romantic partners

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  final DateTime updatedAt;

  // Getter methods for compatibility with existing code
  int get relationshipStrength => currentRelationshipStrength;
  int get importanceLevel => importance;
  String? get email => phoneNumber; // Using phoneNumber as email placeholder
  List<String> get preferredCommunication => communicationPreferences;
  List<String> get interests => commonInterests;

  RelationshipContact({
    required this.id,
    required this.name,
    required this.relationship,
    this.avatarPath,
    this.phoneNumber,
    required this.importance,
    required this.currentRelationshipStrength,
    required this.personalityTraits,
    this.notes,
    this.lastInteractionDate,
    required this.interactionFrequency,
    required this.commonInterests,
    required this.communicationPreferences,
    required this.relationshipHistory,
    required this.isPriority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RelationshipContact.fromJson(Map<String, dynamic> json) {
    return RelationshipContact(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? 'friend',
      avatarPath: json['avatarPath'],
      phoneNumber: json['phoneNumber'],
      importance: json['importance'] ?? 5,
      currentRelationshipStrength: json['currentRelationshipStrength'] ?? 5,
      personalityTraits: List<String>.from(json['personalityTraits'] ?? []),
      notes: json['notes'],
      lastInteractionDate: json['lastInteractionDate'] != null
          ? DateTime.tryParse(json['lastInteractionDate'])
          : null,
      interactionFrequency: json['interactionFrequency'] ?? 7,
      commonInterests: List<String>.from(json['commonInterests'] ?? []),
      communicationPreferences: List<String>.from(
        json['communicationPreferences'] ?? [],
      ),
      relationshipHistory: Map<String, int>.from(
        json['relationshipHistory'] ?? {},
      ),
      isPriority: json['isPriority'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'avatarPath': avatarPath,
      'phoneNumber': phoneNumber,
      'importance': importance,
      'currentRelationshipStrength': currentRelationshipStrength,
      'personalityTraits': personalityTraits,
      'notes': notes,
      'lastInteractionDate': lastInteractionDate?.toIso8601String(),
      'interactionFrequency': interactionFrequency,
      'commonInterests': commonInterests,
      'communicationPreferences': communicationPreferences,
      'relationshipHistory': relationshipHistory,
      'isPriority': isPriority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  RelationshipContact copyWith({
    String? name,
    String? relationship,
    String? avatarPath,
    String? phoneNumber,
    int? importance,
    int? currentRelationshipStrength,
    List<String>? personalityTraits,
    String? notes,
    DateTime? lastInteractionDate,
    int? interactionFrequency,
    List<String>? commonInterests,
    List<String>? communicationPreferences,
    Map<String, int>? relationshipHistory,
    bool? isPriority,
  }) {
    return RelationshipContact(
      id: id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      avatarPath: avatarPath ?? this.avatarPath,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      importance: importance ?? this.importance,
      currentRelationshipStrength:
          currentRelationshipStrength ?? this.currentRelationshipStrength,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      notes: notes ?? this.notes,
      lastInteractionDate: lastInteractionDate ?? this.lastInteractionDate,
      interactionFrequency: interactionFrequency ?? this.interactionFrequency,
      commonInterests: commonInterests ?? this.commonInterests,
      communicationPreferences:
          communicationPreferences ?? this.communicationPreferences,
      relationshipHistory: relationshipHistory ?? this.relationshipHistory,
      isPriority: isPriority ?? this.isPriority,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
