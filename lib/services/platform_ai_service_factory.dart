import 'dart:io';
import 'on_device_ai_service.dart';
import 'android_gemini_nano_service.dart';
import 'ios_coreml_service.dart';

/// Platform-aware AI service factory for TrueCircle
/// 
/// This class automatically detects the platform and returns the appropriate
/// AI service implementation (Android Gemini Nano or iOS Core ML).
/// 
/// Usage:
/// ```dart
/// final aiService = PlatformAIServiceFactory.createService();
/// await aiService.initialize();
/// String response = await aiService.generateDrIrisResponse("Hello Dr. Iris");
/// ```
class PlatformAIServiceFactory {
  
  /// Creates the appropriate AI service based on the current platform
  static OnDeviceAIService createService() {
    if (Platform.isAndroid) {
      return AndroidGeminiNanoService();
    } else if (Platform.isIOS) {
      return IosCoreMLService();
    } else {
      // For web, desktop, or other platforms, return a mock service
      return MockAIService();
    }
  }
  
  /// Get platform-specific information
  static Map<String, dynamic> getPlatformInfo() {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'isAndroid': Platform.isAndroid,
      'isIOS': Platform.isIOS,
      'isWeb': false, // Platform.isWeb not available in dart:io
      'aiFramework': Platform.isAndroid ? 'Gemini Nano' : Platform.isIOS ? 'Core ML' : 'Mock',
    };
  }
}

/// Mock AI service for unsupported platforms or testing
/// 
/// This service provides basic mock responses for platforms that don't
/// have native AI support (web, desktop, etc.) or for testing purposes.
class MockAIService implements OnDeviceAIService {
  
  @override
  Future<void> initialize() async {
    // Mock AI Service initialized
    // Simulate initialization delay
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  @override
  Future<String> generateDrIrisResponse(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 200)); // Simulate processing time
    
    final lowercasePrompt = prompt.toLowerCase();
    
    if (lowercasePrompt.contains('stress')) {
      return "Dr. Iris (Privacy Mode): I understand you're feeling stressed. Try taking a few deep breaths and remember that it's okay to take breaks when you need them.";
    } else if (lowercasePrompt.contains('sad') || lowercasePrompt.contains('depressed')) {
      return "Dr. Iris (Privacy Mode): I hear that you're going through a difficult time. Your feelings are valid, and it's important to be gentle with yourself.";
    } else if (lowercasePrompt.contains('anxious') || lowercasePrompt.contains('anxiety')) {
      return "Dr. Iris (Privacy Mode): Anxiety can be overwhelming, but you're not alone. Try grounding yourself by focusing on your breathing.";
    } else if (lowercasePrompt.contains('happy') || lowercasePrompt.contains('good')) {
      return "Dr. Iris (Privacy Mode): I'm glad to hear you're feeling positive! It's wonderful when we can appreciate the good moments in life.";
    } else {
      return "Dr. Iris (Privacy Mode): Thank you for sharing with me. I'm here to listen and support you through whatever you're experiencing.";
    }
  }
  
  @override
  Future<String> analyzeSentimentAndStress(String textEntry) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final lowercaseText = textEntry.toLowerCase();
    
    // Simple keyword-based sentiment analysis
    int positiveWords = 0;
    int negativeWords = 0;
    
    final positiveKeywords = ['happy', 'good', 'great', 'amazing', 'wonderful', 'excited', 'joy', 'love', 'excellent'];
    final negativeKeywords = ['sad', 'bad', 'terrible', 'awful', 'stressed', 'angry', 'frustrated', 'worried', 'anxious'];
    
    for (String word in positiveKeywords) {
      if (lowercaseText.contains(word)) positiveWords++;
    }
    
    for (String word in negativeKeywords) {
      if (lowercaseText.contains(word)) negativeWords++;
    }
    
    String sentiment;
    String stressLevel;
    
    if (positiveWords > negativeWords) {
      sentiment = "Positive";
      stressLevel = "Low";
    } else if (negativeWords > positiveWords) {
      sentiment = "Negative";
      stressLevel = negativeWords > 2 ? "High" : "Medium";
    } else {
      sentiment = "Neutral";
      stressLevel = "Low";
    }
    
    return "Sentiment: $sentiment, Stress Level: $stressLevel, Confidence: 0.75 (Privacy Mode)";
  }
  
  @override
  Future<String> generateRelationshipTip(List<String> communicationLogSummary) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final tips = [
      "Consider scheduling regular check-ins with your loved ones to maintain stronger relationships.",
      "Quality time together, even if brief, can significantly strengthen your emotional connections.",
      "Active listening is one of the most powerful tools for building deeper relationships.",
      "Small gestures of appreciation can have a big impact on relationship satisfaction.",
      "Open and honest communication helps prevent misunderstandings and builds trust.",
      "Remember that relationships require effort from both sides - don't hesitate to reach out first.",
    ];
    
    // Simple selection based on log length
    final tipIndex = communicationLogSummary.length % tips.length;
    return "${tips[tipIndex]} (Privacy Mode)";
  }
  
  @override
  Future<String> draftFestivalMessage(String contactName, String relationType) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    switch (relationType.toLowerCase()) {
      case 'family':
        return "Dear $contactName, Wishing you and our family joy, prosperity, and togetherness on this special festival! May this celebration bring us closer together. 🎉 (Privacy Mode)";
      case 'friend':
        return "Hey $contactName! Hope you have an amazing festival celebration with lots of happiness and great memories! Looking forward to celebrating together soon! 🎊 (Privacy Mode)";
      case 'colleague':
      case 'professional':
        return "Dear $contactName, Wishing you a joyous festival celebration. May this special time bring you happiness and prosperity. Best regards! 🪔 (Privacy Mode)";
      default:
        return "Dear $contactName, Wishing you joy and happiness on this special festival! May this celebration bring you peace and prosperity. 🙏 (Privacy Mode)";
    }
  }
  
  @override
  Future<bool> isAISupported() async {
    // Mock service is always "supported" but in Privacy Mode
    return true;
  }
  
  /// Additional helper methods for mock service
  
  Future<String> generateMoodInsight(String moodData) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return "Your mood patterns show consistency over time. Consider maintaining your current wellness practices for continued emotional balance. (Privacy Mode)";
  }
  
  Future<String> suggestBreathingExercise(String stressLevel) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    switch (stressLevel.toLowerCase()) {
      case 'high':
        return "Try the 4-7-8 breathing technique: Inhale for 4, hold for 7, exhale for 8. Repeat 4 times. (Privacy Mode)";
      case 'medium':
        return "Practice box breathing: Inhale for 4, hold for 4, exhale for 4, hold for 4. Repeat 5 times. (Privacy Mode)";
      default:
        return "Simple deep breathing: Inhale slowly for 3 seconds, exhale slowly for 3 seconds. Repeat 10 times. (Privacy Mode)";
    }
  }
  
  Future<String> analyzeSleepPattern(String sleepData) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return "Your sleep data suggests good consistency in bedtime routines. Consider maintaining regular sleep schedules for optimal rest. (Privacy Mode)";
  }
  
  Future<String> generateMeditationGuidance(String sessionType) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    switch (sessionType.toLowerCase()) {
      case 'beginner':
        return "Start with 5 minutes of focused breathing. Sit comfortably and focus on your natural breath. When your mind wanders, gently return to your breath. (Privacy Mode)";
      case 'stress_relief':
        return "Practice progressive muscle relaxation. Starting from your toes, tense and release each muscle group. Notice the contrast between tension and relaxation. (Privacy Mode)";
      default:
        return "Find a quiet space and focus on the present moment for 10 minutes. Let thoughts come and go without judgment. (Privacy Mode)";
    }
  }
  
  Future<Map<String, dynamic>> getAIStatus() async {
    return {
      'supported': true,
      'initialized': true,
      'downloading': false,
      'progress': 1.0,
      'mode': 'Privacy Mode',
      'platform': Platform.operatingSystem,
      'service': 'Mock AI Service'
    };
  }
}