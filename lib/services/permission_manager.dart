import 'package:flutter/material.dart';
import 'package:truecircle/models/contact_interaction.dart';

/// 🔒 ZERO-PERMISSION MANAGER - Google Play Store Compliant
///
/// This app operates COMPLETELY offline with NO dangerous permissions.
/// All analysis uses sample data and on-device AI processing.
/// Designed to pass Google Play Store automated review.
class PermissionManager {
  // Sample app - always use sample mode  
  static bool get isSampleMode => true;
  static bool _privacyNoticeShown = false;

  // Getters for app state (always return sample/safe values)
  static bool get hasContactPermission => false; // NEVER request permissions
  static bool get hasCallLogPermission => false; // NEVER request permissions
  static bool get hasSmsPermission => false; // NEVER request permissions
  static bool get userOptedIntoPermissions =>
      false; // NEVER opt into permissions

  // 🎯 GOOGLE PLAY COMPLIANCE: Zero permission initialization
  static Future<void> checkPermissions() async {
    // ✅ NO permission checks - pure offline app
    // This app NEVER requests dangerous permissions
  }

  // 🛡️ PRIVACY NOTICE: Show app is 100% safe and offline
  static Future<bool> showPrivacyDisclaimer(BuildContext context) async {
    if (_privacyNoticeShown) return true;

    bool result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.verified, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(child: Text('🔒 100% सुरक्षित और निजी')),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✅ यह एप आपसे कोई भी permission नहीं मांगती',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700),
                          ),
                          const SizedBox(height: 8),
                          const Text('• कोई contact access नहीं'),
                          const Text('• कोई call log access नहीं'),
                          const Text('• कोई SMS access नहीं'),
                          const Text('• आपका कोई personal data access नहीं'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🤖 यह कैसे काम करता है:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                              '• Sample relationship data से सीखने का अवसर'),
                          const Text(
                              '• Offline AI analysis (कोई internet आवश्यक नहीं)'),
                          const Text(
                              '• Cultural insights और festival recommendations'),
                          const Text(
                              '• Privacy-first design - आपका data केवल आपकी device पर'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '💡 यह एक educational app है जो relationship insights की जानकारी देती है।',
                        style: TextStyle(
                            fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    _privacyNoticeShown = true;
                    Navigator.of(context).pop(true);
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('समझ गया - TrueCircle शुरू करें'),
                ),
              ],
            );
          },
        ) ??
        false;

    return result;
  }

  // 🎯 SAMPLE MODE BANNER: Always visible since app is always in sample mode
  static Widget buildSampleModeBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.3),
            Colors.purple.withValues(alpha: 0.3)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.school, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '📚 Educational Sample Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(Icons.verified, color: Colors.white, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'यह app आपको relationship analysis की जानकारी देने के लिए sample data का उपयोग करती है:',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            '• 📊 Sample contacts के साथ communication patterns\n• 🤖 Offline AI emotion analysis\n• 🎭 Cultural insights और festival recommendations\n• 📱 Privacy-safe learning experience',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔒 Privacy Guarantee:',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                Text(
                  '✓ No personal data access\n✓ No dangerous permissions\n✓ 100% offline operation\n✓ Educational purpose only',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📊 OFFLINE EMOTION ANALYSIS (Educational Sample)
  static Map<String, dynamic> analyzeOfflineEmotion(String text) {
    // Educational emotion analysis based on keywords
    final Map<String, List<String>> emotionKeywords = {
      'happy': [
        'खुश',
        'खुशी',
        'मजा',
        'अच्छा',
        'बढ़िया',
        'happy',
        'good',
        'great',
        'awesome',
        '😊',
        '😄',
        '❤️'
      ],
      'sad': [
        'दुख',
        'उदास',
        'गम',
        'परेशान',
        'sad',
        'upset',
        'down',
        'depressed',
        '😢',
        '😞'
      ],
      'angry': [
        'गुस्सा',
        'नाराज',
        'झुंझला',
        'angry',
        'mad',
        'furious',
        'annoyed',
        '😠',
        '😡'
      ],
      'love': [
        'प्यार',
        'मोहब्बत',
        'इश्क',
        'love',
        'care',
        'adore',
        '💕',
        '💖',
        '❤️'
      ],
      'excited': [
        'उत्साहित',
        'जोश',
        'excited',
        'thrilled',
        'pumped',
        '🎉',
        '🔥'
      ],
    };

    final lowerText = text.toLowerCase();
    Map<String, int> emotionScores = {};

    emotionKeywords.forEach((emotion, keywords) {
      int score = 0;
      for (String keyword in keywords) {
        if (lowerText.contains(keyword.toLowerCase())) {
          score += 1;
        }
      }
      emotionScores[emotion] = score;
    });

    // Find dominant emotion
    String dominantEmotion = 'neutral';
    int maxScore = 0;
    emotionScores.forEach((emotion, score) {
      if (score > maxScore) {
        maxScore = score;
        dominantEmotion = emotion;
      }
    });

    double confidence = maxScore > 0
        ? (maxScore / text.split(' ').length).clamp(0.0, 1.0)
        : 0.5;

    return {
      'emotion': dominantEmotion,
      'confidence': confidence,
      'all_emotions': emotionScores,
      'offline_analysis': true,
      'educational_sample': true,
      'message': '🎓 Educational sample - पूर्ण offline analysis'
    };
  }

  // 📊 EDUCATIONAL RELATIONSHIP INSIGHTS
  static Map<String, dynamic> generateOfflineInsights(
      List<ContactInteraction> interactions) {
    if (interactions.isEmpty) {
      return {
        'relationship_health': 0.7,
        'communication_pattern': 'balanced',
        'suggestions': ['अधिक बातचीत करें', 'नियमित संपर्क बनाए रखें'],
        'educational_sample': true,
        'offline_analysis': true
      };
    }

    // Educational pattern analysis
    int totalInteractions = interactions.length;
    int initiatedByMe = interactions.where((i) => i.initiatedByMe).length;
    double initiationRatio = initiatedByMe / totalInteractions;

    double avgSentiment = interactions
            .map((i) => i.sentimentScore ?? 0.5)
            .fold(0.0, (a, b) => a + b) /
        totalInteractions;

    // Calculate relationship health for educational purposes
    double healthScore =
        (avgSentiment + (1 - (initiationRatio - 0.5).abs() * 2)) / 2;

    String pattern = initiationRatio > 0.7
        ? 'one_sided_by_me'
        : initiationRatio < 0.3
            ? 'one_sided_by_them'
            : 'balanced';

    List<String> suggestions = [];
    if (pattern == 'one_sided_by_me') {
      suggestions.add('कम पहल करें, दूसरे को भी मौका दें');
    } else if (pattern == 'one_sided_by_them') {
      suggestions.add('अधिक पहल करें, रिश्ते में योगदान दें');
    }

    if (avgSentiment < 0.5) {
      suggestions.add('सकारात्मक बातचीत बढ़ाएं');
    }

    return {
      'relationship_health': healthScore,
      'communication_pattern': pattern,
      'suggestions': suggestions,
      'total_interactions': totalInteractions,
      'educational_sample': true,
      'offline_analysis': true,
      'privacy_safe': true
    };
  }

  // 📚 EDUCATIONAL DEMO CONTACTS - 30 days of data
  static List<ContactInteraction> getSampleContacts() {
    List<ContactInteraction> contacts = [];

    // Generate 30 days of demo data
    for (int i = 0; i < 30; i++) {
      contacts.addAll([
        ContactInteraction(
          contactId: 'demo_${i}_1',
          timestamp: DateTime.now().subtract(Duration(days: i)),
          type: InteractionType.call,
          duration: 120 + (i * 10),
          initiatedByMe: i % 2 == 0,
          sentimentScore: 0.6 + (i * 0.01),
          metadata: {
            'contactName': _getDemoName(i % 8),
            'contactPhone': '+91-987654${3210 + i}',
            'demoContact': true
          },
        ),
        ContactInteraction(
          contactId: 'demo_${i}_2',
          timestamp: DateTime.now().subtract(Duration(days: i, hours: 2)),
          type: InteractionType.message,
          duration: 0,
          initiatedByMe: i % 3 != 0,
          sentimentScore: 0.5 + (i * 0.015),
          metadata: {
            'contactName': _getDemoName((i + 1) % 8),
            'contactPhone': '+91-987654${3220 + i}',
            'demoContact': true
          },
        ),
      ]);
    }

    return contacts;
  }

  static String _getDemoName(int index) {
    List<String> names = [
      'राज शर्मा',
      'प्रिया गुप्ता',
      'अमित कुमार',
      'स्नेहा सिंह',
      'विकास अग्रवाल',
      'सुनीता वर्मा',
      'रोहित जैन',
      'मीरा चौधरी'
    ];
    return names[index];
  }

  // Check if educational feature is available (always true)
  static bool isFeatureAvailable(String feature) {
    // All features are available in educational demo mode
    return true;
  }

  // Get educational feature status message
  static String getFeatureStatusMessage(String feature) {
    return 'Educational demo mode - Using sample data for learning';
  }

  // Educational cultural suggestions
  static List<String> getCulturalSuggestions() {
    return [
      '🎊 Diwali के समय अपने रिश्तेदारों को शुभकामनाएं भेजें',
      '🌺 Holi में मित्रों के साथ जश्न मनाएं',
      '🙏 Karva Chauth पर पति-पत्नी के रिश्ते को मजबूत बनाएं',
      '🎭 Navratri में सामुदायिक गतिविधियों में भाग लें',
      '✨ Eid पर सभी धर्मों के मित्रों को बधाई दें',
    ];
  }

  // Reset app state (not needed for Sample App)
  static void resetPermissions() {
    // Sample App doesn't need reset - always in safe mode
    _privacyNoticeShown = false;
  }
}
