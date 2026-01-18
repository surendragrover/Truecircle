import 'package:flutter/material.dart';
import '../../core/storage/local_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int coins = 0;
  int streakDays = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      coins = LocalStore.getCoins();
      streakDays = LocalStore.getStreak();
    });
  }

  Future<void> _claimReward() async {
    final ok = await LocalStore.claimDailyReward(rewardCoins: 10);

    _load();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? '✅ Reward claimed: +10 coins' : '⛔ Already claimed today',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const wellnessScore = 76;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TrueCircle'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text('Coins: $coins'),
              avatar: const Icon(Icons.monetization_on, size: 18),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '📊 Dashboard Analytics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Wellness Score'),
              subtitle: const Text('$wellnessScore / 100'),
              trailing: const Text('Last updated: 2 min ago'),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '🏆 Daily Rewards',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coins: $coins'),
                  const SizedBox(height: 6),
                  Text('Streak: $streakDays days'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _claimReward,
                    icon: const Icon(Icons.card_giftcard),
                    label: const Text('Claim Today’s Reward'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
