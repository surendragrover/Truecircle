import 'package:flutter/material.dart';

import '../content/json_content_screen.dart';

class CbtHubScreen extends StatelessWidget {
  const CbtHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CBT Hub')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.28,
        children: <Widget>[
          _HubCard(
            title: 'Thought Diary',
            icon: Icons.edit_note,
            onTap: () => _openJson(
              context,
              'Thought Diary',
              'assets/data/CBT_Thoughts_En.json',
            ),
          ),
          _HubCard(
            title: 'Coping Cards',
            icon: Icons.style_outlined,
            onTap: () => _openJson(
              context,
              'Coping Cards',
              'assets/data/Coping_cards_En.json',
            ),
          ),
          _HubCard(
            title: 'Micro Lessons',
            icon: Icons.menu_book_outlined,
            onTap: () => _openJson(
              context,
              'Micro Lessons',
              'assets/data/micro_lessons.json',
            ),
          ),
          _HubCard(
            title: 'CBT Library',
            icon: Icons.school_outlined,
            onTap: () => _openJson(
              context,
              'CBT Library',
              'assets/data/cbt_pack.json',
            ),
          ),
          _HubCard(
            title: 'Distortion Detector',
            icon: Icons.search_outlined,
            onTap: () => _openJson(
              context,
              'Cognitive Distortions Detector',
              'assets/data/Cognitive_Distortions_Detector.json',
            ),
          ),
          _HubCard(
            title: 'Belief Restructuring',
            icon: Icons.auto_fix_high_outlined,
            onTap: () => _openJson(
              context,
              'Belief Restructuring Worksheet',
              'assets/data/Complete_Belief_Restructuring_Worksheet.json',
            ),
          ),
          _HubCard(
            title: 'Behavior Activation',
            icon: Icons.directions_run_outlined,
            onTap: () => _openJson(
              context,
              'Behavioral Activation Planner',
              'assets/data/behavioral_activation_data.json',
            ),
          ),
          _HubCard(
            title: 'Exposure Ladder',
            icon: Icons.stairs_outlined,
            onTap: () => _openJson(
              context,
              'Exposure Ladder',
              'assets/data/exposure_ladder.json',
            ),
          ),
          _HubCard(
            title: 'Trigger-Response',
            icon: Icons.account_tree_outlined,
            onTap: () => _openJson(
              context,
              'Trigger-Response Chain Analysis',
              'assets/data/trigger_response_chain_analysis.json',
            ),
          ),
          _HubCard(
            title: 'Relapse Plan',
            icon: Icons.health_and_safety_outlined,
            onTap: () => _openJson(
              context,
              'Relapse Prevention Plan',
              'assets/data/relapse_prevention_plan.json',
            ),
          ),
          _HubCard(
            title: 'Core Belief Tracker',
            icon: Icons.track_changes_outlined,
            onTap: () => _openJson(
              context,
              'Core Belief Tracker',
              'assets/data/core_belief_tracker.json',
            ),
          ),
          _HubCard(
            title: 'Weekly Scorecard',
            icon: Icons.analytics_outlined,
            onTap: () => _openJson(
              context,
              'Weekly CBT Progress Scorecard',
              'assets/data/weekly_cbt_progress_scorecard.json',
            ),
          ),
        ],
      ),
    );
  }

  void _openJson(BuildContext context, String title, String assetPath) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JsonContentScreen(title: title, assetPath: assetPath),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
