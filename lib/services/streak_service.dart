import 'package:hive_flutter/hive_flutter.dart';
import 'reward_service.dart';

/// Tracks 7-day streak: consecutive daily login + all entries completed = 10 bonus coins
class StreakService {
  static const String _streakBoxName = 'streakBox';
  static const String _streakCountKey = 'streak_count';
  static const String _lastStreakDateKey = 'last_streak_date';
  static const String _entriesTodayDoneKey = 'entries_today_done';
  static const int _bonusCoins = 10;
  static const int _targetStreak = 7;

  static Future<void> markEntryCompletedToday() async {
    final Box<dynamic> box = await Hive.openBox<dynamic>(_streakBoxName);
    await box.put(_entriesTodayDoneKey, true);
    await _evaluateStreak();
  }

  static Future<void> markDailyLoginDone() async {
    await _evaluateStreak();
  }

  static Future<void> _evaluateStreak() async {
    final Box<dynamic> box = await Hive.openBox<dynamic>(_streakBoxName);
    final DateTime now = DateTime.now();
    final String today = '${now.year}-${now.month}-${now.day}';
    final String? lastDate = box.get(_lastStreakDateKey) as String?;
    final int currentStreak = (box.get(_streakCountKey, defaultValue: 0) as int?) ?? 0;
    final bool entriesDone = (box.get(_entriesTodayDoneKey, defaultValue: false) as bool?) ?? false;

    // If already evaluated today, skip
    if (lastDate == today) return;

    // Check if yesterday was the last streak day (consecutive)
    final bool consecutive = lastDate != null && _isYesterday(lastDate, today);

    if (consecutive && entriesDone) {
      final int newStreak = currentStreak + 1;
      await box.put(_streakCountKey, newStreak);
      await box.put(_lastStreakDateKey, today);
      await box.put(_entriesTodayDoneKey, false); // reset for tomorrow

      if (newStreak >= _targetStreak) {
        // Award bonus and reset streak
        final RewardService reward = RewardService();
        final wallet = await reward.walletState();
        final int newBalance = wallet.balance + _bonusCoins;
        await Hive.box('userBox').put('coin_balance', newBalance);
        await box.put(_streakCountKey, 0); // reset for next cycle
        // Optional: show celebration banner from UI layer
      }
    } else if (!consecutive) {
      // Broken streak: restart from 1 if today entries done, else 0
      await box.put(_streakCountKey, entriesDone ? 1 : 0);
      await box.put(_lastStreakDateKey, today);
      await box.put(_entriesTodayDoneKey, false);
    } else {
      // Same day or future: just mark date
      await box.put(_lastStreakDateKey, today);
    }
  }

  static bool _isYesterday(String lastIso, String todayIso) {
    final DateTime last = DateTime.parse(lastIso);
    final DateTime today = DateTime.parse(todayIso);
    final Duration diff = today.difference(last);
    return diff.inDays == 1;
  }

  static Future<int> currentStreak() async {
    final Box<dynamic> box = await Hive.openBox<dynamic>(_streakBoxName);
    return (box.get(_streakCountKey, defaultValue: 0) as int?) ?? 0;
  }
}