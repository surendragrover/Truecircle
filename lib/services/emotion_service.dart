import 'package:hive/hive.dart';
import '../models/emotion_entry.dart';

class EmotionService {
  final Box<EmotionEntry>? box;

  const EmotionService(this.box);

  Future<void> addEntry(EmotionEntry entry) async {
    if (box != null) {
      await box!.add(entry);
    } else {
      // Handle null box gracefully - could store in memory or show error
      // Warning: Cannot add entry - no storage box available
    }
  }

  Future<void> updateEntry(int index, EmotionEntry entry) async {
    if (box != null && index < box!.length) {
      await box!.putAt(index, entry);
    }
  }

  Future<void> deleteEntry(int index) async {
    if (box != null && index < box!.length) {
      await box!.deleteAt(index);
    }
  }

  List<EmotionEntry> getAllEntries() {
    if (box != null) {
      final entries = box!.values.toList();
      // If box is empty, add sample data for demo/screenshots
      if (entries.isEmpty) {
        _addSampleData();
        return box!.values.toList();
      }
      return entries;
    } else {
      // Return rich sample data for demo when no storage available
      return _getSampleEntries();
    }
  }

  void _addSampleData() {
    if (box == null) return;

    final sampleEntries = _getSampleEntries();
    for (final entry in sampleEntries) {
      box!.add(entry);
    }
  }

  List<EmotionEntry> _getSampleEntries() {
    final now = DateTime.now();
    return [
      EmotionEntry(
        emotion: 'Excited 🎉',
        intensity: 9,
        timestamp: now.subtract(const Duration(hours: 1)),
        note: 'Got promoted at work! Celebrating with family tonight 🥳',
      ),
      EmotionEntry(
        emotion: 'Grateful 🙏',
        intensity: 8,
        timestamp: now.subtract(const Duration(hours: 3)),
        note:
            'Had a wonderful video call with mom. She shared family recipes 👨‍👩‍👧‍👦',
      ),
      EmotionEntry(
        emotion: 'Calm 😌',
        intensity: 7,
        timestamp: now.subtract(const Duration(hours: 6)),
        note:
            'Morning meditation and yoga session. Perfect start to the day 🧘‍♀️',
      ),
      EmotionEntry(
        emotion: 'Happy 😊',
        intensity: 8,
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        note: 'Surprise birthday party for best friend! Great memories made 🎂',
      ),
      EmotionEntry(
        emotion: 'Proud 💪',
        intensity: 8,
        timestamp: now.subtract(const Duration(days: 1, hours: 8)),
        note: 'Completed my first 5K run! Training paid off 🏃‍♀️',
      ),
      EmotionEntry(
        emotion: 'Content 😊',
        intensity: 7,
        timestamp: now.subtract(const Duration(days: 2)),
        note:
            'Family dinner with delicious homemade food. Love these moments 🍽️',
      ),
      EmotionEntry(
        emotion: 'Motivated 🔥',
        intensity: 8,
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
        note:
            'Started learning a new programming language. Exciting challenges ahead! 💻',
      ),
      EmotionEntry(
        emotion: 'Peaceful ☮️',
        intensity: 6,
        timestamp: now.subtract(const Duration(days: 3)),
        note: 'Weekend trip to the mountains. Nature therapy at its best 🏔️',
      ),
      EmotionEntry(
        emotion: 'Hopeful 🌟',
        intensity: 7,
        timestamp: now.subtract(const Duration(days: 3, hours: 12)),
        note: 'Applied for my dream job. Fingers crossed! 🤞',
      ),
      EmotionEntry(
        emotion: 'Loved ❤️',
        intensity: 9,
        timestamp: now.subtract(const Duration(days: 4)),
        note:
            'Anniversary dinner with my partner. 3 beautiful years together! 💕',
      ),
      EmotionEntry(
        emotion: 'Accomplished ✅',
        intensity: 8,
        timestamp: now.subtract(const Duration(days: 5)),
        note: 'Finished reading "The Alchemist". Such an inspiring book! 📚',
      ),
      EmotionEntry(
        emotion: 'Energetic ⚡',
        intensity: 8,
        timestamp: now.subtract(const Duration(days: 6)),
        note: 'Great workout session! Feeling strong and healthy 💪',
      ),
    ];
  }
}
