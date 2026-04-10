import 'package:flutter/material.dart';
import '../../services/reward_service.dart';
import '../../services/three_brain_relay_service.dart';
import '../../services/streak_service.dart';
import '../../widgets/coin_reward_celebration.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  double _mood = 3;
  final RewardService _rewardService = RewardService();
  final ThreeBrainRelayService _relay = ThreeBrainRelayService.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Daily Check-In',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 20),
          const Text(
            'How are you feeling right now?',
            style: TextStyle(color: Colors.white),
          ),
          Slider(
            value: _mood,
            min: 1,
            max: 5,
            divisions: 4,
            label: _mood.round().toString(),
            onChanged: (double value) {
              setState(() {
                _mood = value;
              });
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              final RewardGrantResult reward = await _rewardService
                  .grantEntryFormCoin(formId: 'daily_checkin');
              await _relay.addEntry(
                source: 'daily_checkin',
                mood: _mood,
                note: 'Daily check-in submitted',
              );
              // Mark entry completed for streak tracking
              await StreakService.markEntryCompletedToday();
              if (!context.mounted) return;
              if (reward.granted) {
                await CoinRewardCelebration.show(
                  context,
                  message:
                      'Coin Earned! +1 for your check-in. Wallet: ${reward.balance}',
                );
                // Check if 7-day streak bonus was triggered
                final int streak = await StreakService.currentStreak();
                if (streak == 0) {
                  // streak reset to 0 means bonus was just awarded
                  if (!context.mounted) return;
                  await CoinRewardCelebration.show(
                    context,
                    message: '🎉 7-Day Streak Bonus! +10 coins.',
                  );
                }
              }
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        reward.granted ? 'Check-in saved' : reward.reason)),
              );
            },
            child: const Text('Save Check-In'),
          ),
        ],
      ),
    );
  }
}
