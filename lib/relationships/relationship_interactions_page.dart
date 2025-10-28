import 'package:flutter/material.dart';
import '../services/json_data_service.dart';

class RelationshipInteractionsPage extends StatelessWidget {
  const RelationshipInteractionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relationship Interactions')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: JsonDataService.instance.getRelationshipInteractions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const _EmptyMsg();
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = items[i];
              final date = (e['date'] ?? '').toString();
              final type = (e['relationship_type'] ?? '').toString();
              final title = (e['title'] ?? '').toString();
              final detail = (e['interaction_detail'] ?? '').toString();
              final mood = (e['mood_effect'] ?? '').toString();
              final score = (e['relationship_score'] ?? '').toString();
              return ListTile(
                leading: const Icon(Icons.people_outline),
                title: Text(title.isEmpty ? 'Interaction' : title),
                subtitle: Text('$date • $type\n$mood\n$detail'),
                isThreeLine: true,
                trailing: Text('Score\n$score', textAlign: TextAlign.center),
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
          'No interactions found. Ensure data/Relations Interactions_Feature.JSON is bundled.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
