import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import './dream_model.dart';

class DreamService {
  final String _boxName = 'dream_space';
  final Uuid _uuid = const Uuid();

  Future<Box<List<dynamic>>> _getBox() async {
    return await Hive.openBox<List<dynamic>>(_boxName);
  }

  Future<void> addDream(String text) async {
    final box = await _getBox();
    final dreams = box.get('dreams', defaultValue: <dynamic>[])?.toList() ?? [];

    final newDream = Dream(
      id: _uuid.v4(),
      text: text,
      createdAt: DateTime.now(),
    );

    dreams.add({
      'id': newDream.id,
      'text': newDream.text,
      'createdAt': newDream.createdAt.toIso8601String(),
    });

    await box.put('dreams', dreams);
  }

  Future<List<Dream>> getDreams() async {
    final box = await _getBox();
    final dreamsData = box.get('dreams', defaultValue: <dynamic>[])?.toList() ?? [];

    return dreamsData.map((data) {
      return Dream(
        id: data['id'] as String,
        text: data['text'] as String,
        createdAt: DateTime.parse(data['createdAt'] as String),
      );
    }).toList();
  }

  Future<void> deleteDream(String id) async {
    final box = await _getBox();
    final dreams = box.get('dreams', defaultValue: <dynamic>[])?.toList() ?? [];

    dreams.removeWhere((dream) => dream['id'] == id);

    await box.put('dreams', dreams);
  }
}
