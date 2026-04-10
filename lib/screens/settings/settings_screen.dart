import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../l10n/app_strings.dart';
import '../../services/app_language_service.dart';
import '../../services/reward_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _supportWhatsappHandle = 'wa.me/918690888121';
  static final Uri _supportWhatsappUri =
      Uri.parse('https://wa.me/918690888121');
  final RewardService _rewardService = RewardService();
  bool _isOnline = true;
  String _lastPaymentId = '';
  String _languageCode = 'en';

  Future<void> _openSupportWhatsapp(BuildContext context) async {
    final bool launched = await launchUrl(
      _supportWhatsappUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.t(context, 'unable_open_whatsapp')),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _isOnline = _readOnlineStatus();
    _languageCode = AppLanguageService.currentLanguageCode();
  }

  Future<void> _setLanguageCode(String code) async {
    await AppLanguageService.setLanguageCode(code);
    if (!mounted) return;
    setState(() {
      _languageCode = AppLanguageService.currentLanguageCode();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.t(
            context,
            'language_changed',
            args: <String, String>{
              'name': AppLanguageService.displayName(_languageCode),
            },
          ),
        ),
      ),
    );
  }

  Future<void> _setOnlineStatus(bool value) async {
    if (!Hive.isBoxOpen('appBox')) return;
    await Hive.box('appBox').put('is_online', value);
    setState(() {
      _isOnline = value;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? AppStrings.t(context, 'online_enabled')
              : AppStrings.t(context, 'offline_enabled'),
        ),
      ),
    );
  }

  bool _readOnlineStatus() {
    if (!Hive.isBoxOpen('appBox')) return false;
    final dynamic raw =
        Hive.box('appBox').get('is_online', defaultValue: false);
    return raw is bool ? raw : false;
  }

  Future<void> _openSubscriptionSheet() async {
    if (!_isOnline) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.t(context, 'online_required_payment_confirmation'),
          ),
        ),
      );
      return;
    }
    final RewardWalletState state = await _rewardService.walletState();
    final String currentTierTitle =
        _rewardService.tierTitle(state.membershipTier);
    final int currentTierLimit =
        _rewardService.dailyChatLimitForTier(state.membershipTier);
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppStrings.t(context, 'subscription_billing'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.t(
                    context,
                    'current_membership',
                    args: <String, String>{'tier': currentTierTitle},
                  ),
                ),
                Text(
                  AppStrings.t(
                    context,
                    'daily_chat_limit',
                    args: <String, String>{
                      'limit': currentTierLimit.toString(),
                    },
                  ),
                ),
                Text(
                  AppStrings.t(
                    context,
                    'available_coins',
                    args: <String, String>{'coins': state.balance.toString()},
                  ),
                ),
                if (state.freeUpgradeUntilIso.isNotEmpty)
                  Text(
                    AppStrings.t(
                      context,
                      'free_upgrade_till',
                      args: <String, String>{'time': state.freeUpgradeUntilIso},
                    ),
                  ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF7FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFB7D8FF)),
                  ),
                  child: Text(
                    AppStrings.t(context, 'payment_note'),
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.t(context, 'tier_limits'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(AppStrings.t(context, 'limit_freemium')),
                Text(AppStrings.t(context, 'limit_contributor')),
                Text(AppStrings.t(context, 'limit_elite')),
                Text(
                  AppStrings.t(context, 'limit_reset'),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.t(context, 'choose_option'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: Text(AppStrings.t(context, 'buy_contributor')),
                  subtitle: Text(AppStrings.t(context, 'buy_contributor_desc')),
                  onTap: () => _startPlanPurchase(
                    sheetContext: sheetContext,
                    tier: 'contributor',
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.diamond_outlined),
                  title: Text(AppStrings.t(context, 'buy_elite')),
                  subtitle: Text(AppStrings.t(context, 'buy_elite_desc')),
                  onTap: () => _startPlanPurchase(
                    sheetContext: sheetContext,
                    tier: 'elite',
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.verified_outlined),
                  title: Text(AppStrings.t(context, 'confirm_payment')),
                  subtitle: Text(AppStrings.t(context, 'confirm_payment_desc')),
                  onTap: () => _openConfirmPaymentDialog(
                    fromContext: sheetContext,
                    initialPaymentId: _lastPaymentId,
                  ),
                ),
                const Divider(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.local_offer_outlined),
                  title: Text(AppStrings.t(context, 'redeem_discount')),
                  subtitle: Text(AppStrings.t(context, 'redeem_discount_desc')),
                  onTap: () async {
                    final result =
                        await _rewardService.redeemMembershipDiscount();
                    if (!mounted) return;
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.message)),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bolt_outlined),
                  title: Text(AppStrings.t(context, 'activate_free_upgrade')),
                  subtitle:
                      Text(AppStrings.t(context, 'activate_free_upgrade_desc')),
                  onTap: () async {
                    final result = await _rewardService.activateFreeUpgrade();
                    if (!mounted) return;
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.message)),
                    );
                  },
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(AppStrings.t(context, 'close')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startPlanPurchase({
    required BuildContext sheetContext,
    required String tier,
  }) async {
    final result = await _rewardService.startPaidSubscription(tier: tier);
    if (!mounted) return;
    if (result.success) {
      final String paymentId = (result.paymentId ?? '').trim();
      if (paymentId.isNotEmpty) {
        _lastPaymentId = paymentId;
      }
    }
    if (sheetContext.mounted) {
      Navigator.of(sheetContext).pop();
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
    final String paymentUrl = (result.paymentUrl ?? '').trim();
    if (result.success && paymentUrl.isNotEmpty) {
      await launchUrl(
        Uri.parse(paymentUrl),
        mode: LaunchMode.externalApplication,
      );
    }
    if (result.success && mounted) {
      await _openConfirmPaymentDialog(
        fromContext: context,
        initialPaymentId: result.paymentId ?? _lastPaymentId,
      );
    }
  }

  Future<void> _openConfirmPaymentDialog({
    required BuildContext fromContext,
    String initialPaymentId = '',
  }) async {
    final TextEditingController paymentIdController = TextEditingController(
      text: initialPaymentId,
    );
    await showDialog<void>(
      context: fromContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.t(context, 'confirm_payment_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(AppStrings.t(context, 'confirm_payment_need_online')),
              const SizedBox(height: 10),
              TextField(
                controller: paymentIdController,
                decoration: InputDecoration(
                  labelText: AppStrings.t(context, 'payment_id'),
                  hintText: AppStrings.t(context, 'enter_payment_id'),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppStrings.t(context, 'cancel')),
            ),
            FilledButton(
              onPressed: () async {
                final String paymentId = paymentIdController.text.trim();
                if (paymentId.isEmpty) return;
                final result = await _rewardService.confirmPaidSubscription(
                  paymentId: paymentId,
                );
                if (!mounted) return;
                _lastPaymentId = paymentId;
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.message)),
                );
              },
              child: Text(AppStrings.t(context, 'confirm')),
            ),
          ],
        );
      },
    );
    paymentIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppStrings.t(context, 'connectivity'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(AppStrings.t(context, 'online_mode_required_payment')),
                  Switch(value: _isOnline, onChanged: _setOnlineStatus),
                ],
              ),
              Text(
                _isOnline
                    ? AppStrings.t(context, 'mode_online')
                    : AppStrings.t(context, 'mode_offline'),
                style: TextStyle(
                  color: _isOnline
                      ? Colors.green.shade700
                      : Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _isOnline ? _openSubscriptionSheet : null,
                icon: const Icon(Icons.payment),
                label: Text(AppStrings.t(context, 'upgrade_subscription')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppStrings.t(context, 'language'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.t(context, 'language_desc'),
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _languageCode,
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'en',
                    child: Text(AppStrings.t(context, 'english')),
                  ),
                  DropdownMenuItem<String>(
                    value: 'hi',
                    child: Text(AppStrings.t(context, 'hindi')),
                  ),
                ],
                onChanged: (String? value) {
                  if (value == null) return;
                  _setLanguageCode(value);
                },
                decoration: InputDecoration(
                  labelText: AppStrings.t(context, 'app_language'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppStrings.t(context, 'support'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.t(context, 'support_desc'),
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 4),
              const Text('Support WhatsApp: wa.me/918690888121',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () => _openSupportWhatsapp(context),
                icon: const Icon(Icons.chat),
                label: Text(
                  AppStrings.t(
                    context,
                    'contact_whatsapp',
                    args: <String, String>{'handle': _supportWhatsappHandle},
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
