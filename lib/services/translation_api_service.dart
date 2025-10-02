import 'dart:convert';
import 'package:http/http.dart' as http;

/// Translation API Service for TrueCircle
/// Provides translation capabilities for all Indian languages
class TranslationApiService {
  static const String _baseUrl =
      'https://translate.googleapis.com/translate/v2';
  static TranslationApiService? _instance;
  static TranslationApiService get instance =>
      _instance ??= TranslationApiService._();

  TranslationApiService._();

  String? _apiKey;

  /// Initialize with API key from environment
  void initialize(String apiKey) {
    _apiKey = apiKey;
  }

  bool get isInitialized => _apiKey != null && _apiKey!.isNotEmpty;

  /// Supported language codes for Indian languages
  static const Map<String, String> supportedLanguageCodes = {
    'as': 'as', // Assamese
    'bn': 'bn', // Bengali
    'pa': 'pa', // Punjabi
    'gu': 'gu', // Gujarati
    'hi': 'hi', // Hindi
    'kn': 'kn', // Kannada
    'ks': 'ks', // Kashmiri
    'ko': 'ko', // Konkani (using Korean code as placeholder)
    'mai': 'mai', // Maithili
    'ml': 'ml', // Malayalam
    'mr': 'mr', // Marathi
    'mni': 'mni', // Meetei/Manipuri
    'ne': 'ne', // Nepali
    'or': 'or', // Odia
    'ta': 'ta', // Tamil
    'te': 'te', // Telugu
    'ur': 'ur', // Urdu
    'en': 'en', // English
  };

  /// Translate text to target language
  Future<String> translate(String text, String targetLanguage) async {
    if (!isInitialized) {
      throw Exception('Translation API not initialized. Please set API key.');
    }

    if (text.trim().isEmpty) return text;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'target': targetLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translations = data['data']['translations'] as List;
        if (translations.isNotEmpty) {
          return translations.first['translatedText'] as String;
        }
      } else {
        throw Exception('Translation failed: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback for demo purposes
      return _getDemoTranslation(text, targetLanguage);
    }

    return text;
  }

  /// Detect language of given text
  Future<String?> detectLanguage(String text) async {
    if (!isInitialized || text.trim().isEmpty) return null;

    try {
      final response = await http.post(
        Uri.parse(
            'https://translate.googleapis.com/translate/v2/detect?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'q': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final detections = data['data']['detections'] as List;
        if (detections.isNotEmpty && detections.first.isNotEmpty) {
          return detections.first.first['language'] as String;
        }
      }
    } catch (e) {
      // Fallback detection for demo
      return _detectDemoLanguage(text);
    }

    return null;
  }

  /// Get available languages from API
  Future<List<Map<String, String>>> getAvailableLanguages() async {
    if (!isInitialized) return [];

    try {
      final response = await http.get(
        Uri.parse(
            'https://translate.googleapis.com/translate/v2/languages?key=$_apiKey&target=en'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final languages = data['data']['languages'] as List;
        return languages
            .map<Map<String, String>>((lang) => {
                  'code': lang['language'] as String,
                  'name': lang['name'] as String,
                })
            .toList();
      }
    } catch (e) {
      // Return demo languages
      return _getDemoLanguages();
    }

    return [];
  }

  /// Bulk translate multiple texts
  Future<List<String>> translateBulk(
      List<String> texts, String targetLanguage) async {
    if (!isInitialized) return texts;

    final results = <String>[];
    for (final text in texts) {
      final translated = await translate(text, targetLanguage);
      results.add(translated);
    }

    return results;
  }

  /// Demo translations for testing without API key
  String _getDemoTranslation(String text, String targetLanguage) {
    final demoTranslations = {
      'hi': {
        'Welcome': 'स्वागत है',
        'Hello': 'नमस्ते',
        'Good Morning': 'सुप्रभात',
        'Thank you': 'धन्यवाद',
        'Language': 'भाषा',
        'Settings': 'सेटिंग्स',
        'Home': 'होम',
        'Profile': 'प्रोफ़ाइल',
      },
      'bn': {
        'Welcome': 'স্বাগতম',
        'Hello': 'হ্যালো',
        'Good Morning': 'সুপ্রভাত',
        'Thank you': 'ধন্যবাদ',
        'Language': 'ভাষা',
        'Settings': 'সেটিংস',
        'Home': 'হোম',
        'Profile': 'প্রোফাইল',
      },
      'ta': {
        'Welcome': 'வரவேற்கிறோம்',
        'Hello': 'வணக்கம்',
        'Good Morning': 'காலை வணக்கம்',
        'Thank you': 'நன்றி',
        'Language': 'மொழி',
        'Settings': 'அமைப்புகள்',
        'Home': 'முகப்பு',
        'Profile': 'சுயவிவரம்',
      },
      'te': {
        'Welcome': 'స్వాగతం',
        'Hello': 'హలో',
        'Good Morning': 'శుభోదయం',
        'Thank you': 'ధన్యవాదాలు',
        'Language': 'భాష',
        'Settings': 'సెట్టింగులు',
        'Home': 'హోమ్',
        'Profile': 'ప్రొఫైల్',
      },
      'gu': {
        'Welcome': 'સ્વાગત છે',
        'Hello': 'હેલો',
        'Good Morning': 'સુપ્રભાત',
        'Thank you': 'આભાર',
        'Language': 'ભાષા',
        'Settings': 'સેટિંગ્સ',
        'Home': 'હોમ',
        'Profile': 'પ્રોફાઇલ',
      },
      'kn': {
        'Welcome': 'ಸ್ವಾಗತ',
        'Hello': 'ಹಲೋ',
        'Good Morning': 'ಶುಭೋದಯ',
        'Thank you': 'ಧನ್ಯವಾದಗಳು',
        'Language': 'ಭಾಷೆ',
        'Settings': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
        'Home': 'ಹೋಮ್',
        'Profile': 'ಪ್ರೊಫೈಲ್',
      },
      'ml': {
        'Welcome': 'സ്വാഗതം',
        'Hello': 'ഹലോ',
        'Good Morning': 'സുപ്രഭാതം',
        'Thank you': 'നന്ദി',
        'Language': 'ഭാഷ',
        'Settings': 'ക്രമീകരണങ്ങൾ',
        'Home': 'ഹോം',
        'Profile': 'പ്രൊഫൈൽ',
      },
      'mr': {
        'Welcome': 'स्वागत आहे',
        'Hello': 'हॅलो',
        'Good Morning': 'सुप्रभात',
        'Thank you': 'धन्यवाद',
        'Language': 'भाषा',
        'Settings': 'सेटिंग्ज',
        'Home': 'होम',
        'Profile': 'प्रोफाइल',
      },
      'ur': {
        'Welcome': 'خوش آمدید',
        'Hello': 'ہیلو',
        'Good Morning': 'صبح بخیر',
        'Thank you': 'شکریہ',
        'Language': 'زبان',
        'Settings': 'ترتیبات',
        'Home': 'ہوم',
        'Profile': 'پروفائل',
      },
    };

    final translations = demoTranslations[targetLanguage];
    return translations?[text] ?? text;
  }

  /// Demo language detection
  String? _detectDemoLanguage(String text) {
    // Simple character-based detection
    if (text.contains(RegExp(r'[\u0900-\u097F]'))) return 'hi'; // Devanagari
    if (text.contains(RegExp(r'[\u0980-\u09FF]'))) return 'bn'; // Bengali
    if (text.contains(RegExp(r'[\u0B80-\u0BFF]'))) return 'ta'; // Tamil
    if (text.contains(RegExp(r'[\u0C00-\u0C7F]'))) return 'te'; // Telugu
    if (text.contains(RegExp(r'[\u0A80-\u0AFF]'))) return 'gu'; // Gujarati
    if (text.contains(RegExp(r'[\u0C80-\u0CFF]'))) return 'kn'; // Kannada
    if (text.contains(RegExp(r'[\u0D00-\u0D7F]'))) return 'ml'; // Malayalam
    if (text.contains(RegExp(r'[\u0600-\u06FF]'))) {
      return 'ur'; // Arabic script (Urdu)
    }
    return 'en'; // Default to English
  }

  /// Demo languages list
  List<Map<String, String>> _getDemoLanguages() {
    return [
      {'code': 'en', 'name': 'English'},
      {'code': 'hi', 'name': 'Hindi'},
      {'code': 'bn', 'name': 'Bengali'},
      {'code': 'ta', 'name': 'Tamil'},
      {'code': 'te', 'name': 'Telugu'},
      {'code': 'gu', 'name': 'Gujarati'},
      {'code': 'kn', 'name': 'Kannada'},
      {'code': 'ml', 'name': 'Malayalam'},
      {'code': 'mr', 'name': 'Marathi'},
      {'code': 'ur', 'name': 'Urdu'},
      {'code': 'pa', 'name': 'Punjabi'},
      {'code': 'as', 'name': 'Assamese'},
      {'code': 'or', 'name': 'Odia'},
      {'code': 'ne', 'name': 'Nepali'},
    ];
  }

  /// Common phrases for each Indian language
  static const Map<String, List<String>> commonPhrases = {
    'hi': [
      'नमस्ते',
      'आपका स्वागत है',
      'धन्यवाद',
      'कृपया',
      'माफ़ करें',
      'सुप्रभात',
      'शुभ रात्रि',
    ],
    'bn': [
      'নমস্কার',
      'স্বাগতম',
      'ধন্যবাদ',
      'দয়া করে',
      'দুঃখিত',
      'সুপ্রভাত',
      'শুভ রাত্রি',
    ],
    'ta': [
      'வணக்கம்',
      'வரவেற்கிறோম்',
      'நன্றி',
      'தயவு செய்து',
      'மன்னிக்கவும்',
      'காலை வணக்கம்',
      'இனிய இரவு',
    ],
    'te': [
      'నమస్కారం',
      'స్వాగతం',
      'ధన్యవాదాలు',
      'దయచేసి',
      'క్షమించండి',
      'శుభోదయం',
      'శుభ రాత్రి',
    ],
    'gu': [
      'નમસ્તે',
      'સ્વાગત છે',
      'આભાર',
      'કૃપા કરીને',
      'માફ કરશો',
      'સુપ્રભાત',
      'શુભ રાત્રિ',
    ],
    'kn': [
      'ನಮಸ್ಕಾರ',
      'ಸ್ವಾಗತ',
      'ಧನ್ಯವಾದಗಳು',
      'ದಯವಿಟ್ಟು',
      'ಕ್ಷಮಿಸಿ',
      'ಶುಭೋದಯ',
      'ಶುಭ ರಾತ್ರಿ',
    ],
    'ml': [
      'നമസ്കാരം',
      'സ്വാഗതം',
      'നന്ദി',
      'ദയവായി',
      'ക്ഷമിക്കണം',
      'സുപ്രഭാതം',
      'ശുഭ രാത്രി',
    ],
    'mr': [
      'नमस्कार',
      'स्वागत आहे',
      'धन्यवाद',
      'कृपया',
      'माफ करा',
      'सुप्रभात',
      'शुभ रात्री',
    ],
    'ur': [
      'السلام علیکم',
      'خوش آمدید',
      'شکریہ',
      'برائے کرم',
      'معاف کریں',
      'صبح بخیر',
      'شب بخیر',
    ],
  };

  /// Get common phrases for a language
  List<String> getCommonPhrases(String languageCode) {
    return commonPhrases[languageCode] ?? [];
  }

  /// Test translation service
  Future<Map<String, dynamic>> testService() async {
    const testText = "Hello, how are you?";
    final testLanguages = ['hi', 'bn', 'ta', 'te'];

    final results = <String, dynamic>{};
    results['original'] = testText;
    results['translations'] = <String, String>{};

    for (final lang in testLanguages) {
      try {
        final translated = await translate(testText, lang);
        results['translations'][lang] = translated;
      } catch (e) {
        results['translations'][lang] = 'Error: $e';
      }
    }

    return results;
  }
}
