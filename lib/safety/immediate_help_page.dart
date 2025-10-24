import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';
import 'safety_plan_page.dart';

class ImmediateHelpPage extends StatelessWidget {
  const ImmediateHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'Immediate Help'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HelpCard(
            icon: Icons.emergency_outlined,
            title: 'If you are in immediate danger',
            lines: [
              'Call your local emergency number (e.g., 112 in India).',
              'Go to the nearest emergency department if you can.',
            ],
          ),
          SizedBox(height: 12),
          _HelpCard(
            icon: Icons.spa_outlined,
            title: 'Self‑soothe pack (offline)',
            lines: [
              'Breathing: Inhale 4 • Hold 4 • Exhale 6 (x5).',
              '5‑4‑3‑2‑1 grounding: Notice 5 sights, 4 touches, 3 sounds, 2 smells, 1 taste.',
              'Move: Light stretch or a short walk if safe.',
            ],
          ),
          SizedBox(height: 12),
          _HelpCard(
            icon: Icons.lock_outline,
            title: 'About this app',
            lines: [
              'Offline and educational-only.',
              'No calls, no contacts, no network access.',
            ],
          ),
          SizedBox(height: 12),
          _HelpCard(
            icon: Icons.people_outline,
            title: 'Reach out nearby',
            lines: [
              'Tell a trusted person around you.',
              'Stay in a safer, public place if needed.',
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SafetyPlanPage()));
            },
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('View Safety Plan'),
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> lines;

  const _HelpCard({
    required this.icon,
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
