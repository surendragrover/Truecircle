import 'dart:io';

class CountryDetectorService {
  static Future<String?> detect() async {
    try {
      final String locale = Platform.localeName; // en_IN, en_US, etc.
      if (locale.length >= 2) {
        final String countryCode = locale.split('_').last.toUpperCase();
        if (countryCode.length == 2) return countryCode;
      }
    } catch (_) {}
    return null;
  }
}
