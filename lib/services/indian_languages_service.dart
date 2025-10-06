import 'package:flutter/material.dart';

/// Indian Language Model
class IndianLanguage {
  final String code;
  final String nameEnglish;
  final String nameNative;
  final String script;
  final bool isSupported;

  const IndianLanguage({
    required this.code,
    required this.nameEnglish,
    required this.nameNative,
    required this.script,
    this.isSupported = true,
  });

  @override
  String toString() => '$nameNative ($nameEnglish)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndianLanguage &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// Indian Languages Service
/// Complete list of Indian languages with native names
class IndianLanguagesService extends ChangeNotifier {
  static IndianLanguagesService? _instance;
  static IndianLanguagesService get instance =>
      _instance ??= IndianLanguagesService._internal();

  IndianLanguagesService._internal();

  String _selectedLanguage = 'hi'; // Default Hindi
  bool _isTranslationEnabled = true;

  String get selectedLanguage => _selectedLanguage;
  bool get isTranslationEnabled => _isTranslationEnabled;

  /// Complete list of Indian languages with native names
  static const List<IndianLanguage> supportedLanguages = [
    // Major Indian Languages as requested
    IndianLanguage(
      code: 'as',
      nameEnglish: 'Assamese',
      nameNative: 'অসমীয়া',
      script: 'Bengali',
    ),
    IndianLanguage(
      code: 'bn',
      nameEnglish: 'Bengali',
      nameNative: 'বাংলা',
      script: 'Bengali',
    ),
    IndianLanguage(
      code: 'pa',
      nameEnglish: 'Eastern Punjabi',
      nameNative: 'ਪੂਰਬੀ ਪੰਜਾਬੀ',
      script: 'Gurmukhi',
    ),
    IndianLanguage(
      code: 'grt',
      nameEnglish: 'Garo',
      nameNative: 'গারো',
      script: 'Latin',
      isSupported: false, // Limited API support
    ),
    IndianLanguage(
      code: 'gu',
      nameEnglish: 'Gujarati',
      nameNative: 'ગુજરાતી',
      script: 'Gujarati',
    ),
    IndianLanguage(
      code: 'hi',
      nameEnglish: 'Hindi',
      nameNative: 'हिन्दी',
      script: 'Devanagari',
    ),
    IndianLanguage(
      code: 'kn',
      nameEnglish: 'Kannada',
      nameNative: 'ಕನ್ನಡ',
      script: 'Kannada',
    ),
    IndianLanguage(
      code: 'ks',
      nameEnglish: 'Kashmiri',
      nameNative: 'कॉशुर',
      script: 'Devanagari',
    ),
    IndianLanguage(
      code: 'kha',
      nameEnglish: 'Khasi',
      nameNative: 'খাসি',
      script: 'Latin',
      isSupported: false, // Limited API support
    ),
    IndianLanguage(
      code: 'kok',
      nameEnglish: 'Konkani',
      nameNative: 'कोंकणी',
      script: 'Devanagari',
    ),
    IndianLanguage(
      code: 'mai',
      nameEnglish: 'Maithili',
      nameNative: 'मैथिली',
      script: 'Devanagari',
    ),
    IndianLanguage(
      code: 'ml',
      nameEnglish: 'Malayalam',
      nameNative: 'മലയാളം',
      script: 'Malayalam',
    ),
    IndianLanguage(
      code: 'mr',
      nameEnglish: 'Marathi',
      nameNative: 'मराठी',
      script: 'Devanagari',
    ),
    IndianLanguage(
      code: 'mni',
      nameEnglish: 'Meetei',
      nameNative: 'মীতেই',
      script: 'Meetei Mayek',
      isSupported: false, // Limited API support
    ),
    IndianLanguage(
      code: 'ne',
      nameEnglish: 'Nepali',
      nameNative: 'नेपाली',
      script: 'Devanagari',
    ),
    IndianLanguage(
      code: 'or',
      nameEnglish: 'Odia',
      nameNative: 'ଓଡ଼ିଆ',
      script: 'Odia',
    ),
    IndianLanguage(
      code: 'ta',
      nameEnglish: 'Tamil',
      nameNative: 'தமிழ்',
      script: 'Tamil',
    ),
    IndianLanguage(
      code: 'te',
      nameEnglish: 'Telugu',
      nameNative: 'తెలుగు',
      script: 'Telugu',
    ),
    IndianLanguage(
      code: 'ur',
      nameEnglish: 'Urdu',
      nameNative: 'اردو',
      script: 'Arabic',
    ),
    // Additional commonly used languages
    IndianLanguage(
      code: 'en',
      nameEnglish: 'English',
      nameNative: 'English',
      script: 'Latin',
    ),
    IndianLanguage(
      code: 'sa',
      nameEnglish: 'Sanskrit',
      nameNative: 'संस्कृतम्',
      script: 'Devanagari',
    ),
  ];

  /// Get list of supported languages only
  List<IndianLanguage> get availableLanguages =>
      supportedLanguages.where((lang) => lang.isSupported).toList();

  /// Get current selected language object
  IndianLanguage get currentLanguage => supportedLanguages.firstWhere(
        (lang) => lang.code == _selectedLanguage,
        orElse: () => supportedLanguages.first,
      );

  /// Change selected language
  Future<void> setLanguage(String languageCode) async {
    if (languageCode != _selectedLanguage) {
      _selectedLanguage = languageCode;
      notifyListeners();
      debugPrint(
          '🌐 Language changed to: ${currentLanguage.nameNative} (${currentLanguage.nameEnglish})');
    }
  }

  /// Toggle translation service
  void toggleTranslation(bool enabled) {
    _isTranslationEnabled = enabled;
    notifyListeners();
    debugPrint('🔄 Translation ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Get language by code
  IndianLanguage? getLanguageByCode(String code) {
    try {
      return supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Get languages by script
  List<IndianLanguage> getLanguagesByScript(String script) {
    return supportedLanguages.where((lang) => lang.script == script).toList();
  }

  /// Check if language needs right-to-left text direction
  bool isRTL(String languageCode) {
    return languageCode == 'ur'; // Urdu uses RTL
  }

  /// Get language direction
  TextDirection getTextDirection(String languageCode) {
    return isRTL(languageCode) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get commonly used languages (top 10)
  List<IndianLanguage> get popularLanguages => [
        supportedLanguages.firstWhere((l) => l.code == 'hi'), // Hindi
        supportedLanguages.firstWhere((l) => l.code == 'en'), // English
        supportedLanguages.firstWhere((l) => l.code == 'bn'), // Bengali
        supportedLanguages.firstWhere((l) => l.code == 'te'), // Telugu
        supportedLanguages.firstWhere((l) => l.code == 'mr'), // Marathi
        supportedLanguages.firstWhere((l) => l.code == 'ta'), // Tamil
        supportedLanguages.firstWhere((l) => l.code == 'gu'), // Gujarati
        supportedLanguages.firstWhere((l) => l.code == 'ur'), // Urdu
        supportedLanguages.firstWhere((l) => l.code == 'kn'), // Kannada
        supportedLanguages.firstWhere((l) => l.code == 'ml'), // Malayalam
      ];

  /// Get regional language suggestions based on location
  Map<String, List<IndianLanguage>> get regionalLanguages => {
        'North India': [
          supportedLanguages.firstWhere((l) => l.code == 'hi'), // Hindi
          supportedLanguages.firstWhere((l) => l.code == 'pa'), // Punjabi
          supportedLanguages.firstWhere((l) => l.code == 'ur'), // Urdu
          supportedLanguages.firstWhere((l) => l.code == 'ks'), // Kashmiri
          supportedLanguages.firstWhere((l) => l.code == 'ne'), // Nepali
        ],
        'South India': [
          supportedLanguages.firstWhere((l) => l.code == 'ta'), // Tamil
          supportedLanguages.firstWhere((l) => l.code == 'te'), // Telugu
          supportedLanguages.firstWhere((l) => l.code == 'kn'), // Kannada
          supportedLanguages.firstWhere((l) => l.code == 'ml'), // Malayalam
        ],
        'East India': [
          supportedLanguages.firstWhere((l) => l.code == 'bn'), // Bengali
          supportedLanguages.firstWhere((l) => l.code == 'as'), // Assamese
          supportedLanguages.firstWhere((l) => l.code == 'or'), // Odia
        ],
        'West India': [
          supportedLanguages.firstWhere((l) => l.code == 'mr'), // Marathi
          supportedLanguages.firstWhere((l) => l.code == 'gu'), // Gujarati
          supportedLanguages.firstWhere((l) => l.code == 'kok'), // Konkani
        ],
      };

  /// Format language name for display
  String getDisplayName(IndianLanguage language, {bool showEnglish = true}) {
    if (showEnglish) {
      return '${language.nameNative} (${language.nameEnglish})';
    }
    return language.nameNative;
  }

  /// Get appropriate font family for language
  String? getFontFamily(String languageCode) {
    switch (languageCode) {
      case 'hi':
      case 'mr':
      case 'ne':
      case 'sa':
      case 'mai':
      case 'kok':
        return 'NotoSansDevanagari';
      case 'bn':
      case 'as':
        return 'NotoSansBengali';
      case 'ta':
        return 'NotoSansTamil';
      case 'te':
        return 'NotoSansTelugu';
      case 'kn':
        return 'NotoSansKannada';
      case 'ml':
        return 'NotoSansMalayalam';
      case 'gu':
        return 'NotoSansGujarati';
      case 'pa':
        return 'NotoSansGurmukhi';
      case 'or':
        return 'NotoSansOriya';
      case 'ur':
        return 'NotoSansUrdu';
      default:
        return null; // Use system default
    }
  }

  /// Initialize service
  static Future<void> initialize() async {
    debugPrint(
        '🌐 Indian Languages Service initialized with ${supportedLanguages.length} languages');
  }
}
