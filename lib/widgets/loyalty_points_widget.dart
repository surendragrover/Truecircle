import 'package:flutter/material.dart';
import 'package:truecircle/services/loyalty_points_service.dart';
import 'package:truecircle/services/language_service.dart';
import 'package:truecircle/widgets/dr_iris_avatar.dart';

/// Loyalty Points Dashboard Widget
class LoyaltyPointsDashboard extends StatefulWidget {
  const LoyaltyPointsDashboard({super.key});

  @override
  State<LoyaltyPointsDashboard> createState() => _LoyaltyPointsDashboardState();
}

class _LoyaltyPointsDashboardState extends State<LoyaltyPointsDashboard> {
  final _loyaltyService = LoyaltyPointsService.instance;
  bool _isProcessingLogin = false;

  @override
  void initState() {
    super.initState();
    _checkDailyLogin();
  }

  Future<void> _checkDailyLogin() async {
    if (_isProcessingLogin) return;

    setState(() => _isProcessingLogin = true);

    try {
      final result = await _loyaltyService.processDailyLogin();

      if (result.isFirstLoginToday && result.pointsAwarded > 0) {
        _showDailyLoginDialog(result);
      }
    } catch (e) {
      debugPrint('Error processing daily login: $e');
    } finally {
      setState(() => _isProcessingLogin = false);
    }
  }

  void _showDailyLoginDialog(DailyLoginResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DrIrisAvatar(size: 80),
            const SizedBox(height: 16),
            Text(
              LanguageService.instance.isHindi
                  ? result.message
                  : result.messageEn,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '+${result.pointsAwarded} Points',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    LanguageService.instance.isHindi
                        ? '${result.loginStreak} दिन की Streak 🔥'
                        : '${result.loginStreak} Day Streak 🔥',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              LanguageService.instance.isHindi ? 'धन्यवाद!' : 'Thank You!',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _loyaltyService,
      builder: (context, child) {
        if (!_loyaltyService.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = _loyaltyService.getPointsSummary();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Points Balance Card
              _buildPointsBalanceCard(summary),
              const SizedBox(height: 16),

              // Login Streak Card
              _buildLoginStreakCard(summary),
              const SizedBox(height: 16),

              // How to Earn Points
              _buildHowToEarnCard(),
              const SizedBox(height: 16),

              // Recent Transactions
              _buildTransactionsCard(summary),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPointsBalanceCard(PointsSummary summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet,
                  color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                LanguageService.instance.isHindi
                    ? 'आपके Points'
                    : 'Your Points',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${summary.totalPoints}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            LanguageService.instance.isHindi
                ? '= ₹${summary.totalPoints} छूट'
                : '= ₹${summary.totalPoints} Discount',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LanguageService.instance.isHindi
                          ? 'कुल अर्जित'
                          : 'Total Earned',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '${summary.totalEarned}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LanguageService.instance.isHindi
                          ? 'कुल खर्च'
                          : 'Total Spent',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '${summary.totalSpent}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginStreakCard(PointsSummary summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department,
              color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LanguageService.instance.isHindi
                      ? 'Login Streak'
                      : 'Login Streak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  LanguageService.instance.isHindi
                      ? '${summary.loginStreak} दिन लगातार!'
                      : '${summary.loginStreak} Days in a Row!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToEarnCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: Colors.amber, size: 24),
                const SizedBox(width: 12),
                Text(
                  LanguageService.instance.isHindi
                      ? 'Points कैसे कमाएं'
                      : 'How to Earn Points',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEarnMethodItem(
              Icons.login,
              LanguageService.instance.isHindi ? 'दैनिक Login' : 'Daily Login',
              LanguageService.instance.isHindi
                  ? '1 Point हर दिन'
                  : '1 Point per Day',
              Colors.green,
            ),
            _buildEarnMethodItem(
              Icons.local_fire_department,
              LanguageService.instance.isHindi
                  ? '7 दिन Streak'
                  : '7 Day Streak',
              LanguageService.instance.isHindi
                  ? '+2 Bonus Points'
                  : '+2 Bonus Points',
              Colors.orange,
            ),
            _buildEarnMethodItem(
              Icons.stars,
              LanguageService.instance.isHindi
                  ? '30 दिन Streak'
                  : '30 Day Streak',
              LanguageService.instance.isHindi
                  ? '+5 Bonus Points'
                  : '+5 Bonus Points',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarnMethodItem(
      IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsCard(PointsSummary summary) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LanguageService.instance.isHindi
                  ? 'हाल की गतिविधि'
                  : 'Recent Activity',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            if (summary.recentTransactions.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      LanguageService.instance.isHindi
                          ? 'कोई गतिविधि नहीं'
                          : 'No Activity Yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              ...summary.recentTransactions.map((transaction) {
                final isEarned = transaction.type == TransactionType.earned;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isEarned
                        ? Colors.green.withValues(alpha: 0.05)
                        : Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isEarned
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isEarned ? Icons.add_circle : Icons.remove_circle,
                        color: isEarned ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LanguageService.instance.isHindi
                                  ? transaction.reasonHi
                                  : transaction.reasonEn,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _formatDate(transaction.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${isEarned ? "+" : ""}${transaction.points}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isEarned ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return LanguageService.instance.isHindi ? 'आज' : 'Today';
    } else if (difference.inDays == 1) {
      return LanguageService.instance.isHindi ? 'कल' : 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Points Usage Calculator Widget for Gift Marketplace
class PointsUsageCalculator extends StatefulWidget {
  final double itemPrice;
  final String itemName;
  final Function(int pointsToUse, double finalPrice, double discountAmount)?
      onPointsChanged;

  const PointsUsageCalculator({
    super.key,
    required this.itemPrice,
    required this.itemName,
    this.onPointsChanged,
  });

  @override
  State<PointsUsageCalculator> createState() => _PointsUsageCalculatorState();
}

class _PointsUsageCalculatorState extends State<PointsUsageCalculator> {
  final _loyaltyService = LoyaltyPointsService.instance;
  int _pointsToUse = 0;
  late int _maxUsablePoints;

  @override
  void initState() {
    super.initState();
    _calculateMaxUsablePoints();
  }

  void _calculateMaxUsablePoints() {
    final maxDiscountAmount = widget.itemPrice * 0.15; // 15% max discount
    _maxUsablePoints =
        maxDiscountAmount.floor().clamp(0, _loyaltyService.totalPoints);
  }

  void _updatePointsUsage(int points) {
    setState(() {
      _pointsToUse = points.clamp(0, _maxUsablePoints);
    });

    final calculation =
        _loyaltyService.calculateDiscount(widget.itemPrice, _pointsToUse);
    widget.onPointsChanged?.call(
      calculation.actualPointsToUse,
      calculation.finalPrice,
      calculation.discountAmount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final calculation =
        _loyaltyService.calculateDiscount(widget.itemPrice, _pointsToUse);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stars, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  LanguageService.instance.isHindi
                      ? 'Points का उपयोग करें'
                      : 'Use Your Points',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Available points
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LanguageService.instance.isHindi
                        ? 'उपलब्ध Points:'
                        : 'Available Points:',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${_loyaltyService.totalPoints}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Points slider
            Text(
              LanguageService.instance.isHindi
                  ? 'उपयोग करने वाले Points: $_pointsToUse'
                  : 'Points to Use: $_pointsToUse',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),

            Slider(
              value: _pointsToUse.toDouble(),
              min: 0,
              max: _maxUsablePoints.toDouble(),
              divisions: _maxUsablePoints > 0 ? _maxUsablePoints : 1,
              onChanged: (value) => _updatePointsUsage(value.toInt()),
              activeColor: Colors.orange,
            ),

            const SizedBox(height: 16),

            // Price calculation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withValues(alpha: 0.1),
                    Colors.green.withValues(alpha: 0.05)
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  _buildPriceRow(
                    LanguageService.instance.isHindi
                        ? 'मूल कीमत:'
                        : 'Original Price:',
                    '₹${widget.itemPrice.toStringAsFixed(0)}',
                    false,
                  ),
                  if (_pointsToUse > 0) ...[
                    _buildPriceRow(
                      LanguageService.instance.isHindi
                          ? 'Points छूट:'
                          : 'Points Discount:',
                      '-₹${calculation.discountAmount.toStringAsFixed(0)}',
                      true,
                    ),
                    const Divider(),
                  ],
                  _buildPriceRow(
                    LanguageService.instance.isHindi
                        ? 'भुगतान राशि:'
                        : 'Amount to Pay:',
                    '₹${calculation.finalPrice.toStringAsFixed(0)}',
                    false,
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Limitation info
            if (calculation.isMaxDiscountReached)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        LanguageService.instance.isHindi
                            ? 'अधिकतम 15% छूट पहुंच गई। कम से कम 85% भुगतान आवश्यक।'
                            : 'Maximum 15% discount reached. Minimum 85% payment required.',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.amber),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, bool isDiscount,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.green : Colors.black87,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isDiscount
                  ? Colors.red
                  : isTotal
                      ? Colors.green
                      : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
