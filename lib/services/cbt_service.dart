import 'package:hive/hive.dart';
import '../models/cbt_models.dart';

/// Offline CBT Service: stores assessments, thought records, coping cards, and lesson progress.
class CBTService {
  static final CBTService instance = CBTService._();
  CBTService._();

  static const _boxAssessments = 'cbt_assessments';
  static const _boxThoughts = 'cbt_thought_records';
  static const _boxCards = 'cbt_coping_cards';
  static const _boxLessons = 'cbt_lessons';

  Future<void> init() async {
    await Hive.openBox<CBTAssessmentResult>(_boxAssessments);
    await Hive.openBox<CBTThoughtRecord>(_boxThoughts);
    await Hive.openBox<CopingCard>(_boxCards);
    await Hive.openBox<CBTMicroLessonProgress>(_boxLessons);
  }

  // ----- Assessments -----
  Future<void> saveAssessment(CBTAssessmentResult r) async {
    final box = Hive.box<CBTAssessmentResult>(_boxAssessments);
    await box.put(r.id, r);
  }

  List<CBTAssessmentResult> getAssessments(String key) {
    final box = Hive.box<CBTAssessmentResult>(_boxAssessments);
    return box.values.where((e) => e.assessmentKey == key).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // ----- Thought Records -----
  Future<void> addThoughtRecord(CBTThoughtRecord tr) async {
    final box = Hive.box<CBTThoughtRecord>(_boxThoughts);
    await box.put(tr.id, tr);
  }

  List<CBTThoughtRecord> listThoughtRecords() {
    final box = Hive.box<CBTThoughtRecord>(_boxThoughts);
    return box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ----- Coping Cards -----
  Future<void> addCopingCard(CopingCard c) async {
    final box = Hive.box<CopingCard>(_boxCards);
    await box.put(c.id, c);
  }

  List<CopingCard> listCopingCards() {
    final box = Hive.box<CopingCard>(_boxCards);
    return box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ----- Lessons -----
  Future<void> setLessonCompleted(String id, bool done) async {
    final box = Hive.box<CBTMicroLessonProgress>(_boxLessons);
    final existing = box.get(id);
    if (existing == null) {
      await box.put(
          id,
          CBTMicroLessonProgress(
              lessonId: id, completed: done, updatedAt: DateTime.now()));
    } else {
      existing.completed = done;
      existing.updatedAt = DateTime.now();
      await existing.save();
    }
  }

  List<CBTMicroLessonProgress> lessonProgress() {
    final box = Hive.box<CBTMicroLessonProgress>(_boxLessons);
    return box.values.toList();
  }
}

/// Basic scoring helpers for common screening tools (simplified ranges; for educational, not diagnostic use).
class CBTScoring {
  static String phq9Band(int score) {
    if (score <= 4) return 'minimal';
    if (score <= 9) return 'mild';
    if (score <= 14) return 'moderate';
    if (score <= 19) return 'moderately severe';
    return 'severe';
  }

  static String gad7Band(int score) {
    if (score <= 4) return 'minimal';
    if (score <= 9) return 'mild';
    if (score <= 14) return 'moderate';
    return 'severe';
  }
}
