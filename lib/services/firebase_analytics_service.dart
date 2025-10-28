import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseAnalyticsService {
  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;

  static FirebaseAnalytics get analytics {
    _analytics ??= FirebaseAnalytics.instance;
    return _analytics!;
  }

  static FirebaseAnalyticsObserver get observer {
    _observer ??= FirebaseAnalyticsObserver(analytics: analytics);
    return _observer!;
  }

  // Track coin system events
  static Future<void> logCoinEarned({
    required String source, // 'daily_login', 'entry_reward', 'bonus'
    required int amount,
    int? streak,
  }) async {
    try {
      await analytics.logEvent(
        name: 'coin_earned',
        parameters: {
          'source': source,
          'amount': amount,
          if (streak != null) 'streak': streak,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  static Future<void> logCoinSpent({
    required String item,
    required int amount,
    required double originalPrice,
    required double discountPercent,
  }) async {
    try {
      await analytics.logEvent(
        name: 'coin_spent',
        parameters: {
          'item_name': item,
          'coin_amount': amount,
          'original_price': originalPrice,
          'discount_percent': discountPercent,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // Track user engagement
  static Future<void> logScreenView(String screenName) async {
    try {
      await analytics.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // Track CBT usage
  static Future<void> logCBTTechniqueUsed(String technique) async {
    try {
      await analytics.logEvent(
        name: 'cbt_technique_used',
        parameters: {'technique': technique},
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // Track Dr. Iris interactions
  static Future<void> logDrIrisChat({
    required String query,
    required String responseType, // 'on_device', 'fallback', 'error'
  }) async {
    try {
      await analytics.logEvent(
        name: 'dr_iris_chat',
        parameters: {
          'query_length': query.length,
          'response_type': responseType,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // Track user retention
  static Future<void> logDailyLogin({
    required int streak,
    required bool earnedReward,
  }) async {
    try {
      await analytics.logEvent(
        name: 'daily_login',
        parameters: {'streak': streak, 'earned_reward': earnedReward},
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // Set user properties
  static Future<void> setUserProperties({
    int? totalCoins,
    int? loginStreak,
    String? preferredLanguage,
  }) async {
    try {
      if (totalCoins != null) {
        await analytics.setUserProperty(
          name: 'total_coins',
          value: totalCoins.toString(),
        );
      }
      if (loginStreak != null) {
        await analytics.setUserProperty(
          name: 'login_streak',
          value: loginStreak.toString(),
        );
      }
      if (preferredLanguage != null) {
        await analytics.setUserProperty(
          name: 'preferred_language',
          value: preferredLanguage,
        );
      }
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }
}
