import 'package:flutter/material.dart';
import '../services/coin_reward_service.dart';
import 'rotating_coin.dart';
import 'sunburst_effect.dart';
import 'coin_earn_animation_dialog.dart';
import '../models/coin_reward.dart';

class CoinDisplayWidget extends StatefulWidget {
  final String userId;
  final bool showHistory;

  const CoinDisplayWidget({
    super.key,
    required this.userId,
    this.showHistory = false,
  });

  @override
  State<CoinDisplayWidget> createState() => _CoinDisplayWidgetState();
}

class _CoinDisplayWidgetState extends State<CoinDisplayWidget> {
  int _totalCoins = 0;
  int _availableCoins = 0;
  List<CoinReward> _rewardHistory = [];
  bool _isLoading = true;
  bool _showSunburst = false;

  @override
  void initState() {
    super.initState();
    _loadCoinData();
  }

  Future<void> _loadCoinData() async {
    try {
      final total = await CoinRewardService.instance.getUserCoinsCount();
      final available = total;

      if (widget.showHistory) {
        final history = await CoinRewardService.instance.getUserRewardHistory();
        setState(() {
          _rewardHistory = history;
        });
      }

      setState(() {
        _totalCoins = total;
        _availableCoins = available;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    return Column(
      children: [
        _buildCoinSummaryCard(),
        if (widget.showHistory) ...[
          const SizedBox(height: 16),
          _buildRewardHistoryCard(),
        ],
      ],
    );
  }

  Widget _buildCoinSummaryCard() {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.amber.shade400, Colors.orange.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                // Trigger sunburst effect when coin is tapped
                setState(() => _showSunburst = true);
                await Future.delayed(const Duration(milliseconds: 900));
                if (mounted) setState(() => _showSunburst = false);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const RotatingCoin(size: 32, tint: Colors.white),
                    if (_showSunburst)
                      const SizedBox(
                        width: 120,
                        height: 120,
                        child: SunburstEffect(size: 120, color: Colors.amber),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your TrueCircle Coins',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$_availableCoins',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Available / $_totalCoins total',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _showCoinInfoDialog(context),
                    child: Row(
                      children: [
                        Text(
                          'Get ₹$_availableCoins shopping discount!',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.info_outline,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _loadCoinData,
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardHistoryCard() {
    if (_rewardHistory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'No coins earned yet',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Add conversations and login daily!',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Coin History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _rewardHistory.take(10).length, // Last 10 entries
            itemBuilder: (context, index) {
              final reward = _rewardHistory[index];
              return _buildRewardHistoryTile(reward);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRewardHistoryTile(CoinReward reward) {
    IconData icon;
    Color iconColor;
    String typeText;

    switch (reward.type) {
      case CoinTransactionType.dailyLogin:
        icon = Icons.login;
        iconColor = Colors.green;
        typeText = 'Daily login';
        break;
      case CoinTransactionType.entryReward:
        icon = Icons.add_comment;
        iconColor = Colors.blue;
        typeText = 'New entry';
        break;
      case CoinTransactionType.bonus:
        icon = Icons.star;
        iconColor = Colors.amber;
        typeText = 'Bonus';
        break;
      case CoinTransactionType.marketplacePurchase:
        icon = Icons.shopping_cart;
        iconColor = Colors.red;
        typeText = 'Spent';
        break;
    }

    return ListTile(
      dense: true,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        reward.description ?? '',
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        '$typeText • ${_formatDate(reward.timestamp)}',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Text(
        '${reward.amount > 0 ? '+' : ''}${reward.amount}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: reward.amount > 0 ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'just now';
    }
  }

  void _showCoinInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Image.asset(
              'assets/images/TrueCircle_Coin.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 24,
                );
              },
            ),
            const SizedBox(width: 8),
            const Text('How TrueCircle coins work'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoSection('🎯 How to earn coins', [
                'Daily login: 1 coin per day',
                'Fill all entry fields completely: 1 coin',
                'Note: No rewards for chatting with Dr. Iris',
              ]),
              const SizedBox(height: 16),
              _buildInfoSection('💰 How to spend coins', [
                '1 coin = ₹1 shopping discount',
                'Use in marketplace for premium features',
                'Redeem for special content',
                'Save up for special rewards',
              ]),
              const SizedBox(height: 16),
              _buildInfoSection('📊 Coin types', [
                'Available coins: ready to spend',
                'Total coins: lifetime earnings',
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...points.map(
          (point) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(point)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Daily Login Reward Check Widget (use on app startup)
class DailyLoginChecker extends StatelessWidget {
  final String userId;
  final VoidCallback? onRewardReceived;

  const DailyLoginChecker({
    super.key,
    required this.userId,
    this.onRewardReceived,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: CoinRewardService.instance.isDailyRewardAvailable(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            // Show animation dialog first, then finalize the reward.
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const CoinEarnAnimationDialog(),
            );

            try {
              await CoinRewardService.instance.finalizeDailyReward();
            } catch (_) {}
            onRewardReceived?.call();
          });
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// Dialog implementation moved to `coin_earn_animation_dialog.dart` to
// allow global reuse by a reward listener.
