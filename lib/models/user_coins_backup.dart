import 'package:hive/hive.dart';

@HiveType(typeId: 11)
class UserCoins extends HiveObject {
  @HiveField(0)
  int totalCoins;

  @HiveField(1)
  DateTime? lastLoginDate;

  @HiveField(2)
  int dailyLoginStreak;

  @HiveField(3)
  List<CoinTransaction> transactions;

  UserCoins({
    this.totalCoins = 0,
    this.lastLoginDate,
    this.dailyLoginStreak = 0,
    required this.transactions,
  });

  /// Daily login coin reward
  bool canClaimDailyLogin() {
    if (lastLoginDate == null) return true;

    final today = DateTime.now();
    final lastLogin = lastLoginDate!;

    return !_isSameDay(today, lastLogin);
  }

  /// Add coins with transaction record
  void addCoins(int amount, CoinTransactionType type, {String? description}) {
    totalCoins += amount;
    transactions.add(
      CoinTransaction(
        amount: amount,
        type: type,
        description: description ?? type.description,
        timestamp: DateTime.now(),
      ),
    );
    save();
  }

  /// Use coins (subtract)
  bool useCoins(int amount, {String? description}) {
    if (totalCoins >= amount) {
      totalCoins -= amount;
      transactions.add(
        CoinTransaction(
          amount: -amount,
          type: CoinTransactionType.purchase,
          description: description ?? 'Marketplace खरीदारी',
          timestamp: DateTime.now(),
        ),
      );
      save();
      return true;
    }
    return false;
  }

  /// Claim daily login reward
  void claimDailyLogin() {
    final today = DateTime.now();

    if (lastLoginDate != null && _isConsecutiveDay(today, lastLoginDate!)) {
      dailyLoginStreak++;
    } else {
      dailyLoginStreak = 1;
    }

    lastLoginDate = today;

    // Bonus coins for streak
    int coinsToAdd = 1;
    if (dailyLoginStreak >= 7) {
      coinsToAdd = 3; // Weekly bonus
    } else if (dailyLoginStreak >= 3) {
      coinsToAdd = 2; // 3-day streak bonus
    }

    addCoins(
      coinsToAdd,
      CoinTransactionType.dailyLogin,
      description: 'रोज़ाना लॉगिन ($dailyLoginStreak दिन की streak)',
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isConsecutiveDay(DateTime today, DateTime lastLogin) {
    final yesterday = today.subtract(const Duration(days: 1));
    return _isSameDay(yesterday, lastLogin);
  }
}

@HiveType(typeId: 11)
class CoinTransaction extends HiveObject {
  @HiveField(0)
  int amount;

  @HiveField(1)
  CoinTransactionType type;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime timestamp;

  CoinTransaction({
    required this.amount,
    required this.type,
    required this.description,
    required this.timestamp,
  });
}

@HiveType(typeId: 12)
enum CoinTransactionType {
  @HiveField(0)
  dailyLogin,

  @HiveField(1)
  conversationEntry,

  @HiveField(2)
  purchase,

  @HiveField(3)
  bonus;

  String get description {
    switch (this) {
      case CoinTransactionType.dailyLogin:
        return 'रोज़ाना लॉगिन बोनस';
      case CoinTransactionType.conversationEntry:
        return 'बातचीत की entry';
      case CoinTransactionType.purchase:
        return 'खरीदारी';
      case CoinTransactionType.bonus:
        return 'बोनस';
    }
  }

  String get displayName {
    switch (this) {
      case CoinTransactionType.dailyLogin:
        return '🎁 Daily Login';
      case CoinTransactionType.conversationEntry:
        return '💬 Conversation';
      case CoinTransactionType.purchase:
        return '🛒 Purchase';
      case CoinTransactionType.bonus:
        return '⭐ Bonus';
    }
  }
}
