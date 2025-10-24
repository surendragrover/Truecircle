import 'package:flutter/material.dart';
import '../models/cbt_micro_lesson.dart';
import '../services/json_data_service.dart';
import 'cbt_micro_lessons_view.dart';

class CBTMicroLessonsPage extends StatelessWidget {
  const CBTMicroLessonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CBT Micro Lessons')),
      body: FutureBuilder<List<CBTMicroLesson>>(
        future: JsonDataService.instance.getCbtMicroLessons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final lessons = snapshot.data ?? const <CBTMicroLesson>[];
          if (lessons.isEmpty) {
            return const _EmptyHint();
          }
          return ListView.separated(
            itemCount: lessons.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return ListTile(
                title: Text(
                  lesson.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CBTMicroLessonsView(lesson: lesson),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.menu_book_outlined, size: 40),
            SizedBox(height: 12),
            Text(
              'No lessons found. Ensure the asset is added to pubspec:\n'
              '  - data/CBT_Micro_Lessons_en.json',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
