import 'package:flutter/material.dart';
import '../services/coin_reward_service.dart';
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/images/TrueCircle_Coin.png',
                width: 32,
                height: 32,
                color: Colors.white,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                    size: 32,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'आपके TrueCircle Coins',
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
                        'उपलब्ध / $_totalCoins कुल',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹$_availableCoins की shopping discount मिलेगी!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11,
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
                'अभी तक कोई coins नहीं मिले',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Conversations add करें और daily login करें!',
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
        typeText = 'दैनिक लॉगिन';
        break;
      case CoinTransactionType.entryReward:
        icon = Icons.add_comment;
        iconColor = Colors.blue;
        typeText = 'नई Entry';
        break;
      case CoinTransactionType.bonus:
        icon = Icons.star;
        iconColor = Colors.amber;
        typeText = 'बोनस';
        break;
      case CoinTransactionType.marketplacePurchase:
        icon = Icons.shopping_cart;
        iconColor = Colors.red;
        typeText = 'इस्तेमाल';
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
      return '${difference.inDays} दिन पहले';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} घंटे पहले';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} मिनट पहले';
    } else {
      return 'अभी';
    }
  }
}

// Daily Login Reward Check Widget (App startup पर use करें)
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
    return FutureBuilder<Map<String, dynamic>>(
      future: CoinRewardService.instance.checkAndGiveDailyReward(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?['rewarded'] == true) {
          // Daily reward मिला है!
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showDailyRewardDialog(context);
            onRewardReceived?.call();
          });
        }
        return const SizedBox.shrink(); // Invisible widget
      },
    );
  }

  void _showDailyRewardDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Image.asset(
                'assets/images/TrueCircle_Coin.png',
                width: 50,
                height: 50,
                color: Colors.amber,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.monetization_on,
                    size: 50,
                    color: Colors.amber,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '🎉 दैनिक बोनस मिला!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'आज का 1 coin reward मिल गया!\nकल फिर से आएं और ज्यादा coins पाएं।',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('धन्यवाद!'),
            ),
          ],
        ),
      ),
    );
  }
}
