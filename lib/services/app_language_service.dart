import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppLanguageService {
  static const String _languageCodeKey = 'app_language_code';
  static const String _defaultLanguageCode = 'en';

  static final ValueNotifier<Locale> localeNotifier =
      ValueNotifier<Locale>(const Locale(_defaultLanguageCode));

  static Future<void> loadSavedLocale() async {
    if (!Hive.isBoxOpen('appBox')) return;
    final Box<dynamic> appBox = Hive.box('appBox');
    final String code =
        (appBox.get(_languageCodeKey, defaultValue: _defaultLanguageCode)
                as String?) ??
            _defaultLanguageCode;
    localeNotifier.value = _localeFromCode(code);
  }

  static Future<void> setLanguageCode(String code) async {
    final String normalized = _normalizeCode(code);
    if (Hive.isBoxOpen('appBox')) {
      await Hive.box('appBox').put(_languageCodeKey, normalized);
    }
    localeNotifier.value = _localeFromCode(normalized);
  }

  static String currentLanguageCode() {
    final String code = localeNotifier.value.languageCode;
    return _normalizeCode(code);
  }

  static String displayName(String code) {
    switch (_normalizeCode(code)) {
      case 'hi':
        return 'Hindi';
      case 'en':
      default:
        return 'English';
    }
  }

  static String _normalizeCode(String code) {
    final String normalized = code.trim().toLowerCase();
    if (normalized == 'hi') return 'hi';
    return 'en';
  }

  static Locale _localeFromCode(String code) {
    return Locale(_normalizeCode(code));
  }
}
