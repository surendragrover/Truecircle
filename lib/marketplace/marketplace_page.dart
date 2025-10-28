import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';
import '../widgets/marketplace_discount_widget.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'TrueCircle Marketplace'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🛍️ TrueCircle Marketplace',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'अपने coins का इस्तेमाल करके 40% तक discount पाएं!',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),

            // Sample product 1
            _buildProductCard(
              context,
              'Premium Meditation Course',
              'गहरे meditation techniques सीखें',
              299.0,
              Icons.self_improvement,
              Colors.purple,
            ),

            const SizedBox(height: 16),

            // Sample product 2
            _buildProductCard(
              context,
              'Personal CBT Therapy Session',
              'Professional therapist के साथ 1-on-1 session',
              799.0,
              Icons.psychology,
              Colors.blue,
            ),

            const SizedBox(height: 16),

            // Sample product 3
            _buildProductCard(
              context,
              'Wellness Journal - Premium',
              'Beautiful handmade wellness journal',
              450.0,
              Icons.book,
              Colors.green,
            ),

            const SizedBox(height: 16),

            // Sample product 4
            _buildProductCard(
              context,
              'Stress Relief Essential Oils Kit',
              'Natural aromatherapy oils set',
              650.0,
              Icons.spa,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    String title,
    String description,
    double price,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(child: Icon(icon, size: 60, color: color)),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 16),

                // 🎉 Coin discount widget
                MarketplaceDiscountWidget(
                  userId: 'default_user',
                  originalPrice: price,
                  onPurchaseComplete: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('$title successfully purchased! 🎉'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
