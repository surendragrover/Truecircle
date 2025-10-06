import 'package:hive/hive.dart';
import 'contact_interaction.dart';

part 'contact.g.dart';

@HiveType(typeId: 1)
class Contact extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String displayName;

  @HiveField(2)
  List<String> phoneNumbers;

  @HiveField(3)
  List<String> emails;

  @HiveField(4)
  String? profilePicture;

  @HiveField(5)
  DateTime? lastContacted;

  @HiveField(6)
  DateTime? firstMet;

  @HiveField(7)
  int totalCalls;

  @HiveField(8)
  int totalMessages;

  @HiveField(9)
  int callsInitiatedByMe;

  @HiveField(10)
  int messagesInitiatedByMe;

  @HiveField(11)
  double averageResponseTime; // in hours

  @HiveField(12)
  List<DateTime> specialDates; // birthdays, anniversaries etc

  @HiveField(13)
  EmotionalScore emotionalScore;

  @HiveField(14)
  double emotionalScoreValue; // 0-100

  @HiveField(15)
  DateTime lastAnalyzed;

  @HiveField(16)
  Map<String, dynamic> metadata; // For additional AI insights

  @HiveField(17)
  List<String> tags; // Family, Friend, Work, etc

  @HiveField(18)
  String? notes; // User notes about this person

  @HiveField(19)
  bool isFavorite;

  @HiveField(20)
  ContactStatus status;

  Contact({
    required this.id,
    required this.displayName,
    this.phoneNumbers = const <String>[],
    this.emails = const <String>[],
    this.profilePicture,
    this.lastContacted,
    this.firstMet,
    this.totalCalls = 0,
    this.totalMessages = 0,
    this.callsInitiatedByMe = 0,
    this.messagesInitiatedByMe = 0,
    this.averageResponseTime = 0.0,
    this.specialDates = const <DateTime>[],
    this.emotionalScore = EmotionalScore.friendlyButFading,
    this.emotionalScoreValue = 50.0,
    DateTime? lastAnalyzed,
    this.metadata = const <String, dynamic>{},
    this.tags = const <String>[],
    this.notes,
    this.isFavorite = false,
    this.status = ContactStatus.active,
  }) : lastAnalyzed = lastAnalyzed ?? DateTime.now();

  // Calculated properties
  int get daysSinceLastContact {
    if (lastContacted == null) return 9999;
    return DateTime.now().difference(lastContacted!).inDays;
  }

  double get mutualityScore {
    if (totalCalls == 0 && totalMessages == 0) return 0.0;

    final totalInteractions = totalCalls + totalMessages;
    final myInitiations = callsInitiatedByMe + messagesInitiatedByMe;

    if (totalInteractions == 0) return 0.0;

    final myInitiationRatio = myInitiations / totalInteractions;
    // Perfect mutuality is 0.5 (50-50), deviation from this reduces score
    return 1.0 - (myInitiationRatio - 0.5).abs() * 2;
  }

  int get interactionFrequency {
    if (firstMet == null) return 0;

    final daysSinceFirstMet = DateTime.now().difference(firstMet!).inDays;
    if (daysSinceFirstMet == 0) return totalCalls + totalMessages;

    return ((totalCalls + totalMessages) / daysSinceFirstMet * 30)
        .round(); // per month
  }

  bool get isResponseTimely {
    return averageResponseTime <= 24.0; // responds within a day
  }

  bool get remembersSpecialDates {
    // This would be calculated based on interaction patterns around special dates
    return specialDates.isNotEmpty && metadata['remembers_dates'] == true;
  }

  String get emotionalScoreEmoji {
    switch (emotionalScore) {
      case EmotionalScore.veryWarm:
        return '💙';
      case EmotionalScore.friendlyButFading:
        return '💛';
      case EmotionalScore.cold:
        return '🖤';
    }
  }

  String get emotionalScoreDescription {
    switch (emotionalScore) {
      case EmotionalScore.veryWarm:
        return 'बहुत नज़दीकी / Very Close';
      case EmotionalScore.friendlyButFading:
        return 'दोस्ताना लेकिन कम होता जा रहा / Friendly but Fading';
      case EmotionalScore.cold:
        return 'ठंडा रिश्ता / Emotionally Distant';
    }
  }

  // AI Insights
  List<String> get aiInsights {
    List<String> insights = [];

    if (daysSinceLastContact > 30) {
      insights.add('लंबे समय से संपर्क नहीं हुआ / No contact for a long time');
    }

    if (mutualityScore < 0.3) {
      insights.add('एकतरफा बातचीत / One-sided communication');
    }

    if (averageResponseTime > 48) {
      insights.add('देर से जवाब देते हैं / Slow to respond');
    }

    if (interactionFrequency < 2) {
      insights.add('कम बातचीत / Low interaction frequency');
    }

    return insights;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'phoneNumbers': phoneNumbers,
        'emails': emails,
        'profilePicture': profilePicture,
        'lastContacted': lastContacted?.toIso8601String(),
        'firstMet': firstMet?.toIso8601String(),
        'totalCalls': totalCalls,
        'totalMessages': totalMessages,
        'callsInitiatedByMe': callsInitiatedByMe,
        'messagesInitiatedByMe': messagesInitiatedByMe,
        'averageResponseTime': averageResponseTime,
        'specialDates': specialDates.map((d) => d.toIso8601String()).toList(),
        'emotionalScore': emotionalScore.toString(),
        'emotionalScoreValue': emotionalScoreValue,
        'lastAnalyzed': lastAnalyzed.toIso8601String(),
        'metadata': metadata,
        'tags': tags,
        'notes': notes,
        'isFavorite': isFavorite,
        'status': status.toString(),
      };

  // Create a copy with updated values
  Contact copyWith({
    String? displayName,
    List<String>? phoneNumbers,
    List<String>? emails,
    String? profilePicture,
    DateTime? lastContacted,
    DateTime? firstMet,
    int? totalCalls,
    int? totalMessages,
    int? callsInitiatedByMe,
    int? messagesInitiatedByMe,
    double? averageResponseTime,
    List<DateTime>? specialDates,
    EmotionalScore? emotionalScore,
    double? emotionalScoreValue,
    DateTime? lastAnalyzed,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? notes,
    bool? isFavorite,
    ContactStatus? status,
  }) {
    return Contact(
      id: id,
      displayName: displayName ?? this.displayName,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      emails: emails ?? this.emails,
      profilePicture: profilePicture ?? this.profilePicture,
      lastContacted: lastContacted ?? this.lastContacted,
      firstMet: firstMet ?? this.firstMet,
      totalCalls: totalCalls ?? this.totalCalls,
      totalMessages: totalMessages ?? this.totalMessages,
      callsInitiatedByMe: callsInitiatedByMe ?? this.callsInitiatedByMe,
      messagesInitiatedByMe:
          messagesInitiatedByMe ?? this.messagesInitiatedByMe,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      specialDates: specialDates ?? this.specialDates,
      emotionalScore: emotionalScore ?? this.emotionalScore,
      emotionalScoreValue: emotionalScoreValue ?? this.emotionalScoreValue,
      lastAnalyzed: lastAnalyzed ?? this.lastAnalyzed,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      status: status ?? this.status,
    );
  }
}

@HiveType(typeId: 2)
enum ContactStatus {
  @HiveField(0)
  active,

  @HiveField(1)
  inactive,

  @HiveField(2)
  blocked,

  @HiveField(3)
  archived,
}
