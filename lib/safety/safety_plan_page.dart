import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';

class SafetyPlanPage extends StatelessWidget {
  const SafetyPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'Safety Plan'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Section(
            title: 'Warning signs',
            lines: [
              'Notice thoughts, feelings, or situations that increase distress.',
              'Keep the plan visible to act early.',
            ],
          ),
          SizedBox(height: 12),
          _Section(
            title: 'Coping strategies (you can try now)',
            lines: [
              'Slow breathing: Inhale 4, hold 4, exhale 6 — repeat 1–2 minutes.',
              'Grounding: Name 5 things you can see, 4 you can feel, 3 you can hear.',
            ],
          ),
          SizedBox(height: 12),
          _Section(
            title: 'People and places that help',
            lines: [
              'Think of a trusted person you can talk to nearby.',
              'Move to a safer, public place if needed.',
            ],
          ),
          SizedBox(height: 12),
          _Section(
            title: 'Reasons to keep going',
            lines: [
              'Write 2–3 personal reasons that matter to you.',
              'Keep this list accessible and read it when needed.',
            ],
          ),
          SizedBox(height: 12),
          _NoteCard(
            text:
                'This app is offline and educational-only. It does not place calls, access contacts, or connect to the internet.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<String> lines;
  const _Section({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...lines.map(
              (l) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('• $l'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String text;
  const _NoteCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Padding(padding: const EdgeInsets.all(16.0), child: Text(text)),
    );
  }
}
