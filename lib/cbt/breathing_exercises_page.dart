import 'package:flutter/material.dart';
import '../services/json_data_service.dart';

class BreathingExercisesPage extends StatelessWidget {
  const BreathingExercisesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breathing Exercises')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: JsonDataService.instance.getBreathingSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const _EmptyMsg(message: 'No exercises available yet.');
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = items[i];
              final technique = (e['technique'] ?? '').toString();
              final duration = (e['duration_minutes'] ?? '').toString();
              final effectiveness = (e['effectiveness'] ?? '').toString();
              return ListTile(
                title: Text(technique.isEmpty ? 'Technique' : technique),
                subtitle: Text(
                  'Duration: $duration min • Effectiveness: $effectiveness',
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MoodJournalPage extends StatelessWidget {
  const MoodJournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Journal')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: JsonDataService.instance.getMoodJournalEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const _EmptyMsg(message: 'No journal entries yet.');
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = items[i];
              final date = (e['date'] ?? '').toString();
              final title = (e['title'] ?? '').toString();
              final mood = (e['mood_rating'] ?? '').toString();
              return ListTile(
                title: Text(title.isEmpty ? 'Entry' : title),
                subtitle: Text('Date: $date • Mood: $mood'),
              );
            },
          );
        },
      ),
    );
  }
}

class EmotionalCheckinPage extends StatelessWidget {
  const EmotionalCheckinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotional Check-in'),
        actions: [
          TextButton(
            onPressed: () {
              // Go straight back to Home (root of the stack)
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Done'),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: JsonDataService.instance.getEmotionalCheckins(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const _EmptyMsg(message: 'No check-ins yet.');
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = items[i];
              final date = (e['date'] ?? '').toString();
              final time = (e['time'] ?? '').toString();
              final emotion = (e['emotion'] ?? '').toString();
              final intensity = (e['intensity'] ?? '').toString();
              return ListTile(
                title: Text('$emotion ($intensity/10)'),
                subtitle: Text('Date: $date • Time: $time'),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyMsg extends StatelessWidget {
  final String message;
  const _EmptyMsg({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
