import 'package:hive/hive.dart';

@HiveType(typeId: 11)
class UserCoins extends HiveObject {
  @HiveField(0)
  int totalCoins;

  @HiveField(1)
  DateTime? lastDailyReward;

  @HiveField(2)
  int dailyLoginStreak;

  UserCoins({
    this.totalCoins = 0,
    this.lastDailyReward,
    this.dailyLoginStreak = 0,
  });

  /// Daily login coin reward
  bool canClaimDailyLogin() {
    if (lastDailyReward == null) return true;

    final today = DateTime.now();
    final lastReward = lastDailyReward!;

    return !_isSameDay(today, lastReward);
  }

  /// Add coins and update daily login streak
  void giveDailyLoginReward() {
    final today = DateTime.now();

    if (canClaimDailyLogin()) {
      // Check if consecutive login to maintain streak
      if (lastDailyReward != null && _isYesterday(lastDailyReward!)) {
        dailyLoginStreak++;
      } else {
        dailyLoginStreak = 1; // Reset streak if gap
      }

      // Fixed daily login reward: always 1 coin (no streak bonus)
      int coinsToAdd = 1;

      totalCoins += coinsToAdd;
      lastDailyReward = today;
      save();
    }
  }

  /// Add coins for entry rewards
  void addCoins(int amount) {
    totalCoins += amount;
    save();
  }

  /// Use coins for marketplace purchases
  bool useCoins(int amount) {
    if (totalCoins >= amount) {
      totalCoins -= amount;
      save();
      return true;
    }
    return false;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isYesterday(DateTime lastLogin) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    return _isSameDay(yesterday, lastLogin);
  }

  Map<String, dynamic> toJson() => {
    'totalCoins': totalCoins,
    'lastDailyReward': lastDailyReward?.toIso8601String(),
    'dailyLoginStreak': dailyLoginStreak,
  };

  factory UserCoins.fromJson(Map<String, dynamic> json) => UserCoins(
    totalCoins: json['totalCoins'] ?? 0,
    lastDailyReward: json['lastDailyReward'] != null
        ? DateTime.parse(json['lastDailyReward'])
        : null,
    dailyLoginStreak: json['dailyLoginStreak'] ?? 0,
  );
}

// Manual Hive adapter
class UserCoinsAdapter extends TypeAdapter<UserCoins> {
  @override
  final int typeId = 11;

  @override
  UserCoins read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserCoins(
      totalCoins: fields[0] as int,
      lastDailyReward: fields[1] as DateTime?,
      dailyLoginStreak: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserCoins obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.totalCoins)
      ..writeByte(1)
      ..write(obj.lastDailyReward)
      ..writeByte(2)
      ..write(obj.dailyLoginStreak);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserCoinsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
