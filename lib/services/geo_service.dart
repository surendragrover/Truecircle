import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';

/// Lightweight Geo service: attempts to detect user's country by calling
/// a public IP geolocation endpoint. Falls back to no-op when network is
/// unavailable. Results are cached in Hive under key 'user_country'.
class GeoService {
  static final GeoService instance = GeoService._internal();
  GeoService._internal();

  /// Attempts network-based detection and stores country code (ISO2) in Hive.
  /// Returns the detected country code (uppercase) or null if not found.
  Future<String?> detectAndStoreCountry() async {
    try {
      final prefs = await Hive.openBox('app_prefs');
      final offline = prefs.get('force_offline', defaultValue: false) as bool;
      if (offline) {
        return prefs.get('user_country') as String?;
      }
    } catch (_) {
      // ignore
    }
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 6);
      final request = await client.getUrl(Uri.parse('https://ipapi.co/json/'));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = json.decode(body) as Map<String, dynamic>;
        final country = (data['country_code'] as String?)?.toUpperCase();
        if (country != null && country.isNotEmpty) {
          final box = await Hive.openBox('app_prefs');
          await box.put('user_country', country);
          return country;
        }
      }
    } catch (e) {
      // Network not available or parsing failed - ignore
    }

    return null;
  }

  /// Returns the stored user country code (ISO2) from Hive, or null if missing.
  Future<String?> getStoredCountry() async {
    try {
      final box = await Hive.openBox('app_prefs');
      final c = box.get('user_country') as String?;
      return c;
    } catch (e) {
      return null;
    }
  }
}
