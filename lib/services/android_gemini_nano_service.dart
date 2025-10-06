import 'package:flutter/services.dart';
import 'on_device_ai_service.dart';

class AndroidGeminiNanoService implements OnDeviceAIService {
  // 'truecircle_ai_channel' is the name we'll use in Android native code.
  static const MethodChannel _channel = MethodChannel('truecircle_ai_channel');

  // --------------------------------------------------------------------------
  // 1. Initialize Function
  // --------------------------------------------------------------------------

  @override
  Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initializeGeminiNano');
      // Gemini Nano initialization called on Android side.
    } on PlatformException {
      // Error calling initializeGeminiNano - If Nano is not available, we won't let the app crash
    } catch (e) {
      // Unexpected error during Gemini Nano initialization: $e
    }
  }
  
  // --------------------------------------------------------------------------
  // 2. Core AI Functions (e.g., Dr. Iris)
  // --------------------------------------------------------------------------

  @override
  Future<String> generateDrIrisResponse(String prompt) async {
    try {
      final String response = await _channel.invokeMethod(
        'generateResponse',
        {'prompt': prompt}, // This data will be sent to Android
      );
      return response;
    } on PlatformException catch (e) {
      return "Dr. Iris (Offline) Error: ${e.message}";
    }
  }

  // All other functions (analyzeSentimentAndStress, generateRelationshipTip, etc.)
  // will also be created in this manner, sending data to Android with different method names.
  
  // --------------------------------------------------------------------------
  // 3. Helper Functions
  // --------------------------------------------------------------------------

  @override
  Future<bool> isAISupported() async {
    try {
      // This asks the native side if the device supports Gemini Nano.
      final bool supported = await _channel.invokeMethod('isNanoSupported');
      return supported;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<String> analyzeSentimentAndStress(String textEntry) async {
    try {
      final String result = await _channel.invokeMethod(
        'analyzeSentiment',
        {'textEntry': textEntry},
      );
      return result;
    } on PlatformException catch (e) {
      return "Sentiment Analysis Error: ${e.message}";
    }
  }
  
  @override
  Future<String> generateRelationshipTip(List<String> communicationLogSummary) async {
    try {
      final String tip = await _channel.invokeMethod(
        'generateRelationshipTip',
        {
          'communicationLog': communicationLogSummary,
          'type': 'relationship_advice',
        },
      );
      return tip;
    } on PlatformException catch (e) {
      return "Relationship Insights (Privacy Mode): ${e.message}";
    } catch (e) {
      return "Relationship insights currently unavailable in Privacy Mode.";
    }
  }
  
  @override
  Future<String> draftFestivalMessage(String contactName, String relationType) async {
    try {
      final String message = await _channel.invokeMethod(
        'draftFestivalMessage',
        {
          'contactName': contactName,
          'relationType': relationType,
          'type': 'festival_greeting',
        },
      );
      return message;
    } on PlatformException catch (e) {
      return "Festival Message (Privacy Mode): ${e.message}";
    } catch (e) {
      return "Festival message drafting currently unavailable in Privacy Mode.";
    }
  }

  // --------------------------------------------------------------------------
  // 4. Additional Helper Functions (Not in base interface)
  // --------------------------------------------------------------------------

  Future<String> generateMoodInsight(String moodData) async {
    try {
      final String insight = await _channel.invokeMethod(
        'generateMoodInsight',
        {
          'moodData': moodData,
          'type': 'mood_analysis',
        },
      );
      return insight;
    } on PlatformException catch (e) {
      return "Mood Insights (Privacy Mode): ${e.message}";
    } catch (e) {
      return "Mood insights currently unavailable in Privacy Mode.";
    }
  }

  Future<String> suggestBreathingExercise(String stressLevel) async {
    try {
      final String suggestion = await _channel.invokeMethod(
        'suggestBreathingExercise',
        {
          'stressLevel': stressLevel,
          'type': 'breathing_guidance',
        },
      );
      return suggestion;
    } on PlatformException catch (e) {
      return "Breathing Exercise (Privacy Mode): ${e.message}";
    } catch (e) {
      return "Breathing exercise suggestions currently unavailable in Privacy Mode.";
    }
  }

  Future<String> analyzeSleepPattern(String sleepData) async {
    try {
      final String analysis = await _channel.invokeMethod(
        'analyzeSleepPattern',
        {
          'sleepData': sleepData,
          'type': 'sleep_analysis',
        },
      );
      return analysis;
    } on PlatformException catch (e) {
      return "Sleep Analysis (Privacy Mode): ${e.message}";
    } catch (e) {
      return "Sleep pattern analysis currently unavailable in Privacy Mode.";
    }
  }

  Future<String> generateMeditationGuidance(String sessionType) async {
    try {
      final String guidance = await _channel.invokeMethod(
        'generateMeditationGuidance',
        {
          'sessionType': sessionType,
          'type': 'meditation_guidance',
        },
      );
      return guidance;
    } on PlatformException catch (e) {
      return "Meditation Guidance (Privacy Mode): ${e.message}";
    } catch (e) {
      return "Meditation guidance currently unavailable in Privacy Mode.";
    }
  }

  // --------------------------------------------------------------------------
  // 4. Additional Helper Functions
  // --------------------------------------------------------------------------

  Future<Map<String, dynamic>> getAIStatus() async {
    try {
      final Map<Object?, Object?> status = await _channel.invokeMethod('getAIStatus');
      return Map<String, dynamic>.from(status);
    } on PlatformException catch (e) {
      return {
        'supported': false,
        'initialized': false,
        'error': e.message,
        'mode': 'Privacy Mode',
      };
    } catch (e) {
      return {
        'supported': false,
        'initialized': false,
        'error': 'Unknown error',
        'mode': 'Privacy Mode',
      };
    }
  }

  /// Clear any cached AI models or data
  Future<void> clearCache() async {
    try {
      await _channel.invokeMethod('clearAICache');
    } on PlatformException {
      // Error clearing AI cache
    }
  }

  /// Check if AI model is currently downloading
  Future<bool> isModelDownloading() async {
    try {
      final bool downloading = await _channel.invokeMethod('isModelDownloading');
      return downloading;
    } on PlatformException {
      // Error checking model download status
      return false;
    }
  }

  /// Get model download progress (0.0 to 1.0)
  Future<double> getDownloadProgress() async {
    try {
      final double progress = await _channel.invokeMethod('getDownloadProgress');
      return progress;
    } on PlatformException {
      // Error getting download progress
      return 0.0;
    }
  }
}