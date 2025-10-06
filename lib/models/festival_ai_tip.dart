import 'package:hive/hive.dart';

part 'festival_ai_tip.g.dart';

/// Festival AI Tip types
enum FestivalTipType {
  message,
  gift,
  decoration,
  food,
  ritual,
  general,
}

/// Festival AI Tip model for Hive storage
/// Stores AI-generated tips and suggestions for festivals
@HiveType(typeId: 11)
class FestivalAITip extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String festivalId;

  @HiveField(2)
  String festivalName;

  @HiveField(3)
  @HiveField(4, defaultValue: FestivalTipType.general)
  FestivalTipType tipType;

  @HiveField(4)
  String title;

  @HiveField(5)
  String titleHindi;

  @HiveField(6)
  String content;

  @HiveField(7)
  String contentHindi;

  @HiveField(8)
  String? emoji;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  bool isEnabled;

  @HiveField(11)
  int priority; // 1 = High, 2 = Medium, 3 = Low

  @HiveField(12)
  List<String>? tags;

  @HiveField(13)
  String? category; // For gifts: "Dry Fruits", "Sweets", etc.

  @HiveField(14)
  double? price; // For gift suggestions

  @HiveField(15)
  String? culturalContext;

  @HiveField(16)
  Map<String, dynamic>? metadata;

  FestivalAITip({
    required this.id,
    required this.festivalId,
    required this.festivalName,
    required this.tipType,
    required this.title,
    required this.titleHindi,
    required this.content,
    required this.contentHindi,
    this.emoji,
    DateTime? createdAt,
    this.isEnabled = true,
    this.priority = 2,
    this.tags,
    this.category,
    this.price,
    this.culturalContext,
    this.metadata,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Get tip type display name
  String get tipTypeDisplayName {
    switch (tipType) {
      case FestivalTipType.message:
        return 'Message';
      case FestivalTipType.gift:
        return 'Gift';
      case FestivalTipType.decoration:
        return 'Decoration';
      case FestivalTipType.food:
        return 'Food';
      case FestivalTipType.ritual:
        return 'Ritual';
      case FestivalTipType.general:
        return 'General';
    }
  }

  /// Get tip type emoji
  String get tipTypeEmoji {
    switch (tipType) {
      case FestivalTipType.message:
        return '💬';
      case FestivalTipType.gift:
        return '🎁';
      case FestivalTipType.decoration:
        return '🎨';
      case FestivalTipType.food:
        return '🍽️';
      case FestivalTipType.ritual:
        return '🙏';
      case FestivalTipType.general:
        return '💡';
    }
  }

  /// Get formatted price
  String get formattedPrice {
    if (price == null) return '';
    return '₹${price!.toStringAsFixed(0)}';
  }

  /// Get priority text
  String get priorityText {
    switch (priority) {
      case 1:
        return 'High Priority';
      case 2:
        return 'Medium Priority';
      case 3:
        return 'Low Priority';
      default:
        return 'Medium Priority';
    }
  }

  /// Check if this tip is for gifts
  bool get isGiftTip => tipType == FestivalTipType.gift;

  /// Check if this tip is for messages
  bool get isMessageTip => tipType == FestivalTipType.message;

  /// Get display emoji (custom or type-based)
  String get displayEmoji => emoji ?? tipTypeEmoji;

  /// Create a copy with updated fields
  FestivalAITip copyWith({
    String? id,
    String? festivalId,
    String? festivalName,
    FestivalTipType? tipType,
    String? title,
    String? titleHindi,
    String? content,
    String? contentHindi,
    String? emoji,
    DateTime? createdAt,
    bool? isEnabled,
    int? priority,
    List<String>? tags,
    String? category,
    double? price,
    String? culturalContext,
    Map<String, dynamic>? metadata,
  }) {
    return FestivalAITip(
      id: id ?? this.id,
      festivalId: festivalId ?? this.festivalId,
      festivalName: festivalName ?? this.festivalName,
      tipType: tipType ?? this.tipType,
      title: title ?? this.title,
      titleHindi: titleHindi ?? this.titleHindi,
      content: content ?? this.content,
      contentHindi: contentHindi ?? this.contentHindi,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      isEnabled: isEnabled ?? this.isEnabled,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      price: price ?? this.price,
      culturalContext: culturalContext ?? this.culturalContext,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'FestivalAITip{id: $id, festivalName: $festivalName, tipType: $tipType, title: $title}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FestivalAITip &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Hive adapter for FestivalTipType enum
@HiveType(typeId: 12)
enum FestivalTipTypeAdapter {
  @HiveField(0)
  message,
  @HiveField(1)
  gift,
  @HiveField(2)
  decoration,
  @HiveField(3)
  food,
  @HiveField(4)
  ritual,
  @HiveField(5)
  general,
}
