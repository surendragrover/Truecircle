import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/privacy_settings.dart';
import '../models/relationship_log.dart';
import 'privacy_mode_manager.dart';
import 'on_device_ai_service.dart';
import '../core/service_locator.dart';

/// Enhanced Privacy Service for TrueCircle
///
/// This service manages privacy settings, Privacy Mode enforcement, and secure
/// access to sensitive device data. It integrates with PrivacyModeManager
/// to ensure privacy-first operation.
///
/// Key Features:
/// - Privacy Mode enforcement by default
/// - Privacy-first data access controls
/// - AI consent management
/// - Secure sensitive data handling
class PrivacyService {
  static const String _boxName = 'privacy_settings';
  late Box<PrivacySettings> _box;

  // Singleton pattern for global access
  static final PrivacyService _instance = PrivacyService._internal();
  factory PrivacyService() => _instance;
  PrivacyService._internal();

  // Privacy mode manager integration
  final PrivacyModeManager _privacyManager = PrivacyModeManager();

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
    // Sample App - always return false (no permissions needed)
    return false;
  }

  Future<bool> requestContactsPermission() async {
    // Sample App - always return false (no permissions needed)
    final settings = getSettings();
    settings.contactsAccess = false;
    await updateSettings(settings);
    return false;
  }

  Future<bool> checkCallLogPermission() async {
    // Sample App - always return false (no permissions needed)
    return false;
  }

  Future<bool> requestCallLogPermission() async {
    // Sample App - always return false (no permissions needed)
    final settings = getSettings();
    settings.callLogAccess = false;
    await updateSettings(settings);
    return false;
  }

  Future<bool> checkSMSPermission() async {
    // Sample App - always return false (no permissions needed)
    return false;
  }

  Future<bool> requestSMSPermission() async {
    // Sample App - always return false (no permissions needed)
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

  // --------------------------------------------------------------------------
  // Privacy Mode and AI Privacy Integration
  // --------------------------------------------------------------------------

  bool isPrivacyMode() => _privacyManager.isPrivacyMode;

  /// Check if AI processing is allowed
  bool canUseAI() {
    return _privacyManager.canUseAI;
  }

  /// Request user consent for AI functionality
  ///
  /// This shows users that AI processing happens entirely on-device
  /// and no data is sent to external servers.
  Future<bool> requestAIConsent() async {
    return await _privacyManager.requestAIConsent();
  }

  // Removed deprecated: getDemoContactsData (use getSampleContactsData)

  List<Map<String, dynamic>> getSampleContactsData() {
    return [
      {
        'id': 'sample_1',
        'name': 'Alex Johnson',
        'phone': '+1 (555) 123-4567',
        'relationship': 'Friend',
        'lastContact': DateTime.now().subtract(const Duration(days: 2)),
        'isDemo': true,
        'privacyNote': 'This is sample data used in Privacy Mode',
      },
      {
        'id': 'sample_2',
        'name': 'Sarah Williams',
        'phone': '+1 (555) 234-5678',
        'relationship': 'Family',
        'lastContact': DateTime.now().subtract(const Duration(days: 1)),
        'isDemo': true,
        'privacyNote': 'This is sample data used in Privacy Mode',
      },
      {
        'id': 'sample_3',
        'name': 'Michael Chen',
        'phone': '+1 (555) 345-6789',
        'relationship': 'Colleague',
        'lastContact': DateTime.now().subtract(const Duration(days: 5)),
        'isDemo': true,
        'privacyNote': 'This is sample data used in Privacy Mode',
      },
    ];
  }

  // Removed deprecated: getDemoCallLogsData (use getSampleCallLogsData)

  List<Map<String, dynamic>> getSampleCallLogsData() {
    return [
      {
        'id': 'call_sample_1',
        'contactName': 'Alex Johnson',
        'phoneNumber': '+1 (555) 123-4567',
        'callType': 'outgoing',
        'duration': 120, // seconds
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'isDemo': true,
        'privacyNote': 'This is sample data used in Privacy Mode',
      },
      {
        'id': 'call_sample_2',
        'contactName': 'Sarah Williams',
        'phoneNumber': '+1 (555) 234-5678',
        'callType': 'incoming',
        'duration': 300,
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'isDemo': true,
        'privacyNote': 'This is sample data used in Privacy Mode',
      },
    ];
  }

  // Removed deprecated: getDemoMessagesData (use getSampleMessagesData)

  List<Map<String, dynamic>> getSampleMessagesData() {
    return [
      {
        'id': 'msg_sample_1',
        'contactName': 'Alex Johnson',
        'phoneNumber': '+1 (555) 123-4567',
        'content': 'Hey, are we still on for dinner tonight?',
        'type': 'received',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'isDemo': true,
        'privacyNote': 'This is sample data used in Privacy Mode',
      },
      {
        'id': 'msg_sample_2',
        'contactName': 'Sarah Williams',
        'phoneNumber': '+1 (555) 234-5678',
        'content': 'Happy birthday! Hope you have a wonderful day!',
        'type': 'received',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'isDemo': true,
        'privacyNote': 'This is sample data used in Privacy Mode',
      },
    ];
  }

  /// Validate that AI operations are permitted in current mode
  bool validateAIAccess(String operation) {
    // In Privacy Mode, only Dr. Iris responses are allowed
    if (isPrivacyMode()) {
      return operation.toLowerCase() == 'generatedrirισresponse' ||
          operation.toLowerCase() == 'dr_iris' ||
          operation.toLowerCase() == 'ai_chat';
    }

    // In full mode, check if user has consented to AI
    return canUseAI();
  }

  /// Get appropriate data source based on current privacy mode
  Future<List<Map<String, dynamic>>> getPrivacyCompliantData(
      String dataType) async {
    switch (dataType.toLowerCase()) {
      case 'contacts':
        return isPrivacyMode()
            ? getSampleContactsData()
            : getSampleContactsData(); // Always sample for privacy
      case 'calls':
        return isPrivacyMode()
            ? getSampleCallLogsData()
            : getSampleCallLogsData(); // Always sample for privacy
      case 'messages':
        return isPrivacyMode()
            ? getSampleMessagesData()
            : getSampleMessagesData(); // Always sample for privacy
      default:
        return [];
    }
  }

  /// Get privacy status including Privacy Mode information
  Map<String, dynamic> getEnhancedPrivacySummary() {
    final settings = getSettings();
    final privacyStatus = _privacyManager.getPrivacyStatus();

    return {
      'privacy_level': settings.privacyLevel,
      'privacy_mode': privacyStatus['mode'],
      // deprecated key removed; use 'isPrivacyMode'
      'privacy_level_description': settings.getPrivacyLevelDescription(),
      'enabled_features': settings.getEnabledFeatures(),
      'privacy_guarantees': settings.getPrivacyGuarantees(),
      'ai_consent': privacyStatus['canUseAI'],
      'privacy_status_message': _privacyManager.getPrivacyStatusMessage(),
      'data_access_messages': {
        'contacts': _privacyManager.getDataAccessMessage('contacts'),
        'calls': _privacyManager.getDataAccessMessage('calls'),
        'messages': _privacyManager.getDataAccessMessage('messages'),
        'ai': _privacyManager.getDataAccessMessage('ai'),
      },
      'last_updated': settings.lastUpdated,
      'language': settings.language,
    };
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
      'privacy_mode_active': isPrivacyMode(),
      'ai_processing_available': canUseAI(),
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

  // ==========================================================================
  // COMMUNICATION TRACKER - Privacy-First Implementation
  // ==========================================================================

  /// यह चैनल नेटिव कोड से कॉल और मैसेज लॉग प्राप्त करेगा
  static const MethodChannel _channel =
      MethodChannel('truecircle_privacy_channel');

  // --------------------------------------------------------------------------
  // 1. Permission and Tracking Management
  // --------------------------------------------------------------------------

  /// [सेटिंग्स] में यूज़र की सहमति के बाद, नेटिव परमिशन प्रॉम्प्ट्स को ट्रिगर करता है।
  ///
  /// यह method केवल privacy mode disable होने पर real permissions request करता है
  Future<bool> requestLogPermissions() async {
    // Privacy Mode check - Privacy Mode में real permissions नहीं मांगते
    if (isPrivacyMode()) {
      debugPrint(
          '🔐 Privacy Service: Privacy Mode active - not requesting real permissions');
      return true; // Privacy Mode में permissions simulate करते हैं
    }

    try {
      debugPrint('📞 Privacy Service: Requesting native log permissions...');

      // नेटिव साइड को परमिशन मांगने के लिए कहते हैं
      final bool granted =
          await _channel.invokeMethod('requestAllLogsPermissions');

      if (granted) {
        debugPrint(
            '✅ Privacy Service: Permissions granted, starting background tracking');
        // अनुमति मिलने पर, बैकग्राउंड ट्रैकिंग शुरू करें
        await _channel.invokeMethod('startBackgroundLogTracking');

        // Privacy settings में update करना
        final settings = getSettings();
        settings.allowCommunicationTracking = true;
        await updateSettings(settings);
      } else {
        debugPrint('❌ Privacy Service: Permissions denied');
      }

      return granted;
    } on PlatformException catch (e) {
      debugPrint(
          '❌ Privacy Service: Platform exception during permission request: $e');
      return false;
    } catch (e) {
      debugPrint(
          '❌ Privacy Service: Unexpected error during permission request: $e');
      return false;
    }
  }

  /// जांचता है कि कॉल/मैसेज लॉग ट्रैकिंग की अनुमति मिली है या नहीं।
  Future<bool> hasLogPermissions() async {
    // Privacy Mode check
    if (isPrivacyMode()) {
      return true; // Privacy Mode में permissions हमेशा available
    }

    try {
      final bool hasPermissions =
          await _channel.invokeMethod('hasLogsPermissions');
      debugPrint('🔍 Privacy Service: Log permissions status: $hasPermissions');
      return hasPermissions;
    } on PlatformException catch (e) {
      debugPrint('❌ Privacy Service: Error checking permissions: $e');
      return false;
    }
  }

  /// Communication tracking को start करना
  Future<bool> startCommunicationTracking() async {
    if (isPrivacyMode()) {
      debugPrint(
          '🔐 Privacy Service: Privacy Mode - communication tracking simulated');
      return true;
    }

    try {
      final hasPermissions = await hasLogPermissions();
      if (!hasPermissions) {
        debugPrint(
            '⚠️ Privacy Service: Cannot start tracking - permissions not granted');
        return false;
      }

      await _channel.invokeMethod('startBackgroundLogTracking');
      debugPrint('✅ Privacy Service: Communication tracking started');
      return true;
    } catch (e) {
      debugPrint(
          '❌ Privacy Service: Error starting communication tracking: $e');
      return false;
    }
  }

  /// Communication tracking को stop करना
  Future<void> stopCommunicationTracking() async {
    if (isPrivacyMode()) {
      debugPrint(
          '🔐 Privacy Service: Privacy Mode - communication tracking stop simulated');
      return;
    }

    try {
      await _channel.invokeMethod('stopBackgroundLogTracking');
      debugPrint('⏹️ Privacy Service: Communication tracking stopped');
    } catch (e) {
      debugPrint(
          '❌ Privacy Service: Error stopping communication tracking: $e');
    }
  }

  // --------------------------------------------------------------------------
  // 2. Data Retrieval and AI Analysis
  // --------------------------------------------------------------------------

  /// स्थानीय डेटाबेस से आवश्यक लॉग समरी (सारांश) प्राप्त करता है।
  /// केवल [favoriteContact] के लिए डेटा लाया जाएगा, जैसा कि यूज़र ने सेट किया है।
  Future<List<RelationshipLog>> getLogSummaryForAI(
      String favoriteContactId) async {
    // Privacy Mode check - sample data return करना
    if (isPrivacyMode()) {
      debugPrint(
          '🔐 Privacy Service: Returning sample communication data for $favoriteContactId');
      return RelationshipLog.generateSampleData(
          favoriteContactId, 'Sample Contact');
    }

    try {
      debugPrint(
          '📊 Privacy Service: Fetching log summary for contact: $favoriteContactId');

      final List<dynamic> logData = await _channel
          .invokeMethod('getLogSummary', {'contactId': favoriteContactId});

      // डेटा को मॉडल में बदलें और AI विश्लेषण के लिए तैयार करें
      final logs =
          logData.map((data) => RelationshipLog.fromJson(data)).toList();

      debugPrint('✅ Privacy Service: Retrieved ${logs.length} log entries');
      return logs;
    } on PlatformException catch (e) {
      debugPrint('❌ Privacy Service: Platform exception fetching logs: $e');
      // Fallback to sample data on error
      return RelationshipLog.generateSampleData(
          favoriteContactId, 'Sample Contact');
    } catch (e) {
      debugPrint('❌ Privacy Service: Unexpected error fetching logs: $e');
      return [];
    }
  }

  /// रिलेशनशिप की वर्तमान स्थिति का ऑफ़लाइन AI विश्लेषण चलाता है।
  Future<String> getRelationshipInsight(String favoriteContactId) async {
    try {
      debugPrint(
          '🧠 Privacy Service: Generating relationship insight for $favoriteContactId');

      // Log data प्राप्त करना
      final logs = await getLogSummaryForAI(favoriteContactId);

      if (logs.isEmpty) {
        return isPrivacyMode()
            ? 'Privacy Mode: Relationship insights के लिए अधिक sample communication data की आवश्यकता है।'
            : 'कोई communication data उपलब्ध नहीं है। कृपया permissions enable करें।';
      }

      // Service Locator से AI service प्राप्त करना
      OnDeviceAIService? aiService;
      try {
        aiService = ServiceLocator.instance.get<OnDeviceAIService>();
      } catch (e) {
        debugPrint('❌ Privacy Service: AI service not available: $e');
        return _generateFallbackInsight(logs);
      }

      // AI सर्विस को समरी (सारांश) भेजें
      final logStrings = logs.map((log) => log.toSummaryString()).toList();

      // Communication stats भी generate करना
      final stats = CommunicationStats.fromLogs(
        favoriteContactId,
        logs,
        DateTime.now().subtract(const Duration(days: 30)),
        DateTime.now(),
      );

      final analysisPrompt = '''
Relationship Communication Analysis:

${stats.toAnalysisString()}

Recent Communication Patterns:
${logStrings.take(10).join('\n')}

कृपया इस data के आधार पर relationship insight प्रदान करें। Focus करें:
1. Communication frequency और patterns
2. Emotional tone trends  
3. Relationship health indicators
4. Practical suggestions for improvement

सभी analysis on-device processing के साथ privacy-safe है।
''';

      debugPrint('📤 Privacy Service: Sending analysis prompt to AI service');
      final insight = await aiService.generateRelationshipTip([analysisPrompt]);

      debugPrint('✅ Privacy Service: Generated relationship insight');
      return insight;
    } catch (e) {
      debugPrint(
          '❌ Privacy Service: Error generating relationship insight: $e');
      return _generateFallbackInsight([]);
    }
  }

  /// Fallback insight generation when AI service is not available
  String _generateFallbackInsight(List<RelationshipLog> logs) {
    if (logs.isEmpty) {
      return isPrivacyMode()
          ? '''Privacy Mode Relationship Insight:

📱 Sample communication data दिखाता है कि आपका relationship healthy patterns follow कर रहा है।

💡 Key Observations:
• Regular communication frequency maintained
• Positive emotional tone में conversations
• Good balance between calls और messages

🎯 Suggestions:
• Continue maintaining current communication patterns
• Regular check-ins schedule करें
• Express appreciation more frequently

यह insight sample data पर based है। Real analysis के लिए privacy settings adjust करें।'''
          : '''Communication Insight:

📊 Limited data available. Enable communication permissions for detailed analysis.

💡 General Relationship Tips:
• Maintain regular communication
• Be attentive to emotional tones
• Quality over quantity in conversations
• Schedule regular meaningful check-ins

For personalized insights, please enable communication tracking in privacy settings.''';
    }

    // Generate basic insight from available logs
    final totalInteractions = logs.length;
    final calls = logs.where((l) => l.type == InteractionType.call).length;
    final messages =
        logs.where((l) => l.type == InteractionType.message).length;
    final avgIntimacy =
        logs.fold(0.0, (sum, log) => sum + log.intimacyScore) / logs.length;

    return '''Communication Insight Summary:

📊 Communication Overview:
• Total interactions: $totalInteractions
• Calls: $calls, Messages: $messages
• Intimacy level: ${(avgIntimacy * 100).toStringAsFixed(0)}%

💡 Key Observations:
${avgIntimacy > 0.7 ? '• Strong emotional connection evident' : '• Room for deeper emotional connection'}
${calls > messages ? '• Voice communication preferred' : '• Text communication preferred'}

🎯 Suggestions:
• Balance different communication types
• Pay attention to emotional tone patterns
• Regular meaningful conversations important

${isPrivacyMode() ? '\n(Privacy Mode: Analysis based on sample data)' : ''}''';
  }
}
