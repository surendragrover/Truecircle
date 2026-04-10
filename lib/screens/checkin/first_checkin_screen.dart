import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../app/app_shell.dart';
import '../../services/reward_service.dart';
import '../../services/streak_service.dart';
import '../../theme/truecircle_theme.dart';
import '../../widgets/coin_reward_celebration.dart';

class FirstCheckInScreen extends StatefulWidget {
  const FirstCheckInScreen({super.key});

  @override
  State<FirstCheckInScreen> createState() => _FirstCheckInScreenState();
}

class _FirstCheckInScreenState extends State<FirstCheckInScreen> {
  double _mood = 3;
  final bool _submitted = false;

  Future<void> _submit() async {
    final Box<dynamic> box = Hive.box('appBox');
    await box.put('first_checkin_mood', _mood);
    await box.put('first_checkin_done', true);

    // Grant 1 coin for first check-in entry
    final RewardService reward = RewardService();
    final rewardResult =
        await reward.grantEntryFormCoin(formId: 'first_checkin');

    // Mark entry completed for streak tracking
    await StreakService.markEntryCompletedToday();

    if (!mounted) return;

    // Show coin celebration
    await CoinRewardCelebration.show(
      context,
      message:
          'Coin Earned! +1 for your first check-in. Wallet: ${rewardResult.balance}',
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: TrueCircleTheme.appBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Spacer(flex: 2),
                Text(
                  'Welcome to your first check-in',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Let\'s take a moment to understand how you feel right now. Your honest answer helps me support you better.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 32),
                Text(
                  'How are you feeling today?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _mood,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _mood.round().toString(),
                  activeColor: Colors.white,
                  inactiveColor: Colors.white30,
                  onChanged: (double value) {
                    setState(() {
                      _mood = value;
                    });
                  },
                ),
                const Spacer(flex: 3),
                Center(
                  child: FilledButton.icon(
                    onPressed: _submitted ? null : _submit,
                    icon: const Icon(Icons.favorite_outline),
                    label: const Text('Share my feeling'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6A1B9A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
