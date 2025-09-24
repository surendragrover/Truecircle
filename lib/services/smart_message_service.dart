import '../models/contact.dart';
import '../models/contact_interaction.dart';

class SmartMessageService {
  /// Generates personalized message suggestions based on relationship analysis
  static List<SmartMessage> generateSmartMessages(Contact contact) {
    final messages = <SmartMessage>[];

    // Analyze relationship patterns
    final daysSinceContact = contact.daysSinceLastContact;
    final emotionalScore = contact.emotionalScore;
    final mutualityScore = contact.mutualityScore;

    // Hindi messages for different scenarios
    if (daysSinceContact > 7) {
      messages.addAll(_getReconnectionMessages(contact));
    }

    if (emotionalScore == EmotionalScore.friendlyButFading) {
      messages.addAll(_getRelationshipBoostMessages(contact));
    }

    if (mutualityScore < 0.3) {
      messages.addAll(_getMutualityMessages(contact));
    }

    // Special occasion messages
    messages.addAll(_getSpecialOccasionMessages(contact));

    // Cultural context messages
    messages.addAll(_getCulturalMessages(contact));

    return messages.take(5).toList(); // Return top 5 suggestions
  }

  static List<SmartMessage> _getReconnectionMessages(Contact contact) {
    final name = contact.displayName.split(' ').first;

    return [
      SmartMessage(
        text: "हैलो $name! बहुत दिन हो गए बात किए... कैसे हो? 😊",
        category: MessageCategory.reconnection,
        confidence: 0.9,
        reasoning: "लंबे समय से संपर्क नहीं हुआ",
      ),
      SmartMessage(
        text: "Hi $name! Hope you're doing well. Missing our chats! ☕",
        category: MessageCategory.reconnection,
        confidence: 0.85,
        reasoning: "Re-establishing connection",
      ),
      SmartMessage(
        text: "$name भाई/बहन, सब ठीक तो है न? मन में आए थे आप 💭",
        category: MessageCategory.reconnection,
        confidence: 0.8,
        reasoning: "Caring check-in message",
      ),
    ];
  }

  static List<SmartMessage> _getRelationshipBoostMessages(Contact contact) {
    final name = contact.displayName.split(' ').first;

    return [
      SmartMessage(
        text: "$name, आजकल कैसा चल रहा है सब? कुछ नया-पुराना बताओ! 😄",
        category: MessageCategory.boost,
        confidence: 0.85,
        reasoning: "रिश्ता मजबूत करने के लिए",
      ),
      SmartMessage(
        text: "Hey $name! Want to catch up over coffee sometime? ☕",
        category: MessageCategory.boost,
        confidence: 0.8,
        reasoning: "Face-to-face reconnection",
      ),
      SmartMessage(
        text:
            "$name जी, आपकी राय चाहिए थी एक बात पर... फ्री हो तो बात करें? 🤔",
        category: MessageCategory.boost,
        confidence: 0.75,
        reasoning: "Seeking advice builds connection",
      ),
    ];
  }

  static List<SmartMessage> _getMutualityMessages(Contact contact) {
    final name = contact.displayName.split(' ').first;

    return [
      SmartMessage(
        text: "$name, कैसे हैं आप? कब मिलना हो रहा है? 😊",
        category: MessageCategory.mutuality,
        confidence: 0.8,
        reasoning: "आपकी तरफ से कम response मिल रहा",
      ),
      SmartMessage(
        text: "Hope I'm not bothering you, $name. Just wanted to check in! 💙",
        category: MessageCategory.mutuality,
        confidence: 0.75,
        reasoning: "Gentle approach for low responders",
      ),
    ];
  }

  static List<SmartMessage> _getSpecialOccasionMessages(Contact contact) {
    final now = DateTime.now();
    final name = contact.displayName.split(' ').first;

    // Weekend messages
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      return [
        SmartMessage(
          text: "$name, वीकेंड कैसा जा रहा है? कुछ खास प्लान? 🎉",
          category: MessageCategory.occasion,
          confidence: 0.7,
          reasoning: "Weekend connection",
        ),
      ];
    }

    // Festival season (example for Diwali period)
    if (now.month == 10 || now.month == 11) {
      return [
        SmartMessage(
          text:
              "$name, त्योहारों का मौसम है! घर में कैसी तैयारियां चल रही हैं? 🪔",
          category: MessageCategory.occasion,
          confidence: 0.85,
          reasoning: "Festival season connectivity",
        ),
      ];
    }

    return [];
  }

  static List<SmartMessage> _getCulturalMessages(Contact contact) {
    final name = contact.displayName.split(' ').first;
    final tags = contact.tags;

    if (tags.contains('परिवार') || tags.contains('family')) {
      return [
        SmartMessage(
          text:
              "$name जी, घर में सब कैसे हैं? बुजुर्गों का आशीर्वाद लेते रहिए 🙏",
          category: MessageCategory.cultural,
          confidence: 0.8,
          reasoning: "Family respect and connection",
        ),
      ];
    }

    if (tags.contains('काम') || tags.contains('work')) {
      return [
        SmartMessage(
          text:
              "$name, काम का बोझ तो नहीं बढ़ रहा? थोड़ा break भी लेते रहना 💼",
          category: MessageCategory.cultural,
          confidence: 0.75,
          reasoning: "Work-life balance concern",
        ),
      ];
    }

    return [];
  }

  /// AI-powered message personalization
  static String personalizeMessage(SmartMessage message, Contact contact) {
    String personalizedText = message.text;

    // Add personal touches based on contact history
    if (contact.tags.contains('दोस्त') && !personalizedText.contains('भाई')) {
      personalizedText = personalizedText.replaceAll('जी', 'यार');
    }

    // Add emojis based on emotional score
    switch (contact.emotionalScore) {
      case EmotionalScore.veryWarm:
        if (!personalizedText.contains('😊') &&
            !personalizedText.contains('💙')) {
          personalizedText += ' 😊';
        }
        break;
      case EmotionalScore.friendlyButFading:
        if (!personalizedText.contains('🤗')) {
          personalizedText += ' 🤗';
        }
        break;
      case EmotionalScore.cold:
        // Keep it simple and respectful
        break;
    }

    return personalizedText;
  }
}

class SmartMessage {
  final String text;
  final MessageCategory category;
  final double confidence; // 0.0 to 1.0
  final String reasoning;
  final DateTime timestamp;

  SmartMessage({
    required this.text,
    required this.category,
    required this.confidence,
    required this.reasoning,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'text': text,
        'category': category.toString(),
        'confidence': confidence,
        'reasoning': reasoning,
        'timestamp': timestamp.toIso8601String(),
      };
}

enum MessageCategory {
  reconnection, // पुनः संपर्क
  boost, // रिश्ता मजबूत करना
  mutuality, // बातचीत संतुलन
  occasion, // अवसर आधारित
  cultural, // सांस्कृतिक संदेश
  celebration, // खुशी की बात
  concern, // चिंता/देखभाल
}

extension MessageCategoryExtension on MessageCategory {
  String get displayName {
    switch (this) {
      case MessageCategory.reconnection:
        return 'पुनः मिलन';
      case MessageCategory.boost:
        return 'रिश्ता बेहतर करें';
      case MessageCategory.mutuality:
        return 'संतुलित बातचीत';
      case MessageCategory.occasion:
        return 'खास मौका';
      case MessageCategory.cultural:
        return 'सांस्कृतिक';
      case MessageCategory.celebration:
        return 'खुशी मनाएं';
      case MessageCategory.concern:
        return 'देखभाल';
    }
  }

  String get emoji {
    switch (this) {
      case MessageCategory.reconnection:
        return '🤝';
      case MessageCategory.boost:
        return '💪';
      case MessageCategory.mutuality:
        return '⚖️';
      case MessageCategory.occasion:
        return '🎉';
      case MessageCategory.cultural:
        return '🇮🇳';
      case MessageCategory.celebration:
        return '🎊';
      case MessageCategory.concern:
        return '💙';
    }
  }
}
