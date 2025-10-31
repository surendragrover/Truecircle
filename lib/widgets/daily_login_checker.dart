import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/coin_reward_service.dart';
import '../core/event_bus.dart';

class DailyLoginChecker extends StatefulWidget {
  final String userId;
  const DailyLoginChecker({super.key, required this.userId});

  @override
  State<DailyLoginChecker> createState() => _DailyLoginCheckerState();
}

class _DailyLoginCheckerState extends State<DailyLoginChecker> {
  @override
  void initState() {
    super.initState();
    _checkDailyLogin();
  }

  Future<void> _checkDailyLogin() async {
    final box = await Hive.openBox('daily_login_tracker');
    final lastLoginString = box.get(widget.userId) as String?;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();

    if (lastLoginString != today) {
      await CoinRewardService.instance.grantCoins(1);
      await box.put(widget.userId, today);
      EventBus.instance.fire(const CoinRewardedEvent(1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // This widget is purely logical, no UI
  }
}
