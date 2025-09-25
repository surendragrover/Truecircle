import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/contact.dart';
import '../models/contact_interaction.dart';

/// 🎭 Cultural & Regional AI - Deep Indian cultural intelligence for relationship management
/// Understands Indian festivals, family dynamics, regional communication styles, and language preferences
class CulturalRegionalAI {
  // Cache for festivals data
  static Map<String, dynamic>? _festivalsData;

  /// 🎉 Load Festivals Data from JSON
  static Future<Map<String, dynamic>> _loadFestivalsData() async {
    if (_festivalsData != null) return _festivalsData!;

    try {
      final String jsonString = await rootBundle
          .loadString('Demo_data/TrueCircle_Festivals_Data.json');
      _festivalsData = json.decode(jsonString);
      return _festivalsData!;
    } catch (e) {
      // Error handling without print in production
      // In debug mode, this would show in development console
      return {
        'festivals': [],
        'metadata': {'totalFestivals': 0}
      };
    }
  }

  /// 🎉 Festival & Cultural Event Management
  static Future<FestivalAnalysis> analyzeFestivalConnections(
      Contact contact, List<ContactInteraction> interactions) async {
    final upcomingFestivals = await getUpcomingFestivals();
    final contactFestivalData =
        _analyzeContactFestivalHistory(contact, interactions);
    final recommendations = _generateFestivalRecommendations(
        contact, contactFestivalData, upcomingFestivals);

    return FestivalAnalysis(
      upcomingFestivals: upcomingFestivals,
      contactFestivalHistory: contactFestivalData,
      recommendations: recommendations,
      priorityLevel: _calculateFestivalPriority(contact, contactFestivalData),
      suggestedMessage: _generateFestivalMessage(
          contact,
          upcomingFestivals.isNotEmpty
              ? upcomingFestivals.first
              : await _getDefaultFestival()),
    );
  }

  /// 🗺️ Regional Communication Style Detection
  static RegionalProfile detectRegionalCommunicationStyle(
      Contact contact, List<ContactInteraction> interactions) {
    final languagePatterns = _analyzeLanguageUsage(interactions);
    final communicationStyle = _inferRegionalStyle(contact, languagePatterns);
    final culturalMarkers = _identifyCulturalMarkers(interactions);

    return RegionalProfile(
      detectedRegion: communicationStyle.region,
      languagePreference: languagePatterns.primaryLanguage,
      communicationStyle: communicationStyle,
      culturalMarkers: culturalMarkers,
      confidence:
          _calculateRegionalConfidence(languagePatterns, culturalMarkers),
      recommendations: _generateRegionalRecommendations(communicationStyle),
    );
  }

  /// 👨‍👩‍👧‍👦 Indian Family Dynamics Understanding
  static FamilyDynamicsInsight analyzeFamilyDynamics(
      Contact contact, List<ContactInteraction> interactions) {
    final relationshipType = _inferFamilyRelationshipType(contact);
    final familyRole = _determineFamilyRole(contact, relationshipType);
    final communicationExpectations = _getFamilyCommExpectations(familyRole);
    final festivals = _getRelevantFamilyFestivals(relationshipType);

    return FamilyDynamicsInsight(
      relationshipType: relationshipType,
      familyRole: familyRole,
      communicationExpectations: communicationExpectations,
      importantOccasions: festivals,
      respectLevel: _calculateRespectLevel(familyRole),
      suggestedApproach: _generateFamilyApproach(familyRole, contact),
    );
  }

  /// 🌐 Language Preference Intelligence
  static LanguageIntelligence analyzeLanguagePreferences(
      Contact contact, List<ContactInteraction> interactions) {
    final usage = _analyzeLanguageUsage(interactions);
    final patterns = _detectCodeSwitchingPatterns(interactions);
    final formality = _assessFormalityPreference(interactions);

    return LanguageIntelligence(
      primaryLanguage: usage.primaryLanguage,
      secondaryLanguage: usage.secondaryLanguage,
      codeSwitchingFrequency: patterns.frequency,
      codeSwitchingTriggers: patterns.triggers,
      formalityPreference: formality,
      recommendedLanguage: _recommendOptimalLanguage(usage, formality, contact),
      culturalNuances: _identifyLanguageCulturalNuances(interactions),
    );
  }

  /// 🎊 Smart Festival Reminder System
  static Future<List<FestivalReminder>> generateFestivalReminders(
      List<Contact> allContacts) async {
    final reminders = <FestivalReminder>[];
    final upcomingFestivals = await getUpcomingFestivals();

    for (final festival in upcomingFestivals.take(3)) {
      final priorityContacts =
          _getPriorityContactsForFestival(allContacts, festival);

      if (priorityContacts.isNotEmpty) {
        reminders.add(FestivalReminder(
          festival: festival,
          daysUntil: festival.date.difference(DateTime.now()).inDays,
          priorityContacts: priorityContacts,
          suggestedActions:
              _generateFestivalActions(festival, priorityContacts),
          culturalTips: _getFestivalCulturalTips(festival),
        ));
      }
    }

    return reminders;
  }

  // Private Helper Methods

  static Future<IndianFestival> _getDefaultFestival() async {
    return IndianFestival(
      name: 'New Year',
      hindiName: 'नव वर्ष',
      date: DateTime(DateTime.now().year + 1, 1, 1),
      type: FestivalType.cultural,
      regions: ['All India'],
      description: 'New Year Celebration',
      greetingMessages: {
        'formal': 'नव वर्ष की शुभकामनाएं! / Happy New Year!',
        'casual': 'Happy New Year! 🎉',
        'family': 'नया साल मुबारक! खुशियों से भरा हो 🎊',
      },
    );
  }

  /// 🎉 Get Upcoming Festivals (Loaded from JSON)
  static Future<List<IndianFestival>> getUpcomingFestivals() async {
    try {
      final festivalsData = await _loadFestivalsData();
      final festivalsList = festivalsData['festivals'] as List<dynamic>? ?? [];

      final now = DateTime.now();
      final currentYear = now.year;

      List<IndianFestival> upcomingFestivals = [];

      for (final festivalData in festivalsList) {
        final festival = IndianFestival(
          name: festivalData['name'] ?? '',
          hindiName: festivalData['hindiName'] ?? '',
          date: _getFestivalDateForYear(festivalData['month'], currentYear),
          type: festivalData['type'] == 'major'
              ? FestivalType.major
              : FestivalType.regional,
          regions: List<String>.from(festivalData['regions'] ?? []),
          description: festivalData['description'] ?? '',
          greetingMessages:
              Map<String, String>.from(festivalData['greetingMessages'] ?? {}),
          culturalTips: List<String>.from(festivalData['culturalTips'] ?? []),
          conversationStarters:
              List<String>.from(festivalData['conversationStarters'] ?? []),
        );

        // Only include festivals that are upcoming (within next 3 months)
        if (festival.date.isAfter(now) &&
            festival.date.isBefore(now.add(const Duration(days: 90)))) {
          upcomingFestivals.add(festival);
        }
      }

      // Sort by date
      upcomingFestivals.sort((a, b) => a.date.compareTo(b.date));
      return upcomingFestivals;
    } catch (e) {
      // Error handling without print in production
      // In debug mode, this would show in development console
      return _getFallbackFestivals();
    }
  }

  /// 🗓️ Get approximate festival date for given month and year
  static DateTime _getFestivalDateForYear(String month, int year) {
    final monthMap = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };

    final monthNumber = monthMap[month] ?? 1;
    // Use middle of month as approximate date
    return DateTime(year, monthNumber, 15);
  }

  /// 🛡️ Fallback festivals if JSON loading fails
  static List<IndianFestival> _getFallbackFestivals() {
    final now = DateTime.now();
    final currentYear = now.year;

    // Indian festivals for current year (approximate dates)
    final festivals = <IndianFestival>[
      IndianFestival(
        name: 'Diwali',
        hindiName: 'दीवाली',
        date: DateTime(currentYear, 11, 12), // Approximate
        type: FestivalType.major,
        regions: ['All India'],
        description: 'Festival of Lights',
        greetingMessages: {
          'formal': 'दीवाली की हार्दिक शुभकामनाएं! / Happy Diwali!',
          'casual': 'Happy Diwali! 🪔✨',
          'family': 'दीवाली मुबारक! खुशियों से भरा हो यह त्योहार 🎆',
        },
      ),
      IndianFestival(
        name: 'Holi',
        hindiName: 'होली',
        date: DateTime(currentYear + 1, 3, 14), // Next year
        type: FestivalType.major,
        regions: ['North India', 'Central India'],
        description: 'Festival of Colors',
        greetingMessages: {
          'formal': 'होली की हार्दिक शुभकामनाएं!',
          'casual': 'Happy Holi! 🌈🎨',
          'family': 'होली मुबारक! रंगों से भरा हो जीवन 🎉',
        },
      ),
      IndianFestival(
        name: 'Eid',
        hindiName: 'ईद',
        date: DateTime(currentYear, 4, 22), // Approximate
        type: FestivalType.major,
        regions: ['All India'],
        description: 'Festival of Breaking Fast',
        greetingMessages: {
          'formal': 'ईद मुबारक! / Eid Mubarak!',
          'casual': 'Eid Mubarak! 🌙✨',
          'family': 'ईद की खुशियां आपके साथ हों 🕌',
        },
      ),
      IndianFestival(
        name: 'Dussehra',
        hindiName: 'दशहरा',
        date: DateTime(currentYear, 10, 24),
        type: FestivalType.major,
        regions: ['All India'],
        description: 'Victory of Good over Evil',
        greetingMessages: {
          'formal': 'दशहरा की शुभकामनाएं!',
          'casual': 'Happy Dussehra! 🏹',
          'family': 'दशहरा मुबारक! बुराई पर अच्छाई की जीत 🎭',
        },
      ),
      IndianFestival(
        name: 'Karva Chauth',
        hindiName: 'करवा चौथ',
        date: DateTime(currentYear, 11, 1),
        type: FestivalType.cultural,
        regions: ['North India'],
        description: 'Festival for married women',
        greetingMessages: {
          'formal': 'करवा चौथ की शुभकामनाएं!',
          'casual': 'Happy Karva Chauth! 🌙',
          'family': 'करवा चौथ मुबारक! सुहाग की लंबी उम्र 💑',
        },
      ),
    ];

    // Filter upcoming festivals (next 60 days)
    return festivals.where((festival) {
      final daysUntil = festival.date.difference(now).inDays;
      return daysUntil >= 0 && daysUntil <= 60;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static ContactFestivalData _analyzeContactFestivalHistory(
      Contact contact, List<ContactInteraction> interactions) {
    final festivalInteractions = <String, List<ContactInteraction>>{};
    final celebratedFestivals = <String>[];

    // Analyze past interactions around festival times
    for (final interaction in interactions) {
      final festivalContext = _identifyFestivalContext(interaction);
      if (festivalContext != null) {
        festivalInteractions[festivalContext] ??= [];
        festivalInteractions[festivalContext]!.add(interaction);
        if (!celebratedFestivals.contains(festivalContext)) {
          celebratedFestivals.add(festivalContext);
        }
      }
    }

    return ContactFestivalData(
      celebratedFestivals: celebratedFestivals,
      festivalInteractions: festivalInteractions,
      lastFestivalContact: _getLastFestivalContact(festivalInteractions),
      festivalEngagement: _calculateFestivalEngagement(festivalInteractions),
    );
  }

  static String? _identifyFestivalContext(ContactInteraction interaction) {
    if (interaction.content == null) return null;

    final content = interaction.content!.toLowerCase();

    if (content.contains('diwali') ||
        content.contains('दीवाली') ||
        content.contains('🪔')) {
      return 'Diwali';
    } else if (content.contains('holi') ||
        content.contains('होली') ||
        content.contains('🌈')) {
      return 'Holi';
    } else if (content.contains('eid') ||
        content.contains('ईद') ||
        content.contains('🌙')) {
      return 'Eid';
    } else if (content.contains('dussehra') || content.contains('दशहरा')) {
      return 'Dussehra';
    } else if (content.contains('karva') || content.contains('करवा')) {
      return 'Karva Chauth';
    }

    return null;
  }

  static LanguageUsagePattern _analyzeLanguageUsage(
      List<ContactInteraction> interactions) {
    int hindiCount = 0;
    int englishCount = 0;
    int hinglishCount = 0;

    for (final interaction in interactions) {
      if (interaction.content != null) {
        final language = _detectMessageLanguage(interaction.content!);
        switch (language) {
          case 'hindi':
            hindiCount++;
            break;
          case 'english':
            englishCount++;
            break;
          case 'hinglish':
            hinglishCount++;
            break;
        }
      }
    }

    final total = hindiCount + englishCount + hinglishCount;
    if (total == 0) {
      return LanguageUsagePattern(
        primaryLanguage: 'unknown',
        secondaryLanguage: 'unknown',
        hindiPercentage: 0,
        englishPercentage: 0,
        hinglishPercentage: 0,
      );
    }

    final hindiPct = hindiCount / total;
    final englishPct = englishCount / total;
    final hinglishPct = hinglishCount / total;

    String primary = 'english';
    String secondary = 'hindi';

    if (hindiPct > englishPct && hindiPct > hinglishPct) {
      primary = 'hindi';
      secondary = englishPct > hinglishPct ? 'english' : 'hinglish';
    } else if (hinglishPct > englishPct && hinglishPct > hindiPct) {
      primary = 'hinglish';
      secondary = hindiPct > englishPct ? 'hindi' : 'english';
    }

    return LanguageUsagePattern(
      primaryLanguage: primary,
      secondaryLanguage: secondary,
      hindiPercentage: hindiPct,
      englishPercentage: englishPct,
      hinglishPercentage: hinglishPct,
    );
  }

  static String _detectMessageLanguage(String content) {
    // Simple language detection based on script and common words
    final hindiRegex = RegExp(r'[\u0900-\u097F]'); // Devanagari script
    final englishWords = [
      'the',
      'and',
      'you',
      'are',
      'how',
      'what',
      'when',
      'where'
    ];
    final hindiWords = [
      'है',
      'का',
      'की',
      'के',
      'में',
      'से',
      'पर',
      'को',
      'और',
      'या'
    ];

    final hasDevanagari = hindiRegex.hasMatch(content);
    final lowerContent = content.toLowerCase();

    final englishMatches =
        englishWords.where((word) => lowerContent.contains(word)).length;
    final hindiMatches =
        hindiWords.where((word) => content.contains(word)).length;

    if (hasDevanagari && hindiMatches > 0 && englishMatches > 0) {
      return 'hinglish'; // Mixed Hindi-English
    } else if (hasDevanagari || hindiMatches > englishMatches) {
      return 'hindi';
    } else {
      return 'english';
    }
  }

  static RegionalCommunicationStyle _inferRegionalStyle(
      Contact contact, LanguageUsagePattern patterns) {
    // Infer region based on various factors
    IndianRegion region = IndianRegion.northIndia; // Default
    CommunicationFormality formality = CommunicationFormality.moderate;

    // Basic region inference (would be enhanced with more data)
    if (patterns.hindiPercentage > 0.6) {
      region = IndianRegion.northIndia;
      formality = CommunicationFormality.formal;
    } else if (patterns.englishPercentage > 0.7) {
      region = IndianRegion.southIndia;
      formality = CommunicationFormality.moderate;
    } else if (patterns.hinglishPercentage > 0.4) {
      region = IndianRegion.westIndia;
      formality = CommunicationFormality.casual;
    }

    return RegionalCommunicationStyle(
      region: region,
      formality: formality,
      directness: _calculateDirectness(region),
      emotionalExpression: _calculateEmotionalExpression(region),
      familyOrientation: _calculateFamilyOrientation(region),
    );
  }

  static FamilyRelationshipType _inferFamilyRelationshipType(Contact contact) {
    final name = contact.displayName.toLowerCase();
    final tags = contact.tags.map((t) => t.toLowerCase()).toList();

    // Check tags first
    if (tags.contains('परिवार') || tags.contains('family')) {
      if (tags.contains('माता') ||
          tags.contains('mother') ||
          tags.contains('mom') ||
          tags.contains('mummy')) {
        return FamilyRelationshipType.mother;
      } else if (tags.contains('पिता') ||
          tags.contains('father') ||
          tags.contains('dad') ||
          tags.contains('papa')) {
        return FamilyRelationshipType.father;
      } else if (tags.contains('भाई') ||
          tags.contains('brother') ||
          tags.contains('bhai')) {
        return FamilyRelationshipType.sibling;
      } else if (tags.contains('बहन') ||
          tags.contains('sister') ||
          tags.contains('didi')) {
        return FamilyRelationshipType.sibling;
      } else {
        return FamilyRelationshipType.extendedFamily;
      }
    }

    // Check name patterns
    if (name.contains('mom') ||
        name.contains('dad') ||
        name.contains('papa') ||
        name.contains('mummy')) {
      return FamilyRelationshipType.parent;
    } else if (name.contains('uncle') ||
        name.contains('aunt') ||
        name.contains('chacha') ||
        name.contains('mausi')) {
      return FamilyRelationshipType.extendedFamily;
    }

    return FamilyRelationshipType.nonFamily;
  }

  static double _calculateDirectness(IndianRegion region) {
    switch (region) {
      case IndianRegion.northIndia:
        return 0.7; // More direct
      case IndianRegion.southIndia:
        return 0.5; // Moderate
      case IndianRegion.westIndia:
        return 0.8; // Very direct
      case IndianRegion.eastIndia:
        return 0.6; // Moderately direct
    }
  }

  static double _calculateEmotionalExpression(IndianRegion region) {
    switch (region) {
      case IndianRegion.northIndia:
        return 0.8; // High emotional expression
      case IndianRegion.southIndia:
        return 0.6; // Moderate
      case IndianRegion.westIndia:
        return 0.7; // Moderate-high
      case IndianRegion.eastIndia:
        return 0.9; // Very high
    }
  }

  static double _calculateFamilyOrientation(IndianRegion region) {
    // All regions have high family orientation, but varying degrees
    switch (region) {
      case IndianRegion.northIndia:
        return 0.9;
      case IndianRegion.southIndia:
        return 0.85;
      case IndianRegion.westIndia:
        return 0.8;
      case IndianRegion.eastIndia:
        return 0.95;
    }
  }

  static List<Contact> _getPriorityContactsForFestival(
      List<Contact> contacts, IndianFestival festival) {
    return contacts
        .where((contact) {
          // Priority based on relationship type and past festival interactions
          final familyType = _inferFamilyRelationshipType(contact);
          final daysSinceContact = contact.daysSinceLastContact;

          // High priority for family and close friends
          if (familyType != FamilyRelationshipType.nonFamily) return true;
          if (contact.tags.contains('close') ||
              contact.tags.contains('नज़दीकी')) {
            return true;
          }
          if (daysSinceContact > 30 &&
              contact.emotionalScore == EmotionalScore.veryWarm) {
            return true;
          }

          return false;
        })
        .take(10)
        .toList(); // Limit to top 10
  }

  static List<String> _generateFestivalActions(
      IndianFestival festival, List<Contact> contacts) {
    return [
      '${contacts.length} लोगों को ${festival.hindiName} की शुभकामनाएं भेजें',
      'व्यक्तिगत संदेश तैयार करें',
      'पारिवारिक संपर्कों को कॉल करें',
      'सोशल मीडिया पर post share करें',
    ];
  }

  static List<String> _getFestivalCulturalTips(IndianFestival festival) {
    switch (festival.name) {
      case 'Diwali':
        return [
          '🪔 दीप जलाने की तस्वीर share करें',
          '🍬 मिठाई की बात करें',
          '💰 Bonus या gifts का mention करें',
          '🏠 सफाई और सजावट के बारे में पूछें',
        ];
      case 'Holi':
        return [
          '🌈 रंगों की बात करें',
          '🎶 Holi के गाने share करें',
          '🍯 गुजिया और भांग का mention करें',
          '👨‍👩‍👧‍👦 पारिवारिक celebration की बात करें',
        ];
      default:
        return ['पारंपरिक शुभकामनाएं भेजें', 'व्यक्तिगत स्पर्श जोड़ें'];
    }
  }

  // Additional helper methods would be implemented...
  static List<FestivalRecommendation> _generateFestivalRecommendations(
      Contact contact,
      ContactFestivalData data,
      List<IndianFestival> festivals) {
    // Implementation for generating festival recommendations
    return [];
  }

  static FestivalPriority _calculateFestivalPriority(
      Contact contact, ContactFestivalData data) {
    return FestivalPriority.high; // Simplified
  }

  static String _generateFestivalMessage(
      Contact contact, IndianFestival festival) {
    final familyType = _inferFamilyRelationshipType(contact);
    final formality =
        familyType == FamilyRelationshipType.nonFamily ? 'formal' : 'family';
    return festival.greetingMessages[formality] ??
        festival.greetingMessages['formal']!;
  }

  static List<String> _identifyCulturalMarkers(
      List<ContactInteraction> interactions) {
    return []; // Implementation needed
  }

  static double _calculateRegionalConfidence(
      LanguageUsagePattern patterns, List<String> markers) {
    return 0.75; // Simplified
  }

  static List<String> _generateRegionalRecommendations(
      RegionalCommunicationStyle style) {
    return []; // Implementation needed
  }

  static FamilyRole _determineFamilyRole(
      Contact contact, FamilyRelationshipType type) {
    return FamilyRole.peer; // Simplified
  }

  static List<String> _getFamilyCommExpectations(FamilyRole role) {
    return []; // Implementation needed
  }

  static List<String> _getRelevantFamilyFestivals(FamilyRelationshipType type) {
    return []; // Implementation needed
  }

  static RespectLevel _calculateRespectLevel(FamilyRole role) {
    return RespectLevel.moderate; // Simplified
  }

  static String _generateFamilyApproach(FamilyRole role, Contact contact) {
    return ''; // Implementation needed
  }

  static CodeSwitchingPattern _detectCodeSwitchingPatterns(
      List<ContactInteraction> interactions) {
    return CodeSwitchingPattern(frequency: 0.5, triggers: []); // Simplified
  }

  static FormalityLevel _assessFormalityPreference(
      List<ContactInteraction> interactions) {
    return FormalityLevel.moderate; // Simplified
  }

  static String _recommendOptimalLanguage(
      LanguageUsagePattern usage, FormalityLevel formality, Contact contact) {
    return usage.primaryLanguage;
  }

  static List<String> _identifyLanguageCulturalNuances(
      List<ContactInteraction> interactions) {
    return []; // Implementation needed
  }

  static DateTime? _getLastFestivalContact(
      Map<String, List<ContactInteraction>> interactions) {
    return null; // Implementation needed
  }

  static double _calculateFestivalEngagement(
      Map<String, List<ContactInteraction>> interactions) {
    return 0.5; // Simplified
  }
}

// Data Models
class FestivalAnalysis {
  final List<IndianFestival> upcomingFestivals;
  final ContactFestivalData contactFestivalHistory;
  final List<FestivalRecommendation> recommendations;
  final FestivalPriority priorityLevel;
  final String suggestedMessage;

  const FestivalAnalysis({
    required this.upcomingFestivals,
    required this.contactFestivalHistory,
    required this.recommendations,
    required this.priorityLevel,
    required this.suggestedMessage,
  });
}

class RegionalProfile {
  final IndianRegion detectedRegion;
  final String languagePreference;
  final RegionalCommunicationStyle communicationStyle;
  final List<String> culturalMarkers;
  final double confidence;
  final List<String> recommendations;

  const RegionalProfile({
    required this.detectedRegion,
    required this.languagePreference,
    required this.communicationStyle,
    required this.culturalMarkers,
    required this.confidence,
    required this.recommendations,
  });
}

class FamilyDynamicsInsight {
  final FamilyRelationshipType relationshipType;
  final FamilyRole familyRole;
  final List<String> communicationExpectations;
  final List<String> importantOccasions;
  final RespectLevel respectLevel;
  final String suggestedApproach;

  FamilyDynamicsInsight({
    required this.relationshipType,
    required this.familyRole,
    required this.communicationExpectations,
    required this.importantOccasions,
    required this.respectLevel,
    required this.suggestedApproach,
  });
}

class LanguageIntelligence {
  final String primaryLanguage;
  final String secondaryLanguage;
  final double codeSwitchingFrequency;
  final List<String> codeSwitchingTriggers;
  final FormalityLevel formalityPreference;
  final String recommendedLanguage;
  final List<String> culturalNuances;

  LanguageIntelligence({
    required this.primaryLanguage,
    required this.secondaryLanguage,
    required this.codeSwitchingFrequency,
    required this.codeSwitchingTriggers,
    required this.formalityPreference,
    required this.recommendedLanguage,
    required this.culturalNuances,
  });
}

class FestivalReminder {
  final IndianFestival festival;
  final int daysUntil;
  final List<Contact> priorityContacts;
  final List<String> suggestedActions;
  final List<String> culturalTips;

  FestivalReminder({
    required this.festival,
    required this.daysUntil,
    required this.priorityContacts,
    required this.suggestedActions,
    required this.culturalTips,
  });
}

class IndianFestival {
  final String name;
  final String hindiName;
  final DateTime date;
  final FestivalType type;
  final List<String> regions;
  final String description;
  final Map<String, String> greetingMessages;
  final List<String> culturalTips;
  final List<String> conversationStarters;

  IndianFestival({
    required this.name,
    required this.hindiName,
    required this.date,
    required this.type,
    required this.regions,
    required this.description,
    required this.greetingMessages,
    this.culturalTips = const [],
    this.conversationStarters = const [],
  });
}

class ContactFestivalData {
  final List<String> celebratedFestivals;
  final Map<String, List<ContactInteraction>> festivalInteractions;
  final DateTime? lastFestivalContact;
  final double festivalEngagement;

  ContactFestivalData({
    required this.celebratedFestivals,
    required this.festivalInteractions,
    required this.lastFestivalContact,
    required this.festivalEngagement,
  });
}

class LanguageUsagePattern {
  final String primaryLanguage;
  final String secondaryLanguage;
  final double hindiPercentage;
  final double englishPercentage;
  final double hinglishPercentage;

  LanguageUsagePattern({
    required this.primaryLanguage,
    required this.secondaryLanguage,
    required this.hindiPercentage,
    required this.englishPercentage,
    required this.hinglishPercentage,
  });
}

class RegionalCommunicationStyle {
  final IndianRegion region;
  final CommunicationFormality formality;
  final double directness;
  final double emotionalExpression;
  final double familyOrientation;

  RegionalCommunicationStyle({
    required this.region,
    required this.formality,
    required this.directness,
    required this.emotionalExpression,
    required this.familyOrientation,
  });
}

class CodeSwitchingPattern {
  final double frequency;
  final List<String> triggers;

  CodeSwitchingPattern({
    required this.frequency,
    required this.triggers,
  });
}

// Enums
enum IndianRegion { northIndia, southIndia, eastIndia, westIndia }

enum FestivalType { major, regional, cultural, religious }

enum FestivalPriority { low, medium, high, critical }

enum FamilyRelationshipType {
  parent,
  mother,
  father,
  sibling,
  extendedFamily,
  nonFamily
}

enum FamilyRole { elder, peer, younger, authority }

enum RespectLevel { casual, moderate, formal, reverential }

enum CommunicationFormality { casual, moderate, formal, traditional }

enum FormalityLevel { casual, moderate, formal }

// Additional classes for completeness
class FestivalRecommendation {
  final String action;
  final String reasoning;
  final int priority;

  FestivalRecommendation({
    required this.action,
    required this.reasoning,
    required this.priority,
  });
}
