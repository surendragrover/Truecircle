import 'package:flutter/material.dart';
import '../services/language_service.dart';

/// Bilingual Error Dialog
/// Shows error messages in both Hindi and English for better user experience
class BilingualErrorDialog extends StatelessWidget {
  final String titleEnglish;
  final String titleHindi;
  final String messageEnglish;
  final String messageHindi;
  final String? solutionEnglish;
  final String? solutionHindi;
  final VoidCallback? onRetry;
  final VoidCallback? onSettings;

  const BilingualErrorDialog({
    super.key,
    required this.titleEnglish,
    required this.titleHindi,
    required this.messageEnglish,
    required this.messageHindi,
    this.solutionEnglish,
    this.solutionHindi,
    this.onRetry,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isHindi = LanguageService.instance.isHindi;
    final title = isHindi ? titleHindi : titleEnglish;
    final message = isHindi ? messageHindi : messageEnglish;
    final solution = isHindi ? solutionHindi : solutionEnglish;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 15),
            ),
            if (solution != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, 
                          color: Colors.blue.shade700, 
                          size: 20
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isHindi ? 'समाधान:' : 'Solution:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      solution,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (onSettings != null)
          TextButton.icon(
            icon: const Icon(Icons.settings),
            label: Text(isHindi ? 'सेटिंग्स' : 'Settings'),
            onPressed: onSettings,
          ),
        if (onRetry != null)
          TextButton.icon(
            icon: const Icon(Icons.refresh),
            label: Text(isHindi ? 'पुनः प्रयास करें' : 'Retry'),
            onPressed: onRetry,
          ),
        TextButton(
          child: Text(isHindi ? 'ठीक है' : 'OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// Show Translation Service Error
  static void showTranslationError(BuildContext context, {VoidCallback? onRetry}) {
    showDialog(
      context: context,
      builder: (context) => BilingualErrorDialog(
        titleEnglish: 'Translation Service Unavailable',
        titleHindi: 'अनुवाद सेवा उपलब्ध नहीं है',
        messageEnglish: 'The translation service is currently unavailable. The app will work in English-only mode with limited translations.',
        messageHindi: 'अनुवाद सेवा फिलहाल उपलब्ध नहीं है। ऐप सीमित अनुवाद के साथ केवल अंग्रेजी मोड में काम करेगा।',
        solutionEnglish: 'To enable full Hindi support, please configure the Google Translate API key in api.env file. Until then, basic translations will be available.',
        solutionHindi: 'पूर्ण हिंदी समर्थन सक्षम करने के लिए, कृपया api.env फ़ाइल में Google Translate API key कॉन्फ़िगर करें। तब तक, बुनियादी अनुवाद उपलब्ध होंगे।',
        onRetry: onRetry,
      ),
    );
  }

  /// Show AI Service Error
  static void showAIServiceError(BuildContext context, {VoidCallback? onRetry}) {
    showDialog(
      context: context,
      builder: (context) => BilingualErrorDialog(
        titleEnglish: 'AI Service Unavailable',
        titleHindi: 'AI सेवा उपलब्ध नहीं है',
        messageEnglish: 'Dr. Iris AI service is not available right now. You can still use the app with sample responses.',
        messageHindi: 'डॉ. आइरिस AI सेवा अभी उपलब्ध नहीं है। आप अभी भी नमूना प्रतिक्रियाओं के साथ ऐप का उपयोग कर सकते हैं।',
        solutionEnglish: 'The AI models may need to be downloaded. Check Settings > AI Models to download them for full functionality.',
        solutionHindi: 'AI मॉडल डाउनलोड करने की आवश्यकता हो सकती है। पूर्ण कार्यक्षमता के लिए सेटिंग्स > AI मॉडल में जाकर उन्हें डाउनलोड करें।',
        onRetry: onRetry,
      ),
    );
  }

  /// Show Generic Error with custom message
  static void showError(
    BuildContext context, {
    required String titleEnglish,
    required String titleHindi,
    required String messageEnglish,
    required String messageHindi,
    String? solutionEnglish,
    String? solutionHindi,
    VoidCallback? onRetry,
    VoidCallback? onSettings,
  }) {
    showDialog(
      context: context,
      builder: (context) => BilingualErrorDialog(
        titleEnglish: titleEnglish,
        titleHindi: titleHindi,
        messageEnglish: messageEnglish,
        messageHindi: messageHindi,
        solutionEnglish: solutionEnglish,
        solutionHindi: solutionHindi,
        onRetry: onRetry,
        onSettings: onSettings,
      ),
    );
  }

  /// Show Offline Mode Info
  static void showOfflineModeInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BilingualErrorDialog(
        titleEnglish: 'Offline Mode Active',
        titleHindi: 'ऑफलाइन मोड सक्रिय',
        messageEnglish: 'You are currently in offline mode. Some features may have limited functionality.',
        messageHindi: 'आप वर्तमान में ऑफलाइन मोड में हैं। कुछ सुविधाओं में सीमित कार्यक्षमता हो सकती है।',
        solutionEnglish: 'Connect to the internet to enable all features, or continue using available offline features.',
        solutionHindi: 'सभी सुविधाओं को सक्षम करने के लिए इंटरनेट से कनेक्ट करें, या उपलब्ध ऑफलाइन सुविधाओं का उपयोग जारी रखें।',
      ),
    );
  }

  /// Show Help Dialog
  static void showHelpDialog(BuildContext context) {
    final isHindi = LanguageService.instance.isHindi;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue.shade700, size: 28),
            const SizedBox(width: 12),
            Text(
              isHindi ? 'मदद चाहिए?' : 'Need Help?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpSection(
                isHindi,
                icon: Icons.translate,
                titleEn: 'Translation Issues',
                titleHi: 'अनुवाद समस्याएं',
                descEn: 'If translations are not working, the app will show English text with basic Hindi support.',
                descHi: 'यदि अनुवाद काम नहीं कर रहे हैं, तो ऐप बुनियादी हिंदी समर्थन के साथ अंग्रेजी टेक्स्ट दिखाएगा।',
              ),
              const Divider(height: 24),
              _buildHelpSection(
                isHindi,
                icon: Icons.psychology,
                titleEn: 'Dr. Iris AI',
                titleHi: 'डॉ. आइरिस AI',
                descEn: 'Dr. Iris may use sample responses if AI models are not downloaded. Download models from Settings.',
                descHi: 'यदि AI मॉडल डाउनलोड नहीं हैं तो डॉ. आइरिस नमूना प्रतिक्रियाओं का उपयोग कर सकती हैं। सेटिंग्स से मॉडल डाउनलोड करें।',
              ),
              const Divider(height: 24),
              _buildHelpSection(
                isHindi,
                icon: Icons.wifi_off,
                titleEn: 'Offline Mode',
                titleHi: 'ऑफलाइन मोड',
                descEn: 'Most features work offline. Connect to internet for full AI capabilities.',
                descHi: 'अधिकांश सुविधाएं ऑफलाइन काम करती हैं। पूर्ण AI क्षमताओं के लिए इंटरनेट से कनेक्ट करें।',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(isHindi ? 'ठीक है' : 'OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  static Widget _buildHelpSection(
    bool isHindi, {
    required IconData icon,
    required String titleEn,
    required String titleHi,
    required String descEn,
    required String descHi,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isHindi ? titleHi : titleEn,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            isHindi ? descHi : descEn,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
