import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About TrueCircle')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _AboutBlock(
            title: 'What this app is',
            lines: [
              'A neutral-mode, offline, educational application.',
              'It does not request runtime permissions or make network calls.',
            ],
          ),
          SizedBox(height: 12),
          _AboutBlock(
            title: 'Privacy-first by design',
            lines: [
              'English-only output in-app to avoid confusion.',
              'No contacts, no calls, no SMS, no online services.',
            ],
          ),
          SizedBox(height: 12),
          _AboutBlock(
            title: 'Brand',
            lines: [
              'TrueCircle is the brand used across the app.',
              'This build is a clean, minimal foundation for future features.',
            ],
          ),
        ],
      ),
    );
  }
}

class _AboutBlock extends StatelessWidget {
  final String title;
  final List<String> lines;
  const _AboutBlock({required this.title, required this.lines});

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
