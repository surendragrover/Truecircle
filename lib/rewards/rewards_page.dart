import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'Rewards'),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Offline placeholder. Future: on-device badges and milestones (no network).',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
