import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';  // Temporarily disabled
import 'package:shared_preferences/shared_preferences.dart';

class TrueCirclePaymentService {
  // static final Razorpay _razorpay = Razorpay();  // Temporarily disabled
  static bool _isInitialized = false;

  // Pricing Plans
  static const double lifetimePremiumPrice = 99.0; // ₹99 lifetime
  static const double monthlyPremiumPrice = 29.0; // ₹29/month
  static const double yearlyPremiumPrice = 299.0; // ₹299/year

  // Initialize payment service
  static void initialize() {
    if (!_isInitialized) {
      // Razorpay initialization temporarily disabled
      // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      _isInitialized = true;
    }
  }

  // Dispose payment service
  static void dispose() {
    // _razorpay.clear();  // Temporarily disabled
    _isInitialized = false;
  }

  // Show premium upgrade options
  static Future<void> showPremiumUpgrade(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.amber[600], size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TrueCircle Premium',
                      style: TextStyle(fontSize: 18)),
                  Text('Unlock Full Potential',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium Benefits
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[50]!, Colors.purple[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('🚀 Premium Features:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      _buildPremiumFeature('🤖', 'Unlimited AI Analysis'),
                      _buildPremiumFeature('💬', 'Unlimited Smart Messages'),
                      _buildPremiumFeature(
                          '📊', 'Advanced Analytics Dashboard'),
                      _buildPremiumFeature('🌍', '50+ Cultural AI Insights'),
                      _buildPremiumFeature('📱', 'Multi-Device Sync'),
                      _buildPremiumFeature('🚫', 'Zero Advertisements'),
                      _buildPremiumFeature('⚡', 'Priority Support'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Pricing Options
                const Text('💰 Choose Your Plan:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),

                // Lifetime Plan (Recommended)
                _buildPricingCard(
                  context: context,
                  title: '🏆 Lifetime Premium',
                  price: '₹99',
                  description: 'One-time payment • Best Value',
                  features: [
                    '✅ All Premium Features',
                    '✅ Lifetime Access',
                    '✅ No Recurring Charges'
                  ],
                  isRecommended: true,
                  onTap: () => _processPayment(
                      context, lifetimePremiumPrice, 'lifetime'),
                ),

                const SizedBox(height: 12),

                // Monthly Plan
                _buildPricingCard(
                  context: context,
                  title: '📅 Monthly Premium',
                  price: '₹29/month',
                  description: 'Recurring monthly • Cancel anytime',
                  features: ['✅ All Premium Features', '✅ Monthly Billing'],
                  onTap: () =>
                      _processPayment(context, monthlyPremiumPrice, 'monthly'),
                ),

                const SizedBox(height: 12),

                // Yearly Plan
                _buildPricingCard(
                  context: context,
                  title: '🎯 Yearly Premium',
                  price: '₹299/year',
                  description: 'Save 17% • Annual billing',
                  features: ['✅ All Premium Features', '✅ Save ₹49/year'],
                  onTap: () =>
                      _processPayment(context, yearlyPremiumPrice, 'yearly'),
                ),

                const SizedBox(height: 16),

                // Security & Trust
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: Colors.green[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🔒 100% Secure Payment • UPI, Cards, Wallets Supported',
                          style:
                              TextStyle(fontSize: 12, color: Colors.green[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Maybe Later',
                  style: TextStyle(color: Colors.grey[600])),
            ),
          ],
        );
      },
    );
  }

  // Build premium feature row
  static Widget _buildPremiumFeature(String icon, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(feature, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // Build pricing card
  static Widget _buildPricingCard({
    required BuildContext context,
    required String title,
    required String price,
    required String description,
    required List<String> features,
    required VoidCallback onTap,
    bool isRecommended = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRecommended ? Colors.amber[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRecommended ? Colors.amber[300]! : Colors.grey[300]!,
            width: isRecommended ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(description,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isRecommended
                              ? Colors.amber[700]
                              : Colors.blue[700],
                        )),
                    if (isRecommended)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber[600],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('BEST VALUE',
                            style: TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Text(feature, style: const TextStyle(fontSize: 12)),
                )),
          ],
        ),
      ),
    );
  }

  // Process payment based on plan
  static Future<void> _processPayment(
      BuildContext context, double amount, String planType) async {
    Navigator.of(context).pop(); // Close the upgrade dialog

    // Show payment method selection
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('💳 Select Payment Method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Amount: ₹${amount.toStringAsFixed(0)}'),
              const SizedBox(height: 16),

              // UPI Payment
              _buildPaymentMethodTile(
                context: context,
                icon: '📱',
                title: 'UPI Payment',
                subtitle: 'PhonePe, Google Pay, PayTM, BHIM',
                onTap: () {
                  Navigator.of(context).pop();
                  _processRazorpayPayment(context, amount, planType, 'upi');
                },
              ),

              // Card Payment
              _buildPaymentMethodTile(
                context: context,
                icon: '💳',
                title: 'Credit/Debit Card',
                subtitle: 'Visa, Mastercard, RuPay',
                onTap: () {
                  Navigator.of(context).pop();
                  _processRazorpayPayment(context, amount, planType, 'card');
                },
              ),

              // Net Banking
              _buildPaymentMethodTile(
                context: context,
                icon: '🏦',
                title: 'Net Banking',
                subtitle: 'All major banks supported',
                onTap: () {
                  Navigator.of(context).pop();
                  _processRazorpayPayment(
                      context, amount, planType, 'netbanking');
                },
              ),

              // Wallet Payment
              _buildPaymentMethodTile(
                context: context,
                icon: '👛',
                title: 'Digital Wallets',
                subtitle: 'PayTM, Mobikwik, FreeCharge',
                onTap: () {
                  Navigator.of(context).pop();
                  _processRazorpayPayment(context, amount, planType, 'wallet');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Build payment method tile
  static Widget _buildPaymentMethodTile({
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 24)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // Process Razorpay payment - Temporarily disabled
  static Future<void> _processRazorpayPayment(BuildContext context,
      double amount, String planType, String paymentMethod) async {
    initialize();

    // Temporarily commented out due to Razorpay dependency issues
    /*
    final options = {
      'key': 'rzp_test_your_key_here', // Replace with your Razorpay key
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'TrueCircle',
      'description': 'Premium Subscription ($planType)',
      'prefill': {
        'contact': '', // User phone number
        'email': '', // User email
      },
      'theme': {
        'color': '#3399cc',
      },
      'method': {
        'upi': paymentMethod == 'upi',
        'card': paymentMethod == 'card',
        'netbanking': paymentMethod == 'netbanking',
        'wallet': paymentMethod == 'wallet',
      },
      'notes': {
        'plan_type': planType,
        'app_name': 'TrueCircle',
      },
    };
    */

    try {
      // _razorpay.open(options);  // Temporarily disabled - Razorpay integration
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Razorpay payment temporarily disabled'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Temporarily disabled - Razorpay integration
  /*
  // Handle payment success
  static void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Store payment information
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium', true);
      await prefs.setString('payment_id', response.paymentId ?? '');
      await prefs.setString('signature', response.signature ?? '');
      await prefs.setString(
          'premium_activated_date', DateTime.now().toIso8601String());

      // Activate premium features
      await _activatePremiumFeatures();

      // Show success message
      // Note: You might want to navigate to a success screen instead
      debugPrint('Payment successful: ${response.paymentId}');
    } catch (e) {
      debugPrint('Error handling payment success: $e');
    }
  }

  // Handle payment error
  static void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment failed: ${response.code} - ${response.message}');
    // Show error message to user
  }

  // Handle external wallet
  static void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External wallet selected: ${response.walletName}');
  }
  */

  // Activate premium features
  static Future<void> _activatePremiumFeatures() async {
    final prefs = await SharedPreferences.getInstance();

    // Remove all usage limits
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.remove('ai_usage_$today');
    await prefs.remove('messages_usage_$today');

    // Enable all premium features
    final premiumFeatures = [
      'unlimited_ai_analysis',
      'advanced_emotional_scoring',
      'cultural_ai_premium',
      'predictive_analytics_advanced',
      'export_pdf_excel',
      'multi_device_sync',
      'premium_themes',
      'priority_support',
    ];

    for (final feature in premiumFeatures) {
      await prefs.setBool('feature_$feature', true);
    }
  }

  // Check if user is premium
  static Future<bool> isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_premium') ?? false;
  }

  // Get payment information
  static Future<Map<String, String?>> getPaymentInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'payment_id': prefs.getString('payment_id'),
      'activated_date': prefs.getString('premium_activated_date'),
      'signature': prefs.getString('signature'),
    };
  }

  // Restore premium access (for reinstalls)
  static Future<bool> restorePremiumAccess(String paymentId) async {
    // Verify payment with server
    // For now, we'll assume it's valid
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', true);
    await prefs.setString('payment_id', paymentId);
    await _activatePremiumFeatures();
    return true;
  }
}
