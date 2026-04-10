import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BillingRedemptionResult {
  const BillingRedemptionResult({
    required this.success,
    required this.message,
    this.couponCode,
    this.discountPercent,
    this.freeUpgradeHours,
    this.paymentId,
    this.paymentUrl,
    this.membershipTier,
  });

  final bool success;
  final String message;
  final String? couponCode;
  final int? discountPercent;
  final int? freeUpgradeHours;
  final String? paymentId;
  final String? paymentUrl;
  final String? membershipTier;
}

class BillingService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://truecircleai.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  Future<BillingRedemptionResult> redeemDiscount({
    required String userId,
    required int coinsSpent,
  }) async {
    final bool isOnline = _isOnlineMode();
    if (!isOnline) {
      return const BillingRedemptionResult(
        success: false,
        message:
            'Internet required to redeem discount. Please enable online mode in Settings.',
      );
    }
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/api/rewards/redeem-discount',
        data: <String, dynamic>{
          'user_id': userId,
          'coins_spent': coinsSpent,
        },
      );
      final Map<String, dynamic> data = (response.data is Map<String, dynamic>)
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      return BillingRedemptionResult(
        success: (data['success'] as bool?) ?? true,
        message: (data['message'] as String?) ?? 'Discount unlocked.',
        couponCode: data['coupon_code'] as String?,
        discountPercent: (data['discount_percent'] as num?)?.toInt() ?? 20,
      );
    } catch (_) {
      return const BillingRedemptionResult(
        success: false,
        message:
            'Could not connect to payment server. Please try again in online mode.',
      );
    }
  }

  Future<BillingRedemptionResult> activateFreeUpgrade({
    required String userId,
  }) async {
    final bool isOnline = _isOnlineMode();
    if (!isOnline) {
      return const BillingRedemptionResult(
        success: false,
        message:
            'Internet required to activate upgrade. Please enable online mode in Settings.',
      );
    }
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/api/rewards/free-upgrade',
        data: <String, dynamic>{
          'user_id': userId,
        },
      );
      final Map<String, dynamic> data = (response.data is Map<String, dynamic>)
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      return BillingRedemptionResult(
        success: (data['success'] as bool?) ?? true,
        message: (data['message'] as String?) ?? 'Free upgrade activated.',
        freeUpgradeHours: (data['free_upgrade_hours'] as num?)?.toInt() ?? 24,
      );
    } catch (_) {
      return const BillingRedemptionResult(
        success: false,
        message:
            'Could not connect to payment server. Please try again in online mode.',
      );
    }
  }

  Future<BillingRedemptionResult> startSubscriptionPayment({
    required String userId,
    required String planTier,
  }) async {
    final bool isOnline = _isOnlineMode();
    if (!isOnline) {
      return const BillingRedemptionResult(
        success: false,
        message:
            'Internet required for payment. Please enable online mode before starting payment.',
      );
    }
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/api/billing/subscription/start',
        data: <String, dynamic>{
          'user_id': userId,
          'plan_tier': planTier,
        },
      );
      final Map<String, dynamic> data = (response.data is Map<String, dynamic>)
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      return BillingRedemptionResult(
        success: (data['success'] as bool?) ?? true,
        message: (data['message'] as String?) ??
            'Payment initiated. Complete payment and then confirm.',
        paymentId: data['payment_id'] as String?,
        paymentUrl: data['payment_url'] as String?,
      );
    } catch (_) {
      return const BillingRedemptionResult(
        success: false,
        message:
            'Could not start payment right now. Please check internet and try again.',
      );
    }
  }

  Future<BillingRedemptionResult> confirmSubscriptionPayment({
    required String userId,
    required String paymentId,
  }) async {
    final bool isOnline = _isOnlineMode();
    if (!isOnline) {
      return const BillingRedemptionResult(
        success: false,
        message:
            'Internet required for payment confirmation. Please enable online mode.',
      );
    }
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/api/billing/subscription/confirm',
        data: <String, dynamic>{
          'user_id': userId,
          'payment_id': paymentId,
        },
      );
      final Map<String, dynamic> data = (response.data is Map<String, dynamic>)
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      return BillingRedemptionResult(
        success: (data['success'] as bool?) ?? true,
        message: (data['message'] as String?) ??
            'Payment confirmed and subscription activated.',
        membershipTier: data['membership_tier'] as String?,
      );
    } catch (_) {
      return const BillingRedemptionResult(
        success: false,
        message:
            'Could not confirm payment right now. Please keep online mode enabled and try again.',
      );
    }
  }

  bool _isOnlineMode() {
    if (!Hive.isBoxOpen('appBox')) return false;
    final dynamic raw =
        Hive.box('appBox').get('is_online', defaultValue: false);
    return raw is bool ? raw : false;
  }
}
