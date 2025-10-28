import 'package:hive/hive.dart';

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
  String userId;

  @HiveField(1)
  int totalCoins;

  @HiveField(2)
  int usedCoins;

  @HiveField(3)
  DateTime lastLoginReward;

  @HiveField(4)
  List<String> rewardHistory;

  UserCoins({
    required this.userId,
    this.totalCoins = 0,
    this.usedCoins = 0,
    required this.lastLoginReward,
    List<String>? rewardHistory,
  }) : rewardHistory = rewardHistory ?? [];

  int get availableCoins => totalCoins - usedCoins;

  bool get canGetDailyReward {
    final now = DateTime.now();
    final lastReward = lastLoginReward;
    return now.difference(lastReward).inDays >= 1;
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'totalCoins': totalCoins,
    'usedCoins': usedCoins,
    'lastLoginReward': lastLoginReward.toIso8601String(),
    'rewardHistory': rewardHistory,
  };

  factory UserCoins.fromJson(Map<String, dynamic> json) => UserCoins(
    userId: json['userId'],
    totalCoins: json['totalCoins'] ?? 0,
    usedCoins: json['usedCoins'] ?? 0,
    lastLoginReward: DateTime.parse(json['lastLoginReward']),
    rewardHistory: List<String>.from(json['rewardHistory'] ?? []),
  );
}
