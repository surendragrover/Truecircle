import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Google Translate API Service for TrueCircle
/// Provides Hindi-English translation capabilities
/// Falls back to offline mode if API unavailable
class GoogleTranslateService {
  static const String _baseUrl =
      'https://translation.googleapis.com/language/translate/v2';
  static String? _apiKey;
  static bool _isInitialized = false;

  /// Initialize the translation service with API key
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final String envString = await rootBundle.loadString('api.env');
      final envLines = envString.split('\n');

      for (String line in envLines) {
        if (line.startsWith('GOOGLE_TRANSLATE_API_KEY=')) {
          _apiKey = line.split('=')[1].trim();
          break;
        }
      }

      _isInitialized = true;
      debugPrint('Google Translate Service initialized');
    } catch (e) {
      debugPrint('Error initializing Google Translate Service: $e');
      _isInitialized = false;
    }
  }

  /// Translate text from one language to another
  /// Supports: 'en' (English) ↔ 'hi' (Hindi)
  static Future<String?> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (!_isInitialized) await initialize();

    if (_apiKey == null) {
      debugPrint('Google Translate API key not found - using fallback');
      return _getFallbackTranslation(text, sourceLanguage, targetLanguage);
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: json.encode({
          'q': text,
          'source': sourceLanguage,
          'target': targetLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final translations = data['data']['translations'] as List;

        if (translations.isNotEmpty) {
          final translatedText = translations.first['translatedText'] as String;
          debugPrint('Translation successful: $text → $translatedText');
          return translatedText;
        }
      } else {
        debugPrint(
            'Translation API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }

    // Fallback to basic translation
    return _getFallbackTranslation(text, sourceLanguage, targetLanguage);
  }

  /// Translate English to Hindi
  static Future<String?> translateToHindi(String englishText) async {
    return await translateText(
      text: englishText,
      sourceLanguage: 'en',
      targetLanguage: 'hi',
    );
  }

  /// Translate Hindi to English
  static Future<String?> translateToEnglish(String hindiText) async {
    return await translateText(
      text: hindiText,
      sourceLanguage: 'hi',
      targetLanguage: 'en',
    );
  }

  /// Auto-detect language and translate to the opposite
  /// If English detected → translate to Hindi
  /// If Hindi detected → translate to English
  static Future<Map<String, String?>> autoTranslate(String text) async {
    final detectedLanguage = _detectLanguage(text);

    if (detectedLanguage == 'hi') {
      final englishTranslation = await translateToEnglish(text);
      return {
        'original': text,
        'originalLanguage': 'hi',
        'translated': englishTranslation,
        'translatedLanguage': 'en',
      };
    } else {
      final hindiTranslation = await translateToHindi(text);
      return {
        'original': text,
        'originalLanguage': 'en',
        'translated': hindiTranslation,
        'translatedLanguage': 'hi',
      };
    }
  }

  /// Get bilingual response with both Hindi and English
  static Future<Map<String, String>> getBilingualResponse(String text) async {
    final detectedLanguage = _detectLanguage(text);

    if (detectedLanguage == 'hi') {
      // Original is Hindi, translate to English
      final englishTranslation = await translateToEnglish(text);
      return {
        'hindi': text,
        'english': englishTranslation ?? text,
        'primaryLanguage': 'hi',
      };
    } else {
      // Original is English, translate to Hindi
      final hindiTranslation = await translateToHindi(text);
      return {
        'english': text,
        'hindi': hindiTranslation ?? text,
        'primaryLanguage': 'en',
      };
    }
  }

  /// Basic language detection for Hindi vs English
  static String _detectLanguage(String text) {
    // Simple detection based on Devanagari script presence
    final hindiPattern = RegExp(r'[\u0900-\u097F]');
    return hindiPattern.hasMatch(text) ? 'hi' : 'en';
  }

  /// Fallback translations for common phrases
  static String? _getFallbackTranslation(
      String text, String sourceLanguage, String targetLanguage) {
    final fallbackTranslations = <String, Map<String, String>>{
      // Common emotions
      'happy': {'hi': 'खुश', 'en': 'happy'},
      'sad': {'hi': 'उदास', 'en': 'sad'},
      'excited': {'hi': 'उत्साहित', 'en': 'excited'},
      'calm': {'hi': 'शांत', 'en': 'calm'},
      'stressed': {'hi': 'तनावग्रस्त', 'en': 'stressed'},
      'grateful': {'hi': 'आभारी', 'en': 'grateful'},
      'anxious': {'hi': 'चिंतित', 'en': 'anxious'},

      // Common phrases
      'good morning': {'hi': 'सुप्रभात', 'en': 'good morning'},
      'good evening': {'hi': 'शुभ संध्या', 'en': 'good evening'},
      'thank you': {'hi': 'धन्यवाद', 'en': 'thank you'},
      'family': {'hi': 'परिवार', 'en': 'family'},
      'friend': {'hi': 'मित्र', 'en': 'friend'},
      'love': {'hi': 'प्रेम', 'en': 'love'},

      // Hindi common words
      'खुश': {'en': 'happy', 'hi': 'खुश'},
      'परिवार': {'en': 'family', 'hi': 'परिवार'},
      'मित्र': {'en': 'friend', 'hi': 'मित्र'},
      'प्रेम': {'en': 'love', 'hi': 'प्रेम'},
      'धन्यवाद': {'en': 'thank you', 'hi': 'धन्यवाद'},
    };

    final lowerText = text.toLowerCase().trim();
    final translation = fallbackTranslations[lowerText];

    if (translation != null && translation.containsKey(targetLanguage)) {
      return translation[targetLanguage];
    }

    debugPrint('No fallback translation found for: $text');
    return text; // Return original text if no translation found
  }

  /// Batch translate multiple texts
  static Future<List<String?>> batchTranslate({
    required List<String> texts,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final List<String?> translations = [];

    for (String text in texts) {
      final translation = await translateText(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
      translations.add(translation);
    }

    return translations;
  }

  /// Check if translation service is available
  static bool get isAvailable => _isInitialized && _apiKey != null;

  /// Get supported language codes
  static List<String> get supportedLanguages => ['en', 'hi'];

  /// Cultural context-aware translation
  /// Adds cultural context for better translation quality
  static Future<String?> translateWithContext({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? context, // e.g., 'festival', 'family', 'work'
  }) async {
    String enhancedText = text;

    if (context != null) {
      enhancedText = '$text [Context: $context]';
    }

    final translation = await translateText(
      text: enhancedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );

    // Remove context marker from translation
    if (translation != null && context != null) {
      return translation.replaceAll(RegExp(r'\[Context:.*?\]'), '').trim();
    }

    return translation;
  }
}
