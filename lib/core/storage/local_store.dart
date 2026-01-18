import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStore {
  static const String _boxName = 'tc_box';

  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  // ---------------- COINS ----------------
  static int getCoins() {
    return _box.get('coins', defaultValue: 0) as int;
  }

  static Future<void> setCoins(int value) async {
    await _box.put('coins', value);
  }

  static Future<void> addCoins(int value) async {
    final current = getCoins();
    await setCoins(current + value);
  }

  // ---------------- STREAK ----------------
  static int getStreak() {
    return _box.get('streak', defaultValue: 0) as int;
  }

  static Future<void> setStreak(int value) async {
    await _box.put('streak', value);
  }

  static DateTime? getLastClaimDate() {
    final s = _box.get('last_claim_date');
    if (s == null) return null;
    return DateTime.tryParse(s.toString());
  }

  static Future<void> setLastClaimDate(DateTime date) async {
    // store only date (yyyy-mm-dd)
    final onlyDate = DateTime(date.year, date.month, date.day);
    await _box.put('last_claim_date', onlyDate.toIso8601String());
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Reward: per day only
  // Returns: true if claimed, false if already claimed today
  static Future<bool> claimDailyReward({int rewardCoins = 10}) async {
    final now = DateTime.now();
    final last = getLastClaimDate();

    // Already claimed today
    if (last != null && _isSameDay(last, now)) {
      return false;
    }

    // Streak logic:
    // If last claim was yesterday -> streak+1
    // Else -> streak=1
    int streak = getStreak();
    if (last == null) {
      streak = 1;
    } else {
      final yesterday = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));
      if (_isSameDay(last, yesterday)) {
        streak = streak + 1;
      } else {
        streak = 1;
      }
    }

    await setStreak(streak);
    await setLastClaimDate(now);
    await addCoins(rewardCoins);

    return true;
  }
}
