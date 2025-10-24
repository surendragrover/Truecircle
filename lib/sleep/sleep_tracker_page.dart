import 'package:flutter/material.dart';
import '../services/json_data_service.dart';

class SleepTrackerPage extends StatelessWidget {
  const SleepTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Tracker')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: JsonDataService.instance.getSleepTrackerEntries(),
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
              final day = (e['day'] ?? '').toString();
              final dur = (e['duration'] ?? '').toString();
              final q = (e['quality'] ?? '').toString();
              final bed = (e['bedtime'] ?? '').toString();
              final wake = (e['wakeTime'] ?? '').toString();
              final notes = (e['notes'] ?? '').toString();
              return ListTile(
                leading: const Icon(Icons.nightlight_round),
                title: Text('Day $day • $dur • Q$q/10'),
                subtitle: Text('Bed: $bed • Wake: $wake\n$notes'),
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
          'No sleep data available. Ensure data/Sleep_Tracker.json is bundled.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
