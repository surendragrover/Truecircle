import 'package:hive/hive.dart';
import '../models/privacy_settings.dart';

class PrivacyService {
  static const String _boxName = 'privacy_settings';
  late Box<PrivacySettings> _box;

  // Singleton pattern for global access
  static final PrivacyService _instance = PrivacyService._internal();
  factory PrivacyService() => _instance;
  PrivacyService._internal();

  // Initialize the service
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<PrivacySettings>(_boxName);
    } else {
      _box = Hive.box<PrivacySettings>(_boxName);
    }
  }

  // Get current privacy settings
  PrivacySettings getSettings() {
    final settings = _box.get('current_settings');
    if (settings == null) {
      // First time user - return basic privacy settings
      final basicSettings = PrivacySettings.basicPrivacy();
      _box.put('current_settings', basicSettings);
      return basicSettings;
    }
    return settings;
  }

  // Update privacy settings
  Future<void> updateSettings(PrivacySettings settings) async {
    settings.lastUpdated = DateTime.now();
    await _box.put('current_settings', settings);
  }

  // Check if user has seen privacy intro
  bool hasSeenPrivacyIntro() {
    return getSettings().hasSeenPrivacyIntro;
  }

  // Mark privacy intro as seen
  Future<void> markPrivacyIntroSeen() async {
    final settings = getSettings();
    settings.hasSeenPrivacyIntro = true;
    await updateSettings(settings);
  }

  // System Permission Checks
  Future<bool> checkContactsPermission() async {
    // Demo app - always return false (no permissions needed)
    return false;
  }

  Future<bool> requestContactsPermission() async {
    // Demo app - always return false (no permissions needed)
    final settings = getSettings();
    settings.contactsAccess = false;
    await updateSettings(settings);
    return false;
  }

  Future<bool> checkCallLogPermission() async {
    // Demo app - always return false (no permissions needed)
    return false;
  }

  Future<bool> requestCallLogPermission() async {
    // Demo app - always return false (no permissions needed)
    final settings = getSettings();
    settings.callLogAccess = false;
    await updateSettings(settings);
    return false;
  }

  Future<bool> checkSMSPermission() async {
    // Demo app - always return false (no permissions needed)
    return false;
  }

  Future<bool> requestSMSPermission() async {
    // Demo app - always return false (no permissions needed)
    return false;
  }

  // Privacy Level Management
  Future<void> setPrivacyLevel(String level) async {
    final settings = getSettings();
    settings.updatePrivacyLevel(level);
    await updateSettings(settings);
  }

  // Feature Toggle Methods
  Future<void> toggleContactsAccess(bool enabled) async {
    if (enabled) {
      // Request system permission first
      final granted = await requestContactsPermission();
      if (!granted) return;
    }

    final settings = getSettings();
    settings.togglePermission('contacts', enabled);
    await updateSettings(settings);
  }

  Future<void> toggleCallLogAccess(bool enabled) async {
    if (enabled) {
      final granted = await requestCallLogPermission();
      if (!granted) return;
    }

    final settings = getSettings();
    settings.togglePermission('callLog', enabled);
    await updateSettings(settings);
  }

  Future<void> toggleSMSAccess(bool enabled) async {
    if (enabled) {
      final granted = await requestSMSPermission();
      if (!granted) return;
    }

    final settings = getSettings();
    settings.togglePermission('smsMetadata', enabled);
    await updateSettings(settings);
  }

  Future<void> toggleSentimentAnalysis(bool enabled) async {
    final settings = getSettings();
    settings.togglePermission('sentimentAnalysis', enabled);
    await updateSettings(settings);
  }

  Future<void> toggleAIInsights(bool enabled) async {
    final settings = getSettings();
    settings.togglePermission('aiInsights', enabled);
    await updateSettings(settings);
  }

  // Data Management
  Future<void> clearAllData() async {
    // Clear all Hive boxes
    await Hive.box('emotion_entries').clear();
    await Hive.box('contacts').clear();
    await Hive.box('contact_interactions').clear();

    // Reset privacy settings to basic
    final basicSettings = PrivacySettings.basicPrivacy();
    await updateSettings(basicSettings);
  }

  Future<Map<String, dynamic>> exportUserData() async {
    final settings = getSettings();
    if (!settings.dataExport) {
      throw Exception('Data export is disabled in privacy settings');
    }

    return {
      'export_date': DateTime.now().toIso8601String(),
      'privacy_settings': settings.toJson(),
      'app_version': '1.0.0',
      'note':
          'All data exported from local device only - never stored in cloud',
      'note_hindi':
          'सारा डेटा केवल आपके डिवाइस से एक्सपोर्ट किया गया - कभी क्लाउड में स्टोर नहीं किया',
    };
  }

  // Privacy Audit Log
  Future<void> logPrivacyAction(
      String action, Map<String, dynamic> details) async {
    final auditLog = Hive.box('privacy_audit');
    await auditLog.add({
      'timestamp': DateTime.now().toIso8601String(),
      'action': action,
      'details': details,
    });
  }

  // Get Privacy Summary for UI
  Map<String, dynamic> getPrivacySummary() {
    final settings = getSettings();
    return {
      'privacy_level': settings.privacyLevel,
      'privacy_level_description': settings.getPrivacyLevelDescription(),
      'enabled_features': settings.getEnabledFeatures(),
      'privacy_guarantees': settings.getPrivacyGuarantees(),
      'last_updated': settings.lastUpdated,
      'language': settings.language,
    };
  }

  // Language Management
  Future<void> setLanguage(String language) async {
    final settings = getSettings();
    settings.language = language;
    await updateSettings(settings);
  }

  String getCurrentLanguage() {
    return getSettings().language;
  }
}
