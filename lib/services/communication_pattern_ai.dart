import 'dart:math' as math;
import '../models/contact.dart';
import '../models/contact_interaction.dart';

/// 📱 Smart Contact Analysis - Communication Pattern AI
/// Advanced analysis of calling, messaging, and interaction patterns
class CommunicationPatternAI {
  /// Communication Pattern Analysis - कौन कितनी बार call/message करता है
  static CommunicationPattern analyzeCommunicationPattern(Contact contact) {
    final totalInteractions = contact.totalCalls + contact.totalMessages;
    final myInitiations =
        contact.callsInitiatedByMe + contact.messagesInitiatedByMe;

    // Calculate patterns
    final initiationRatio =
        totalInteractions > 0 ? myInitiations / totalInteractions : 0.0;
    final callToMessageRatio = contact.totalMessages > 0
        ? contact.totalCalls / contact.totalMessages
        : 0.0;
    final frequency = _calculateFrequency(contact);

    return CommunicationPattern(
      totalInteractions: totalInteractions,
      myInitiationRatio: initiationRatio,
      theirInitiationRatio: 1.0 - initiationRatio,
      callToMessageRatio: callToMessageRatio,
      averageFrequency: frequency,
      preferredMethod: _getPreferredMethod(contact),
      communicationStyle:
          _determineCommunicationStyle(initiationRatio, callToMessageRatio),
    );
  }

  /// Response Time Analysis - कितनी जल्दी reply आता है
  static ResponseTimeAnalysis analyzeResponseTime(
      Contact contact, List<ContactInteraction> interactions) {
    final responseTimes = <Duration>[];
    final myResponseTimes = <Duration>[];
    final timePatterns = <String, double>{};

    // Analyze recent interactions for response patterns
    for (int i = 1; i < interactions.length; i++) {
      final current = interactions[i];
      final previous = interactions[i - 1];

      if (current.timestamp.isAfter(previous.timestamp)) {
        final responseTime = current.timestamp.difference(previous.timestamp);

        if (!current.initiatedByMe && previous.initiatedByMe) {
          // Their response to my message
          responseTimes.add(responseTime);
        } else if (current.initiatedByMe && !previous.initiatedByMe) {
          // My response to their message
          myResponseTimes.add(responseTime);
        }

        // Time pattern analysis
        final hour = current.timestamp.hour;
        final timeSlot = _getTimeSlot(hour);
        timePatterns[timeSlot] = (timePatterns[timeSlot] ?? 0) + 1;
      }
    }

    return ResponseTimeAnalysis(
      averageResponseTime: _calculateAverageResponseTime(responseTimes),
      myAverageResponseTime: _calculateAverageResponseTime(myResponseTimes),
      responseConsistency: _calculateConsistency(responseTimes),
      fastResponsePercentage: _calculateFastResponsePercentage(responseTimes),
      timePatterns: timePatterns,
      responseTrend: _calculateResponseTrend(responseTimes),
    );
  }

  /// Conversation Sentiment Analysis - बातचीत में warmth है या coldness
  static ConversationSentiment analyzeConversationSentiment(
      List<ContactInteraction> interactions) {
    double positiveScore = 0.0;
    double neutralScore = 0.0;
    double negativeScore = 0.0;
    int totalAnalyzed = 0;

    final recentInteractions =
        interactions.take(50).toList(); // Analyze recent 50 interactions

    for (final interaction in recentInteractions) {
      if (interaction.content != null && interaction.content!.isNotEmpty) {
        final sentiment = _analyzeSentiment(interaction.content!);
        positiveScore += sentiment.positive;
        neutralScore += sentiment.neutral;
        negativeScore += sentiment.negative;
        totalAnalyzed++;
      }
    }

    if (totalAnalyzed == 0) {
      return ConversationSentiment(
        overallSentiment: SentimentType.neutral,
        positivePercentage: 33.33,
        neutralPercentage: 33.33,
        negativePercentage: 33.33,
        sentimentTrend: SentimentTrend.stable,
        warmthLevel: WarmthLevel.moderate,
      );
    }

    final avgPositive = (positiveScore / totalAnalyzed) * 100;
    final avgNeutral = (neutralScore / totalAnalyzed) * 100;
    final avgNegative = (negativeScore / totalAnalyzed) * 100;

    return ConversationSentiment(
      overallSentiment:
          _getOverallSentiment(avgPositive, avgNeutral, avgNegative),
      positivePercentage: avgPositive,
      neutralPercentage: avgNeutral,
      negativePercentage: avgNegative,
      sentimentTrend: _calculateSentimentTrend(recentInteractions),
      warmthLevel: _calculateWarmthLevel(avgPositive, avgNegative),
    );
  }

  /// Special Dates Memory Analysis - birthday, anniversary याद रखते हैं या नहीं
  static SpecialDatesMemory analyzeSpecialDatesMemory(
      Contact contact, List<ContactInteraction> interactions) {
    final specialDates = contact.specialDates;
    final memoryScore = <String, double>{};
    final missedDates = <DateTime>[];
    final rememberedDates = <DateTime>[];

    for (final specialDate in specialDates) {
      final dateType = _getDateType(specialDate);
      final wasRemembered = _wasDateRemembered(specialDate, interactions);

      if (wasRemembered) {
        rememberedDates.add(specialDate);
        memoryScore[dateType] = (memoryScore[dateType] ?? 0) + 1;
      } else {
        missedDates.add(specialDate);
      }
    }

    final totalDates = specialDates.length;
    final overallMemoryScore =
        totalDates > 0 ? rememberedDates.length / totalDates : 0.0;

    return SpecialDatesMemory(
      overallMemoryScore: overallMemoryScore,
      rememberedDates: rememberedDates,
      missedDates: missedDates,
      memoryByType: memoryScore,
      memoryTrend: _calculateMemoryTrend(contact, interactions),
      isBirthdayRemembered: _isBirthdayRemembered(contact, interactions),
    );
  }

  // Helper methods
  static double _calculateFrequency(Contact contact) {
    if (contact.lastContacted == null) return 0.0;

    final daysSinceFirst = contact.firstMet != null
        ? DateTime.now().difference(contact.firstMet!).inDays
        : 365;

    final totalInteractions = contact.totalCalls + contact.totalMessages;
    return daysSinceFirst > 0 ? totalInteractions / daysSinceFirst : 0.0;
  }

  static PreferredMethod _getPreferredMethod(Contact contact) {
    if (contact.totalCalls > contact.totalMessages * 1.5) {
      return PreferredMethod.call;
    } else if (contact.totalMessages > contact.totalCalls * 1.5) {
      return PreferredMethod.message;
    } else {
      return PreferredMethod.mixed;
    }
  }

  static CommunicationStyle _determineCommunicationStyle(
      double initiationRatio, double callToMessageRatio) {
    if (initiationRatio > 0.7) {
      return CommunicationStyle.initiator; // मैं ज्यादा शुरुआत करता हूं
    } else if (initiationRatio < 0.3) {
      return CommunicationStyle.responder; // वे ज्यादा शुरुआत करते हैं
    } else {
      return CommunicationStyle.balanced; // संतुलित
    }
  }

  static Duration _calculateAverageResponseTime(List<Duration> responseTimes) {
    if (responseTimes.isEmpty) return Duration.zero;

    final totalMinutes =
        responseTimes.fold(0, (sum, duration) => sum + duration.inMinutes);
    return Duration(minutes: totalMinutes ~/ responseTimes.length);
  }

  static double _calculateConsistency(List<Duration> responseTimes) {
    if (responseTimes.isEmpty) return 0.0;

    final avgMinutes = responseTimes.fold(0, (sum, d) => sum + d.inMinutes) /
        responseTimes.length;
    final variance = responseTimes.fold(
            0.0, (sum, d) => sum + math.pow(d.inMinutes - avgMinutes, 2)) /
        responseTimes.length;
    final standardDeviation = math.sqrt(variance);

    // Lower standard deviation = higher consistency
    return math.max(0.0, 1.0 - (standardDeviation / avgMinutes));
  }

  static double _calculateFastResponsePercentage(List<Duration> responseTimes) {
    if (responseTimes.isEmpty) return 0.0;

    final fastResponses =
        responseTimes.where((duration) => duration.inMinutes <= 30).length;
    return (fastResponses / responseTimes.length) * 100;
  }

  static String _getTimeSlot(int hour) {
    if (hour >= 6 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 21) return 'Evening';
    return 'Night';
  }

  static ResponseTrend _calculateResponseTrend(List<Duration> responseTimes) {
    if (responseTimes.length < 10) return ResponseTrend.stable;

    final recent = responseTimes.take(responseTimes.length ~/ 2);
    final older = responseTimes.skip(responseTimes.length ~/ 2);

    final recentAvg =
        recent.fold(0, (sum, d) => sum + d.inMinutes) / recent.length;
    final olderAvg =
        older.fold(0, (sum, d) => sum + d.inMinutes) / older.length;

    final difference = recentAvg - olderAvg;

    if (difference > 60) return ResponseTrend.slowing; // Getting slower
    if (difference < -60) return ResponseTrend.improving; // Getting faster
    return ResponseTrend.stable;
  }

  static MessageSentiment _analyzeSentiment(String message) {
    // Simple sentiment analysis for Hindi/English
    final positiveWords = [
      'good',
      'great',
      'awesome',
      'love',
      'happy',
      'excellent',
      'wonderful',
      'अच्छा',
      'बहुत',
      'खुश',
      'प्यार',
      'शानदार',
      'बेहतरीन',
      '😊',
      '😄',
      '❤️',
      '💙'
    ];

    final negativeWords = [
      'bad',
      'terrible',
      'hate',
      'angry',
      'sad',
      'disappointed',
      'awful',
      'बुरा',
      'गुस्सा',
      'दुख',
      'परेशान',
      'गलत',
      '😢',
      '😡',
      '😞'
    ];

    final lowerMessage = message.toLowerCase();
    double positive = 0.0;
    double negative = 0.0;

    for (final word in positiveWords) {
      if (lowerMessage.contains(word.toLowerCase())) positive += 1.0;
    }

    for (final word in negativeWords) {
      if (lowerMessage.contains(word.toLowerCase())) negative += 1.0;
    }

    final total = positive + negative;
    if (total == 0) {
      return MessageSentiment(positive: 0.0, neutral: 1.0, negative: 0.0);
    }

    return MessageSentiment(
      positive: positive / total,
      neutral: total == 0 ? 1.0 : 0.0,
      negative: negative / total,
    );
  }

  static SentimentType _getOverallSentiment(
      double positive, double neutral, double negative) {
    if (positive > negative && positive > neutral) {
      return SentimentType.positive;
    }
    if (negative > positive && negative > neutral) {
      return SentimentType.negative;
    }
    return SentimentType.neutral;
  }

  static SentimentTrend _calculateSentimentTrend(
      List<ContactInteraction> interactions) {
    if (interactions.length < 20) return SentimentTrend.stable;

    final recent = interactions.take(10);
    final older = interactions.skip(10).take(10);

    double recentPositive = 0.0;
    double olderPositive = 0.0;

    for (final interaction in recent) {
      if (interaction.content != null) {
        recentPositive += _analyzeSentiment(interaction.content!).positive;
      }
    }

    for (final interaction in older) {
      if (interaction.content != null) {
        olderPositive += _analyzeSentiment(interaction.content!).positive;
      }
    }

    final difference = recentPositive - olderPositive;

    if (difference > 2.0) return SentimentTrend.improving;
    if (difference < -2.0) return SentimentTrend.declining;
    return SentimentTrend.stable;
  }

  static WarmthLevel _calculateWarmthLevel(double positive, double negative) {
    final warmthScore = positive - negative;

    if (warmthScore > 30) return WarmthLevel.veryWarm;
    if (warmthScore > 10) return WarmthLevel.warm;
    if (warmthScore > -10) return WarmthLevel.moderate;
    if (warmthScore > -30) return WarmthLevel.cool;
    return WarmthLevel.cold;
  }

  static String _getDateType(DateTime date) {
    // Simple categorization - in real implementation, this would be more sophisticated
    return 'Birthday'; // Placeholder
  }

  static bool _wasDateRemembered(
      DateTime specialDate, List<ContactInteraction> interactions) {
    // Check if there was communication around the special date (±3 days)
    final startDate = specialDate.subtract(const Duration(days: 3));
    final endDate = specialDate.add(const Duration(days: 3));

    return interactions.any((interaction) =>
        interaction.timestamp.isAfter(startDate) &&
        interaction.timestamp.isBefore(endDate));
  }

  static MemoryTrend _calculateMemoryTrend(
      Contact contact, List<ContactInteraction> interactions) {
    // Placeholder - would analyze historical special date remembrance
    return MemoryTrend.stable;
  }

  static bool _isBirthdayRemembered(
      Contact contact, List<ContactInteraction> interactions) {
    // Check if birthday communications exist
    return contact.specialDates.isNotEmpty;
  }
}

// Data Models
class CommunicationPattern {
  final int totalInteractions;
  final double myInitiationRatio;
  final double theirInitiationRatio;
  final double callToMessageRatio;
  final double averageFrequency;
  final PreferredMethod preferredMethod;
  final CommunicationStyle communicationStyle;

  CommunicationPattern({
    required this.totalInteractions,
    required this.myInitiationRatio,
    required this.theirInitiationRatio,
    required this.callToMessageRatio,
    required this.averageFrequency,
    required this.preferredMethod,
    required this.communicationStyle,
  });

  String get initiationAnalysis {
    if (myInitiationRatio > 0.7) {
      return 'आप ज्यादा बातचीत शुरू करते हैं';
    } else if (myInitiationRatio < 0.3) {
      return 'वे ज्यादा बातचीत शुरू करते हैं';
    } else {
      return 'संतुलित बातचीत';
    }
  }
}

class ResponseTimeAnalysis {
  final Duration averageResponseTime;
  final Duration myAverageResponseTime;
  final double responseConsistency;
  final double fastResponsePercentage;
  final Map<String, double> timePatterns;
  final ResponseTrend responseTrend;

  ResponseTimeAnalysis({
    required this.averageResponseTime,
    required this.myAverageResponseTime,
    required this.responseConsistency,
    required this.fastResponsePercentage,
    required this.timePatterns,
    required this.responseTrend,
  });

  String get responseSpeedDescription {
    final minutes = averageResponseTime.inMinutes;
    if (minutes < 30) return 'तुरंत जवाब देते हैं';
    if (minutes < 180) return 'जल्दी जवाब देते हैं';
    if (minutes < 1440) return 'कुछ घंटों में जवाब देते हैं';
    return 'देर से जवाब देते हैं';
  }
}

class ConversationSentiment {
  final SentimentType overallSentiment;
  final double positivePercentage;
  final double neutralPercentage;
  final double negativePercentage;
  final SentimentTrend sentimentTrend;
  final WarmthLevel warmthLevel;

  ConversationSentiment({
    required this.overallSentiment,
    required this.positivePercentage,
    required this.neutralPercentage,
    required this.negativePercentage,
    required this.sentimentTrend,
    required this.warmthLevel,
  });
}

class SpecialDatesMemory {
  final double overallMemoryScore;
  final List<DateTime> rememberedDates;
  final List<DateTime> missedDates;
  final Map<String, double> memoryByType;
  final MemoryTrend memoryTrend;
  final bool isBirthdayRemembered;

  SpecialDatesMemory({
    required this.overallMemoryScore,
    required this.rememberedDates,
    required this.missedDates,
    required this.memoryByType,
    required this.memoryTrend,
    required this.isBirthdayRemembered,
  });

  String get memoryDescription {
    if (overallMemoryScore > 0.8) return 'बहुत अच्छी याददाश्त';
    if (overallMemoryScore > 0.5) return 'ठीक-ठाक याददाश्त';
    return 'खास दिन भूल जाते हैं';
  }
}

class MessageSentiment {
  final double positive;
  final double neutral;
  final double negative;

  MessageSentiment({
    required this.positive,
    required this.neutral,
    required this.negative,
  });
}

// Enums
enum PreferredMethod { call, message, mixed }

enum CommunicationStyle { initiator, responder, balanced }

enum ResponseTrend { improving, stable, slowing }

enum SentimentType { positive, neutral, negative }

enum SentimentTrend { improving, stable, declining }

enum WarmthLevel { veryWarm, warm, moderate, cool, cold }

enum MemoryTrend { improving, stable, declining }
