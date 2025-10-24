import 'package:hive/hive.dart';
import '../models/emotional_awareness_selection.dart';

class EmotionalAwarenessService {
  EmotionalAwarenessService._();
  static final EmotionalAwarenessService instance =
      EmotionalAwarenessService._();

  static const String _boxName = 'tc_emotional_awareness';

  Future<Box<EmotionalAwarenessSelection>> _box() async {
    if (!Hive.isAdapterRegistered(70)) {
      Hive.registerAdapter(EAOccurrenceTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(71)) {
      Hive.registerAdapter(EmotionalAwarenessSelectionAdapter());
    }
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<EmotionalAwarenessSelection>(_boxName);
    }
    return Hive.openBox<EmotionalAwarenessSelection>(_boxName);
  }

  Future<Map<String, EAOccurrenceType>> getAllSelections() async {
    final b = await _box();
    final map = <String, EAOccurrenceType>{};
    for (final sel in b.values) {
      map[sel.question] = sel.occurrence;
    }
    return map;
  }

  Future<void> setSelection({
    required String question,
    required EAOccurrenceType? occurrence,
  }) async {
    final b = await _box();
    final key = _stableId(question);
    if (occurrence == null) {
      await b.delete(key);
      return;
    }
    final existing = b.get(key);
    final sel = EmotionalAwarenessSelection(
      id: key,
      question: question,
      occurrence: occurrence,
      updatedAt: DateTime.now(),
    );
    if (existing == null) {
      await b.put(key, sel);
    } else {
      existing
        ..question = sel.question
        ..occurrence = sel.occurrence
        ..updatedAt = sel.updatedAt
        ..save();
    }
  }

  String _stableId(String question) {
    // Simple stable hash (FNV-1a 32-bit)
    const int fnvPrime = 0x01000193;
    int hash = 0x811C9DC5;
    for (int i = 0; i < question.length; i++) {
      hash ^= question.codeUnitAt(i);
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }
}
