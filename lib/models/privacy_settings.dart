import 'package:hive/hive.dart';

part 'privacy_settings.g.dart';

@HiveType(typeId: 6)
class PrivacySettings extends HiveObject {
  @HiveField(0)
  bool contactsAccess;

  @HiveField(1)
  bool callLogAccess;

  @HiveField(2)
  bool smsMetadataAccess;

  @HiveField(3)
  bool sentimentAnalysis;

  @HiveField(4)
  bool aiInsights;

  @HiveField(5)
  bool dataExport;

  @HiveField(6)
  bool notificationsEnabled;

  @HiveField(7)
  DateTime lastUpdated;

  @HiveField(8)
  String privacyLevel; // 'basic', 'standard', 'advanced'

  @HiveField(9)
  Map<String, bool> granularPermissions;

  @HiveField(10)
  bool hasSeenPrivacyIntro;

  @HiveField(11)
  String language; // 'en' or 'hi'

  PrivacySettings({
    this.contactsAccess = false,
    this.callLogAccess = false,
    this.smsMetadataAccess = false,
    this.sentimentAnalysis = false,
    this.aiInsights = true,
    this.dataExport = true,
    this.notificationsEnabled = false,
    DateTime? lastUpdated,
    this.privacyLevel = 'basic',
    this.granularPermissions = const <String, bool>{},
    this.hasSeenPrivacyIntro = false,
    this.language = 'en',
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  // Privacy Level Presets
  static PrivacySettings basicPrivacy() {
    return PrivacySettings(
      contactsAccess: true,
      callLogAccess: false,
      smsMetadataAccess: false,
      sentimentAnalysis: false,
      aiInsights: true,
      privacyLevel: 'basic',
    );
  }

  static PrivacySettings standardPrivacy() {
    return PrivacySettings(
      contactsAccess: true,
      callLogAccess: true,
      smsMetadataAccess: false,
      sentimentAnalysis: false,
      aiInsights: true,
      privacyLevel: 'standard',
    );
  }

  static PrivacySettings advancedPrivacy() {
    return PrivacySettings(
      contactsAccess: true,
      callLogAccess: true,
      smsMetadataAccess: true,
      sentimentAnalysis: true,
      aiInsights: true,
      privacyLevel: 'advanced',
    );
  }

  // Permission Helpers
  bool canAccessContacts() => contactsAccess;
  bool canAnalyzeCallPatterns() => callLogAccess;
  bool canAnalyzeMessagePatterns() => smsMetadataAccess;
  bool canPerformSentimentAnalysis() => sentimentAnalysis;
  bool canShowAIInsights() => aiInsights;

  // Localized Descriptions
  String getPrivacyLevelDescription() {
    switch (privacyLevel) {
      case 'basic':
        return language == 'hi'
            ? 'केवल संपर्क सूची - बुनियादी विश्लेषण'
            : 'Contacts only - Basic analysis';
      case 'standard':
        return language == 'hi'
            ? 'संपर्क + कॉल पैटर्न - संतुलित विश्लेषण'
            : 'Contacts + Call patterns - Balanced analysis';
      case 'advanced':
        return language == 'hi'
            ? 'पूर्ण विश्लेषण - अधिकतम अंतर्दृष्टि'
            : 'Full analysis - Maximum insights';
      default:
        return 'Unknown privacy level';
    }
  }

  List<String> getEnabledFeatures() {
    List<String> features = [];

    if (contactsAccess) {
      features.add(language == 'hi' ? 'संपर्क विश्लेषण' : 'Contact Analysis');
    }
    if (callLogAccess) {
      features.add(language == 'hi' ? 'कॉल पैटर्न' : 'Call Patterns');
    }
    if (smsMetadataAccess) {
      features.add(language == 'hi' ? 'संदेश पैटर्न' : 'Message Patterns');
    }
    if (sentimentAnalysis) {
      features.add(language == 'hi' ? 'भावना विश्लेषण' : 'Sentiment Analysis');
    }
    if (aiInsights) {
      features.add(language == 'hi' ? 'AI अंतर्दृष्टि' : 'AI Insights');
    }

    return features;
  }

  // Privacy Guarantees
  List<String> getPrivacyGuarantees() {
    return language == 'hi'
        ? [
            '🔒 सारा डेटा आपके डिवाइस पर ही रहता है',
            '🚫 कभी भी क्लाउड पर डेटा नहीं भेजा जाता',
            '👤 आपका डेटा केवल आपका है',
            '🗑️ कभी भी डेटा डिलीट कर सकते हैं',
            '⚙️ हर फीचर को on/off कर सकते हैं',
            '📱 100% ऑफ़लाइन काम करता है',
          ]
        : [
            '🔒 All data stays on your device only',
            '🚫 Never uploaded to cloud servers',
            '👤 Your data belongs only to you',
            '🗑️ Delete data anytime you want',
            '⚙️ Toggle any feature on/off',
            '📱 Works 100% offline',
          ];
  }

  // Update methods
  void updatePrivacyLevel(String level) {
    privacyLevel = level;
    lastUpdated = DateTime.now();

    switch (level) {
      case 'basic':
        contactsAccess = true;
        callLogAccess = false;
        smsMetadataAccess = false;
        sentimentAnalysis = false;
        break;
      case 'standard':
        contactsAccess = true;
        callLogAccess = true;
        smsMetadataAccess = false;
        sentimentAnalysis = false;
        break;
      case 'advanced':
        contactsAccess = true;
        callLogAccess = true;
        smsMetadataAccess = true;
        sentimentAnalysis = true;
        break;
    }
  }

  void togglePermission(String permission, bool value) {
    switch (permission) {
      case 'contacts':
        contactsAccess = value;
        break;
      case 'callLog':
        callLogAccess = value;
        break;
      case 'smsMetadata':
        smsMetadataAccess = value;
        break;
      case 'sentimentAnalysis':
        sentimentAnalysis = value;
        break;
      case 'aiInsights':
        aiInsights = value;
        break;
      case 'notifications':
        notificationsEnabled = value;
        break;
    }
    lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'contactsAccess': contactsAccess,
        'callLogAccess': callLogAccess,
        'smsMetadataAccess': smsMetadataAccess,
        'sentimentAnalysis': sentimentAnalysis,
        'aiInsights': aiInsights,
        'dataExport': dataExport,
        'notificationsEnabled': notificationsEnabled,
        'lastUpdated': lastUpdated.toIso8601String(),
        'privacyLevel': privacyLevel,
        'granularPermissions': granularPermissions,
        'hasSeenPrivacyIntro': hasSeenPrivacyIntro,
        'language': language,
      };
}
