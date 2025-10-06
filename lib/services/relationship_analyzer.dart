import 'dart:math';
import '../models/contact.dart';
import '../models/contact_interaction.dart';

/// AI-Powered Relationship Interaction Analyzer
/// यह service हर contact के interaction patterns को analyze करके
/// relationship health, deterioration signals, और improvement suggestions देती है
class RelationshipAnalyzer {
  /// Analyzes interaction patterns to detect relationship health
  RelationshipHealth analyzeRelationshipHealth(
      Contact contact, List<ContactInteraction> interactions) {
    // 1. Communication Frequency Analysis
    final frequencyScore = _analyzeFrequency(interactions);

    // 2. Response Pattern Analysis
    final responseScore = _analyzeResponsePatterns(interactions);

    // 3. Initiation Balance Analysis
    final mutualityScore = _analyzeMutuality(contact, interactions);

    // 4. Temporal Pattern Analysis (degradation over time)
    final temporalScore = _analyzeTemporalPatterns(interactions);

    // 5. Sentiment Trend Analysis
    final sentimentScore = _analyzeSentimentTrends(interactions);

    return RelationshipHealth(
      contact: contact,
      overallScore: _calculateOverallScore(frequencyScore, responseScore,
          mutualityScore, temporalScore, sentimentScore),
      frequencyHealth: frequencyScore,
      responseHealth: responseScore,
      mutualityHealth: mutualityScore,
      temporalHealth: temporalScore,
      sentimentHealth: sentimentScore,
      lastAnalyzed: DateTime.now(),
      warnings: _generateWarnings(contact, interactions),
      insights: _generateInsights(contact, interactions),
      recommendations: _generateRecommendations(contact, interactions),
    );
  }

  /// 📊 Communication Frequency Analysis
  double _analyzeFrequency(List<ContactInteraction> interactions) {
    if (interactions.isEmpty) return 0.0;

    final now = DateTime.now();
    final last30Days = interactions
        .where((i) => now.difference(i.timestamp).inDays <= 30)
        .length;

    // Calculate trend using 90-day comparison
    final last90Days = interactions
        .where((i) => now.difference(i.timestamp).inDays <= 90)
        .length;

    // Use 90-day data for trend analysis
    final trend = last90Days > 0 ? (last30Days / (last90Days / 3.0)) : 1.0;

    // Ideal frequency: 4-8 interactions per month
    final monthlyFrequency = last30Days;

    // Apply trend factor to the base score
    double frequencyScore;
    if (monthlyFrequency >= 4 && monthlyFrequency <= 12) {
      frequencyScore = 1.0;
    } else if (monthlyFrequency >= 2 && monthlyFrequency <= 20) {
      frequencyScore = 0.7;
    } else if (monthlyFrequency >= 1) {
      frequencyScore = 0.4;
    } else {
      frequencyScore = 0.1;
    }

    // Adjust score based on trend (growing = bonus, declining = penalty)
    return frequencyScore * (0.7 + 0.3 * trend).clamp(0.3, 1.3);
  }

  /// ⚡ Response Pattern Analysis
  double _analyzeResponsePatterns(List<ContactInteraction> interactions) {
    if (interactions.length < 2) return 0.5;

    // Analyze response times and consistency
    var responseDelays = <double>[];

    for (int i = 1; i < interactions.length; i++) {
      final current = interactions[i];
      final previous = interactions[i - 1];

      if (current.initiatedByMe != previous.initiatedByMe) {
        final delayHours =
            current.timestamp.difference(previous.timestamp).inHours.toDouble();
        responseDelays.add(delayHours);
      }
    }

    if (responseDelays.isEmpty) return 0.5;

    final avgResponseTime =
        responseDelays.reduce((a, b) => a + b) / responseDelays.length;

    // Quick responses (< 6 hours) = good
    if (avgResponseTime <= 6) return 1.0;
    if (avgResponseTime <= 24) return 0.8;
    if (avgResponseTime <= 72) return 0.5;
    return 0.2;
  }

  /// 🤝 Mutuality Analysis (Two-way communication)
  double _analyzeMutuality(
      Contact contact, List<ContactInteraction> interactions) {
    if (interactions.isEmpty) return 0.0;

    final myInitiations = interactions.where((i) => i.initiatedByMe).length;
    final totalInteractions = interactions.length;

    final myRatio = myInitiations / totalInteractions;

    // Ideal ratio: 40-60% (balanced initiation)
    final deviation = (myRatio - 0.5).abs();

    if (deviation <= 0.1) return 1.0; // 40-60% range
    if (deviation <= 0.2) return 0.7; // 30-70% range
    if (deviation <= 0.3) return 0.4; // 20-80% range
    return 0.1; // Very one-sided
  }

  /// 📈 Temporal Pattern Analysis (Relationship trajectory)
  double _analyzeTemporalPatterns(List<ContactInteraction> interactions) {
    if (interactions.length < 4) return 0.5;

    final sortedInteractions = List<ContactInteraction>.from(interactions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Compare recent 3 months vs previous 3 months
    final now = DateTime.now();
    final recent = sortedInteractions
        .where((i) => now.difference(i.timestamp).inDays <= 90)
        .length;
    final previous = sortedInteractions
        .where((i) =>
            now.difference(i.timestamp).inDays > 90 &&
            now.difference(i.timestamp).inDays <= 180)
        .length;

    if (previous == 0) return 0.5;

    final changeRatio = recent / previous;

    if (changeRatio >= 1.2) return 1.0; // Improving
    if (changeRatio >= 0.8) return 0.8; // Stable
    if (changeRatio >= 0.5) return 0.5; // Declining
    return 0.2; // Rapidly deteriorating
  }

  /// 💭 Sentiment Trend Analysis
  double _analyzeSentimentTrends(List<ContactInteraction> interactions) {
    final sentimentInteractions =
        interactions.where((i) => i.sentimentScore != null).toList();

    if (sentimentInteractions.length < 3) return 0.5;

    // Analyze sentiment trend over time
    sentimentInteractions.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final recentSentiment = sentimentInteractions
            .skip(max(0, sentimentInteractions.length - 5))
            .map((i) => i.sentimentScore!)
            .reduce((a, b) => a + b) /
        min(5, sentimentInteractions.length);

    // Convert sentiment (-1 to 1) to health score (0 to 1)
    return (recentSentiment + 1) / 2;
  }

  /// 🎯 Overall Relationship Score Calculation
  double _calculateOverallScore(double frequency, double response,
      double mutuality, double temporal, double sentiment) {
    // Weighted average based on importance
    return (frequency * 0.25 +
        response * 0.20 +
        mutuality * 0.25 +
        temporal * 0.20 +
        sentiment * 0.10);
  }

  /// ⚠️ Generate Relationship Warnings
  List<RelationshipWarning> _generateWarnings(
      Contact contact, List<ContactInteraction> interactions) {
    List<RelationshipWarning> warnings = [];

    final daysSinceLastContact = contact.daysSinceLastContact;

    // Warning: Long gap in communication
    if (daysSinceLastContact > 30) {
      warnings.add(RelationshipWarning(
        type: WarningType.communicationGap,
        severity: daysSinceLastContact > 90
            ? WarningSeverity.high
            : WarningSeverity.medium,
        titleEn: "Long silence period",
        titleHi: "लंबे समय से खामोशी",
        descriptionEn: "$daysSinceLastContact days since last contact",
        descriptionHi: "पिछली बार से $daysSinceLastContact दिन हो गए",
      ));
    }

    // Warning: One-sided communication
    if (contact.mutualityScore < 0.3) {
      warnings.add(RelationshipWarning(
        type: WarningType.oneSided,
        severity: WarningSeverity.medium,
        titleEn: "One-sided communication",
        titleHi: "एकतरफा बातचीत",
        descriptionEn: "You're initiating most conversations",
        descriptionHi: "ज्यादातर बातचीत आप ही शुरू कर रहे हैं",
      ));
    }

    return warnings;
  }

  /// 💡 Generate AI Insights
  List<RelationshipInsight> _generateInsights(
      Contact contact, List<ContactInteraction> interactions) {
    List<RelationshipInsight> insights = [];

    // Insight: Communication pattern
    final avgResponseHours = contact.averageResponseTime;
    if (avgResponseHours <= 2) {
      insights.add(RelationshipInsight(
        type: InsightType.positive,
        titleEn: "Quick responder",
        titleHi: "तुरंत जवाब देने वाले",
        descriptionEn:
            "They usually respond within ${avgResponseHours.toStringAsFixed(1)} hours",
        descriptionHi:
            "वे आमतौर पर ${avgResponseHours.toStringAsFixed(1)} घंटे में जवाब देते हैं",
      ));
    }

    // Insight: Best contact time
    insights.add(_analyzeBestContactTime(interactions));

    return insights;
  }

  /// 🎯 Generate Actionable Recommendations
  List<RelationshipRecommendation> _generateRecommendations(
      Contact contact, List<ContactInteraction> interactions) {
    List<RelationshipRecommendation> recommendations = [];

    final daysSinceLastContact = contact.daysSinceLastContact;

    // Recommendation: Reach out
    if (daysSinceLastContact > 14) {
      recommendations.add(RelationshipRecommendation(
        type: RecommendationType.reachOut,
        priority: daysSinceLastContact > 30
            ? RecommendationPriority.high
            : RecommendationPriority.medium,
        titleEn: "Time to reach out",
        titleHi: "संपर्क करने का समय",
        descriptionEn:
            "It's been $daysSinceLastContact days. Send a friendly message!",
        descriptionHi:
            "$daysSinceLastContact दिन हो गए हैं। एक दोस्ताना संदेश भेजें!",
        suggestedActions: [
          "Send a casual 'How are you?' message",
          "Share something they might find interesting",
          "Ask about their recent activities"
        ],
        suggestedActionsHi: [
          "कैजुअल 'कैसे हो?' मैसेज भेजें",
          "कुछ दिलचस्प शेयर करें",
          "उनकी हाल की गतिविधियों के बारे में पूछें"
        ],
      ));
    }

    return recommendations;
  }

  RelationshipInsight _analyzeBestContactTime(
      List<ContactInteraction> interactions) {
    final hourCounts = <int, int>{};

    for (final interaction in interactions) {
      final hour = interaction.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    if (hourCounts.isEmpty) {
      return RelationshipInsight(
        type: InsightType.neutral,
        titleEn: "No pattern found",
        titleHi: "कोई पैटर्न नहीं मिला",
        descriptionEn: "Need more data to analyze contact patterns",
        descriptionHi: "संपर्क पैटर्न का विश्लेषण करने के लिए अधिक डेटा चाहिए",
      );
    }

    final bestHour =
        hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    String timeOfDay = "morning";
    String timeOfDayHi = "सुबह";

    if (bestHour >= 12 && bestHour < 17) {
      timeOfDay = "afternoon";
      timeOfDayHi = "दोपहर";
    } else if (bestHour >= 17 && bestHour < 21) {
      timeOfDay = "evening";
      timeOfDayHi = "शाम";
    } else if (bestHour >= 21 || bestHour < 6) {
      timeOfDay = "night";
      timeOfDayHi = "रात";
    }

    return RelationshipInsight(
      type: InsightType.actionable,
      titleEn: "Best contact time",
      titleHi: "संपर्क का सबसे अच्छा समय",
      descriptionEn: "They're most active in the $timeOfDay",
      descriptionHi: "वे $timeOfDayHi में सबसे ज्यादा सक्रिय रहते हैं",
    );
  }
}

/// Relationship Health Analysis Result
class RelationshipHealth {
  final Contact contact;
  final double overallScore; // 0-1
  final double frequencyHealth;
  final double responseHealth;
  final double mutualityHealth;
  final double temporalHealth;
  final double sentimentHealth;
  final DateTime lastAnalyzed;
  final List<RelationshipWarning> warnings;
  final List<RelationshipInsight> insights;
  final List<RelationshipRecommendation> recommendations;

  RelationshipHealth({
    required this.contact,
    required this.overallScore,
    required this.frequencyHealth,
    required this.responseHealth,
    required this.mutualityHealth,
    required this.temporalHealth,
    required this.sentimentHealth,
    required this.lastAnalyzed,
    required this.warnings,
    required this.insights,
    required this.recommendations,
  });

  /// Get relationship status emoji and description
  String get healthEmoji {
    if (overallScore >= 0.8) return '💚';
    if (overallScore >= 0.6) return '💛';
    if (overallScore >= 0.4) return '🧡';
    return '❤️‍🩹';
  }

  String get healthDescription {
    if (overallScore >= 0.8) return 'Strong Relationship / मजबूत रिश्ता';
    if (overallScore >= 0.6) return 'Good Connection / अच्छा जुड़ाव';
    if (overallScore >= 0.4) return 'Needs Attention / ध्यान देने की जरूरत';
    return 'Requires Care / देखभाल की जरूरत';
  }
}

/// Relationship Warning Types
class RelationshipWarning {
  final WarningType type;
  final WarningSeverity severity;
  final String titleEn;
  final String titleHi;
  final String descriptionEn;
  final String descriptionHi;

  RelationshipWarning({
    required this.type,
    required this.severity,
    required this.titleEn,
    required this.titleHi,
    required this.descriptionEn,
    required this.descriptionHi,
  });
}

enum WarningType {
  communicationGap,
  oneSided,
  decliningSentiment,
  responseDelay
}

enum WarningSeverity { low, medium, high, critical }

/// Relationship Insights
class RelationshipInsight {
  final InsightType type;
  final String titleEn;
  final String titleHi;
  final String descriptionEn;
  final String descriptionHi;

  RelationshipInsight({
    required this.type,
    required this.titleEn,
    required this.titleHi,
    required this.descriptionEn,
    required this.descriptionHi,
  });
}

enum InsightType { positive, negative, neutral, actionable }

/// Relationship Recommendations
class RelationshipRecommendation {
  final RecommendationType type;
  final RecommendationPriority priority;
  final String titleEn;
  final String titleHi;
  final String descriptionEn;
  final String descriptionHi;
  final List<String> suggestedActions;
  final List<String> suggestedActionsHi;

  RelationshipRecommendation({
    required this.type,
    required this.priority,
    required this.titleEn,
    required this.titleHi,
    required this.descriptionEn,
    required this.descriptionHi,
    required this.suggestedActions,
    required this.suggestedActionsHi,
  });
}

enum RecommendationType {
  reachOut,
  improveBalance,
  changeApproach,
  specialOccasion
}

enum RecommendationPriority { low, medium, high, urgent }
