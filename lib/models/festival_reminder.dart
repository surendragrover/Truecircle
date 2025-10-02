import 'package:hive/hive.dart';

part 'festival_reminder.g.dart';

/// Festival Reminder model for Hive storage
/// Stores festival reminder data with cultural context
@HiveType(typeId: 10)
class FestivalReminder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String festivalName;

  @HiveField(2)
  String festivalNameHindi;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String description;

  @HiveField(5)
  String culturalSignificance;

  @HiveField(6)
  List<String> traditions;

  @HiveField(7)
  bool isEnabled;

  @HiveField(8)
  DateTime? lastNotified;

  @HiveField(9)
  String emoji;

  @HiveField(10)
  String region; // North India, South India, All India

  @HiveField(11)
  int priority; // 1 = High, 2 = Medium, 3 = Low

  @HiveField(12)
  Map<String, dynamic>? customSettings;

  FestivalReminder({
    required this.id,
    required this.festivalName,
    required this.festivalNameHindi,
    required this.date,
    required this.description,
    required this.culturalSignificance,
    required this.traditions,
    this.isEnabled = true,
    this.lastNotified,
    this.emoji = '🎊',
    this.region = 'All India',
    this.priority = 2,
    this.customSettings,
  });

  /// Check if festival is upcoming (within next 30 days)
  bool get isUpcoming {
    final now = DateTime.now();
    final daysUntil = date.difference(now).inDays;
    return daysUntil >= 0 && daysUntil <= 30;
  }

  /// Check if festival is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get days until festival
  int get daysUntil {
    final now = DateTime.now();
    return date.difference(now).inDays;
  }

  /// Get formatted date string
  String get formattedDate {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Get Hindi month names
  String get formattedDateHindi {
    final hindiMonths = [
      'जनवरी',
      'फरवरी',
      'मार्च',
      'अप्रैल',
      'मई',
      'जून',
      'जुलाई',
      'अगस्त',
      'सितंबर',
      'अक्टूबर',
      'नवंबर',
      'दिसंबर'
    ];
    return '${date.day} ${hindiMonths[date.month - 1]} ${date.year}';
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

  /// Get priority color
  int get priorityColor {
    switch (priority) {
      case 1:
        return 0xFFE57373; // Red
      case 2:
        return 0xFFFFB74D; // Orange
      case 3:
        return 0xFF81C784; // Green
      default:
        return 0xFFFFB74D;
    }
  }

  /// Create a copy with updated fields
  FestivalReminder copyWith({
    String? id,
    String? festivalName,
    String? festivalNameHindi,
    DateTime? date,
    String? description,
    String? culturalSignificance,
    List<String>? traditions,
    bool? isEnabled,
    DateTime? lastNotified,
    String? emoji,
    String? region,
    int? priority,
    Map<String, dynamic>? customSettings,
  }) {
    return FestivalReminder(
      id: id ?? this.id,
      festivalName: festivalName ?? this.festivalName,
      festivalNameHindi: festivalNameHindi ?? this.festivalNameHindi,
      date: date ?? this.date,
      description: description ?? this.description,
      culturalSignificance: culturalSignificance ?? this.culturalSignificance,
      traditions: traditions ?? this.traditions,
      isEnabled: isEnabled ?? this.isEnabled,
      lastNotified: lastNotified ?? this.lastNotified,
      emoji: emoji ?? this.emoji,
      region: region ?? this.region,
      priority: priority ?? this.priority,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  @override
  String toString() {
    return 'FestivalReminder{id: $id, festivalName: $festivalName, date: $date, isEnabled: $isEnabled}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FestivalReminder &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
