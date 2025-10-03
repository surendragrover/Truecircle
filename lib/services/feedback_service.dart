import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FeedbackEntry {
  final DateTime timestamp;
  final String category;
  final String message;
  final String language;
  FeedbackEntry({required this.timestamp,required this.category,required this.message,required this.language});
  Map<String,dynamic> toJson()=>{
    'ts': timestamp.toIso8601String(),
    'category': category,
    'message': message,
    'lang': language,
  };
}

class FeedbackService {
  FeedbackService._internal();
  static final FeedbackService instance = FeedbackService._internal();
  static const _boxName='user_feedback_box';

  Future<void> submit({required String category, required String message, required String language}) async {
    try {
      final box = await Hive.openBox(_boxName);
      final list = (box.get('entries', defaultValue: <dynamic>[]) as List).cast<Map>().cast<Map<String,dynamic>>();
      list.insert(0, FeedbackEntry(timestamp: DateTime.now(), category: category, message: message, language: language).toJson());
      await box.put('entries', list);
    } catch (e) {
      debugPrint('Feedback submit error: $e');
    }
  }

  Future<List<Map<String,dynamic>>> getAll() async {
    final box = await Hive.openBox(_boxName);
    return (box.get('entries', defaultValue: <dynamic>[]) as List).cast<Map>().cast<Map<String,dynamic>>();
  }
}
