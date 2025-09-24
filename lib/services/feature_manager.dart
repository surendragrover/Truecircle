import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeatureManager {
  static const String _premiumKey = 'is_premium_user';
  static const String _trialKey = 'trial_end_date';

  // Free tier daily limits
  static const int freeAiInsightsLimit = 5;
  static const int freeSmartMessagesLimit = 3;
  static const int freeGoalsLimit = 3;
  static const int freeContactsLimit = 3; // Demo contacts only

  // Check if user is premium
  static Future<bool> isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool(_premiumKey) ?? false;

    if (!isPremium) {
      // Check if user is in trial period
      final trialEndString = prefs.getString(_trialKey);
      if (trialEndString != null) {
        final trialEnd = DateTime.parse(trialEndString);
        if (DateTime.now().isBefore(trialEnd)) {
          return true; // Still in trial
        }
      }
    }

    return isPremium;
  }

  // Start 7-day free trial
  static Future<void> startFreeTrial() async {
    final prefs = await SharedPreferences.getInstance();
    final trialEnd = DateTime.now().add(const Duration(days: 7));
    await prefs.setString(_trialKey, trialEnd.toIso8601String());
  }

  // Activate premium subscription
  static Future<void> activatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, true);
    await prefs.remove(_trialKey); // Remove trial data
  }

  // Check specific feature availability
  static Future<bool> isFeatureAvailable(String feature) async {
    final isPremium = await isPremiumUser();
    if (isPremium) return true;

    switch (feature) {
      case 'unlimited_ai_analysis':
      case 'advanced_emotional_scoring':
      case 'cultural_ai_premium':
      case 'predictive_analytics_advanced':
      case 'export_pdf_excel':
      case 'multi_device_sync':
      case 'premium_themes':
      case 'priority_support':
        return false;

      case 'basic_ai_analysis':
      case 'basic_emotional_scoring':
      case 'basic_goal_setting':
      case 'basic_export':
        return true;

      default:
        return true; // Basic features always available
    }
  }

  // Check daily usage limits for free users
  static Future<bool> canUseFeature(String feature) async {
    final isPremium = await isPremiumUser();
    if (isPremium) return true;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD

    switch (feature) {
      case 'ai_analysis':
        final todayUsage = prefs.getInt('ai_usage_$today') ?? 0;
        return todayUsage < freeAiInsightsLimit;

      case 'smart_messages':
        final todayUsage = prefs.getInt('messages_usage_$today') ?? 0;
        return todayUsage < freeSmartMessagesLimit;

      case 'goal_creation':
        final totalGoals = prefs.getInt('total_goals') ?? 0;
        return totalGoals < freeGoalsLimit;

      default:
        return true;
    }
  }

  // Increment usage counter
  static Future<void> incrementUsage(String feature) async {
    final isPremium = await isPremiumUser();
    if (isPremium) return; // No limits for premium users

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    final currentUsage = prefs.getInt('${feature}_usage_$today') ?? 0;
    await prefs.setInt('${feature}_usage_$today', currentUsage + 1);
  }

  // Get remaining usage for today
  static Future<int> getRemainingUsage(String feature) async {
    final isPremium = await isPremiumUser();
    if (isPremium) return 999; // Unlimited for premium

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    switch (feature) {
      case 'ai_analysis':
        final todayUsage = prefs.getInt('ai_usage_$today') ?? 0;
        return (freeAiInsightsLimit - todayUsage).clamp(
          0,
          freeAiInsightsLimit,
        );

      case 'smart_messages':
        final todayUsage = prefs.getInt('messages_usage_$today') ?? 0;
        return (freeSmartMessagesLimit - todayUsage).clamp(
          0,
          freeSmartMessagesLimit,
        );

      default:
        return 999;
    }
  }

  // Show upgrade prompt when limit reached
  static Future<void> showUpgradePrompt(
    BuildContext context,
    String feature,
  ) async {
    final featureName = _getFeatureDisplayName(feature);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Text('Limit Reached'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'आपने आज की $featureName limit पूरी कर ली है।',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    const Text(
                      '👑 Premium में मिलता है:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('✅ Unlimited $featureName'),
                    const Text('✅ Advanced AI features'),
                    const Text('✅ Zero advertisements'),
                    const Text('✅ Priority support'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('कल फिर कोशिश करूंगा'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showRewardedAdOption(context, feature);
              },
              child: const Text('Ad देखकर +1 Extra'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showPremiumUpgrade(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Premium में Upgrade'),
            ),
          ],
        );
      },
    );
  }

  // Show premium upgrade screen
  static Future<void> _showPremiumUpgrade(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Text('TrueCircle Premium'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🚀 Unlimited Relationship Intelligence',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildPremiumFeature('🤖', 'Unlimited AI Analysis'),
                _buildPremiumFeature('💬', 'Unlimited Smart Messages'),
                _buildPremiumFeature('📊', 'Advanced Analytics Dashboard'),
                _buildPremiumFeature('🌍', '50+ Cultural AI Insights'),
                _buildPremiumFeature('📱', 'Multi-Device Sync'),
                _buildPremiumFeature('🚫', 'Zero Advertisements'),
                _buildPremiumFeature('⚡', 'Priority Customer Support'),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '🎁 Special Offer',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('7-day FREE trial'),
                      Text('Then ₹99/month'),
                      Text('Cancel anytime'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe Later'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await startFreeTrial();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 7-day FREE trial शुरू हो गई!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Start FREE Trial'),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildPremiumFeature(String icon, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(child: Text(feature, style: const TextStyle(fontSize: 14))),
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
        ],
      ),
    );
  }

  static Future<void> _showRewardedAdOption(
    BuildContext context,
    String feature,
  ) async {
    // Implementation for rewarded ads
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Watch Ad for Extra Usage'),
          content: Text(
            '30-second ad देखकर आपको 1 extra ${_getFeatureDisplayName(feature)} मिल जाएगी।',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No Thanks'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Show rewarded ad here
                await _grantExtraUsage(feature);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '🎉 1 extra ${_getFeatureDisplayName(feature)} मिल गई!',
                      ),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              },
              child: const Text('Watch Ad'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _grantExtraUsage(String feature) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Grant one extra usage by reducing today's count
    final currentUsage = prefs.getInt('${feature}_usage_$today') ?? 0;
    if (currentUsage > 0) {
      await prefs.setInt('${feature}_usage_$today', currentUsage - 1);
    }
  }

  static String _getFeatureDisplayName(String feature) {
    switch (feature) {
      case 'ai_analysis':
        return 'AI Analysis';
      case 'smart_messages':
        return 'Smart Message';
      case 'goal_creation':
        return 'Goal';
      default:
        return 'Feature';
    }
  }

  // Premium feature wrapper widget
  static Widget wrapWithPremiumCheck({
    required Widget child,
    required String feature,
    required BuildContext context,
  }) {
    return FutureBuilder<bool>(
      future: isFeatureAvailable(feature),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return child;
        } else {
          return GestureDetector(
            onTap: () => _showPremiumUpgrade(context),
            child: Stack(
              children: [
                Opacity(opacity: 0.5, child: child),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, color: Colors.white, size: 32),
                          SizedBox(height: 8),
                          Text(
                            'Premium Feature',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
