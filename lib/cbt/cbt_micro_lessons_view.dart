import 'package:flutter/material.dart';
import '../models/cbt_micro_lesson.dart';

class CBTMicroLessonsView extends StatelessWidget {
  final CBTMicroLesson lesson;
  const CBTMicroLessonsView({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CBT Lesson')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [Text(lesson.text)],
      ),
    );
  }
}
