import 'package:flutter/material.dart';
import '../services/coin_reward_service.dart';

class MarketplaceDiscountWidget extends StatefulWidget {
  final String userId;
  final double originalPrice;
  final VoidCallback? onPurchaseComplete;

  const MarketplaceDiscountWidget({
    super.key,
    required this.userId,
    required this.originalPrice,
    this.onPurchaseComplete,
  });

  @override
  State<MarketplaceDiscountWidget> createState() =>
      _MarketplaceDiscountWidgetState();
}

class _MarketplaceDiscountWidgetState extends State<MarketplaceDiscountWidget> {
  int _availableCoins = 0;
  double _maxDiscount = 0;
  double _finalPrice = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateDiscount();
  }

  Future<void> _calculateDiscount() async {
    try {
      final coins = await CoinRewardService.instance.getUserCoinsCount();
      final discountData = await CoinRewardService.instance
          .calculateMarketplaceDiscount(widget.originalPrice);
      final discount = discountData['discountAmount'];

      setState(() {
        _availableCoins = coins;
        _maxDiscount = discount;
        _finalPrice = widget.originalPrice - discount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _finalPrice = widget.originalPrice;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_offer,
                    color: Colors.purple.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'TrueCircle Coins Discount',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price breakdown
            _buildPriceRow(
              'मूल कीमत',
              '₹${widget.originalPrice.toStringAsFixed(2)}',
              isOriginal: true,
            ),

            if (_maxDiscount > 0) ...[
              _buildPriceRow(
                'Coins Discount (${_maxDiscount.round()} coins)',
                '- ₹${_maxDiscount.toStringAsFixed(2)}',
                isDiscount: true,
              ),
              const Divider(),
              _buildPriceRow(
                'अंतिम कीमत',
                '₹${_finalPrice.toStringAsFixed(2)}',
                isFinal: true,
              ),

              const SizedBox(height: 16),

              // Savings highlight
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.savings, color: Colors.green.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'आप ₹${_maxDiscount.toStringAsFixed(2)} बचा रहे हैं! (${((_maxDiscount / widget.originalPrice) * 100).toStringAsFixed(0)}% discount)',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'अभी आपके पास कोई coins नहीं हैं। Conversations add करके coins earn करें!',
                        style: TextStyle(color: Colors.orange, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Available coins info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/TrueCircle_Coin.png',
                    width: 20,
                    height: 20,
                    color: Colors.blue.shade600,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.monetization_on,
                        color: Colors.blue.shade600,
                        size: 20,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'उपलब्ध coins: $_availableCoins',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _calculateDiscount,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Purchase button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _maxDiscount > 0 ? _processPurchase : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _maxDiscount > 0
                      ? Colors.green
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _maxDiscount > 0
                      ? '₹${_finalPrice.toStringAsFixed(2)} में खरीदें (${_maxDiscount.round()} coins use करें)'
                      : '₹${widget.originalPrice.toStringAsFixed(2)} में खरीदें',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String price, {
    bool isOriginal = false,
    bool isDiscount = false,
    bool isFinal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isFinal ? 18 : 14,
              fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : Colors.black87,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: isFinal ? 18 : 14,
              fontWeight: isFinal ? FontWeight.bold : FontWeight.w500,
              color: isDiscount
                  ? Colors.green
                  : (isFinal ? Colors.blue : Colors.black87),
              decoration: isOriginal && _maxDiscount > 0
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPurchase() async {
    if (_maxDiscount <= 0) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Confirm करें'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'आप ${_maxDiscount.round()} coins use करके ₹${_maxDiscount.toStringAsFixed(2)} बचाएंगे।',
            ),
            const SizedBox(height: 8),
            Text('Final amount: ₹${_finalPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text(
              'Confirm करें?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Purchase'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Process the coin usage
      final success = await CoinRewardService.instance.useCoinForPurchase(
        _maxDiscount.round(),
        widget.originalPrice,
        'Marketplace Item',
      );

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🎉 Purchase successful! ₹${_maxDiscount.toStringAsFixed(2)} saved!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // Refresh coin data
        await _calculateDiscount();

        // Callback
        widget.onPurchaseComplete?.call();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Simple coins-only display widget for headers/navbars
class SimpleCoinDisplay extends StatelessWidget {
  final String userId;
  final VoidCallback? onTap;

  const SimpleCoinDisplay({super.key, required this.userId, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/TrueCircle_Coin.png',
              width: 18,
              height: 18,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 18,
                );
              },
            ),
            const SizedBox(width: 4),
            FutureBuilder<int>(
              future: CoinRewardService.instance.getUserCoinsCount(),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data?.toString() ?? '0',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
