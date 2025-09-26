import 'package:flutter/material.dart';

class RelationshipInsightsPage extends StatelessWidget {
  final bool isFullMode;

  const RelationshipInsightsPage({super.key, required this.isFullMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relationship Insights'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, size: 80, color: Colors.pink),
            const SizedBox(height: 20),
            Text(
              'Relationship Insights Page',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              isFullMode
                  ? 'Full relationship analysis will be displayed here.'
                  : 'Demo relationship insights will be displayed here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
