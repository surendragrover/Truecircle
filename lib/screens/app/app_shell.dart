import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../l10n/app_strings.dart';
import '../../services/reward_service.dart';
import '../../services/streak_service.dart';
import '../../theme/truecircle_theme.dart';
import '../../widgets/coin_reward_celebration.dart';
import '../chat/dr_iris_chat_screen.dart';
import '../checkin/checkin_screen.dart';
import '../content/json_content_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../settings/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final RewardService _rewardService = RewardService();
  bool _isOnline = false;

  static const List<Widget> _pages = <Widget>[
    DashboardScreen(),
    CheckInScreen(),
    DrIrisChatScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _isOnline = _readOnlineStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final RewardGrantResult result =
          await _rewardService.grantDailyLoginCoinIfEligible();
      if (result.granted) {
        await StreakService.markDailyLoginDone();
        if (!mounted) return;
        await CoinRewardCelebration.show(
          context,
          message: 'Daily Login Reward! +1 coin. Wallet: ${result.balance}',
        );
        // Check if 7-day streak bonus was triggered
        final int streak = await StreakService.currentStreak();
        if (streak == 0) {
          // streak reset to 0 means bonus was just awarded
          if (!mounted) return;
          await CoinRewardCelebration.show(
            context,
            message: '🎉 7-Day Streak Bonus! +10 coins.',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: _buildAppBarTitle(),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => _setOnlineStatus(!_isOnline),
              child: Container(
                constraints: const BoxConstraints(minWidth: 126),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _isOnline ? Colors.green.shade600 : Colors.orange.shade700,
                    width: 1.6,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      _isOnline ? Icons.wifi : Icons.wifi_off,
                      size: 18,
                      color: _isOnline ? Colors.green.shade700 : Colors.orange.shade800,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isOnline
                          ? AppStrings.t(context, 'mode_online_short')
                          : AppStrings.t(context, 'mode_offline_short'),
                      style: TextStyle(
                        color:
                            _isOnline ? Colors.green.shade700 : Colors.orange.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          PopupMenuButton<_AppMenuAction>(
            icon: const Icon(Icons.more_vert),
            onSelected: _onMenuSelected,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<_AppMenuAction>>[
              PopupMenuItem<_AppMenuAction>(
                value: _AppMenuAction.settings,
                child: Text(AppStrings.t(context, 'settings')),
              ),
              PopupMenuItem<_AppMenuAction>(
                value: _AppMenuAction.faq,
                child: Text(AppStrings.t(context, 'faq')),
              ),
              PopupMenuItem<_AppMenuAction>(
                value: _AppMenuAction.howItWorks,
                child: Text(AppStrings.t(context, 'how_it_works')),
              ),
              PopupMenuItem<_AppMenuAction>(
                value: _AppMenuAction.terms,
                child: Text('T&C'),
              ),
              PopupMenuItem<_AppMenuAction>(
                value: _AppMenuAction.privacy,
                child: Text(AppStrings.t(context, 'privacy_policy')),
              ),
              PopupMenuItem<_AppMenuAction>(
                value: _AppMenuAction.wallet,
                child: Text(AppStrings.t(context, 'wallet')),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: TrueCircleTheme.appBackgroundGradient,
        ),
        child: SafeArea(child: _pages[_index]),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0x26FFFFFF),
          indicatorColor: Colors.white24,
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
              (Set<WidgetState> states) {
            final bool selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? Colors.white : Colors.white70,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
              (Set<WidgetState> states) {
            final bool selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (int index) {
            setState(() {
              _index = index;
            });
          },
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: AppStrings.t(context, 'dashboard'),
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite),
              label: AppStrings.t(context, 'check_in'),
            ),
            NavigationDestination(
              icon: _drIrisNavAvatar(selected: false),
              selectedIcon: _drIrisNavAvatar(selected: true),
              label: 'Dr Iris',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: AppStrings.t(context, 'settings'),
            ),
          ],
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

  Future<void> _setOnlineStatus(bool value) async {
    if (!Hive.isBoxOpen('appBox')) return;
    await Hive.box('appBox').put('is_online', value);
    if (!mounted) return;
    setState(() {
      _isOnline = value;
    });
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

  Widget _buildAppBarTitle() {
    if (_index == 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircleAvatar(
            radius: 12,
            backgroundImage:
                const AssetImage('assets/images/dr_iris_avatar.png'),
          ),
          const SizedBox(width: 8),
          const Text('Dr Iris'),
        ],
      );
    }
    return Text(
      _index == 0
          ? AppStrings.t(context, 'truecircle')
          : _index == 1
              ? AppStrings.t(context, 'daily_check_in')
              : AppStrings.t(context, 'settings'),
    );
  }

  static Widget _drIrisNavAvatar({required bool selected}) {
    return CircleAvatar(
      radius: selected ? 12 : 11,
      backgroundColor: Colors.white.withValues(alpha: selected ? 0.30 : 0.18),
      child: CircleAvatar(
        radius: selected ? 10 : 9,
        backgroundImage: const AssetImage('assets/images/dr_iris_avatar.png'),
      ),
    );
  }

  void _onMenuSelected(_AppMenuAction action) {
    switch (action) {
      case _AppMenuAction.settings:
        setState(() {
          _index = 3;
        });
        return;
      case _AppMenuAction.faq:
        _openInfoPage(
          title: AppStrings.t(context, 'faq'),
          assetPath: 'assets/data/faq.json',
        );
        return;
      case _AppMenuAction.howItWorks:
        _openInfoPage(
          title: AppStrings.t(context, 'how_it_works'),
          assetPath: 'assets/data/how_it_works.json',
        );
        return;
      case _AppMenuAction.terms:
        _openInfoPage(
          title: AppStrings.t(context, 'terms_conditions'),
          assetPath: 'assets/data/terms_conditions.json',
        );
        return;
      case _AppMenuAction.privacy:
        _openInfoPage(
          title: AppStrings.t(context, 'privacy_policy'),
          assetPath: 'assets/data/Privacy_Policy.JSON',
        );
        return;
      case _AppMenuAction.wallet:
        _openWalletDialog();
        return;
    }
  }

  void _openInfoPage({
    required String title,
    required String assetPath,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JsonContentScreen(
          title: title,
          assetPath: assetPath,
        ),
      ),
    );
  }

  Future<void> _openWalletDialog() async {
    final RewardWalletState state = await _rewardService.walletState();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.t(context, 'wallet')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppStrings.t(
                  context,
                  'wallet_coins',
                  args: <String, String>{'coins': state.balance.toString()},
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.t(
                  context,
                  'wallet_membership',
                  args: <String, String>{'tier': state.membershipTier},
                ),
              ),
              if (state.freeUpgradeUntilIso.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  AppStrings.t(
                    context,
                    'wallet_free_upgrade_until',
                    args: <String, String>{'time': state.freeUpgradeUntilIso},
                  ),
                ),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                final result = await _rewardService.redeemMembershipDiscount();
                if (!mounted) return;
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.message)),
                );
              },
              child: Text(AppStrings.t(context, 'use_coins')),
            ),
            FilledButton(
              onPressed: () async {
                final result = await _rewardService.activateFreeUpgrade();
                if (!mounted) return;
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.message)),
                );
              },
              child: const Text('Free Upgrade'),
            ),
          ],
        );
      },
    );
  }
}

enum _AppMenuAction {
  settings,
  faq,
  howItWorks,
  terms,
  privacy,
  wallet,
}
