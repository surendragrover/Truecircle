import 'package:flutter/material.dart';
import '../services/festival_reminder_service.dart';

/// Simple Festival Reminder Widget - Clean Implementation
class FestivalReminderWidget extends StatefulWidget {
  const FestivalReminderWidget({super.key});

  @override
  State<FestivalReminderWidget> createState() => _FestivalReminderWidgetState();
}

class _FestivalReminderWidgetState extends State<FestivalReminderWidget> {
  final FestivalReminderService _service = FestivalReminderService.instance;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.celebration, color: Colors.orange[800]),
                const SizedBox(width: 8),
                const Text(
                  'Festival Reminders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Load default festivals button
            ElevatedButton(
              onPressed: () async {
                await _service.loadDefaultFestivals();
                setState(() {});
              },
              child: const Text('Load Default Festivals'),
            ),
            const SizedBox(height: 16),

            // Show upcoming festivals
            ..._buildUpcomingFestivals(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildUpcomingFestivals() {
    final upcoming = _service.getUpcomingFestivals();

    if (upcoming.isEmpty) {
      return [
        const Center(
          child: Text(
            'No upcoming festivals loaded.\nTap "Load Default Festivals" to see reminders.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ];
    }

    return upcoming
        .map((festival) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Text(
                  festival.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(festival.festivalName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(festival.festivalNameHindi),
                    Text(
                      '${festival.daysUntil} days remaining',
                      style: TextStyle(
                        color: festival.daysUntil <= 7
                            ? Colors.red
                            : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: Switch(
                  value: festival.isEnabled,
                  onChanged: (value) async {
                    await _service.toggleReminder(festival.id);
                    setState(() {});
                  },
                ),
              ),
            ))
        .toList();
  }
}
