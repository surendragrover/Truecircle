import 'dart:io';
import 'on_device_ai_service.dart';
import 'android_gemini_nano_service.dart';
import 'ios_coreml_service.dart';
import 'privacy_service.dart';
import 'privacy_mode_manager.dart';

/// Privacy-Aware AI Service Factory for TrueCircle
///
/// Creates AI services with built-in privacy + sample mode controls.
/// Ensures AI functionality respects user privacy settings and provides
/// safe, reduced-scope behavior in sample (privacy) mode.
///
/// Key Features:
/// - Privacy-first AI service creation
/// - Sample mode enforcement
/// - Platform-specific AI integration
/// - Consent validation before AI operations
class PrivacyAwareAIServiceFactory {
  static final PrivacyModeManager _privacyManager = PrivacyModeManager();

  /// Creates the appropriate AI service with privacy controls
  static OnDeviceAIService createPrivacyAwareService() {
    if (Platform.isAndroid) {
      return PrivacyAwareAndroidAIService();
    } else if (Platform.isIOS) {
      return PrivacyAwareIOSAIService();
    } else {
      return PrivacyAwareMockAIService();
    }
  }

  /// Get platform-specific information with privacy status
  static Map<String, dynamic> getPlatformInfo() {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'isAndroid': Platform.isAndroid,
      'isIOS': Platform.isIOS,
      'aiFramework': Platform.isAndroid
          ? 'Gemini Nano'
          : Platform.isIOS
              ? 'Core ML'
              : 'Mock',
      'privacyMode':
          _privacyManager.isPrivacyMode ? 'Privacy Mode' : 'Full Access Mode',
      'aiConsent': _privacyManager.canUseAI,
    };
  }
}

/// Privacy-aware wrapper for Android Gemini Nano service
class PrivacyAwareAndroidAIService implements OnDeviceAIService {
  final AndroidGeminiNanoService _androidService = AndroidGeminiNanoService();
  final PrivacyService _privacyService = PrivacyService();
  final PrivacyModeManager _privacyManager = PrivacyModeManager();

  @override
  Future<void> initialize() async {
    // Request AI consent before initialization
    bool aiConsent = await _privacyManager.requestAIConsent();
    if (!aiConsent) {
      // Privacy-Aware AI: AI consent not granted, operating in limited mode
      return;
    }

    await _androidService.initialize();
  }

  @override
  Future<String> generateDrIrisResponse(String prompt) async {
    // Dr. Iris allowed in sample mode (on-device emotional support)
    if (!_privacyService.validateAIAccess('dr_iris')) {
      return "Dr. Iris (Privacy Mode): I'm here to support you. All our conversations happen privately on your device.";
    }

    try {
      return await _androidService.generateDrIrisResponse(prompt);
    } catch (e) {
      return "Dr. Iris (Privacy Mode): I'm currently in privacy mode. I'm here to listen and support you.";
    }
  }

  @override
  Future<String> analyzeSentimentAndStress(String textEntry) async {
    // In sample mode, only basic analysis is allowed
    if (_privacyService.isPrivacyMode()) {
      return _performBasicSentimentAnalysis(textEntry);
    }

    if (!_privacyService.validateAIAccess('sentiment_analysis')) {
      return "Sentiment Analysis (Privacy Mode): Analysis uses privacy-protected methods.";
    }

    return await _androidService.analyzeSentimentAndStress(textEntry);
  }

  @override
  Future<String> generateRelationshipTip(
      List<String> communicationLogSummary) async {
    // In sample mode, provide general relationship advice
    if (_privacyService.isPrivacyMode()) {
      return _generatePrivacyFriendlyRelationshipTip();
    }

    if (!_privacyService.validateAIAccess('relationship_analysis')) {
      return "Relationship Insights (Privacy Mode): Tips are based on general relationship best practices.";
    }

    return await _androidService
        .generateRelationshipTip(communicationLogSummary);
  }

  @override
  Future<String> draftFestivalMessage(
      String contactName, String relationType) async {
    // Festival messages allowed in sample mode (cultural + positive)
    if (_privacyService.isPrivacyMode()) {
      return _generatePrivacyFriendlyFestivalMessage(contactName, relationType);
    }

    return await _androidService.draftFestivalMessage(
        contactName, relationType);
  }

  @override
  Future<bool> isAISupported() async {
    return await _androidService.isAISupported();
  }

  // Privacy-friendly helper methods
  String _performBasicSentimentAnalysis(String textEntry) {
    final lowercaseText = textEntry.toLowerCase();

    int positiveScore = 0;
    int negativeScore = 0;

    final positiveWords = [
      'happy',
      'good',
      'great',
      'amazing',
      'wonderful',
      'excited',
      'joy',
      'love'
    ];
    final negativeWords = [
      'sad',
      'bad',
      'terrible',
      'stressed',
      'angry',
      'frustrated',
      'worried',
      'anxious'
    ];

    for (String word in positiveWords) {
      if (lowercaseText.contains(word)) positiveScore++;
    }

    for (String word in negativeWords) {
      if (lowercaseText.contains(word)) negativeScore++;
    }

    String sentiment = positiveScore > negativeScore
        ? 'Positive'
        : negativeScore > positiveScore
            ? 'Negative'
            : 'Neutral';
    String stressLevel = negativeScore > 2
        ? 'High'
        : negativeScore > 0
            ? 'Medium'
            : 'Low';

    return "Sentiment: $sentiment, Stress Level: $stressLevel (Privacy Mode Analysis)";
  }

  String _generatePrivacyFriendlyRelationshipTip() {
    final tips = [
      "Communication is the foundation of strong relationships. Consider reaching out to someone you care about today.",
      "Quality time together, even if brief, can significantly strengthen your emotional connections.",
      "Active listening is one of the most powerful tools for building deeper relationships.",
      "Small gestures of appreciation can have a big impact on relationship satisfaction.",
      "Remember that healthy relationships require effort from both sides - don't hesitate to reach out first.",
    ];

    final randomIndex = DateTime.now().millisecond % tips.length;
    return "${tips[randomIndex]} (Privacy Mode)";
  }

  String _generatePrivacyFriendlyFestivalMessage(
      String contactName, String relationType) {
    switch (relationType.toLowerCase()) {
      case 'family':
        return "Dear $contactName, Wishing you and our family joy, prosperity, and togetherness on this special festival! 🎉 (Privacy Mode)";
      case 'friend':
        return "Hey $contactName! Hope you have an amazing festival celebration with lots of happiness and great memories! 🎊 (Privacy Mode)";
      default:
        return "Dear $contactName, Wishing you joy and happiness on this special festival! May this celebration bring you peace and prosperity. 🙏 (Privacy Mode)";
    }
  }
}

/// Privacy-aware wrapper for iOS Core ML service
class PrivacyAwareIOSAIService implements OnDeviceAIService {
  final IosCoreMLService _iosService = IosCoreMLService();
  final PrivacyService _privacyService = PrivacyService();
  final PrivacyModeManager _privacyManager = PrivacyModeManager();

  @override
  Future<void> initialize() async {
    bool aiConsent = await _privacyManager.requestAIConsent();
    if (!aiConsent) {
      // Privacy-Aware AI: AI consent not granted, operating in limited mode
      return;
    }

    await _iosService.initialize();
  }

  @override
  Future<String> generateDrIrisResponse(String prompt) async {
    if (!_privacyService.validateAIAccess('dr_iris')) {
      return "Dr. Iris (Privacy Mode): I'm here to support you. All our conversations happen privately on your device.";
    }

    try {
      return await _iosService.generateDrIrisResponse(prompt);
    } catch (e) {
      return "Dr. Iris (Privacy Mode): I'm currently in privacy mode. I'm here to listen and support you.";
    }
  }

  @override
  Future<String> analyzeSentimentAndStress(String textEntry) async {
    if (_privacyService.isPrivacyMode()) {
      return _performBasicSentimentAnalysis(textEntry);
    }

    if (!_privacyService.validateAIAccess('sentiment_analysis')) {
      return "Sentiment Analysis (Privacy Mode): Analysis uses privacy-protected methods.";
    }

    return await _iosService.analyzeSentimentAndStress(textEntry);
  }

  @override
  Future<String> generateRelationshipTip(
      List<String> communicationLogSummary) async {
    if (_privacyService.isPrivacyMode()) {
      return _generatePrivacyFriendlyRelationshipTip();
    }

    if (!_privacyService.validateAIAccess('relationship_analysis')) {
      return "Relationship Insights (Privacy Mode): Tips are based on general relationship best practices.";
    }

    return await _iosService.generateRelationshipTip(communicationLogSummary);
  }

  @override
  Future<String> draftFestivalMessage(
      String contactName, String relationType) async {
    if (_privacyService.isPrivacyMode()) {
      return _generatePrivacyFriendlyFestivalMessage(contactName, relationType);
    }

    return await _iosService.draftFestivalMessage(contactName, relationType);
  }

  @override
  Future<bool> isAISupported() async {
    return await _iosService.isAISupported();
  }

  // Same privacy-friendly helper methods as Android version
  String _performBasicSentimentAnalysis(String textEntry) {
    // Implementation similar to Android version
    final lowercaseText = textEntry.toLowerCase();

    int positiveScore = 0;
    int negativeScore = 0;

    final positiveWords = [
      'happy',
      'good',
      'great',
      'amazing',
      'wonderful',
      'excited',
      'joy',
      'love'
    ];
    final negativeWords = [
      'sad',
      'bad',
      'terrible',
      'stressed',
      'angry',
      'frustrated',
      'worried',
      'anxious'
    ];

    for (String word in positiveWords) {
      if (lowercaseText.contains(word)) positiveScore++;
    }

    for (String word in negativeWords) {
      if (lowercaseText.contains(word)) negativeScore++;
    }

    String sentiment = positiveScore > negativeScore
        ? 'Positive'
        : negativeScore > positiveScore
            ? 'Negative'
            : 'Neutral';
    String stressLevel = negativeScore > 2
        ? 'High'
        : negativeScore > 0
            ? 'Medium'
            : 'Low';

    return "Sentiment: $sentiment, Stress Level: $stressLevel (Privacy Mode Analysis)";
  }

  String _generatePrivacyFriendlyRelationshipTip() {
    final tips = [
      "Communication is the foundation of strong relationships. Consider reaching out to someone you care about today.",
      "Quality time together, even if brief, can significantly strengthen your emotional connections.",
      "Active listening is one of the most powerful tools for building deeper relationships.",
      "Small gestures of appreciation can have a big impact on relationship satisfaction.",
      "Remember that healthy relationships require effort from both sides - don't hesitate to reach out first.",
    ];

    final randomIndex = DateTime.now().millisecond % tips.length;
    return "${tips[randomIndex]} (Privacy Mode)";
  }

  String _generatePrivacyFriendlyFestivalMessage(
      String contactName, String relationType) {
    switch (relationType.toLowerCase()) {
      case 'family':
        return "Dear $contactName, Wishing you and our family joy, prosperity, and togetherness on this special festival! 🎉 (Privacy Mode)";
      case 'friend':
        return "Hey $contactName! Hope you have an amazing festival celebration with lots of happiness and great memories! 🎊 (Privacy Mode)";
      default:
        return "Dear $contactName, Wishing you joy and happiness on this special festival! May this celebration bring you peace and prosperity. 🙏 (Privacy Mode)";
    }
  }
}

/// Privacy-aware mock service for unsupported platforms
class PrivacyAwareMockAIService implements OnDeviceAIService {
  @override
  Future<void> initialize() async {
    // Privacy-Aware Mock AI Service initialized
  }

  @override
  Future<String> generateDrIrisResponse(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final lowercasePrompt = prompt.toLowerCase();

    if (lowercasePrompt.contains('stress')) {
      return "Dr. Iris (Privacy Mode): I understand you're feeling stressed. Take deep breaths and be kind to yourself.";
    } else if (lowercasePrompt.contains('anxious')) {
      return "Dr. Iris (Privacy Mode): Anxiety is challenging. Try focusing on things you can control right now.";
    } else {
      return "Dr. Iris (Privacy Mode): I'm here to support you. All our conversations are private and happen only on your device.";
    }
  }

  @override
  Future<String> analyzeSentimentAndStress(String textEntry) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return "Sentiment: Neutral, Stress Level: Low (Privacy Mode Analysis)";
  }

  @override
  Future<String> generateRelationshipTip(
      List<String> communicationLogSummary) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return "Consider having meaningful conversations with people you care about. (Privacy Mode)";
  }

  @override
  Future<String> draftFestivalMessage(
      String contactName, String relationType) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return "Dear $contactName, Wishing you joy and happiness on this special occasion! (Privacy Mode)";
  }

  @override
  Future<bool> isAISupported() async {
    return true;
  }
}
