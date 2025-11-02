import 'package:flutter/material.dart';
import '../../relationships/relationship_interactions_page.dart';
import '../../core/spacing.dart';

class RelationshipBehaviorHomeWidget extends StatelessWidget {
  const RelationshipBehaviorHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.self_improvement_outlined, color: Color(0xFF10B981)),
                SizedBox(width: 8),
                Text(
                  'Relationship Behavior',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Is there a pattern in your interactions you want to improve? Pick one and reflect.',
            ),
            const SizedBox(height: AppGaps.small),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RelationshipInteractionsPage(),
                    ),
                  );
                },
                child: const Text('Reflect now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
