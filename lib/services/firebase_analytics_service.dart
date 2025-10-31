import 'package:true_circle/core/log_service.dart';

/// Offline analytics stub used when Firebase is removed.
///
/// Keeps the same public API surface (static methods) but performs
/// no external network calls. Writes events to local LogService so
/// developers can inspect them in debug builds.
class FirebaseAnalyticsService {
  FirebaseAnalyticsService._();

  static Future<void> _log(String tag, Map<String, Object?> details) async {
    LogService.instance.log('[ANALYTICS STUB] $tag: $details');
  }

  static Future<void> logCoinEarned({
    required String source,
    required int amount,
    int? streak,
  }) async {
    await _log('coin_earned', {
      'source': source,
      'amount': amount,
      if (streak != null) 'streak': streak,
    });
  }

  static Future<void> logCoinSpent({
    required String item,
    required int amount,
    required double originalPrice,
    required double discountPercent,
  }) async {
    await _log('coin_spent', {
      'item_name': item,
      'coin_amount': amount,
      'original_price': originalPrice,
      'discount_percent': discountPercent,
    });
  }

  static Future<void> logScreenView(String screenName) async {
    await _log('screen_view', {'screen': screenName});
  }

  static Future<void> logCBTTechniqueUsed(String technique) async {
    await _log('cbt_technique_used', {'technique': technique});
  }

  static Future<void> logDrIrisChat({
    required String query,
    required String responseType,
  }) async {
    await _log('dr_iris_chat', {
      'query_length': query.length,
      'response_type': responseType,
    });
  }

  static Future<void> logDailyLogin({
    required int streak,
    required bool earnedReward,
  }) async {
    await _log('daily_login', {
      'streak': streak,
      'earned_reward': earnedReward,
    });
  }

  static Future<void> setUserProperties({
    int? totalCoins,
    int? loginStreak,
    String? preferredLanguage,
  }) async {
    await _log('set_user_properties', {
      if (totalCoins != null) 'total_coins': totalCoins,
      if (loginStreak != null) 'login_streak': loginStreak,
      if (preferredLanguage != null) 'preferred_language': preferredLanguage,
    });
  }
}
