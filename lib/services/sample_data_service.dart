import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:truecircle/models/contact_interaction.dart';
import 'package:truecircle/models/emotion_entry.dart';
import 'json_data_service.dart';

class SampleDataService {
  static final Random _random = Random();
  static SampleDataService? _instance;
  static SampleDataService get instance =>
      _instance ??= SampleDataService._internal();

  SampleDataService._internal();

  // Cache for loaded JSON data
  static Map<String, dynamic>? _emotionalCheckinData;
  static List<dynamic>? _moodJournalData;

  // Sample contacts with realistic relationship data
  static List<Map<String, dynamic>> getSampleContacts() {
    return [
      {
        'id': 'sample_1',
        'name': 'John Smith',
        'phone': '+1234567890',
        'email': 'john.smith@email.com',
        'relationship': 'Best Friend',
        'emotionalScore': 8.5,
        'communicationFrequency': 'Daily',
        'lastContact': DateTime.now().subtract(const Duration(hours: 2)),
        'personalityType': 'Extroverted',
        'culturalBackground': 'American',
        'importantDates': ['1995-06-15'], // Birthday
        'interests': ['Technology', 'Sports', 'Movies'],
        'communicationStyle': 'Direct and Friendly',
        'avatar': 'assets/images/avatar.png', // <-- FIX HERE
      },
      {
        'id': 'sample_2',
        'name': 'Sarah Johnson',
        'phone': '+1234567891',
        'email': 'sarah.j@email.com',
        'relationship': 'Family - Sister',
        'emotionalScore': 9.2,
        'communicationFrequency': 'Weekly',
        'lastContact': DateTime.now().subtract(const Duration(days: 3)),
        'personalityType': 'Caring',
        'culturalBackground': 'Canadian',
        'importantDates': ['1992-03-22'], // Birthday
        'interests': ['Reading', 'Cooking', 'Travel'],
        'communicationStyle': 'Supportive and Warm',
        'avatar': 'assets/images/avatar.png', // <-- FIX HERE
      },
      {
        'id': 'sample_3',
        'name': 'Mike Wilson',
        'phone': '+1234567892',
        'email': 'mike.wilson@company.com',
        'relationship': 'Colleague',
        'emotionalScore': 7.8,
        'communicationFrequency': 'Work Days',
        'lastContact': DateTime.now().subtract(const Duration(hours: 8)),
        'personalityType': 'Professional',
        'culturalBackground': 'British',
        'importantDates': ['1988-11-30'],
        'interests': ['Business', 'Golf', 'Networking'],
        'communicationStyle': 'Professional and Concise',
        'avatar': 'assets/images/avatar.png', // <-- FIX HERE
      },
      {
        'id': 'sample_4',
        'name': 'Emma Davis',
        'phone': '+1234567893',
        'email': 'emma.davis@university.edu',
        'relationship': 'Friend - University',
        'emotionalScore': 8.9,
        'communicationFrequency': 'Few times a week',
        'lastContact': DateTime.now().subtract(const Duration(hours: 16)),
        'personalityType': 'Creative',
        'culturalBackground': 'Australian',
        'importantDates': ['1997-08-12'],
        'interests': ['Art', 'Music', 'Photography'],
        'communicationStyle': 'Creative and Expressive',
        'avatar': 'assets/images/avatar.png', // <-- FIX HERE
      },
      {
        'id': 'sample_5',
        'name': 'David Brown',
        'phone': '+1234567894',
        'email': 'david.brown@email.com',
        'relationship': 'Romantic Partner',
        'emotionalScore': 9.5,
        'communicationFrequency': 'Multiple times daily',
        'lastContact': DateTime.now().subtract(const Duration(minutes: 30)),
        'personalityType': 'Loving',
        'culturalBackground': 'Spanish',
        'importantDates': ['1993-12-05', '2023-02-14'], // Birthday, Anniversary
        'interests': ['Music', 'Dancing', 'Cooking'],
        'communicationStyle': 'Romantic and Caring',
        'avatar': 'assets/images/avatar.png', // <-- FIX HERE
      },
      {
        'id': 'sample_6',
        'name': 'Lisa Chen',
        'phone': '+1234567895',
        'email': 'lisa.chen@email.com',
        'relationship': 'Friend - Childhood',
        'emotionalScore': 8.7,
        'communicationFrequency': 'Monthly',
        'lastContact': DateTime.now().subtract(const Duration(days: 12)),
        'personalityType': 'Loyal',
        'culturalBackground': 'Chinese',
        'importantDates': ['1994-05-28'],
        'interests': ['Martial Arts', 'Medicine', 'History'],
        'communicationStyle': 'Thoughtful and Deep',
        'avatar': 'assets/images/avatar.png', // <-- FIX HERE
      },
      {
        'id': 'sample_7',
        'name': 'Robert Garcia',
        'phone': '+1234567896',
        'email': 'robert.garcia@email.com',
        'relationship': 'Neighbor',
        'emotionalScore': 7.2,
        'communicationFrequency': 'Occasionally',
        'lastContact': DateTime.now().subtract(const Duration(days: 25)),
        'personalityType': 'Friendly',
        'culturalBackground': 'Mexican',
        'importantDates': ['1985-09-17'],
        'interests': ['Gardening', 'Soccer', 'Family'],
        'communicationStyle': 'Warm and Neighborly',
        'avatar': 'assets/images/avatar.png', // <-- FIX HERE
      },
      {
        'id': 'sample_8',
        'name': 'Jennifer Kim',
        'phone': '+1234567897',
        'email': 'jennifer.kim@startup.com',
        'relationship': 'Business Partner',
        'emotionalScore': 8.3,
        'communicationFrequency': 'Daily',
        'lastContact': DateTime.now().subtract(const Duration(hours: 4)),
        'personalityType': 'Ambitious',
        'culturalBackground': 'Korean',
        'importantDates': ['1990-07-21'],
        'interests': ['Entrepreneurship', 'Innovation', 'Fitness'],
        'communicationStyle': 'Strategic and Motivating',
        'avatar': 'assets/images/avatar.png', // <-- FIX HERE
      },
    ];
  }

  // Generate sample interaction history
  static List<ContactInteraction> getSampleInteractions() {
    List<ContactInteraction> interactions = [];
    List<Map<String, dynamic>> contacts = getSampleContacts();

    for (var contact in contacts) {
      // Generate realistic interaction patterns
      int interactionCount = _getInteractionCountByFrequency(
        contact['communicationFrequency'],
      );

      for (int i = 0; i < interactionCount; i++) {
        interactions.add(
          ContactInteraction(
            contactId: contact['id'],
            timestamp: _generateRandomTimestamp(
              contact['communicationFrequency'],
              i,
            ),
            type: _getRandomInteractionType(),
            duration: _getRandomDuration(),
            initiatedByMe: _random.nextBool(),
            content: _generateRandomMessage(),
            sentimentScore: _generateEmotionalScore(contact['emotionalScore']),
          ),
        );
      }
    }

    return interactions..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Generate sample emotion entries
  static List<EmotionEntry> getSampleEmotionEntries() {
    List<EmotionEntry> entries = [];
    List<String> emotions = [
      'Happy',
      'Grateful',
      'Excited',
      'Calm',
      'Loved',
      'Confident',
      'Peaceful',
    ];
    List<String> contexts = [
      'Great conversation with John',
      'Family dinner with Sarah',
      'Successful meeting with Mike',
      'Creative session with Emma',
      'Romantic evening with David',
      'Nostalgic chat with Lisa',
      'Friendly neighbor chat with Robert',
      'Productive business call with Jennifer',
    ];

    for (int i = 0; i < 15; i++) {
      entries.add(
        EmotionEntry(
          emotion: emotions[_random.nextInt(emotions.length)],
          intensity: 3 + _random.nextInt(3), // 3-5 intensity
          timestamp: DateTime.now().subtract(
            Duration(days: i, hours: _random.nextInt(24)),
          ),
          note: contexts[_random.nextInt(contexts.length)],
        ),
      );
    }

    return entries..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Sample AI predictions and insights
  static Map<String, dynamic> getSampleAIInsights() {
    return {
      'relationshipPredictions': [
        {
          'contactName': 'John Smith',
          'prediction': 'Relationship strength increasing',
          'confidence': 0.87,
          'reasoning': 'Communication frequency has improved 25% this month',
          'suggestedActions': [
            'Plan weekend activity',
            'Send motivational message',
          ],
        },
        {
          'contactName': 'Sarah Johnson',
          'prediction': 'May need more attention',
          'confidence': 0.73,
          'reasoning':
              'Haven\'t connected in 3 days, longer than usual pattern',
          'suggestedActions': ['Send caring message', 'Plan family video call'],
        },
        {
          'contactName': 'David Brown',
          'prediction': 'Relationship very stable',
          'confidence': 0.94,
          'reasoning':
              'Consistent daily communication with high emotional scores',
          'suggestedActions': ['Plan surprise date', 'Express appreciation'],
        },
      ],
      'emotionalTrends': {
        'weeklyAverage': 8.2,
        'monthlyTrend': 'Improving',
        'dominantEmotions': ['Happy', 'Grateful', 'Loved'],
        'stressFactors': ['Work pressure', 'Long distance with Lisa'],
        'improvementAreas': [
          'More quality time with family',
          'Regular check-ins with distant friends',
        ],
      },
      'communicationPatterns': {
        'preferredTimes': ['Morning: 9-11 AM', 'Evening: 7-9 PM'],
        'responseRates': {
          'Immediate': 0.65,
          'Within hour': 0.25,
          'Later': 0.10,
        },
        'communicationModes': {'Calls': 0.40, 'Messages': 0.45, 'Video': 0.15},
        'averageInteractionLength': '12 minutes',
      },
      'culturalInsights': [
        {
          'culture': 'Spanish',
          'upcoming': 'Día de los Muertos - November 2',
          'suggestion': 'Send David a meaningful message about family memories',
        },
        {
          'culture': 'Chinese',
          'upcoming': 'Chinese New Year - February 10',
          'suggestion':
              'Plan celebration with Lisa, respect traditional customs',
        },
        {
          'culture': 'Korean',
          'upcoming': 'Chuseok - September 29',
          'suggestion': 'Acknowledge Jennifer\'s cultural celebration',
        },
      ],
    };
  }

  // Sample smart message suggestions
  static List<Map<String, dynamic>> getSampleSmartMessages() {
    return [
      {
        'contactName': 'John Smith',
        'message':
            'Hey John! Hope your presentation went well today. Want to grab coffee this weekend?',
        'reason':
            'Based on your supportive friendship and regular weekend meetups',
        'tone': 'Casual and Supportive',
        'aiConfidence': 0.89,
      },
      {
        'contactName': 'Sarah Johnson',
        'message':
            'Thinking of you, sis! How did mom\'s doctor appointment go? Love you ❤️',
        'reason': 'Family concern and regular health check-ins pattern',
        'tone': 'Caring and Familial',
        'aiConfidence': 0.92,
      },
      {
        'contactName': 'Emma Davis',
        'message':
            'Saw this amazing art exhibition poster and thought of you! Your style would love it 🎨',
        'reason':
            'Based on her creative interests and your shared artistic appreciation',
        'tone': 'Thoughtful and Creative',
        'aiConfidence': 0.85,
      },
      {
        'contactName': 'David Brown',
        'message':
            'Missing you already... can\'t wait for our dinner tonight. Te amo 💕',
        'reason': 'Romantic relationship pattern with Spanish cultural touch',
        'tone': 'Romantic and Loving',
        'aiConfidence': 0.96,
      },
    ];
  }

  // Sample goal tracking
  static Map<String, dynamic> getSampleGoals() {
    return {
      'activeGoals': [
        {
          'id': 'goal_1',
          'title': 'Call family weekly',
          'target': 'Call Sarah every Sunday',
          'progress': 0.75,
          'currentStreak': 3,
          'bestStreak': 5,
          'nextMilestone': 'Complete month (4/4 weeks)',
        },
        {
          'id': 'goal_2',
          'title': 'Strengthen work relationships',
          'target': 'Have one personal conversation with Mike weekly',
          'progress': 0.60,
          'currentStreak': 2,
          'bestStreak': 4,
          'nextMilestone': 'Reach 5-week streak',
        },
        {
          'id': 'goal_3',
          'title': 'Stay connected with old friends',
          'target': 'Message Lisa at least twice per month',
          'progress': 0.50,
          'currentStreak': 1,
          'bestStreak': 2,
          'nextMilestone': 'Establish monthly rhythm',
        },
      ],
      'completedGoals': [
        {
          'title': 'Daily communication with David',
          'completedDate': DateTime.now().subtract(const Duration(days: 30)),
          'achievement': 'Maintained 30-day streak',
        },
      ],
      'suggestedGoals': [
        'Send birthday wishes to all contacts',
        'Have video calls with distant friends monthly',
        'Practice active listening in conversations',
        'Remember and ask about important events',
      ],
    };
  }

  // Helper methods
  static int _getInteractionCountByFrequency(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'multiple times daily':
        return 20;
      case 'daily':
        return 10;
      case 'few times a week':
        return 6;
      case 'weekly':
        return 3;
      case 'work days':
        return 5;
      case 'monthly':
        return 2;
      case 'occasionally':
        return 1;
      default:
        return 3;
    }
  }

  static InteractionType _getRandomInteractionType() {
    List<InteractionType> types = [
      InteractionType.call,
      InteractionType.message,
      InteractionType.videoCall,
      InteractionType.whatsapp,
      InteractionType.email
    ];
    return types[_random.nextInt(types.length)];
  }

  static String _generateRandomMessage() {
    List<String> messages = [
      'Hey! How are you doing?',
      'Thanks for your help earlier',
      'Looking forward to catching up soon',
      'Hope you had a great day!',
      'Let me know when you\'re free',
      'Thanks for thinking of me',
      'Great catching up with you',
      'Have a wonderful weekend!',
    ];
    return messages[_random.nextInt(messages.length)];
  }

  static DateTime _generateRandomTimestamp(String frequency, int index) {
    switch (frequency.toLowerCase()) {
      case 'multiple times daily':
        return DateTime.now().subtract(Duration(hours: index * 3));
      case 'daily':
        return DateTime.now().subtract(Duration(days: index));
      case 'few times a week':
        return DateTime.now().subtract(Duration(days: index * 2));
      case 'weekly':
        return DateTime.now().subtract(Duration(days: index * 7));
      case 'monthly':
        return DateTime.now().subtract(Duration(days: index * 15));
      default:
        return DateTime.now().subtract(Duration(days: index * 5));
    }
  }

  static int _getRandomDuration() {
    List<int> durations = [0, 120, 180, 300, 420, 600]; // 0 for messages
    return durations[_random.nextInt(durations.length)];
  }

  static double _generateEmotionalScore(double baseScore) {
    // Add some variation to base score
    double variation = (_random.nextDouble() - 0.5) * 1.0; // ±0.5 variation
    double score = baseScore + variation;
    return score.clamp(1.0, 10.0);
  }

  // Get sample reminders
  static List<Map<String, dynamic>> getSampleReminders() {
    return [
      {
        'id': 'reminder_1',
        'title': 'Sarah\'s Birthday',
        'date': DateTime.now().add(const Duration(days: 5)),
        'contactName': 'Sarah Johnson',
        'type': 'birthday',
        'importance': 'high',
        'suggestion': 'Plan a surprise video call with family',
      },
      {
        'id': 'reminder_2',
        'title': 'Call Lisa',
        'date': DateTime.now().add(const Duration(days: 3)),
        'contactName': 'Lisa Chen',
        'type': 'regular_contact',
        'importance': 'medium',
        'suggestion': 'Check in on her medical residency progress',
      },
      {
        'id': 'reminder_3',
        'title': 'Anniversary with David',
        'date': DateTime.now().add(const Duration(days: 12)),
        'contactName': 'David Brown',
        'type': 'anniversary',
        'importance': 'high',
        'suggestion': 'Book that Spanish restaurant he mentioned',
      },
    ];
  }

  /// Load Emotional Check-in Sample Data from JSON
  static Future<Map<String, dynamic>> getEmotionalCheckinJsonData() async {
    // Temporarily disabled cache to ensure fresh data load
    // if (_emotionalCheckinData != null) return _emotionalCheckinData!;

    try {
      final String jsonString = await rootBundle
          .loadString('Demo_data/TrueCircle_Emotional_Checkin_Demo_Data.json');
      _emotionalCheckinData = json.decode(jsonString);
      final dailyEntries =
          _emotionalCheckinData!['daily_entries'] as List? ?? [];
      debugPrint('Loaded ${dailyEntries.length} emotional checkin entries');
      return _emotionalCheckinData!;
    } catch (e) {
      debugPrint('Error loading emotional checkin data: $e');
      return {'daily_entries': []};
    }
  }

  /// Get formatted emotional insights for display
  Future<List<Map<String, dynamic>>> getFormattedEmotionalInsights() async {
    final data = await getEmotionalCheckinJsonData();
    final entries = data['daily_entries'] as List<dynamic>? ?? [];

    return entries
        .map((entry) => {
              'date': entry['date'] ?? 'Unknown',
              'emotion': entry['emotion'] ?? {'en': 'neutral', 'hi': 'सामान्य'},
              'intensity': entry['intensity'] ?? 5,
              'trigger': entry['trigger'] ?? {'en': 'unknown', 'hi': 'अज्ञात'},
              'notes':
                  entry['notes'] ?? {'en': 'No notes', 'hi': 'कोई नोट नहीं'},
            })
        .cast<Map<String, dynamic>>()
        .toList();
  }

  /// Load Mood Journal Data from JSON
  static Future<List<dynamic>> getMoodJournalJsonData() async {
    // Temporarily disabled cache to ensure fresh data load
    // if (_moodJournalData != null) return _moodJournalData!;

    try {
      final String jsonString =
          await rootBundle.loadString('Demo_data/Mood_Journal_Demo_Data.json');
      _moodJournalData = json.decode(jsonString);
      debugPrint('Loaded ${_moodJournalData!.length} mood journal entries');
      return _moodJournalData!;
    } catch (e) {
      debugPrint('Error loading mood journal data: $e');
      return [];
    }
  }

  /// Load Sleep Tracker Data from JSON
  static Future<Map<String, dynamic>> getSleepTrackerJsonData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('Demo_data/Sleep_Tracker.json');
      return json.decode(jsonString);
    } catch (e) {
      debugPrint('Error loading sleep tracker data: $e');
      return {'sleepTracking': []};
    }
  }

  // Add missing methods for compatibility
  static Map<String, dynamic> getComprehensiveDashboardData() {
    return {
      'totalFeatures': 12,
      'activeUsers': 1,
      'demoDataAvailable': true,
      'loyaltyPoints': 5,
    };
  }

  static Future<List<Map<String, dynamic>>> getFormattedMoodJournalEntries() async {
    try {
      final data = await getMoodJournalJsonData();
      return data.map<Map<String, dynamic>>((entry) => {
        'date': entry['date'] ?? 'Unknown',
        'mood': entry['mood'] ?? 'neutral',
        'intensity': entry['intensity'] ?? 5,
        'notes': entry['notes'] ?? 'No notes',
      }).toList();
    } catch (e) {
      debugPrint('Error formatting mood journal entries: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getFormattedRelationshipInsights() async {
    try {
      // Load real relationship data from JSON
      final relationshipData = await JsonDataService.instance.getRelationshipData();
      debugPrint('✅ TrueCircle: Loaded ${relationshipData.length} real relationship insights from JSON');
      
      // Return the actual JSON data instead of dummy data
      return relationshipData;
    } catch (e) {
      debugPrint('❌ Error loading relationship insights: $e');
      // Fallback to original dummy data if JSON fails
      return [
        {
          'title': 'Communication Patterns',
          'insight': 'You communicate most actively with family members',
          'score': 8.5,
          'trend': 'positive'
        },
        {
          'title': 'Emotional Wellness',
          'insight': 'Your emotional state has been stable this week',  
          'score': 7.8,
          'trend': 'stable'
        },
      ];
    }
  }

  /// Get festivals data from JSON - NEW METHOD
  static Future<Map<String, dynamic>> getFestivalsData() async {
    try {
      final festivalsData = await JsonDataService.instance.getFestivalsData();
      debugPrint('✅ TrueCircle: Loaded ${festivalsData['festivals'].length} festivals from JSON');
      return festivalsData;
    } catch (e) {
      debugPrint('❌ Error loading festivals data: $e');
      return {
        'festivals': [],
        'metadata': {'error': 'Failed to load festivals'}
      };
    }
  }

  /// Get upcoming festivals - NEW METHOD  
  static Future<List<Map<String, dynamic>>> getUpcomingFestivals() async {
    try {
      final upcomingFestivals = await JsonDataService.instance.getUpcomingFestivals();
      debugPrint('✅ TrueCircle: Loaded ${upcomingFestivals.length} upcoming festivals');
      return upcomingFestivals;
    } catch (e) {
      debugPrint('❌ Error loading upcoming festivals: $e');
      return [];
    }
  }
}
