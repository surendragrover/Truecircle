import 'package:hive_flutter/hive_flutter.dart';
import 'billing_service.dart';

class RewardGrantResult {
  const RewardGrantResult({
    required this.granted,
    required this.balance,
    required this.reason,
  });

  final bool granted;
  final int balance;
  final String reason;
}

class RewardWalletState {
  const RewardWalletState({
    required this.balance,
    required this.membershipTier,
    required this.freeUpgradeUntilIso,
  });

  final int balance;
  final String membershipTier;
  final String freeUpgradeUntilIso;
}

class RewardService {
  static const String _coinBalanceKey = 'coin_balance';
  static const String _lastDailyLoginDateKey = 'last_daily_login_date';
  static const String _membershipTierKey = 'membership_tier';
  static const String _freeUpgradeUntilKey = 'free_upgrade_until';
  static const String _lastFreeUpgradeAtKey = 'last_free_upgrade_at';
  static const String _userIdKey = 'reward_user_id';
  static const int _freeUpgradeCoinCost = 5;
  static const Duration _cooldown24h = Duration(hours: 24);
  static const int _freemiumDailyChatLimit = 8;
  static const int _contributorDailyChatLimit = 30;
  static const int _eliteDailyChatLimit = 150;
  final BillingService _billingService = BillingService();

  Box<dynamic> _userBox() => Hive.box('userBox');

  Future<RewardWalletState> walletState() async {
    final Box<dynamic> box = _userBox();
    await _refreshTimeBoundMembership(box);
    final String rawTier =
        (box.get(_membershipTierKey, defaultValue: 'basic') as String?) ??
            'basic';
    final String normalizedTier = normalizeMembershipTier(rawTier);
    return RewardWalletState(
      balance: (box.get(_coinBalanceKey, defaultValue: 0) as int?) ?? 0,
      membershipTier: normalizedTier,
      freeUpgradeUntilIso:
          (box.get(_freeUpgradeUntilKey, defaultValue: '') as String?) ?? '',
    );
  }

  Future<String> currentMembershipTier() async {
    final Box<dynamic> box = _userBox();
    await _refreshTimeBoundMembership(box);
    final String rawTier =
        (box.get(_membershipTierKey, defaultValue: 'basic') as String?) ??
            'basic';
    return normalizeMembershipTier(rawTier);
  }

  String normalizeMembershipTier(String rawTier) {
    switch (rawTier.trim().toLowerCase()) {
      case 'freemium':
      case 'basic':
        return 'freemium';
      case 'contributor':
      case 'trial_plus':
      case 'plus':
        return 'contributor';
      case 'elite':
      case 'premium':
        return 'elite';
      default:
        return 'freemium';
    }
  }

  int dailyChatLimitForTier(String tier) {
    switch (normalizeMembershipTier(tier)) {
      case 'contributor':
        return _contributorDailyChatLimit;
      case 'elite':
        return _eliteDailyChatLimit;
      case 'freemium':
      default:
        return _freemiumDailyChatLimit;
    }
  }

  String tierTitle(String tier) {
    switch (normalizeMembershipTier(tier)) {
      case 'contributor':
        return 'Contributor';
      case 'elite':
        return 'Elite';
      case 'freemium':
      default:
        return 'Freemium';
    }
  }

  Future<RewardGrantResult> grantDailyLoginCoinIfEligible() async {
    final Box<dynamic> box = _userBox();
    final DateTime now = DateTime.now();
    final String today = '${now.year}-${now.month}-${now.day}';
    final String? lastDate = box.get(_lastDailyLoginDateKey) as String?;
    final int current =
        (box.get(_coinBalanceKey, defaultValue: 0) as int?) ?? 0;

    if (lastDate == today) {
      return RewardGrantResult(
        granted: false,
        balance: current,
        reason: 'Daily coin already claimed today.',
      );
    }

    final int next = current + 1;
    await box.put(_coinBalanceKey, next);
    await box.put(_lastDailyLoginDateKey, today);
    return RewardGrantResult(
      granted: true,
      balance: next,
      reason: 'Daily login reward',
    );
  }

  Future<RewardGrantResult> grantEntryFormCoin({
    required String formId,
  }) async {
    final Box<dynamic> box = _userBox();
    final int current =
        (box.get(_coinBalanceKey, defaultValue: 0) as int?) ?? 0;

    final int next = current + 1;
    await box.put(_coinBalanceKey, next);
    return RewardGrantResult(
      granted: true,
      balance: next,
      reason: 'Entry submitted: $formId',
    );
  }

  Future<BillingRedemptionResult> redeemMembershipDiscount() async {
    final Box<dynamic> box = _userBox();
    final int current =
        (box.get(_coinBalanceKey, defaultValue: 0) as int?) ?? 0;
    if (current < 5) {
      return const BillingRedemptionResult(
        success: false,
        message: 'Need at least 5 coins for discount.',
      );
    }
    final String userId = await _userId(box);
    final BillingRedemptionResult billing =
        await _billingService.redeemDiscount(
      userId: userId,
      coinsSpent: 5,
    );
    if (!billing.success) {
      return billing;
    }
    await box.put(_coinBalanceKey, current - 5);
    return billing;
  }

  Future<BillingRedemptionResult> activateFreeUpgrade() async {
    final Box<dynamic> box = _userBox();
    final DateTime now = DateTime.now();
    final String? lastAtIso = box.get(_lastFreeUpgradeAtKey) as String?;
    final int current =
        (box.get(_coinBalanceKey, defaultValue: 0) as int?) ?? 0;
    if (lastAtIso != null && lastAtIso.isNotEmpty) {
      final DateTime? lastAt = DateTime.tryParse(lastAtIso);
      if (lastAt != null) {
        final Duration diff = now.difference(lastAt);
        if (diff < _cooldown24h) {
          final Duration remaining = _cooldown24h - diff;
          return BillingRedemptionResult(
            success: false,
            message:
                'Free upgrade re-activates in ${_formatDuration(remaining)}.',
          );
        }
      }
    }
    if (current < _freeUpgradeCoinCost) {
      return BillingRedemptionResult(
        success: false,
        message: 'Need at least $_freeUpgradeCoinCost coins for free upgrade.',
      );
    }

    final String userId = await _userId(box);
    final BillingRedemptionResult billing =
        await _billingService.activateFreeUpgrade(userId: userId);
    if (!billing.success) return billing;

    final int next = current - _freeUpgradeCoinCost;
    final int hours = billing.freeUpgradeHours ?? 24;
    final DateTime until = now.add(Duration(hours: hours));
    await box.put(_coinBalanceKey, next);
    await box.put(_membershipTierKey, 'trial_plus');
    await box.put(_freeUpgradeUntilKey, until.toIso8601String());
    await box.put(_lastFreeUpgradeAtKey, now.toIso8601String());
    return BillingRedemptionResult(
      success: billing.success,
      message: '${billing.message} Coins used: $_freeUpgradeCoinCost.',
      couponCode: billing.couponCode,
      discountPercent: billing.discountPercent,
      freeUpgradeHours: billing.freeUpgradeHours,
    );
  }

  Future<BillingRedemptionResult> startPaidSubscription({
    required String tier,
  }) async {
    final Box<dynamic> box = _userBox();
    final String normalizedTier = normalizeMembershipTier(tier);
    if (normalizedTier == 'freemium') {
      return const BillingRedemptionResult(
        success: false,
        message: 'Freemium plan is already free. Choose Contributor or Elite.',
      );
    }
    final String userId = await _userId(box);
    return _billingService.startSubscriptionPayment(
      userId: userId,
      planTier: normalizedTier,
    );
  }

  Future<BillingRedemptionResult> confirmPaidSubscription({
    required String paymentId,
  }) async {
    final Box<dynamic> box = _userBox();
    final String userId = await _userId(box);
    final BillingRedemptionResult billing =
        await _billingService.confirmSubscriptionPayment(
      userId: userId,
      paymentId: paymentId,
    );
    if (!billing.success) {
      return billing;
    }

    final String rawTier = (billing.membershipTier ?? '').trim();
    if (rawTier.isNotEmpty) {
      await box.put(_membershipTierKey, rawTier);
      await box.put(_freeUpgradeUntilKey, '');
      await box.put(_lastFreeUpgradeAtKey, '');
    }
    return billing;
  }

  Future<String> _userId(Box<dynamic> box) async {
    final String existing =
        (box.get(_userIdKey, defaultValue: '') as String?) ?? '';
    if (existing.isNotEmpty) return existing;
    final String created = 'tc-${DateTime.now().millisecondsSinceEpoch}';
    await box.put(_userIdKey, created);
    return created;
  }

  String _formatDuration(Duration duration) {
    final int totalMinutes = duration.inMinutes;
    if (totalMinutes <= 0) return '0m';
    final int hours = totalMinutes ~/ 60;
    final int mins = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  Future<void> _refreshTimeBoundMembership(Box<dynamic> box) async {
    final String rawTier =
        (box.get(_membershipTierKey, defaultValue: 'basic') as String?) ??
            'basic';
    if (rawTier.trim().toLowerCase() != 'trial_plus') {
      return;
    }

    final String untilIso =
        (box.get(_freeUpgradeUntilKey, defaultValue: '') as String?) ?? '';
    final DateTime? until = DateTime.tryParse(untilIso);
    final DateTime now = DateTime.now();
    if (until == null || now.isAfter(until)) {
      await box.put(_membershipTierKey, 'basic');
      await box.put(_freeUpgradeUntilKey, '');
    }
  }
}
