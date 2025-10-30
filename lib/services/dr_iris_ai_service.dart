import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Enhanced Dr. Iris AI Service specifically for TrueCircle.tflite model
/// Handles emotional healing, relationship guidance, and emotional health support
class DrIrisAIService {
  static const _methodChannel = MethodChannel('truecircle_ai_channel');

  DrIrisAIService._();
  static final DrIrisAIService instance = DrIrisAIService._();

  bool _isInitialized = false;
  bool _isSupported = false;

  /// Initialize TrueCircle.tflite model
  Future<bool> initialize() async {
    if (_isInitialized) return _isSupported;

    try {
      // Check if TrueCircle AI model is supported on device
      _isSupported =
          await _methodChannel.invokeMethod<bool>('isAltModelSupported') ??
          false;

      if (_isSupported) {
        // Initialize the TrueCircle.tflite model
        final initResult =
            await _methodChannel.invokeMethod<bool>('initializeAltModel') ??
            false;
        _isSupported = initResult;
      }

      _isInitialized = true;
      return _isSupported;
    } on PlatformException catch (e) {
      debugPrint('Failed to initialize TrueCircle AI model: ${e.message}');
      _isSupported = false;
      _isInitialized = true;
      return false;
    }
  }

  /// Check if TrueCircle AI model is supported and ready
  bool get isSupported => _isSupported;
  bool get isInitialized => _isInitialized;

  /// Generate AI response for emotional healing and relationship guidance
  Future<String> generateResponse({
    required String userMessage,
    String? emotionalState,
    String? relationshipContext,
    bool allowFallback = true,
  }) async {
    if (!_isSupported) {
      throw PlatformException(
        code: 'MODEL_NOT_SUPPORTED',
        message: 'TrueCircle AI model is not supported on this device',
      );
    }

    try {
      // Prepare context for TrueCircle model
      final contextualPrompt = _buildContextualPrompt(
        userMessage: userMessage,
        emotionalState: emotionalState,
        relationshipContext: relationshipContext,
      );

      final args = <String, dynamic>{
        'type': 'dr_iris_healing',
        'prompt': contextualPrompt,
        'mode': 'emotional_guidance',
        'max_tokens': 200,
        'temperature': 0.7,
      };

      final response = await _methodChannel.invokeMethod<String>(
        'generateResponse',
        args,
      );

      if (response == null || response.trim().isEmpty) {
        if (allowFallback) {
          return _getFallbackResponse(userMessage);
        } else {
          throw PlatformException(
            code: 'AI_EMPTY',
            message: 'AI returned empty response and fallback disabled',
          );
        }
      }

      return _processAIResponse(response);
    } on PlatformException catch (e) {
      debugPrint('AI generation error: ${e.message}');
      if (allowFallback) {
        return _getFallbackResponse(userMessage);
      }
      rethrow;
    }
  }

  /// Build contextual prompt for TrueCircle model focusing on emotional healing
  String _buildContextualPrompt({
    required String userMessage,
    String? emotionalState,
    String? relationshipContext,
  }) {
    final StringBuilder prompt = StringBuilder();

    // Core identity and purpose
    prompt.writeln('You are Dr. Iris, a compassionate emotional therapist.');
    prompt.writeln('Your main purpose is to:');
    prompt.writeln('- Heal emotional pain and suffering');
    prompt.writeln('- Save and strengthen relationships');
    prompt.writeln('- Improve emotional health and wellbeing');
    prompt.writeln('- Provide practical, actionable solutions');
    prompt.writeln('');

    // Add emotional context if available
    if (emotionalState != null && emotionalState.isNotEmpty) {
      prompt.writeln('User\'s current emotional state: $emotionalState');
    }

    // Add relationship context if available
    if (relationshipContext != null && relationshipContext.isNotEmpty) {
      prompt.writeln('Relationship context: $relationshipContext');
    }

    prompt.writeln('');
    prompt.writeln('User\'s words: "$userMessage"');
    prompt.writeln('');
    prompt.writeln('Style and format guidelines:');
    prompt.writeln('- 2–4 short sentences, conversational and empathetic.');
    prompt.writeln('- Avoid bullet lists unless explicitly asked.');
    prompt.writeln(
      '- Reflect one key phrase from the user to show understanding.',
    );
    prompt.writeln('- End with one gentle follow-up question, not more.');

    return prompt.toString();
  }

  /// Process and enhance AI response
  String _processAIResponse(String response) {
    // Clean up the response
    String processed = response.trim();

    // Remove leading bullet/numbering patterns to reduce template feel
    processed = processed
        .replaceAll(RegExp(r'^[-•\d)\s]+', multiLine: true), '')
        .replaceAll(RegExp(r'\n\s*[-•]\s*'), '\n');

    // Ensure the response ends with a sentence terminator for readability
    if (!(processed.endsWith('.') ||
        processed.endsWith('!') ||
        processed.endsWith('?'))) {
      processed = '$processed.';
    }

    // Keep clean tone: avoid auto-emoji if user didn't use them

    return processed;
  }

  /// Fallback responses for when AI model is not available
  String _getFallbackResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    // Emotional distress
    if (message.contains('sad') ||
        message.contains('depressed') ||
        message.contains('depression') ||
        message.contains('down')) {
      return "I understand you're going through a difficult time. Take slow, deep breaths right now and remind yourself—I am safe and this moment will pass. What happened that increased this sadness?";
    }

    // Relationship issues
    if (message.contains('relationship') ||
        message.contains('partner') ||
        message.contains('fight') ||
        message.contains('breakup')) {
      return "Relationship troubles affect the heart—this is natural. First calm your mind, then try to listen to them without interrupting. What's the biggest knot you feel in your mind right now?";
    }

    // Anxiety/stress
    if (message.contains('anxiety') ||
        message.contains('anxious') ||
        message.contains('stress') ||
        message.contains('worried')) {
      return "Anxiety comes and goes like waves. Right now, relax your shoulders, soften your jaw, and take 4-7-8 breaths. What is worrying you the most at this moment?";
    }

    // Default supportive response
    return "I can feel what you're saying—your emotions are valid. Take a deep breath, and let's break the issue into smaller parts. What could be the first small step according to you?";
  }

  /// Save conversation for learning (local storage)
  Future<void> saveConversation({
    required String userMessage,
    required String aiResponse,
    String? emotionalState,
  }) async {
    try {
      // This would typically save to Hive for offline learning
      // Implementation depends on your local storage strategy
      debugPrint('Conversation saved for future learning');
    } catch (e) {
      debugPrint('Failed to save conversation: $e');
    }
  }

  /// Get personalized suggestions based on user's emotional patterns
  Future<List<String>> getPersonalizedSuggestions() async {
    // This would analyze past conversations and provide personalized suggestions
    return [
      'Share one happy memory from today',
      'Say "thank you" to someone you care about',
      'Spend 5 minutes in nature or by a window',
      'Listen to your favorite uplifting music',
      'Help someone and find joy in giving',
      'Write down 3 things you\'re grateful for',
      'Take 10 deep, mindful breaths',
      'Do one small act of self-care',
    ];
  }
}

/// Helper class for building strings
class StringBuilder {
  final StringBuffer _buffer = StringBuffer();

  void writeln(String line) {
    _buffer.writeln(line);
  }

  @override
  String toString() => _buffer.toString();
}
