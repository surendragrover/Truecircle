import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    const tips = [
      'Name the thought. Ask: Is it a fact or a story?',
      'Breathe slowly: Inhale 4 • Hold 4 • Exhale 6.',
      'Reframe: What’s a kinder, more helpful alternative?',
    ];
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'Learn'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(tips[i]),
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: tips.length,
      ),
    );
  }
}
