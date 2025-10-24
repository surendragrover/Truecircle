import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';
import '../models/cbt_micro_lesson.dart';

class CBTMicroLessonsView extends StatelessWidget {
  final CBTMicroLesson lesson;
  const CBTMicroLessonsView({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'CBT Lesson'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [Text(lesson.text)],
      ),
    );
  }
}
