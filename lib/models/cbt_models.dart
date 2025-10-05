import 'package:hive/hive.dart';

part 'cbt_models.g.dart';

// Reserve new unique typeIds above existing max (currently 32). Start at 40.

@HiveType(typeId: 40)
class CBTAssessmentResult extends HiveObject {
  @HiveField(0)
  String id; // e.g. depression_phq9_2025_10_04T12:00
  @HiveField(1)
  String assessmentKey; // phq9, gad7, adhd_screener, ed_screener
  @HiveField(2)
  Map<String, int> answers; // questionId -> score
  @HiveField(3)
  int totalScore;
  @HiveField(4)
  DateTime timestamp;
  @HiveField(5)
  String severityBand; // e.g. mild / moderate / severe
  @HiveField(6)
  String localizedSummaryEn;
  @HiveField(7)
  String localizedSummaryHi;

  CBTAssessmentResult({
    required this.id,
    required this.assessmentKey,
    required this.answers,
    required this.totalScore,
    required this.timestamp,
    required this.severityBand,
    required this.localizedSummaryEn,
    required this.localizedSummaryHi,
  });
}

@HiveType(typeId: 41)
class CBTThoughtRecord extends HiveObject {
  @HiveField(0)
  String id; // iso timestamp
  @HiveField(1)
  DateTime createdAt;
  @HiveField(2)
  String situation;
  @HiveField(3)
  String automaticThought;
  @HiveField(4)
  String emotion;
  @HiveField(5)
  int emotionIntensityBefore; // 0-100
  @HiveField(6)
  String cognitiveDistortion; // selected label
  @HiveField(7)
  String rationalResponse;
  @HiveField(8)
  int emotionIntensityAfter; // 0-100

  CBTThoughtRecord({
    required this.id,
    required this.createdAt,
    required this.situation,
    required this.automaticThought,
    required this.emotion,
    required this.emotionIntensityBefore,
    required this.cognitiveDistortion,
    required this.rationalResponse,
    required this.emotionIntensityAfter,
  });
}

@HiveType(typeId: 42)
class CopingCard extends HiveObject {
  @HiveField(0)
  String id; // uuid
  @HiveField(1)
  String unhelpfulBelief;
  @HiveField(2)
  String adaptiveBelief;
  @HiveField(3)
  List<String> evidenceFor;
  @HiveField(4)
  List<String> evidenceAgainst;
  @HiveField(5)
  DateTime createdAt;

  CopingCard({
    required this.id,
    required this.unhelpfulBelief,
    required this.adaptiveBelief,
    required this.evidenceFor,
    required this.evidenceAgainst,
    required this.createdAt,
  });
}

@HiveType(typeId: 43)
class CBTMicroLessonProgress extends HiveObject {
  @HiveField(0)
  String lessonId;
  @HiveField(1)
  bool completed;
  @HiveField(2)
  DateTime updatedAt;

  CBTMicroLessonProgress(
      {required this.lessonId,
      required this.completed,
      required this.updatedAt});
}

@HiveType(typeId: 44)
class HypnotherapySessionLog extends HiveObject {
  @HiveField(0)
  String id; // iso timestamp or uuid
  @HiveField(1)
  DateTime startedAt;
  @HiveField(2)
  DateTime? completedAt;
  @HiveField(3)
  String scriptKey; // identifier for the hypnotherapy script
  @HiveField(4)
  int relaxationRatingBefore; // 0-10
  @HiveField(5)
  int relaxationRatingAfter; // 0-10
  @HiveField(6)
  String focusIntent; // user goal e.g. sleep, stress, confidence
  @HiveField(7)
  String notes; // optional notes

  HypnotherapySessionLog({
    required this.id,
    required this.startedAt,
    required this.completedAt,
    required this.scriptKey,
    required this.relaxationRatingBefore,
    required this.relaxationRatingAfter,
    required this.focusIntent,
    required this.notes,
  });
}

@HiveType(typeId: 45)
class SharedArticle extends HiveObject {
  @HiveField(0)
  String id; // token or uuid
  @HiveField(1)
  String title;
  @HiveField(2)
  String author;
  @HiveField(3)
  String body;
  @HiveField(4)
  DateTime createdAt;
  @HiveField(5)
  bool imported; // whether user has imported into local reading list
  @HiveField(6)
  String sourceEmail; // origin pointer (e.g. surendragrover@gmail.com)
  @HiveField(7)
  bool favorite; // user flag
  @HiveField(8)
  String? bodyHi; // optional Hindi body
  @HiveField(9)
  List<String> tags; // extracted keyword tags

  SharedArticle({
    required this.id,
    required this.title,
    required this.author,
    required this.body,
    required this.createdAt,
    required this.imported,
    required this.sourceEmail,
    this.favorite = false,
    this.bodyHi,
    List<String>? tags,
  }) : tags = tags ?? [];
}
