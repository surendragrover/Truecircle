import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'indian_languages_service.dart';
import 'translation_api_service.dart';

/// Complete App Localization Service for TrueCircle
/// Makes entire app available in all Indian languages
class AppLocalizationService extends ChangeNotifier {
  static AppLocalizationService? _instance;
  static AppLocalizationService get instance =>
      _instance ??= AppLocalizationService._();

  AppLocalizationService._();

  Box? _localizationBox;
  String _currentLanguage = 'hi'; // Default to Hindi
  Map<String, Map<String, String>> _translations = {};
  bool _isInitialized = false;

  String get currentLanguage => _currentLanguage;
  bool get isInitialized => _isInitialized;

  /// Initialize the localization service
  Future<void> initialize() async {
    try {
      _localizationBox = await Hive.openBox('app_localizations');
      _currentLanguage = _localizationBox?.get('current_language') ?? 'hi';

      // Load cached translations
      final cachedTranslations = _localizationBox?.get('cached_translations');
      if (cachedTranslations != null) {
        _translations = Map<String, Map<String, String>>.from(
          cachedTranslations.map((key, value) => MapEntry(
                key.toString(),
                Map<String, String>.from(value),
              )),
        );
      }

      // Load default translations
      await _loadDefaultTranslations();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Localization service initialization failed: $e');
    }
  }

  /// Change app language
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      await _localizationBox?.put('current_language', languageCode);

      // Load translations for new language if not cached
      if (!_translations.containsKey(languageCode)) {
        await _loadTranslationsForLanguage(languageCode);
      }

      notifyListeners();
    }
  }

  /// Get localized string
  String translate(String key, [Map<String, dynamic>? params]) {
    final languageTranslations = _translations[_currentLanguage] ?? {};
    String translation = languageTranslations[key] ?? key;

    // Handle parameters
    if (params != null) {
      params.forEach((paramKey, value) {
        translation = translation.replaceAll('{$paramKey}', value.toString());
      });
    }

    return translation;
  }

  /// Shorthand for translate
  String t(String key, [Map<String, dynamic>? params]) =>
      translate(key, params);

  /// Get current language details
  IndianLanguage get currentLanguageDetails {
    const languages = IndianLanguagesService.supportedLanguages;
    return languages.firstWhere(
      (lang) => lang.code == _currentLanguage,
      orElse: () => languages.first,
    );
  }

  /// Load default translations for all supported languages
  Future<void> _loadDefaultTranslations() async {
    final defaultTranslations = _getDefaultTranslations();

    for (final languageCode in defaultTranslations.keys) {
      _translations[languageCode] = defaultTranslations[languageCode]!;
    }

    // Cache translations
    await _cacheTranslations();
  }

  /// Load translations for specific language
  Future<void> _loadTranslationsForLanguage(String languageCode) async {
    if (_translations.containsKey(languageCode)) return;

    try {
      // Try to get from API if available
      final translationService = TranslationApiService.instance;
      if (translationService.isInitialized) {
        final baseKeys = _getBaseTranslationKeys();
        final translatedValues = await translationService.translateBulk(
          baseKeys.values.toList(),
          languageCode,
        );

        final apiTranslations = <String, String>{};
        final keysList = baseKeys.keys.toList();
        for (int i = 0;
            i < keysList.length && i < translatedValues.length;
            i++) {
          apiTranslations[keysList[i]] = translatedValues[i];
        }

        _translations[languageCode] = apiTranslations;
      } else {
        // Use default translations
        _translations[languageCode] =
            _getDefaultTranslations()[languageCode] ?? {};
      }

      await _cacheTranslations();
    } catch (e) {
      debugPrint('Failed to load translations for $languageCode: $e');
      // Use default translations as fallback
      _translations[languageCode] =
          _getDefaultTranslations()[languageCode] ?? {};
    }
  }

  /// Cache translations to local storage
  Future<void> _cacheTranslations() async {
    try {
      await _localizationBox?.put('cached_translations', _translations);
    } catch (e) {
      debugPrint('Failed to cache translations: $e');
    }
  }

  /// Get base translation keys in English
  Map<String, String> _getBaseTranslationKeys() {
    return {
      // App General
      'app_name': 'TrueCircle',
      'welcome': 'Welcome',
      'hello': 'Hello',
      'good_morning': 'Good Morning',
      'good_evening': 'Good Evening',
      'thank_you': 'Thank You',
      'please': 'Please',
      'sorry': 'Sorry',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'settings': 'Settings',
      'profile': 'Profile',
      'home': 'Home',
      'back': 'Back',
      'next': 'Next',
      'done': 'Done',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',

      // Navigation
      'emotions': 'Emotions',
      'contacts': 'Contacts',
      'relationships': 'Relationships',
      'festivals': 'Festivals',
      'budget': 'Budget',
      'loyalty': 'Loyalty Points',
      'languages': 'Languages',

      // Authentication
      'sign_in': 'Sign In',
      'sign_out': 'Sign Out',
      'guest_mode': 'Continue as Guest',
      'phone_number': 'Phone Number',
      'enter_otp': 'Enter OTP',
      'verify': 'Verify',
      'resend_otp': 'Resend OTP',

      // Emotions
      'how_are_you_feeling': 'How are you feeling?',
      'emotion_happy': 'Happy',
      'emotion_sad': 'Sad',
      'emotion_angry': 'Angry',
      'emotion_excited': 'Excited',
      'emotion_calm': 'Calm',
      'emotion_anxious': 'Anxious',
      'emotion_love': 'Love',
      'emotion_grateful': 'Grateful',
      'log_emotion': 'Log Emotion',
      'emotion_history': 'Emotion History',

      // Contacts & Relationships
      'add_contact': 'Add Contact',
      'contact_name': 'Contact Name',
      'relationship_type': 'Relationship Type',
      'family': 'Family',
      'friends': 'Friends',
      'colleagues': 'Colleagues',
      'partner': 'Partner',
      'analyze_relationship': 'Analyze Relationship',
      'relationship_health': 'Relationship Health',
      'communication_pattern': 'Communication Pattern',

      // Festivals
      'upcoming_festivals': 'Upcoming Festivals',
      'festival_wishes': 'Festival Wishes',
      'send_greetings': 'Send Greetings',
      'festival_tips': 'Festival Tips',
      'gift_suggestions': 'Gift Suggestions',
      'dry_fruits': 'Dry Fruits',
      'sweets': 'Sweets',
      'flowers': 'Flowers',
      'decorations': 'Decorations',

      // Budget
      'event_budget': 'Event Budget',
      'total_budget': 'Total Budget',
      'spent_amount': 'Spent Amount',
      'remaining_budget': 'Remaining Budget',
      'add_expense': 'Add Expense',
      'expense_category': 'Expense Category',
      'food': 'Food',
      'gifts': 'Gifts',
      'travel': 'Travel',
      'miscellaneous': 'Miscellaneous',

      // Loyalty Points
      'daily_login': 'Daily Login',
      'points_earned': 'Points Earned',
      'total_points': 'Total Points',
      'redeem_points': 'Redeem Points',
      'point_value': '1 Point = ₹1',
      'max_discount': 'Maximum 15% discount',
      'login_streak': 'Login Streak',
      'bonus_points': 'Bonus Points',

      // Languages
      'change_language': 'Change Language',
      'select_language': 'Select Language',
      'popular_languages': 'Popular Languages',
      'all_languages': 'All Languages',
      'regional_languages': 'Regional Languages',
      'translation_test': 'Translation Test',
      'translate_text': 'Translate Text',

      // Privacy & Settings
      'privacy_settings': 'Privacy Settings',
      'notification_settings': 'Notification Settings',
      'data_analysis': 'Data Analysis',
      'content_analysis': 'Content Analysis',
      'cultural_insights': 'Cultural Insights',
      'enable_notifications': 'Enable Notifications',
      'sync_contacts': 'Sync Contacts',

      // Messages & Notifications
      'new_message': 'New Message',
      'no_messages': 'No Messages',
      'mark_as_read': 'Mark as Read',
      'notification_title': 'TrueCircle Notification',
      'daily_reminder': 'Don\'t forget to log your emotions today!',
      'festival_reminder': 'Festival reminder: {festival_name} is coming!',
      'loyalty_earned': 'You earned {points} loyalty points!',

      // Cultural AI
      'cultural_ai': 'Cultural AI',
      'festival_insights': 'Festival Insights',
      'regional_customs': 'Regional Customs',
      'family_traditions': 'Family Traditions',
      'cultural_tips': 'Cultural Tips',
      'hindi_greetings': 'Hindi Greetings',
      'regional_greetings': 'Regional Greetings',

      // Statistics
      'statistics': 'Statistics',
      'weekly_summary': 'Weekly Summary',
      'monthly_report': 'Monthly Report',
      'emotion_trends': 'Emotion Trends',
      'relationship_insights': 'Relationship Insights',
      'festival_participation': 'Festival Participation',
      'budget_overview': 'Budget Overview',

      // Common Phrases
      'namaste': 'Namaste',
      'dhanyawad': 'Thank You',
      'kshama_kariye': 'Sorry',
      'suprabhat': 'Good Morning',
      'shubh_ratri': 'Good Night',
      'sat_sri_akal': 'Sat Sri Akal',
      'adab': 'Adab',
      'vanakkam': 'Vanakkam',
      'namaskar': 'Namaskar',

      // Errors & Validations
      'required_field': 'This field is required',
      'invalid_phone': 'Invalid phone number',
      'invalid_otp': 'Invalid OTP',
      'network_error': 'Network connection error',
      'try_again': 'Please try again',
      'something_went_wrong': 'Something went wrong',
      'feature_not_available': 'This feature is not available yet',
    };
  }

  /// Get default translations for all supported languages
  Map<String, Map<String, String>> _getDefaultTranslations() {
    return {
      // Hindi translations
      'hi': {
        'app_name': 'ट्रूसर्कल',
        'welcome': 'स्वागत है',
        'hello': 'नमस्ते',
        'good_morning': 'सुप्रभात',
        'good_evening': 'शुभ संध्या',
        'thank_you': 'धन्यवाद',
        'please': 'कृपया',
        'sorry': 'क्षमा करें',
        'yes': 'हाँ',
        'no': 'नहीं',
        'ok': 'ठीक है',
        'cancel': 'रद्द करें',
        'save': 'सेव करें',
        'delete': 'डिलीट करें',
        'edit': 'संपादित करें',
        'add': 'जोड़ें',
        'settings': 'सेटिंग्स',
        'profile': 'प्रोफ़ाइल',
        'home': 'होम',
        'back': 'वापस',
        'next': 'अगला',
        'done': 'पूर्ण',
        'loading': 'लोड हो रहा है...',
        'error': 'त्रुटि',
        'success': 'सफलता',
        'emotions': 'भावनाएं',
        'contacts': 'संपर्क',
        'relationships': 'रिश्ते',
        'festivals': 'त्योहार',
        'budget': 'बजट',
        'loyalty': 'लॉयल्टी पॉइंट्स',
        'languages': 'भाषाएं',
        'sign_in': 'साइन इन करें',
        'sign_out': 'साइन आउट करें',
        'guest_mode': 'गेस्ट के रूप में जारी रखें',
        'phone_number': 'फोन नंबर',
        'enter_otp': 'OTP दर्ज करें',
        'verify': 'सत्यापित करें',
        'resend_otp': 'OTP फिर से भेजें',
        'how_are_you_feeling': 'आप कैसा महसूस कर रहे हैं?',
        'emotion_happy': 'खुश',
        'emotion_sad': 'उदास',
        'emotion_angry': 'गुस्से में',
        'emotion_excited': 'उत्साहित',
        'emotion_calm': 'शांत',
        'emotion_anxious': 'चिंतित',
        'emotion_love': 'प्रेम',
        'emotion_grateful': 'आभारी',
        'log_emotion': 'भावना लॉग करें',
        'emotion_history': 'भावना इतिहास',
        'upcoming_festivals': 'आने वाले त्योहार',
        'festival_wishes': 'त्योहारी शुभकामनाएं',
        'daily_login': 'दैनिक लॉगिन',
        'points_earned': 'अर्जित अंक',
        'change_language': 'भाषा बदलें',
        'namaste': 'नमस्ते',
        'dhanyawad': 'धन्यवाद',
      },

      // Bengali translations
      'bn': {
        'app_name': 'ট্রুসার্কেল',
        'welcome': 'স্বাগতম',
        'hello': 'নমস্কার',
        'good_morning': 'সুপ্রভাত',
        'good_evening': 'শুভ সন্ধ্যা',
        'thank_you': 'ধন্যবাদ',
        'please': 'দয়া করে',
        'sorry': 'দুঃখিত',
        'yes': 'হ্যাঁ',
        'no': 'না',
        'ok': 'ঠিক আছে',
        'cancel': 'বাতিল',
        'save': 'সেভ করুন',
        'delete': 'মুছে দিন',
        'edit': 'সম্পাদনা করুন',
        'add': 'যোগ করুন',
        'settings': 'সেটিংস',
        'profile': 'প্রোফাইল',
        'home': 'হোম',
        'back': 'ফিরে যান',
        'next': 'পরবর্তী',
        'done': 'সম্পন্ন',
        'loading': 'লোড হচ্ছে...',
        'emotions': 'আবেগ',
        'contacts': 'যোগাযোগ',
        'relationships': 'সম্পর্ক',
        'festivals': 'উৎসব',
        'languages': 'ভাষা',
        'emotion_happy': 'খুশি',
        'emotion_sad': 'দুঃখিত',
        'upcoming_festivals': 'আসন্ন উৎসব',
        'change_language': 'ভাষা পরিবর্তন করুন',
      },

      // Tamil translations
      'ta': {
        'app_name': 'ட்ருசர்கிள்',
        'welcome': 'வரவேற்கிறோம்',
        'hello': 'வணக்கம்',
        'good_morning': 'காலை வணக்கம்',
        'good_evening': 'மாலை வணக்கம்',
        'thank_you': 'நன்றி',
        'please': 'தயவு செய்து',
        'sorry': 'மன்னிக்கவும்',
        'yes': 'ஆம்',
        'no': 'இல்லை',
        'ok': 'சரி',
        'cancel': 'ரத்து செய்',
        'save': 'சேமி',
        'delete': 'அழி',
        'edit': 'திருத்து',
        'add': 'சேர்',
        'settings': 'அமைப்புகள்',
        'profile': 'சுயவிவரம்',
        'home': 'முகப்பு',
        'emotions': 'உணர்வுகள்',
        'contacts': 'தொடர்புகள்',
        'relationships': 'உறவுகள்',
        'festivals': 'விழாக்கள்',
        'languages': 'மொழிகள்',
        'emotion_happy': 'மகிழ்ச்சி',
        'emotion_sad': 'சோகம்',
        'upcoming_festivals': 'வரும் விழாக்கள்',
        'change_language': 'மொழியை மாற்று',
      },

      // Telugu translations
      'te': {
        'app_name': 'ట్రూసర్కిల్',
        'welcome': 'స్వాగతం',
        'hello': 'నమస్కారం',
        'good_morning': 'శుభోదయం',
        'good_evening': 'శుభ సాయంత్రం',
        'thank_you': 'ధన్యవాదాలు',
        'please': 'దయచేసి',
        'sorry': 'క్షమించండి',
        'yes': 'అవును',
        'no': 'కాదు',
        'ok': 'సరే',
        'cancel': 'రద్దు చేయి',
        'save': 'సేవ్ చేయి',
        'emotions': 'భావనలు',
        'contacts': 'పరిచయాలు',
        'relationships': 'సంబంధాలు',
        'festivals': 'పండుగలు',
        'languages': 'భాషలు',
        'emotion_happy': 'సంతోషం',
        'upcoming_festivals': 'రాబోయే పండుగలు',
        'change_language': 'భాష మార్చు',
      },

      // Gujarati translations
      'gu': {
        'app_name': 'ટ્રુસર્કલ',
        'welcome': 'સ્વાગત છે',
        'hello': 'નમસ્તે',
        'good_morning': 'સુપ્રભાત',
        'good_evening': 'સાંજે સારી',
        'thank_you': 'આભાર',
        'please': 'કૃપા કરીને',
        'sorry': 'માફ કરશો',
        'yes': 'હા',
        'no': 'ના',
        'emotions': 'લાગણીઓ',
        'contacts': 'સંપર્કો',
        'relationships': 'સંબંધો',
        'festivals': 'તહેવારો',
        'languages': 'ભાષાઓ',
        'upcoming_festivals': 'આવનારા તહેવારો',
        'change_language': 'ભાષા બદલો',
      },

      // Kannada translations
      'kn': {
        'app_name': 'ಟ್ರೂಸರ್ಕಲ್',
        'welcome': 'ಸ್ವಾಗತ',
        'hello': 'ನಮಸ್ಕಾರ',
        'good_morning': 'ಶುಭೋದಯ',
        'good_evening': 'ಶುಭ ಸಂಜೆ',
        'thank_you': 'ಧನ್ಯವಾದಗಳು',
        'emotions': 'ಭಾವನೆಗಳು',
        'contacts': 'ಸಂಪರ್ಕಗಳು',
        'festivals': 'ಹಬ್ಬಗಳು',
        'languages': 'ಭಾಷೆಗಳು',
        'change_language': 'ಭಾಷೆ ಬದಲಾಯಿಸಿ',
      },

      // Malayalam translations
      'ml': {
        'app_name': 'ട്രൂസർക്കിൾ',
        'welcome': 'സ്വാഗതം',
        'hello': 'നമസ്കാരം',
        'good_morning': 'സുപ്രഭാതം',
        'good_evening': 'ശുഭ സായാഹ്നം',
        'thank_you': 'നന്ദി',
        'emotions': 'വികാരങ്ങൾ',
        'contacts': 'കോൺടാക്റ്റുകൾ',
        'festivals': 'ഉത്സവങ്ങൾ',
        'languages': 'ഭാഷകൾ',
        'change_language': 'ഭാഷ മാറ്റുക',
      },

      // Marathi translations
      'mr': {
        'app_name': 'ट्रुसर्कल',
        'welcome': 'स्वागत आहे',
        'hello': 'नमस्कार',
        'good_morning': 'सुप्रभात',
        'good_evening': 'शुभ संध्याकाळ',
        'thank_you': 'धन्यवाद',
        'emotions': 'भावना',
        'contacts': 'संपर्क',
        'festivals': 'सण',
        'languages': 'भाषा',
        'change_language': 'भाषा बदला',
      },

      // Urdu translations
      'ur': {
        'app_name': 'ٹرو سرکل',
        'welcome': 'خوش آمدید',
        'hello': 'السلام علیکم',
        'good_morning': 'صبح بخیر',
        'good_evening': 'شام بخیر',
        'thank_you': 'شکریہ',
        'emotions': 'جذبات',
        'contacts': 'رابطے',
        'festivals': 'تہوار',
        'languages': 'زبانیں',
        'change_language': 'زبان تبدیل کریں',
      },

      // Punjabi translations
      'pa': {
        'app_name': 'ਟਰੂਸਰਕਲ',
        'welcome': 'ਜੀ ਆਇਆਂ ਨੂੰ',
        'hello': 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ',
        'good_morning': 'ਸੁਪ੍ਰਭਾਤ',
        'thank_you': 'ਧੰਨਵਾਦ',
        'emotions': 'ਭਾਵਨਾਵਾਂ',
        'contacts': 'ਸੰਪਰਕ',
        'festivals': 'ਤਿਉਹਾਰ',
        'languages': 'ਭਾਸ਼ਾਵਾਂ',
        'change_language': 'ਭਾਸ਼ਾ ਬਦਲੋ',
      },
    };
  }

  /// Get available language options
  List<LanguageOption> getAvailableLanguages() {
    const supportedLanguages = IndianLanguagesService.supportedLanguages;
    return supportedLanguages
        .map((lang) => LanguageOption(
              code: lang.code,
              name: lang.nameEnglish,
              nativeName: lang.nameNative,
              isSupported: _translations.containsKey(lang.code),
            ))
        .toList();
  }

  /// Clear all cached translations
  Future<void> clearCache() async {
    await _localizationBox?.delete('cached_translations');
    _translations.clear();
    await _loadDefaultTranslations();
    notifyListeners();
  }

  /// Force reload translations from API
  Future<void> reloadTranslations() async {
    _translations.clear();
    await _loadDefaultTranslations();
    await _loadTranslationsForLanguage(_currentLanguage);
    notifyListeners();
  }
}

/// Language option model
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final bool isSupported;

  LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.isSupported,
  });
}

/// Extension for easy access to translations
extension LocalizationExtension on BuildContext {
  String translate(String key, [Map<String, dynamic>? params]) {
    return AppLocalizationService.instance.translate(key, params);
  }

  String t(String key, [Map<String, dynamic>? params]) {
    return AppLocalizationService.instance.translate(key, params);
  }
}
