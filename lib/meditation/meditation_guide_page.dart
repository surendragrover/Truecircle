import 'package:flutter/material.dart';
import '../services/json_data_service.dart';

class MeditationGuidePage extends StatelessWidget {
  const MeditationGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meditation Guide')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: JsonDataService.instance.getMeditationGuides(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const _EmptyMsg();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = items[i];
              final title = (e['title'] ?? '').toString();
              final type = (e['type'] ?? '').toString();
              final mins = (e['duration_minutes'] ?? '').toString();
              final diff = (e['difficulty'] ?? '').toString();
              final effect = (e['mood_effect'] ?? '').toString();
              return ListTile(
                leading: const Icon(Icons.self_improvement_outlined),
                title: Text(title.isEmpty ? 'Session' : title),
                subtitle: Text('$type • $mins min • $diff\n$effect'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyMsg extends StatelessWidget {
  const _EmptyMsg();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'No meditation data found. Ensure data/Meditation_Guide_Demo_Data.json is bundled.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
