import 'package:flutter/material.dart';
import 'google_translate_service.dart';

/// Centralized Language Management Service for TrueCircle
/// Auto-translates content when language is switched
/// Eliminates need for separate Hindi/English text in code
class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  static LanguageService get instance => _instance;

  LanguageService._internal() {
    _initializeTranslation();
  }

  String _currentLanguage = 'English'; // Default language
  final Map<String, String> _translationCache = {}; // Cache translations
  bool _isTranslationReady = false;

  String get currentLanguage => _currentLanguage;
  bool get isHindi => _currentLanguage == 'Hindi';
  bool get isEnglish => _currentLanguage == 'English';
  String get languageCode => _currentLanguage == 'Hindi' ? 'hi' : 'en';

  /// Initialize translation service
  Future<void> _initializeTranslation() async {
    await GoogleTranslateService.initialize();
    _isTranslationReady = GoogleTranslateService.isAvailable;
    debugPrint(
        'Language Service initialized. Translation ready: $_isTranslationReady');
  }

  /// Switch language and notify listeners
  Future<void> switchLanguage(String newLanguage) async {
    if (_currentLanguage != newLanguage) {
      _currentLanguage = newLanguage;
      debugPrint('Language switched to: $_currentLanguage');
      notifyListeners(); // This will trigger UI rebuild with auto-translation
    }
  }

  /// Auto-translate text based on current language
  /// Returns cached translation if available, otherwise translates on demand
  Future<String> autoTranslate(String originalText, {String? context}) async {
    if (!_isTranslationReady) {
      return originalText; // Return original if translation not ready
    }

    // Create cache key
    final cacheKey = '${originalText}_${_currentLanguage}_$context';

    // Return cached translation if available
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }

    try {
      String? translatedText;

      // Detect source language and translate accordingly
      final detectedLang = _detectLanguage(originalText);

      if (_currentLanguage == 'Hindi' && detectedLang == 'en') {
        // Translate English to Hindi
        translatedText = await GoogleTranslateService.translateWithContext(
          text: originalText,
          sourceLanguage: 'en',
          targetLanguage: 'hi',
          context: context,
        );
      } else if (_currentLanguage == 'English' && detectedLang == 'hi') {
        // Translate Hindi to English
        translatedText = await GoogleTranslateService.translateWithContext(
          text: originalText,
          sourceLanguage: 'hi',
          targetLanguage: 'en',
          context: context,
        );
      } else {
        // Same language or no translation needed
        translatedText = originalText;
      }

      // Cache the translation
      final result = translatedText ?? originalText;
      _translationCache[cacheKey] = result;

      return result;
    } catch (e) {
      debugPrint('Auto-translation error: $e');
      return originalText; // Return original on error
    }
  }

  /// Get text in current language (auto-translates if needed)
  /// Usage: getText('Hello, how are you?')
  /// Will return Hindi translation if current language is Hindi
  Future<String> getText(String text, {String? context}) async {
    return await autoTranslate(text, context: context);
  }

  /// Get bilingual text pair (both Hindi and English)
  /// Useful for showing both languages simultaneously
  Future<BilingualText> getBilingualText(String text, {String? context}) async {
    final translation = await GoogleTranslateService.getBilingualResponse(text);

    return BilingualText(
      english: translation['english'] ?? text,
      hindi: translation['hindi'] ?? text,
      primaryLanguage: translation['primaryLanguage'] ?? 'en',
    );
  }

  /// Pre-cache common translations for better performance
  Future<void> preCacheCommonTranslations() async {
    final commonTexts = [
      // Navigation
      'Home', 'Settings', 'Profile', 'Help',
      // Emotions
      'Happy', 'Sad', 'Excited', 'Calm', 'Stressed', 'Grateful', 'Anxious',
      // Relationships
      'Family', 'Friend', 'Partner', 'Colleague', 'Neighbor',
      // Common actions
      'Save', 'Cancel', 'Edit', 'Delete', 'Share', 'Next', 'Previous',
      // Greetings
      'Good Morning', 'Good Evening', 'Thank you', 'Welcome',
      // Dr. Iris responses
      'How can I help you today?', 'Tell me more about that',
      'That sounds important',
    ];

    for (String text in commonTexts) {
      await autoTranslate(text);
    }

    debugPrint('Pre-cached ${commonTexts.length} common translations');
  }

  /// Detect language of text (simple detection)
  String _detectLanguage(String text) {
    final hindiPattern = RegExp(r'[\u0900-\u097F]');
    return hindiPattern.hasMatch(text) ? 'hi' : 'en';
  }

  /// Clear translation cache (useful for memory management)
  void clearCache() {
    _translationCache.clear();
    debugPrint('Translation cache cleared');
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cached_translations': _translationCache.length,
      'current_language': _currentLanguage,
      'translation_ready': _isTranslationReady,
    };
  }
}

/// Bilingual text container
class BilingualText {
  final String english;
  final String hindi;
  final String primaryLanguage;

  const BilingualText({
    required this.english,
    required this.hindi,
    required this.primaryLanguage,
  });

  /// Get text in specified language
  String getInLanguage(String language) {
    return language == 'Hindi' ? hindi : english;
  }

  /// Get text in current app language
  String getCurrentLanguageText() {
    return LanguageService.instance.isHindi ? hindi : english;
  }

  @override
  String toString() {
    return getCurrentLanguageText();
  }
}

/// Extension for easy translation of strings
extension AutoTranslate on String {
  /// Auto-translate this string based on current language
  Future<String> tr({String? context}) async {
    return await LanguageService.instance.autoTranslate(this, context: context);
  }

  /// Get bilingual version of this string
  Future<BilingualText> bilingual({String? context}) async {
    return await LanguageService.instance
        .getBilingualText(this, context: context);
  }
}

/// Widget that auto-translates its text based on current language
class AutoTranslateText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final String? context;
  final int? maxLines;
  final TextOverflow? overflow;

  const AutoTranslateText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.context,
    this.maxLines,
    this.overflow,
  });

  @override
  State<AutoTranslateText> createState() => _AutoTranslateTextState();
}

class _AutoTranslateTextState extends State<AutoTranslateText> {
  String _translatedText = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTranslation();

    // Listen to language changes
    LanguageService.instance.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageService.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    _loadTranslation();
  }

  Future<void> _loadTranslation() async {
    setState(() => _isLoading = true);

    final translatedText = await LanguageService.instance.autoTranslate(
      widget.text,
      context: widget.context,
    );

    if (mounted) {
      setState(() {
        _translatedText = translatedText;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Text(
        widget.text, // Show original while loading
        style: widget.style?.copyWith(color: Colors.grey.shade400),
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
      );
    }

    return Text(
      _translatedText,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}

/// Button that auto-translates its text
class AutoTranslateButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonStyle? style;
  final String? context;

  const AutoTranslateButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style,
    this.context,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: AutoTranslateText(
        text,
        context: this.context,
      ),
    );
  }
}
