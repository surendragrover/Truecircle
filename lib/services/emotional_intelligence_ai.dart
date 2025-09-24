import 'dart:math' as math;
import '../models/contact_interaction.dart';

/// 🧠 Emotional Intelligence AI - Advanced message analysis
/// Analyzes tone, emojis, language style, and cultural context
class EmotionalIntelligenceAI {
  /// Message Tone Analysis - "हैलो कैसे हो?" vs "क्या चाहिए?" - tone में फर्क
  static MessageToneAnalysis analyzeMessageTone(
      String message, String language) {
    final normalizedMessage = message.toLowerCase().trim();

    // Analyze formal vs informal patterns
    final formalityScore =
        _calculateFormalityScore(normalizedMessage, language);
    final politenessScore =
        _calculatePolitenessScore(normalizedMessage, language);
    final warmthScore = _calculateWarmthScore(normalizedMessage, language);
    final urgencyScore = _calculateUrgencyScore(normalizedMessage, language);

    return MessageToneAnalysis(
      formalityLevel: _getFormalityLevel(formalityScore),
      politenessLevel: _getPolitenessLevel(politenessScore),
      warmthLevel: _getWarmthLevel(warmthScore),
      urgencyLevel: _getUrgencyLevel(urgencyScore),
      overallTone:
          _determineOverallTone(formalityScore, politenessScore, warmthScore),
      culturalContext: _analyzeCulturalContext(normalizedMessage, language),
      toneScore: (formalityScore + politenessScore + warmthScore) / 3,
    );
  }

  /// Emoji Pattern Recognition - 😊❤️ vs 👍 - emotional depth समझना
  static EmojiPatternAnalysis analyzeEmojiPatterns(List<String> messages) {
    final emojiMap = <String, int>{};
    final emotionalCategories = <EmotionalCategory, int>{};

    int totalMessages = 0;
    int messagesWithEmojis = 0;

    for (final message in messages) {
      totalMessages++;
      final emojis = _extractEmojis(message);

      if (emojis.isNotEmpty) {
        messagesWithEmojis++;

        for (final emoji in emojis) {
          emojiMap[emoji] = (emojiMap[emoji] ?? 0) + 1;

          final category = _categorizeEmoji(emoji);
          emotionalCategories[category] =
              (emotionalCategories[category] ?? 0) + 1;
        }
      }
    }

    return EmojiPatternAnalysis(
      emojiUsageFrequency:
          totalMessages > 0 ? messagesWithEmojis / totalMessages : 0.0,
      mostUsedEmojis: _getTopEmojis(emojiMap, 10),
      emotionalCategories: emotionalCategories,
      emojiDiversity: emojiMap.length.toDouble(),
      expressiveness: _calculateExpressiveness(emojiMap, emotionalCategories),
      emojiPersonality: _determineEmojiPersonality(emotionalCategories),
    );
  }

  /// Language Style Detection - formal vs casual बातचीत
  static LanguageStyleAnalysis analyzeLanguageStyle(
      List<String> messages, String language) {
    double formalityTotal = 0.0;
    double complexityTotal = 0.0;
    double vocabularyRichness = 0.0;
    final wordFrequency = <String, int>{};
    final uniqueWords = <String>{};

    for (final message in messages) {
      final words = message.toLowerCase().split(RegExp(r'\s+'));

      // Formality analysis
      formalityTotal +=
          _calculateFormalityScore(message.toLowerCase(), language);

      // Complexity analysis
      complexityTotal += _calculateComplexityScore(message, language);

      // Vocabulary analysis
      for (final word in words) {
        if (word.length > 2) {
          // Ignore very short words
          wordFrequency[word] = (wordFrequency[word] ?? 0) + 1;
          uniqueWords.add(word);
        }
      }
    }

    final totalWords =
        wordFrequency.values.fold(0, (sum, count) => sum + count);
    vocabularyRichness = totalWords > 0 ? uniqueWords.length / totalWords : 0.0;

    return LanguageStyleAnalysis(
      formalityLevel: formalityTotal / messages.length,
      complexityLevel: complexityTotal / messages.length,
      vocabularyRichness: vocabularyRichness,
      communicationStyle:
          _determineCommunicationStyle(formalityTotal / messages.length),
      languageEvolution: _analyzeLanguageEvolution(messages, language),
      codeSwithcing: _analyzeCodeSwitching(messages),
    );
  }

  /// Cultural Context AI - Hindi/English में अलग emotional expressions
  static CulturalContextAnalysis analyzeCulturalContext(List<String> messages) {
    final hindiPatterns = <String, int>{};
    final englishPatterns = <String, int>{};
    final culturalMarkers = <String, int>{};

    double hindiCount = 0;
    double englishCount = 0;
    double mixedCount = 0;

    for (final message in messages) {
      final languageDetection = _detectLanguage(message);

      switch (languageDetection) {
        case 'hindi':
          hindiCount++;
          _extractCulturalMarkers(message, hindiPatterns);
          break;
        case 'english':
          englishCount++;
          _extractCulturalMarkers(message, englishPatterns);
          break;
        case 'mixed':
          mixedCount++;
          break;
      }

      // Extract cultural markers (ji, sahib, bhai, etc.)
      _extractIndianCulturalMarkers(message, culturalMarkers);
    }

    final totalMessages = messages.length.toDouble();

    return CulturalContextAnalysis(
      hindiUsagePercentage:
          totalMessages > 0 ? (hindiCount / totalMessages) * 100 : 0,
      englishUsagePercentage:
          totalMessages > 0 ? (englishCount / totalMessages) * 100 : 0,
      codeSwitchingPercentage:
          totalMessages > 0 ? (mixedCount / totalMessages) * 100 : 0,
      culturalMarkers: culturalMarkers,
      respectLevel: _calculateRespectLevel(culturalMarkers),
      culturalAdaptation:
          _analyzeCulturalAdaptation(hindiPatterns, englishPatterns),
      communicationContext: _determineCommunicationContext(culturalMarkers),
    );
  }

  /// Advanced Sentiment Evolution Analysis
  static SentimentEvolution analyzeSentimentEvolution(
      List<ContactInteraction> interactions) {
    final sentimentTimeline = <DateTime, double>{};
    final emotionalMilestones = <DateTime, String>{};

    for (final interaction in interactions) {
      if (interaction.content != null && interaction.content!.isNotEmpty) {
        final sentiment = _calculateAdvancedSentiment(interaction.content!);
        sentimentTimeline[interaction.timestamp] = sentiment;

        // Detect emotional milestones
        if (sentiment > 0.8 || sentiment < -0.8) {
          emotionalMilestones[interaction.timestamp] =
              sentiment > 0 ? 'Very Positive' : 'Very Negative';
        }
      }
    }

    return SentimentEvolution(
      sentimentTimeline: sentimentTimeline,
      emotionalMilestones: emotionalMilestones,
      overallTrend: _calculateSentimentTrend(sentimentTimeline),
      sentimentVolatility: _calculateSentimentVolatility(sentimentTimeline),
      emotionalStability: _calculateEmotionalStability(sentimentTimeline),
    );
  }

  // Helper Methods
  static double _calculateFormalityScore(String message, String language) {
    final formalWords = language == 'hindi'
        ? ['आप', 'आपका', 'कृपया', 'धन्यवाद', 'नमस्कार', 'जी', 'साहब']
        : ['please', 'thank', 'sir', 'madam', 'kindly', 'regards', 'sincerely'];

    final informalWords = language == 'hindi'
        ? ['तू', 'तेरा', 'यार', 'भाई', 'दोस्त', 'अरे', 'ओये']
        : ['hey', 'hi', 'bro', 'dude', 'mate', 'sup', 'yeah'];

    double formalCount = 0;
    double informalCount = 0;

    for (final word in formalWords) {
      if (message.contains(word)) formalCount++;
    }

    for (final word in informalWords) {
      if (message.contains(word)) informalCount++;
    }

    if (formalCount + informalCount == 0) return 0.5; // Neutral
    return formalCount / (formalCount + informalCount);
  }

  static double _calculatePolitenessScore(String message, String language) {
    final politeMarkers = language == 'hindi'
        ? ['कृपया', 'धन्यवाद', 'क्षमा', 'माफ', 'जी हां', 'आपका']
        : ['please', 'thank', 'sorry', 'excuse', 'appreciate', 'grateful'];

    double politenessCount = 0;
    for (final marker in politeMarkers) {
      if (message.contains(marker)) politenessCount++;
    }

    return math.min(1.0, politenessCount / 3); // Normalized to 0-1
  }

  static double _calculateWarmthScore(String message, String language) {
    final warmWords = language == 'hindi'
        ? ['प्यार', 'दिल', 'खुशी', 'मित्र', 'स्नेह', '❤️', '😊', '😄']
        : ['love', 'heart', 'happy', 'dear', 'warm', '❤️', '😊', '😄'];

    double warmthCount = 0;
    for (final word in warmWords) {
      if (message.contains(word)) warmthCount++;
    }

    return math.min(1.0, warmthCount / 2);
  }

  static double _calculateUrgencyScore(String message, String language) {
    final urgentMarkers = language == 'hindi'
        ? ['जल्दी', 'तुरंत', 'अभी', 'फौरन', 'जरूरी', '!', 'URGENT']
        : ['urgent', 'asap', 'immediately', 'now', 'quick', '!', 'URGENT'];

    double urgencyCount = 0;
    for (final marker in urgentMarkers) {
      if (message.contains(marker)) urgencyCount++;
    }

    return math.min(1.0, urgencyCount / 2);
  }

  static List<String> _extractEmojis(String message) {
    final emojiRegex = RegExp(
        r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
        unicode: true);
    return emojiRegex
        .allMatches(message)
        .map((match) => match.group(0)!)
        .toList();
  }

  static EmotionalCategory _categorizeEmoji(String emoji) {
    final joyEmojis = ['😊', '😄', '😁', '🙂', '😃', '😆', '🤗', '😍'];
    final loveEmojis = ['❤️', '💙', '💚', '💛', '🧡', '💜', '💕', '💖'];
    final sadEmojis = ['😢', '😭', '😞', '🙁', '😔', '😟', '😕'];
    final angryEmojis = ['😡', '😠', '🤬', '😤', '💢'];

    if (joyEmojis.contains(emoji)) return EmotionalCategory.joy;
    if (loveEmojis.contains(emoji)) return EmotionalCategory.love;
    if (sadEmojis.contains(emoji)) return EmotionalCategory.sadness;
    if (angryEmojis.contains(emoji)) return EmotionalCategory.anger;
    return EmotionalCategory.neutral;
  }

  static double _calculateComplexityScore(String message, String language) {
    final words = message.split(' ');
    final averageWordLength =
        words.fold(0, (sum, word) => sum + word.length) / words.length;
    final sentenceCount = message.split(RegExp(r'[.!?]')).length;

    // Complexity based on word length and sentence structure
    return math.min(
        1.0, (averageWordLength - 3) / 5 + (words.length / sentenceCount) / 10);
  }

  static String _detectLanguage(String message) {
    final hindiRegex = RegExp(r'[\u0900-\u097F]');
    final englishRegex = RegExp(r'[a-zA-Z]');

    final hindiMatches = hindiRegex.allMatches(message).length;
    final englishMatches = englishRegex.allMatches(message).length;

    if (hindiMatches > 0 && englishMatches > 0) return 'mixed';
    if (hindiMatches > englishMatches) return 'hindi';
    if (englishMatches > hindiMatches) return 'english';
    return 'unknown';
  }

  static void _extractIndianCulturalMarkers(
      String message, Map<String, int> markers) {
    final culturalWords = [
      'जी',
      'साहब',
      'भाई',
      'बहन',
      'अंकल',
      'आंटी',
      'दीदी',
      'भैया'
    ];

    for (final word in culturalWords) {
      if (message.contains(word)) {
        markers[word] = (markers[word] ?? 0) + 1;
      }
    }
  }

  static double _calculateRespectLevel(Map<String, int> culturalMarkers) {
    final respectMarkers = ['जी', 'साहब', 'आप', 'sir', 'madam'];
    double respectCount = 0;

    for (final marker in respectMarkers) {
      respectCount += culturalMarkers[marker] ?? 0;
    }

    final totalMarkers =
        culturalMarkers.values.fold(0, (sum, count) => sum + count);
    return totalMarkers > 0 ? respectCount / totalMarkers : 0.5;
  }

  static double _calculateAdvancedSentiment(String content) {
    // Placeholder for advanced sentiment analysis
    // In real implementation, this would use ML models
    return 0.5;
  }

  static double _calculateSentimentVolatility(
      Map<DateTime, double> sentimentTimeline) {
    final values = sentimentTimeline.values.toList();
    if (values.length < 2) return 0.0;

    double variance = 0.0;
    final mean = values.fold(0.0, (sum, val) => sum + val) / values.length;

    for (final value in values) {
      variance += math.pow(value - mean, 2);
    }

    return math.sqrt(variance / values.length);
  }

  // Additional helper methods would be implemented here...
  static FormalityLevel _getFormalityLevel(double score) {
    if (score > 0.7) return FormalityLevel.veryFormal;
    if (score > 0.5) return FormalityLevel.formal;
    if (score > 0.3) return FormalityLevel.neutral;
    if (score > 0.1) return FormalityLevel.informal;
    return FormalityLevel.veryInformal;
  }

  static PolitenessLevel _getPolitenessLevel(double score) {
    if (score > 0.8) return PolitenessLevel.veryPolite;
    if (score > 0.6) return PolitenessLevel.polite;
    if (score > 0.4) return PolitenessLevel.neutral;
    if (score > 0.2) return PolitenessLevel.rude;
    return PolitenessLevel.veryRude;
  }

  static WarmthLevel _getWarmthLevel(double score) {
    if (score > 0.8) return WarmthLevel.veryWarm;
    if (score > 0.6) return WarmthLevel.warm;
    if (score > 0.4) return WarmthLevel.neutral;
    if (score > 0.2) return WarmthLevel.cool;
    return WarmthLevel.cold;
  }

  static UrgencyLevel _getUrgencyLevel(double score) {
    if (score > 0.8) return UrgencyLevel.urgent;
    if (score > 0.6) return UrgencyLevel.high;
    if (score > 0.4) return UrgencyLevel.medium;
    if (score > 0.2) return UrgencyLevel.low;
    return UrgencyLevel.none;
  }

  static MessageTone _determineOverallTone(
      double formality, double politeness, double warmth) {
    final overall = (formality + politeness + warmth) / 3;
    if (overall > 0.7) return MessageTone.professional;
    if (overall > 0.5) return MessageTone.friendly;
    if (overall > 0.3) return MessageTone.neutral;
    if (overall > 0.1) return MessageTone.casual;
    return MessageTone.harsh;
  }

  static CulturalContext _analyzeCulturalContext(
      String message, String language) {
    // Placeholder implementation
    return CulturalContext.indian;
  }

  static List<MapEntry<String, int>> _getTopEmojis(
      Map<String, int> emojiMap, int count) {
    final sorted = emojiMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(count).toList();
  }

  static double _calculateExpressiveness(
      Map<String, int> emojiMap, Map<EmotionalCategory, int> categories) {
    final totalEmojis = emojiMap.values.fold(0, (sum, count) => sum + count);
    final uniqueEmojis = emojiMap.length;
    return totalEmojis > 0 ? uniqueEmojis / totalEmojis : 0.0;
  }

  static EmojiPersonality _determineEmojiPersonality(
      Map<EmotionalCategory, int> categories) {
    final total = categories.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return EmojiPersonality.reserved;

    final joyPercent = (categories[EmotionalCategory.joy] ?? 0) / total;
    final lovePercent = (categories[EmotionalCategory.love] ?? 0) / total;

    if (joyPercent > 0.5) return EmojiPersonality.joyful;
    if (lovePercent > 0.3) return EmojiPersonality.affectionate;
    return EmojiPersonality.balanced;
  }

  static CommunicationStyle _determineCommunicationStyle(
      double formalityLevel) {
    if (formalityLevel > 0.7) return CommunicationStyle.professional;
    if (formalityLevel > 0.3) return CommunicationStyle.balanced;
    return CommunicationStyle.casual;
  }

  static LanguageEvolution _analyzeLanguageEvolution(
      List<String> messages, String language) {
    // Placeholder - would analyze how language style changes over time
    return LanguageEvolution.stable;
  }

  static double _analyzeCodeSwitching(List<String> messages) {
    int codeSwitchingInstances = 0;
    for (final message in messages) {
      if (_detectLanguage(message) == 'mixed') {
        codeSwitchingInstances++;
      }
    }
    return messages.isNotEmpty ? codeSwitchingInstances / messages.length : 0.0;
  }

  static void _extractCulturalMarkers(
      String message, Map<String, int> patterns) {
    // Extract language-specific cultural patterns
  }

  static CulturalAdaptation _analyzeCulturalAdaptation(
      Map<String, int> hindiPatterns, Map<String, int> englishPatterns) {
    // Analyze how the person adapts their communication style
    return CulturalAdaptation.adaptive;
  }

  static CommunicationContext _determineCommunicationContext(
      Map<String, int> culturalMarkers) {
    final formalMarkers =
        (culturalMarkers['जी'] ?? 0) + (culturalMarkers['साहब'] ?? 0);
    if (formalMarkers > 5) return CommunicationContext.professional;
    return CommunicationContext.personal;
  }

  static SentimentTrend _calculateSentimentTrend(
      Map<DateTime, double> sentimentTimeline) {
    // Calculate if sentiment is improving, declining, or stable
    return SentimentTrend.stable;
  }

  static double _calculateEmotionalStability(
      Map<DateTime, double> sentimentTimeline) {
    return _calculateSentimentVolatility(sentimentTimeline);
  }
}

// Data Models
class MessageToneAnalysis {
  final FormalityLevel formalityLevel;
  final PolitenessLevel politenessLevel;
  final WarmthLevel warmthLevel;
  final UrgencyLevel urgencyLevel;
  final MessageTone overallTone;
  final CulturalContext culturalContext;
  final double toneScore;

  MessageToneAnalysis({
    required this.formalityLevel,
    required this.politenessLevel,
    required this.warmthLevel,
    required this.urgencyLevel,
    required this.overallTone,
    required this.culturalContext,
    required this.toneScore,
  });
}

class EmojiPatternAnalysis {
  final double emojiUsageFrequency;
  final List<MapEntry<String, int>> mostUsedEmojis;
  final Map<EmotionalCategory, int> emotionalCategories;
  final double emojiDiversity;
  final double expressiveness;
  final EmojiPersonality emojiPersonality;

  EmojiPatternAnalysis({
    required this.emojiUsageFrequency,
    required this.mostUsedEmojis,
    required this.emotionalCategories,
    required this.emojiDiversity,
    required this.expressiveness,
    required this.emojiPersonality,
  });
}

class LanguageStyleAnalysis {
  final double formalityLevel;
  final double complexityLevel;
  final double vocabularyRichness;
  final CommunicationStyle communicationStyle;
  final LanguageEvolution languageEvolution;
  final double codeSwithcing;

  LanguageStyleAnalysis({
    required this.formalityLevel,
    required this.complexityLevel,
    required this.vocabularyRichness,
    required this.communicationStyle,
    required this.languageEvolution,
    required this.codeSwithcing,
  });
}

class CulturalContextAnalysis {
  final double hindiUsagePercentage;
  final double englishUsagePercentage;
  final double codeSwitchingPercentage;
  final Map<String, int> culturalMarkers;
  final double respectLevel;
  final CulturalAdaptation culturalAdaptation;
  final CommunicationContext communicationContext;

  CulturalContextAnalysis({
    required this.hindiUsagePercentage,
    required this.englishUsagePercentage,
    required this.codeSwitchingPercentage,
    required this.culturalMarkers,
    required this.respectLevel,
    required this.culturalAdaptation,
    required this.communicationContext,
  });
}

class SentimentEvolution {
  final Map<DateTime, double> sentimentTimeline;
  final Map<DateTime, String> emotionalMilestones;
  final SentimentTrend overallTrend;
  final double sentimentVolatility;
  final double emotionalStability;

  SentimentEvolution({
    required this.sentimentTimeline,
    required this.emotionalMilestones,
    required this.overallTrend,
    required this.sentimentVolatility,
    required this.emotionalStability,
  });
}

// Enums
enum FormalityLevel { veryFormal, formal, neutral, informal, veryInformal }

enum PolitenessLevel { veryPolite, polite, neutral, rude, veryRude }

enum WarmthLevel { veryWarm, warm, neutral, cool, cold }

enum UrgencyLevel { urgent, high, medium, low, none }

enum MessageTone { professional, friendly, neutral, casual, harsh }

enum CulturalContext { indian, western, mixed, universal }

enum EmotionalCategory { joy, love, sadness, anger, surprise, fear, neutral }

enum EmojiPersonality { joyful, affectionate, reserved, expressive, balanced }

enum CommunicationStyle { professional, balanced, casual }

enum LanguageEvolution { improving, stable, declining }

enum CulturalAdaptation { adaptive, consistent, rigid }

enum CommunicationContext { professional, personal, mixed }

enum SentimentTrend { improving, stable, declining }
