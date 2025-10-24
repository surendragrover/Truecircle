import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';
import '../services/json_data_service.dart';

class CBTTechniquesPage extends StatelessWidget {
  const CBTTechniquesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'CBT Techniques'),
      body: FutureBuilder<List<String>>(
        future: JsonDataService.instance.getCbtTechniques(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('No techniques found.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, i) => ListTile(
              leading: const Icon(Icons.handyman_outlined),
              title: Text(items[i]),
            ),
          );
        },
      ),
    );
  }
}
