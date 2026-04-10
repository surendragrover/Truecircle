import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSService {
  static const String _boxName = 'sosBox';
  static const String _profileKey = 'safety_profile';

  static Future<void> saveEmergencyNumbersFor(String countryCode) async {
    final Map<String, List<String>> numbers = _countryEmergencyNumbers[countryCode] ?? _countryEmergencyNumbers['DEFAULT']!;
    final Box<dynamic> box = await Hive.openBox<dynamic>(_boxName);
    await box.put('police', numbers['police']);
    await box.put('medical', numbers['medical']);
    await box.put('fire', numbers['fire']);
    await box.put('country', countryCode);
  }

  static Future<List<String>?> getPolice() async {
    final Box<dynamic> box = await Hive.openBox<dynamic>(_boxName);
    return box.get('police')?.cast<String>();
  }

  static Future<List<String>?> getMedical() async {
    final Box<dynamic> box = await Hive.openBox<dynamic>(_boxName);
    return box.get('medical')?.cast<String>();
  }

  static Future<List<String>?> getFire() async {
    final Box<dynamic> box = await Hive.openBox<dynamic>(_boxName);
    return box.get('fire')?.cast<String>();
  }

  static Future<void> saveSafetyProfile(Map<String, dynamic> profile) async {
    final Box<dynamic> box = await Hive.openBox<dynamic>(_boxName);
    await box.put(_profileKey, profile);
  }

  static Future<Map<String, dynamic>> getSafetyProfile() async {
    final Box<dynamic> box = await Hive.openBox<dynamic>(_boxName);
    final dynamic raw = box.get(_profileKey, defaultValue: <String, dynamic>{});
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return <String, dynamic>{};
  }

  static Future<String> getSavedCountryCode() async {
    final Box<dynamic> box = await Hive.openBox<dynamic>(_boxName);
    return (box.get('country', defaultValue: 'IN') as String?) ?? 'IN';
  }

  static List<String> supportedCountryCodes() {
    return _countryEmergencyNumbers.keys
        .where((String c) => c != 'DEFAULT')
        .toList(growable: false);
  }

  static Map<String, List<String>> emergencyNumbersFor(String countryCode) {
    return _countryEmergencyNumbers[countryCode] ??
        _countryEmergencyNumbers['DEFAULT']!;
  }

  static Future<bool> callTrustedContactIfPermitted() async {
    final Map<String, dynamic> profile = await getSafetyProfile();
    final bool allowed =
        (profile['allow_call_trusted_contact'] as bool?) ?? false;
    final String number =
        (profile['trusted_contact_number'] as String?)?.trim() ?? '';
    if (!allowed || number.isEmpty) return false;
    return _dial(number);
  }

  static Future<bool> callEmergencyIfPermitted() async {
    final Map<String, dynamic> profile = await getSafetyProfile();
    final bool allowed =
        (profile['allow_call_country_emergency'] as bool?) ?? false;
    if (!allowed) return false;

    final String countryCode =
        (profile['country_code'] as String?) ?? await getSavedCountryCode();
    final Map<String, List<String>> numbers = emergencyNumbersFor(countryCode);
    final String number =
        (numbers['medical']?.isNotEmpty ?? false) ? numbers['medical']!.first : '112';
    return _dial(number);
  }

  static Future<bool> _dial(String number) async {
    final String sanitized = number.replaceAll(RegExp(r'[^0-9+]'), '');
    if (sanitized.isEmpty) return false;
    final Uri uri = Uri(scheme: 'tel', path: sanitized);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static const Map<String, Map<String, List<String>>> _countryEmergencyNumbers = <String, Map<String, List<String>>>{
    'IN': {
      'police': ['100', '112'],
      'medical': ['102', '108', '112'],
      'fire': ['101', '112'],
    },
    'US': {
      'police': ['911'],
      'medical': ['911'],
      'fire': ['911'],
    },
    'UK': {
      'police': ['999', '112'],
      'medical': ['999', '112'],
      'fire': ['999', '112'],
    },
    'DEFAULT': {
      'police': ['112'],
      'medical': ['112'],
      'fire': ['112'],
    },
  };
}
