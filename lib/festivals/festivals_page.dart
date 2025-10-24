import 'package:flutter/material.dart';
import '../services/json_data_service.dart';
import '../core/truecircle_app_bar.dart';

class FestivalsPage extends StatelessWidget {
  const FestivalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'Festivals'),
      body: FutureBuilder<List<Map<String, String>>>(
        future: JsonDataService.instance.getFestivalsList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? const <Map<String, String>>[];
          if (items.isEmpty) {
            return const _EmptyMsg();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = items[i];
              final name = e['name'] ?? 'Festival';
              final month = e['month'] ?? '';
              final type = e['type'] ?? '';
              return ListTile(
                leading: const Icon(Icons.celebration_outlined),
                title: Text(name),
                subtitle: Text('$month • $type'),
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
          'No festivals data available. Ensure data/TrueCircle_Festivals_Data.json is bundled.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
