// lib/services/emotional_score_service.dart
import '../models/contact_interaction.dart';
import '../models/contact.dart';

class EmotionalScoreService {
  static EmotionalScore calculateScore(
      Contact contact, List<ContactInteraction> interactions) {
    double score = 0.0;

    // Base score from contact data
    score += contact.totalCalls * 2.0;
    score += contact.totalMessages * 1.0;

    // Mutuality bonus
    score += contact.mutualityScore * 10.0;

    // Response time penalty
    if (contact.averageResponseTime > 24.0) {
      score -= 5.0;
    } else if (contact.averageResponseTime < 2.0) {
      score += 3.0;
    }

    // Recency penalty
    final daysSince = contact.daysSinceLastContact;
    if (daysSince > 30) {
      score -= 10.0;
    } else if (daysSince > 14) {
      score -= 5.0;
    } else if (daysSince < 7) {
      score += 2.0;
    }

    // Recent interaction analysis
    final recentInteractions = interactions
        .where((i) =>
            i.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .toList();

    score += recentInteractions.length * 0.5;

    // Sentiment bonus
    final avgSentiment = recentInteractions
            .where((i) => i.sentimentScore != null)
            .map((i) => i.sentimentScore!)
            .fold(0.0, (a, b) => a + b) /
        (recentInteractions.where((i) => i.sentimentScore != null).length + 1);
    score += avgSentiment * 5.0;

    // Convert to enum
    if (score >= 20.0) return EmotionalScore.veryWarm;
    if (score >= 10.0) return EmotionalScore.friendlyButFading;
    return EmotionalScore.cold;
  }

  static EmotionalScore calculateAdvancedScore(
      Contact contact, List<ContactInteraction> interactions) {
    if (interactions.isEmpty) {
      return EmotionalScore.cold;
    }

    double score = 0.0;

    // Base score from contact data
    score += contact.totalCalls * 2.0;
    score += contact.totalMessages * 1.0;

    // Mutuality bonus
    score += contact.mutualityScore * 10.0;

    // Response time factor
    if (contact.averageResponseTime > 24.0) {
      score -= 5.0;
    } else if (contact.averageResponseTime < 2.0) {
      score += 3.0;
    }

    // Recency factor
    final daysSince = contact.daysSinceLastContact;
    if (daysSince > 30) {
      score -= 10.0;
    } else if (daysSince > 14) {
      score -= 5.0;
    } else if (daysSince < 7) {
      score += 2.0;
    }

    // Recent interaction analysis
    final recentInteractions = interactions
        .where((i) =>
            i.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .toList();

    score += recentInteractions.length * 0.5;

    // Sentiment analysis from recent interactions
    final positiveInteractions = recentInteractions
        .where((i) => i.sentimentScore != null && i.sentimentScore! > 0.1)
        .length;
    final negativeInteractions = recentInteractions
        .where((i) => i.sentimentScore != null && i.sentimentScore! < -0.1)
        .length;

    score += positiveInteractions * 2.0;
    score -= negativeInteractions * 3.0;

    // Interaction diversity bonus
    final interactionTypes =
        recentInteractions.map((i) => i.type).toSet().length;
    score += interactionTypes * 1.0;

    // Duration factor for calls
    final totalCallDuration = recentInteractions
        .where((i) =>
            i.type == InteractionType.call ||
            i.type == InteractionType.videoCall)
        .map((i) => i.duration)
        .fold(0, (a, b) => a + b);

    if (totalCallDuration > 3600) {
      // more than 1 hour
      score += 5.0;
    } else if (totalCallDuration > 600) {
      // more than 10 minutes
      score += 2.0;
    }

    // Convert to enum
    if (score >= 25.0) return EmotionalScore.veryWarm;
    if (score >= 10.0) return EmotionalScore.friendlyButFading;
    return EmotionalScore.cold;
  }
}
