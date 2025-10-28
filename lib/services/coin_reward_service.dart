import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/coin_reward.dart';
import '../models/user_coins.dart';
import 'firebase_analytics_service.dart';

class CoinRewardService {
  static const String _coinsBoxName = 'user_coins_box';
  static const String _rewardsBoxName = 'coin_rewards_box';

  Box<UserCoins>? _coinsBox;
  Box<CoinReward>? _rewardsBox;

  static CoinRewardService? _instance;
  static CoinRewardService get instance {
    _instance ??= CoinRewardService._();
    return _instance!;
  }

  CoinRewardService._();

  Future<void> initialize() async {
    try {
      _coinsBox = await Hive.openBox<UserCoins>(_coinsBoxName);
      _rewardsBox = await Hive.openBox<CoinReward>(_rewardsBoxName);
    } catch (e) {
      debugPrint('Coin Reward Service initialize error: $e');
    }
  }

  // ===== USER COINS MANAGEMENT =====

  Future<UserCoins> _getUserCoins() async {
    const userId = 'default_user'; // Single user for now
    UserCoins? userCoins = _coinsBox?.get(userId);

    if (userCoins == null) {
      // Create new UserCoins if doesn't exist
      userCoins = UserCoins();
      await _coinsBox?.put(userId, userCoins);
    }

    return userCoins;
  }

  // ===== DAILY LOGIN REWARD =====

  Future<Map<String, dynamic>> checkAndGiveDailyReward() async {
    try {
      final userCoins = await _getUserCoins();

      if (userCoins.canClaimDailyLogin()) {
        userCoins.giveDailyLoginReward();

        // Create reward record
        final reward = CoinReward(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: CoinTransactionType.dailyLogin,
          amount: userCoins.dailyLoginStreak >= 7
              ? 3
              : (userCoins.dailyLoginStreak >= 3 ? 2 : 1),
          timestamp: DateTime.now(),
          description:
              'रोज़ाना लॉगिन (${userCoins.dailyLoginStreak} दिन की streak)',
        );

        await _rewardsBox?.put(reward.id, reward);

        // Track analytics
        await FirebaseAnalyticsService.logCoinEarned(
          source: 'daily_login',
          amount: reward.amount,
          streak: userCoins.dailyLoginStreak,
        );

        await FirebaseAnalyticsService.logDailyLogin(
          streak: userCoins.dailyLoginStreak,
          earnedReward: true,
        );

        return {
          'rewarded': true,
          'coins': reward.amount,
          'streak': userCoins.dailyLoginStreak,
          'message':
              'बधाई! आपको ${reward.amount} सिक्के मिले! 🎉\n${userCoins.dailyLoginStreak} दिन की streak!',
        };
      }

      return {'rewarded': false, 'message': 'आज का reward पहले से claimed है!'};
    } catch (e) {
      debugPrint('Daily reward error: $e');
      return {'rewarded': false, 'message': 'Error claiming reward'};
    }
  }

  // ===== ENTRY REWARD =====

  Future<void> giveEntryReward() async {
    try {
      final userCoins = await _getUserCoins();
      userCoins.addCoins(1);

      // Create reward record
      final reward = CoinReward(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: CoinTransactionType.entryReward,
        amount: 1,
        timestamp: DateTime.now(),
        description: 'Communication entry के लिए reward',
      );

      await _rewardsBox?.put(reward.id, reward);
      debugPrint('Entry reward given: 1 coin');
    } catch (e) {
      debugPrint('Entry reward error: $e');
    }
  }

  // ===== MARKETPLACE DISCOUNT =====

  Future<Map<String, dynamic>> calculateMarketplaceDiscount(
    double originalPrice,
  ) async {
    try {
      final userCoins = await _getUserCoins();
      const maxDiscountPercent = 40.0;
      const coinValue = 1.0; // 1 coin = ₹1 discount

      final maxDiscountAmount = originalPrice * maxDiscountPercent / 100;
      final availableDiscount = (userCoins.totalCoins * coinValue).clamp(
        0.0,
        maxDiscountAmount,
      );
      final coinsNeeded = availableDiscount.round();
      final discountPercent = (availableDiscount / originalPrice * 100).clamp(
        0.0,
        maxDiscountPercent,
      );
      final finalPrice = originalPrice - availableDiscount;

      return {
        'canApplyDiscount': availableDiscount > 0,
        'originalPrice': originalPrice,
        'discountAmount': availableDiscount,
        'discountPercent': discountPercent,
        'finalPrice': finalPrice,
        'coinsNeeded': coinsNeeded,
        'userCoins': userCoins.totalCoins,
      };
    } catch (e) {
      debugPrint('Calculate discount error: $e');
      return {
        'canApplyDiscount': false,
        'originalPrice': originalPrice,
        'discountAmount': 0.0,
        'discountPercent': 0.0,
        'finalPrice': originalPrice,
        'coinsNeeded': 0,
        'userCoins': 0,
      };
    }
  }

  Future<bool> useCoinForPurchase(
    int coinsToUse,
    double originalPrice,
    String itemName,
  ) async {
    try {
      final userCoins = await _getUserCoins();

      if (userCoins.useCoins(coinsToUse)) {
        // Create usage record
        final usage = CoinReward(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: CoinTransactionType.marketplacePurchase,
          amount: -coinsToUse, // Negative for usage
          timestamp: DateTime.now(),
          description: '$itemName की खरीदारी में इस्तेमाल',
        );

        await _rewardsBox?.put(usage.id, usage);
        debugPrint('Used $coinsToUse coins for $itemName purchase');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Use coin error: $e');
      return false;
    }
  }

  // ===== QUERIES =====

  Future<List<CoinReward>> getUserRewardHistory() async {
    try {
      final allRewards = _rewardsBox?.values.toList() ?? [];
      return allRewards..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Get reward history error: $e');
      return [];
    }
  }

  Future<int> getUserCoinsCount() async {
    try {
      final userCoins = await _getUserCoins();
      return userCoins.totalCoins;
    } catch (e) {
      debugPrint('Get user coins error: $e');
      return 0;
    }
  }

  Future<int> getDailyLoginStreak() async {
    try {
      final userCoins = await _getUserCoins();
      return userCoins.dailyLoginStreak;
    } catch (e) {
      debugPrint('Get streak error: $e');
      return 0;
    }
  }

  // ===== ADMIN/DEBUG =====

  Future<void> addBonusCoins(int amount, String reason) async {
    try {
      final userCoins = await _getUserCoins();
      userCoins.addCoins(amount);

      final reward = CoinReward(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: CoinTransactionType.bonus,
        amount: amount,
        timestamp: DateTime.now(),
        description: reason,
      );

      await _rewardsBox?.put(reward.id, reward);
      debugPrint('Added $amount bonus coins: $reason');
    } catch (e) {
      debugPrint('Add bonus coins error: $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      await _coinsBox?.clear();
      await _rewardsBox?.clear();
      debugPrint('Cleared all coin data');
    } catch (e) {
      debugPrint('Clear data error: $e');
    }
  }
}
