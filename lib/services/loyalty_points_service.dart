import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// TrueCircle Loyalty Points System
/// Daily login rewards: 1 point = ₹1
/// Maximum discount: 15% (User pays minimum 85%)
/// Points can be used for gift purchases
class LoyaltyPointsService extends ChangeNotifier {
  static const String _boxName = 'loyalty_points';
  static const String _pointsKey = 'total_points';
  static const String _lastLoginKey = 'last_login_date';
  static const String _loginStreakKey = 'login_streak';
  static const String _pointsHistoryKey = 'points_history';

  // Constants
  static const int dailyLoginPoints = 1; // 1 point per day
  static const double maxDiscountPercent = 15.0; // 15% maximum discount
  static const double minPaymentPercent = 85.0; // User must pay at least 85%

  static LoyaltyPointsService? _instance;
  static LoyaltyPointsService get instance =>
      _instance ??= LoyaltyPointsService._internal();

  LoyaltyPointsService._internal() {
    _initializeService();
  }

  int _totalPoints = 0;
  int _loginStreak = 0;
  List<PointsTransaction> _pointsHistory = [];
  bool _isInitialized = false;

  // Getters
  int get totalPoints => _totalPoints;
  int get loginStreak => _loginStreak;
  List<PointsTransaction> get pointsHistory =>
      List.unmodifiable(_pointsHistory);
  bool get isInitialized => _isInitialized;

  /// Initialize the loyalty points service
  Future<void> _initializeService() async {
    try {
      await Hive.openBox(_boxName);
      final box = Hive.box(_boxName);

      _totalPoints = box.get(_pointsKey, defaultValue: 0);
      _loginStreak = box.get(_loginStreakKey, defaultValue: 0);

      // Load points history
      final historyData = box.get(_pointsHistoryKey, defaultValue: <dynamic>[]);
      _pointsHistory = (historyData as List<dynamic>)
          .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return PointsTransaction.fromMap(item);
              } else if (item is Map) {
                return PointsTransaction.fromMap(
                    Map<String, dynamic>.from(item));
              }
              return null;
            } catch (e) {
              debugPrint('Error parsing points transaction: $e');
              return null;
            }
          })
          .where((item) => item != null)
          .cast<PointsTransaction>()
          .toList();

      _isInitialized = true;
      notifyListeners();

      debugPrint(
          '✅ Loyalty Points Service initialized - Total Points: $_totalPoints, Streak: $_loginStreak');
    } catch (e) {
      debugPrint('❌ Error initializing Loyalty Points Service: $e');
      _isInitialized = false;
    }
  }

  /// Check daily login and award points
  Future<DailyLoginResult> processDailyLogin() async {
    if (!_isInitialized) await _initializeService();

    final box = Hive.box(_boxName);
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final lastLoginStr = box.get(_lastLoginKey, defaultValue: '');

    // Check if already logged in today
    if (lastLoginStr == todayStr) {
      return DailyLoginResult(
        pointsAwarded: 0,
        totalPoints: _totalPoints,
        loginStreak: _loginStreak,
        isFirstLoginToday: false,
        message: 'आज आप पहले से ही login कर चुके हैं! कल वापस आएं।',
        messageEn: 'You have already logged in today! Come back tomorrow.',
      );
    }

    // Calculate streak
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayStr =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    if (lastLoginStr == yesterdayStr) {
      // Continue streak
      _loginStreak++;
    } else if (lastLoginStr.isEmpty) {
      // First time login
      _loginStreak = 1;
    } else {
      // Streak broken
      _loginStreak = 1;
    }

    // Calculate bonus points for streak
    int pointsToAward = dailyLoginPoints;
    if (_loginStreak >= 7) {
      pointsToAward += 2; // Bonus for weekly streak
    } else if (_loginStreak >= 30) {
      pointsToAward += 5; // Bonus for monthly streak
    }

    // Award points
    await _addPoints(
        pointsToAward, 'Daily Login Reward', 'दैनिक लॉगिन रिवार्ड');

    // Update last login date
    await box.put(_lastLoginKey, todayStr);
    await box.put(_loginStreakKey, _loginStreak);

    String message =
        'बधाई हो! $pointsToAward points मिले। Total: $_totalPoints points';
    String messageEn =
        'Congratulations! Earned $pointsToAward points. Total: $_totalPoints points';

    if (_loginStreak >= 7) {
      message += '\n🔥 $_loginStreak दिन की streak! Bonus मिला!';
      messageEn += '\n🔥 $_loginStreak day streak! Bonus earned!';
    }

    return DailyLoginResult(
      pointsAwarded: pointsToAward,
      totalPoints: _totalPoints,
      loginStreak: _loginStreak,
      isFirstLoginToday: true,
      message: message,
      messageEn: messageEn,
    );
  }

  /// Add points to user account
  Future<void> _addPoints(int points, String reasonEn, String reasonHi) async {
    if (!_isInitialized) await _initializeService();

    _totalPoints += points;

    // Add transaction to history
    final transaction = PointsTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.earned,
      points: points,
      timestamp: DateTime.now(),
      reasonEn: reasonEn,
      reasonHi: reasonHi,
      balanceAfter: _totalPoints,
    );

    _pointsHistory.insert(0, transaction);

    // Keep only last 100 transactions
    if (_pointsHistory.length > 100) {
      _pointsHistory = _pointsHistory.take(100).toList();
    }

    // Save to storage
    final box = Hive.box(_boxName);
    await box.put(_pointsKey, _totalPoints);
    await box.put(
        _pointsHistoryKey, _pointsHistory.map((t) => t.toMap()).toList());

    notifyListeners();
    debugPrint('💰 Points added: $points, Total: $_totalPoints');
  }

  /// Use points for purchase (with discount limitations)
  Future<PurchaseResult> usePointsForPurchase({
    required String itemName,
    required double originalPrice,
    required int pointsToUse,
  }) async {
    if (!_isInitialized) await _initializeService();

    // Validation checks
    if (pointsToUse > _totalPoints) {
      return PurchaseResult(
        success: false,
        error:
            'Insufficient points! You have $_totalPoints points, but trying to use $pointsToUse',
        errorHi:
            'पर्याप्त points नहीं हैं! आपके पास $_totalPoints points हैं, लेकिन $pointsToUse use करने की कोशिश कर रहे हैं।',
      );
    }

    // Calculate maximum allowed discount (15% of original price)
    final maxDiscountAmount = originalPrice * (maxDiscountPercent / 100);
    final maxPointsUsable = maxDiscountAmount.floor(); // 1 point = ₹1

    // Limit points usage to maximum discount
    final actualPointsToUse =
        pointsToUse > maxPointsUsable ? maxPointsUsable : pointsToUse;
    final discountAmount = actualPointsToUse.toDouble();
    final finalPrice = originalPrice - discountAmount;
    final userPayment = finalPrice;
    final userPaymentPercent = (userPayment / originalPrice) * 100;

    // Ensure user pays at least 85%
    if (userPaymentPercent < minPaymentPercent) {
      return PurchaseResult(
        success: false,
        error:
            'Maximum discount of $maxDiscountPercent% exceeded. You must pay at least ${minPaymentPercent.toStringAsFixed(0)}%',
        errorHi:
            'अधिकतम $maxDiscountPercent% छूट पार हो गई। आपको कम से कम ${minPaymentPercent.toStringAsFixed(0)}% भुगतान करना होगा।',
      );
    }

    // Process the purchase
    await _deductPoints(actualPointsToUse, 'Gift Purchase: $itemName',
        'उपहार खरीदी: $itemName');

    return PurchaseResult(
      success: true,
      originalPrice: originalPrice,
      discountAmount: discountAmount,
      finalPrice: finalPrice,
      pointsUsed: actualPointsToUse,
      pointsRequested: pointsToUse,
      remainingPoints: _totalPoints,
      userPaymentPercent: userPaymentPercent,
      maxDiscountReached: actualPointsToUse == maxPointsUsable,
    );
  }

  /// Deduct points from user account
  Future<void> _deductPoints(
      int points, String reasonEn, String reasonHi) async {
    if (points > _totalPoints) {
      throw Exception('Insufficient points');
    }

    _totalPoints -= points;

    // Add transaction to history
    final transaction = PointsTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.spent,
      points: -points, // Negative for spent
      timestamp: DateTime.now(),
      reasonEn: reasonEn,
      reasonHi: reasonHi,
      balanceAfter: _totalPoints,
    );

    _pointsHistory.insert(0, transaction);

    // Save to storage
    final box = Hive.box(_boxName);
    await box.put(_pointsKey, _totalPoints);
    await box.put(
        _pointsHistoryKey, _pointsHistory.map((t) => t.toMap()).toList());

    notifyListeners();
    debugPrint('💸 Points deducted: $points, Total: $_totalPoints');
  }

  /// Calculate discount for a given price and points
  DiscountCalculation calculateDiscount(double price, int pointsToUse) {
    final maxDiscountAmount = price * (maxDiscountPercent / 100);
    final maxPointsUsable = maxDiscountAmount.floor();

    final actualPointsToUse =
        pointsToUse > maxPointsUsable ? maxPointsUsable : pointsToUse;
    final actualPointsToUse2 =
        actualPointsToUse > _totalPoints ? _totalPoints : actualPointsToUse;

    final discountAmount = actualPointsToUse2.toDouble();
    final finalPrice = price - discountAmount;
    final paymentPercent = (finalPrice / price) * 100;

    return DiscountCalculation(
      originalPrice: price,
      requestedPoints: pointsToUse,
      maxPointsUsable: maxPointsUsable,
      actualPointsToUse: actualPointsToUse2,
      discountAmount: discountAmount,
      finalPrice: finalPrice,
      paymentPercent: paymentPercent,
      isMaxDiscountReached: actualPointsToUse2 == maxPointsUsable,
      hasInsufficientPoints: pointsToUse > _totalPoints,
    );
  }

  /// Get points summary
  PointsSummary getPointsSummary() {
    final recentTransactions = _pointsHistory.take(10).toList();
    final totalEarned = _pointsHistory
        .where((t) => t.type == TransactionType.earned)
        .fold(0, (sum, t) => sum + t.points.abs());
    final totalSpent = _pointsHistory
        .where((t) => t.type == TransactionType.spent)
        .fold(0, (sum, t) => sum + t.points.abs());

    return PointsSummary(
      totalPoints: _totalPoints,
      totalEarned: totalEarned,
      totalSpent: totalSpent,
      loginStreak: _loginStreak,
      recentTransactions: recentTransactions,
    );
  }

  /// Reset all points (for testing/admin)
  Future<void> resetPoints() async {
    if (!_isInitialized) return;

    final box = Hive.box(_boxName);
    await box.clear();

    _totalPoints = 0;
    _loginStreak = 0;
    _pointsHistory.clear();

    notifyListeners();
    debugPrint('🔄 All points reset');
  }
}

/// Daily login result
class DailyLoginResult {
  final int pointsAwarded;
  final int totalPoints;
  final int loginStreak;
  final bool isFirstLoginToday;
  final String message;
  final String messageEn;

  DailyLoginResult({
    required this.pointsAwarded,
    required this.totalPoints,
    required this.loginStreak,
    required this.isFirstLoginToday,
    required this.message,
    required this.messageEn,
  });
}

/// Purchase result with discount calculation
class PurchaseResult {
  final bool success;
  final String? error;
  final String? errorHi;
  final double originalPrice;
  final double discountAmount;
  final double finalPrice;
  final int pointsUsed;
  final int pointsRequested;
  final int remainingPoints;
  final double userPaymentPercent;
  final bool maxDiscountReached;

  PurchaseResult({
    required this.success,
    this.error,
    this.errorHi,
    this.originalPrice = 0,
    this.discountAmount = 0,
    this.finalPrice = 0,
    this.pointsUsed = 0,
    this.pointsRequested = 0,
    this.remainingPoints = 0,
    this.userPaymentPercent = 100,
    this.maxDiscountReached = false,
  });
}

/// Discount calculation helper
class DiscountCalculation {
  final double originalPrice;
  final int requestedPoints;
  final int maxPointsUsable;
  final int actualPointsToUse;
  final double discountAmount;
  final double finalPrice;
  final double paymentPercent;
  final bool isMaxDiscountReached;
  final bool hasInsufficientPoints;

  DiscountCalculation({
    required this.originalPrice,
    required this.requestedPoints,
    required this.maxPointsUsable,
    required this.actualPointsToUse,
    required this.discountAmount,
    required this.finalPrice,
    required this.paymentPercent,
    required this.isMaxDiscountReached,
    required this.hasInsufficientPoints,
  });
}

/// Points summary for dashboard
class PointsSummary {
  final int totalPoints;
  final int totalEarned;
  final int totalSpent;
  final int loginStreak;
  final List<PointsTransaction> recentTransactions;

  PointsSummary({
    required this.totalPoints,
    required this.totalEarned,
    required this.totalSpent,
    required this.loginStreak,
    required this.recentTransactions,
  });
}

/// Points transaction record
class PointsTransaction {
  final String id;
  final TransactionType type;
  final int points; // Positive for earned, negative for spent
  final DateTime timestamp;
  final String reasonEn;
  final String reasonHi;
  final int balanceAfter;

  PointsTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.timestamp,
    required this.reasonEn,
    required this.reasonHi,
    required this.balanceAfter,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'points': points,
      'timestamp': timestamp.toIso8601String(),
      'reasonEn': reasonEn,
      'reasonHi': reasonHi,
      'balanceAfter': balanceAfter,
    };
  }

  factory PointsTransaction.fromMap(Map<String, dynamic> map) {
    return PointsTransaction(
      id: map['id'],
      type: TransactionType.values[map['type']],
      points: map['points'],
      timestamp: DateTime.parse(map['timestamp']),
      reasonEn: map['reasonEn'],
      reasonHi: map['reasonHi'],
      balanceAfter: map['balanceAfter'],
    );
  }
}

enum TransactionType {
  earned,
  spent,
}
