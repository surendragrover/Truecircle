import 'package:flutter/material.dart';
import '../../communication/communication_tracker_page.dart';
import '../../core/spacing.dart';
import '../../widgets/entry_box.dart';
import '../../core/log_service.dart';

class CommunicationTrackerHomeWidget extends StatelessWidget {
  const CommunicationTrackerHomeWidget({super.key});

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
                Icon(Icons.chat_bubble_outline, color: Color(0xFF3B82F6)),
                SizedBox(width: 8),
                Text(
                  'Communication Tracker',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Who did you last talk to, and how did it feel? Log a quick note.',
            ),
            const SizedBox(height: AppGaps.small),
            EntryBox(
              hintText: 'Who did you talk to? How did it feel?',
              submitLabel: 'Log',
              onSubmit: (text) async {
                LogService.instance.log('CommunicationQuick: $text');
              },
            ),
            const SizedBox(height: AppGaps.small),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CommunicationTrackerPage(),
                    ),
                  );
                },
                child: const Text('Log now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
