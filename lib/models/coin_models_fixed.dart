import 'package:hive/hive.dart';

// Single enum definition
enum CoinTransactionType { dailyLogin, entryReward, marketplacePurchase, bonus }

@HiveType(typeId: 10)
class CoinReward extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  CoinTransactionType type;

  @HiveField(2)
  int amount;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String? description;

  CoinReward({
    required this.id,
    required this.type,
    required this.amount,
    required this.timestamp,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'timestamp': timestamp.toIso8601String(),
    'description': description,
  };

  factory CoinReward.fromJson(Map<String, dynamic> json) => CoinReward(
    id: json['id'],
    type: CoinTransactionType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => CoinTransactionType.bonus,
    ),
    amount: json['amount'] ?? 0,
    timestamp: DateTime.parse(json['timestamp']),
    description: json['description'],
  );
}

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

      // Calculate bonus based on streak
      int coinsToAdd = 1;
      if (dailyLoginStreak >= 7) {
        coinsToAdd = 3; // Weekly bonus
      } else if (dailyLoginStreak >= 3) {
        coinsToAdd = 2; // 3-day streak bonus
      }

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

// Manual Hive adapters (following TrueCircle convention)
class CoinTransactionTypeAdapter extends TypeAdapter<CoinTransactionType> {
  @override
  final int typeId = 72;

  @override
  CoinTransactionType read(BinaryReader reader) {
    final value = reader.readByte();
    switch (value) {
      case 0:
        return CoinTransactionType.dailyLogin;
      case 1:
        return CoinTransactionType.entryReward;
      case 2:
        return CoinTransactionType.marketplacePurchase;
      case 3:
        return CoinTransactionType.bonus;
      default:
        return CoinTransactionType.bonus;
    }
  }

  @override
  void write(BinaryWriter writer, CoinTransactionType obj) {
    switch (obj) {
      case CoinTransactionType.dailyLogin:
        writer.writeByte(0);
        break;
      case CoinTransactionType.entryReward:
        writer.writeByte(1);
        break;
      case CoinTransactionType.marketplacePurchase:
        writer.writeByte(2);
        break;
      case CoinTransactionType.bonus:
        writer.writeByte(3);
        break;
    }
  }
}

class CoinRewardAdapter extends TypeAdapter<CoinReward> {
  @override
  final int typeId = 10;

  @override
  CoinReward read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoinReward(
      id: fields[0] as String,
      type: fields[1] as CoinTransactionType,
      amount: fields[2] as int,
      timestamp: fields[3] as DateTime,
      description: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CoinReward obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinRewardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
