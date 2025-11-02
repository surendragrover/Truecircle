import 'package:flutter/material.dart';
import '../../relationships/relationship_insights_page.dart';
import '../../core/spacing.dart';
import '../../widgets/entry_box.dart';
import '../../core/log_service.dart';

class RelationshipInsightsHomeWidget extends StatelessWidget {
  const RelationshipInsightsHomeWidget({super.key});

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
                Icon(Icons.favorite_outline, color: Color(0xFF8B5CF6)),
                SizedBox(width: 8),
                Text(
                  'Relationship Insights',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'What recent moment in a relationship felt meaningful—or difficult? Write one line about it.',
            ),
            const SizedBox(height: AppGaps.small),
            EntryBox(
              hintText: 'Write one-line about a recent relationship moment...',
              submitLabel: 'Save',
              onSubmit: (text) async {
                // Log the quick insight; deeper saving can be added later
                LogService.instance.log('RelationshipQuick: $text');
              },
            ),
            const SizedBox(height: AppGaps.small),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RelationshipInsightsPage(),
                    ),
                  );
                },
                child: const Text('Answer now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
