import 'package:flutter/material.dart';
import 'cbt_micro_lessons_page.dart';
import 'phq9_page.dart';
import 'cbt_techniques_page.dart';
import 'cbt_thoughts_page.dart';
import 'psychology_articles_page.dart';

class CBTHubPage extends StatelessWidget {
  const CBTHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CBT Hub')),
      body: ListView(
        children: [
          _HubTile(
            icon: Icons.menu_book_outlined,
            title: 'Micro Lessons',
            subtitle: 'Short CBT insights from local data',
            onTap: () => _open(context, const CBTMicroLessonsPage()),
          ),
          _HubTile(
            icon: Icons.assignment_outlined,
            title: 'PHQ‑9 (Depression) – Offline',
            subtitle: '9‑item self‑report with local scoring',
            onTap: () => _open(context, const PHQ9Page()),
          ),
          _HubTile(
            icon: Icons.handyman_outlined,
            title: 'CBT Techniques',
            subtitle: 'Practical tools from local data',
            onTap: () => _open(context, const CBTTechniquesPage()),
          ),
          _HubTile(
            icon: Icons.psychology_outlined,
            title: 'CBT Thoughts',
            subtitle: 'Common thought patterns (static list)',
            onTap: () => _open(context, const CBTThoughtsPage()),
          ),
          _HubTile(
            icon: Icons.menu_book_outlined,
            title: 'Psychology Articles',
            subtitle: 'Educational articles (offline)',
            onTap: () => _open(context, const PsychologyArticlesPage()),
          ),
          const SizedBox(height: 8),
          const _ComingSoon(),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _HubTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Coming soon: Assessments (PHQ-9, GAD-7), CBT journaling with on-device storage.',
        style: TextStyle(color: Theme.of(context).hintColor),
      ),
    );
  }
}
