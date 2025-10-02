import 'dart:math' as math;
import '../models/contact.dart';
import '../models/contact_interaction.dart';
import '../services/huggingface_service.dart';
import '../services/communication_pattern_ai.dart' as comm;

/// 🔮 Predictive Relationship AI - Advanced relationship forecasting
/// Predicts relationship health, warns about drift, suggests optimal contact times
class PredictiveRelationshipAI {
  final HuggingFaceService _huggingFace;

  PredictiveRelationshipAI(this._huggingFace);

  /// Comprehensive Relationship Health Score Prediction
  Future<RelationshipHealthPrediction> predictRelationshipHealth(
      Contact contact, List<ContactInteraction> interactions) async {
    // Analyze multiple dimensions
    final communicationPattern =
        comm.CommunicationPatternAI.analyzeCommunicationPattern(contact);
    final responseAnalysis =
        comm.CommunicationPatternAI.analyzeResponseTime(contact, interactions);
    final sentimentAnalysis =
        comm.CommunicationPatternAI.analyzeConversationSentiment(interactions);

    // AI-powered sentiment prediction
    final recentMessages = interactions
        .where((i) => i.content != null && i.content!.isNotEmpty)
        .take(10)
        .map((i) => {'content': i.content!})
        .toList();

    final aiHealthPrediction =
        await _huggingFace.predictRelationshipHealth(recentMessages);

    // Calculate comprehensive health score
    final healthScore = _calculateComprehensiveHealthScore(
      communicationPattern,
      responseAnalysis,
      sentimentAnalysis,
      contact,
      aiHealthPrediction,
    );

    // Predict future trajectory
    final trajectory = _predictTrajectory(interactions, healthScore);

    // Generate risk assessment
    final riskFactors =
        _identifyRiskFactors(contact, interactions, healthScore);

    // AI-powered recommendations
    final recommendations =
        await _generateAIRecommendations(contact, healthScore, riskFactors);

    return RelationshipHealthPrediction(
      overallHealthScore: healthScore,
      trajectory: trajectory,
      riskLevel: _calculateRiskLevel(healthScore, riskFactors),
      riskFactors: riskFactors,
      recommendations: recommendations,
      confidenceLevel:
          _calculateConfidenceLevel(interactions.length, aiHealthPrediction),
      timeToAction: _calculateTimeToAction(healthScore, trajectory),
      strengths: _identifyStrengths(communicationPattern, sentimentAnalysis),
      warnings: _generateWarnings(healthScore, riskFactors),
    );
  }

  /// 🚨 Early Warning System for Relationship Drift
  RelationshipWarning? detectRelationshipDrift(
      Contact contact, List<ContactInteraction> interactions) {
    if (interactions.length < 10) return null;

    // Analyze recent vs historical patterns
    final recentInteractions =
        interactions.take(interactions.length ~/ 3).toList();
    final historicalInteractions =
        interactions.skip(interactions.length ~/ 3).toList();

    final recentPattern = _analyzeInteractionPattern(recentInteractions);
    final historicalPattern =
        _analyzeInteractionPattern(historicalInteractions);

    // Detect significant changes
    final driftIndicators = <String, double>{};

    // Frequency drift
    final frequencyDrift =
        (historicalPattern['frequency']! - recentPattern['frequency']!).abs();
    if (frequencyDrift > 0.3) {
      driftIndicators['frequency_decline'] = frequencyDrift;
    }

    // Response time drift
    final responseTimeDrift = recentPattern['avg_response_hours']! -
        historicalPattern['avg_response_hours']!;
    if (responseTimeDrift > 24) {
      // More than 24 hours increase
      driftIndicators['response_delay'] = responseTimeDrift;
    }

    // Sentiment drift
    final sentimentDrift = historicalPattern['sentiment_score']! -
        recentPattern['sentiment_score']!;
    if (sentimentDrift > 0.2) {
      driftIndicators['sentiment_decline'] = sentimentDrift;
    }

    // Initiation drift (if user is always initiating now)
    final initiationDrift = recentPattern['my_initiation_ratio']! -
        historicalPattern['my_initiation_ratio']!;
    if (initiationDrift > 0.3) {
      driftIndicators['initiation_imbalance'] = initiationDrift;
    }

    if (driftIndicators.isNotEmpty) {
      return RelationshipWarning(
        type: _determineWarningType(driftIndicators),
        severity: _calculateWarningSeverity(driftIndicators),
        message: _generateWarningMessage(contact.displayName, driftIndicators),
        suggestedActions: _generateSuggestedActions(driftIndicators),
        detectedAt: DateTime.now(),
        driftIndicators: driftIndicators,
      );
    }

    return null;
  }

  /// ⏰ Best Time to Connect Prediction
  Future<OptimalContactTime> predictBestContactTime(
      Contact contact, List<ContactInteraction> interactions) async {
    // Analyze historical response patterns by time
    final timePatterns = <int, ResponseData>{}; // Hour -> Response data

    for (final interaction in interactions) {
      final hour = interaction.timestamp.hour;
      final data = timePatterns[hour] ?? ResponseData(hour);

      if (!interaction.initiatedByMe) {
        // They initiated contact at this time
        data.theirInitiations++;
      } else {
        // We initiated, check if they responded quickly
        final nextInteraction = _findNextInteraction(interaction, interactions);
        if (nextInteraction != null && !nextInteraction.initiatedByMe) {
          final responseTime =
              nextInteraction.timestamp.difference(interaction.timestamp);
          data.responseTime.add(responseTime);
        }
      }

      timePatterns[hour] = data;
    }

    // Analyze patterns
    final optimalHours = <int>[];
    double bestScore = 0.0;

    for (final entry in timePatterns.entries) {
      final hour = entry.key;
      final data = entry.value;

      // Calculate engagement score for this hour
      final engagementScore = _calculateEngagementScore(data);

      if (engagementScore > bestScore) {
        bestScore = engagementScore;
        optimalHours.clear();
        optimalHours.add(hour);
      } else if ((engagementScore - bestScore).abs() < 0.1) {
        optimalHours.add(hour);
      }
    }

    // Day of week analysis
    final dayPatterns = _analyzeDayPatterns(interactions);

    return OptimalContactTime(
      bestHours: optimalHours,
      bestDays: dayPatterns.keys.take(3).toList(),
      engagementScore: bestScore,
      reasoning: _generateContactTimeReasoning(optimalHours, dayPatterns),
      confidence: _calculateTimeConfidence(interactions.length),
      nextSuggestedContact:
          _calculateNextSuggestedContact(optimalHours, dayPatterns),
    );
  }

  /// 💡 Personalized Conversation Starter Generator
  Future<List<ConversationStarter>> generatePersonalizedStarters(
      Contact contact, List<ContactInteraction> interactions) async {
    final starters = <ConversationStarter>[];

    // Get context for AI generation
    final relationshipContext = {
      'relationship_type': _inferRelationshipType(contact),
      'days_since_contact': contact.daysSinceLastContact,
      'emotional_score': contact.emotionalScore.toString(),
      'communication_style': _inferCommunicationStyle(interactions),
    };

    // AI-generated starters
    final aiStarters = await _huggingFace.generateConversationStarters(
        contact.displayName, relationshipContext);

    if (aiStarters['starters'] != null) {
      final aiMessages = aiStarters['starters'] as List<String>;
      for (int i = 0; i < aiMessages.length; i++) {
        starters.add(ConversationStarter(
          text: aiMessages[i],
          category: ConversationCategory.aiGenerated,
          confidence: 0.8 -
              (i * 0.1), // Decrease confidence for lower ranked suggestions
          reasoning: 'AI विश्लेषण के आधार पर व्यक्तिगत सुझाव',
        ));
      }
    }

    // Context-based starters
    starters.addAll(_generateContextBasedStarters(contact, interactions));

    // Emotional state-based starters
    starters.addAll(_generateEmotionalStarters(contact, interactions));

    // Cultural context starters
    starters.addAll(_generateCulturalStarters(contact));

    // Sort by confidence and return top suggestions
    starters.sort((a, b) => b.confidence.compareTo(a.confidence));
    return starters.take(8).toList();
  }

  /// 📈 Relationship Trajectory Forecasting
  RelationshipForecast forecastRelationshipTrajectory(
      Contact contact, List<ContactInteraction> interactions,
      {int daysAhead = 30}) {
    final currentHealth = _getCurrentHealthScore(contact, interactions);
    final trend = _calculateCurrentTrend(interactions);

    // Project future health based on current trajectory
    final projectedHealth =
        _projectHealthScore(currentHealth, trend, daysAhead);

    // Identify key milestones and potential issues
    final milestones = _identifyFutureMilestones(contact, daysAhead);
    final potentialIssues = _identifyPotentialIssues(projectedHealth, trend);

    return RelationshipForecast(
      currentHealth: currentHealth,
      projectedHealth: projectedHealth,
      trend: trend,
      confidence: _calculateForecastConfidence(interactions.length),
      milestones: milestones,
      potentialIssues: potentialIssues,
      recommendations:
          _generateForecastRecommendations(projectedHealth, potentialIssues),
      forecastPeriod: daysAhead,
    );
  }

  // Helper Methods
  double _calculateComprehensiveHealthScore(
    comm.CommunicationPattern commPattern,
    comm.ResponseTimeAnalysis responseAnalysis,
    comm.ConversationSentiment sentiment,
    Contact contact,
    Map<String, dynamic> aiPrediction,
  ) {
    // Weight different factors
    double score = 0.0;

    // Communication mutuality (25%)
    score += commPattern.myInitiationRatio < 0.8
        ? 0.25
        : 0.25 * (1 - commPattern.myInitiationRatio);

    // Response time quality (20%)
    final responseMinutes = responseAnalysis.averageResponseTime.inMinutes;
    score += responseMinutes < 60
        ? 0.20
        : responseMinutes < 240
            ? 0.15
            : 0.10;

    // Sentiment quality (25%)
    score += sentiment.positivePercentage / 100 * 0.25;

    // Recent contact frequency (15%)
    final daysSince = contact.daysSinceLastContact;
    score += daysSince < 3
        ? 0.15
        : daysSince < 7
            ? 0.10
            : 0.05;

    // AI prediction weight (15%)
    if (aiPrediction['health_score'] != null) {
      score += (aiPrediction['health_score'] as double) * 0.15;
    }

    return math.min(1.0, score);
  }

  RelationshipTrajectory _predictTrajectory(
      List<ContactInteraction> interactions, double currentHealth) {
    if (interactions.length < 10) return RelationshipTrajectory.stable;

    final recentScore = _calculateRecentScore(interactions.take(5).toList());
    final olderScore =
        _calculateRecentScore(interactions.skip(5).take(5).toList());

    final difference = recentScore - olderScore;

    if (difference > 0.1) return RelationshipTrajectory.improving;
    if (difference < -0.1) return RelationshipTrajectory.declining;
    return RelationshipTrajectory.stable;
  }

  double _calculateRecentScore(List<ContactInteraction> interactions) {
    // Simplified scoring based on interaction patterns
    if (interactions.isEmpty) return 0.5;

    final totalInteractions = interactions.length;
    final myInitiations = interactions.where((i) => i.initiatedByMe).length;
    final balance = 1.0 - (myInitiations / totalInteractions - 0.5).abs() * 2;

    return balance;
  }

  List<String> _identifyRiskFactors(Contact contact,
      List<ContactInteraction> interactions, double healthScore) {
    final risks = <String>[];

    if (contact.daysSinceLastContact > 14) {
      risks.add('लंबे समय से संपर्क नहीं हुआ');
    }

    if (healthScore < 0.3) {
      risks.add('रिश्ते की गुणवत्ता में गिरावट');
    }

    final myInitiationRatio =
        contact.callsInitiatedByMe + contact.messagesInitiatedByMe;
    final totalInitiations = contact.totalCalls + contact.totalMessages;
    if (totalInitiations > 0 && myInitiationRatio / totalInitiations > 0.8) {
      risks.add('हमेशा आप ही बातचीत शुरू करते हैं');
    }

    if (contact.averageResponseTime > 24) {
      risks.add('देर से जवाब देते हैं');
    }

    return risks;
  }

  Future<List<String>> _generateAIRecommendations(
      Contact contact, double healthScore, List<String> riskFactors) async {
    final recommendations = <String>[];

    if (healthScore < 0.4) {
      recommendations.add('${contact.displayName} को गर्मजोशी भरा संदेश भेजें');
      recommendations.add('पुरानी यादों की बात करें');
      recommendations.add('मिलने का प्रोग्राम बनाएं');
    } else if (healthScore < 0.7) {
      recommendations.add('नियमित संपर्क बनाए रखें');
      recommendations.add('उनकी रुचियों के बारे में पूछें');
    } else {
      recommendations.add('बहुत अच्छा रिश्ता! इसे बनाए रखें');
      recommendations.add('खुशी के मौकों को साझा करते रहें');
    }

    return recommendations;
  }

  RiskLevel _calculateRiskLevel(double healthScore, List<String> riskFactors) {
    if (healthScore < 0.3 || riskFactors.length > 3) return RiskLevel.high;
    if (healthScore < 0.6 || riskFactors.length > 1) return RiskLevel.medium;
    return RiskLevel.low;
  }

  double _calculateConfidenceLevel(
      int interactionCount, Map<String, dynamic> aiPrediction) {
    double confidence = math.min(
        1.0, interactionCount / 50.0); // More interactions = higher confidence

    if (aiPrediction['confidence'] != null) {
      confidence = (confidence + (aiPrediction['confidence'] as double)) / 2;
    }

    return confidence;
  }

  Duration _calculateTimeToAction(
      double healthScore, RelationshipTrajectory trajectory) {
    if (healthScore < 0.3) return const Duration(days: 1); // Urgent
    if (healthScore < 0.5) return const Duration(days: 3); // Soon
    if (trajectory == RelationshipTrajectory.declining) {
      return const Duration(days: 7); // Week
    }
    return const Duration(days: 14); // Regular check-in
  }

  List<String> _identifyStrengths(
      comm.CommunicationPattern pattern, comm.ConversationSentiment sentiment) {
    final strengths = <String>[];

    if (pattern.communicationStyle == comm.CommunicationStyle.balanced) {
      strengths.add('संतुलित बातचीत');
    }

    if (sentiment.warmthLevel == comm.WarmthLevel.veryWarm ||
        sentiment.warmthLevel == comm.WarmthLevel.warm) {
      strengths.add('गर्मजोशी भरा रिश्ता');
    }

    if (sentiment.positivePercentage > 70) {
      strengths.add('सकारात्मक संवाद');
    }

    return strengths;
  }

  List<String> _generateWarnings(double healthScore, List<String> riskFactors) {
    final warnings = <String>[];

    if (healthScore < 0.3) {
      warnings.add('⚠️ रिश्ता खराब होने का खतरा');
    }

    if (riskFactors.contains('लंबे समय से संपर्क नहीं हुआ')) {
      warnings.add('📱 तुरंत संपर्क करने की जरूरत');
    }

    return warnings;
  }

  // Additional helper methods would be implemented here...
  Map<String, double> _analyzeInteractionPattern(
      List<ContactInteraction> interactions) {
    if (interactions.isEmpty) {
      return {
        'frequency': 0.0,
        'avg_response_hours': 24.0,
        'sentiment_score': 0.5,
        'my_initiation_ratio': 0.5,
      };
    }

    final totalInteractions = interactions.length;
    final myInitiations = interactions.where((i) => i.initiatedByMe).length;
    final daySpan = interactions.first.timestamp
        .difference(interactions.last.timestamp)
        .inDays;

    return {
      'frequency': daySpan > 0
          ? totalInteractions / daySpan
          : totalInteractions.toDouble(),
      'avg_response_hours': 12.0, // Placeholder
      'sentiment_score': 0.6, // Placeholder
      'my_initiation_ratio':
          totalInteractions > 0 ? myInitiations / totalInteractions : 0.5,
    };
  }

  WarningType _determineWarningType(Map<String, double> indicators) {
    if (indicators.containsKey('sentiment_decline')) {
      return WarningType.sentimentDecline;
    }
    if (indicators.containsKey('frequency_decline')) {
      return WarningType.communicationDrop;
    }
    if (indicators.containsKey('response_delay')) {
      return WarningType.responseDelay;
    }
    if (indicators.containsKey('initiation_imbalance')) {
      return WarningType.initiationImbalance;
    }
    return WarningType.general;
  }

  WarningSeverity _calculateWarningSeverity(Map<String, double> indicators) {
    final maxValue = indicators.values.reduce(math.max);
    if (maxValue > 0.7) return WarningSeverity.critical;
    if (maxValue > 0.5) return WarningSeverity.high;
    if (maxValue > 0.3) return WarningSeverity.medium;
    return WarningSeverity.low;
  }

  String _generateWarningMessage(String name, Map<String, double> indicators) {
    if (indicators.containsKey('sentiment_decline')) {
      return '$name के साथ बातचीत में कमी आई है';
    }
    if (indicators.containsKey('frequency_decline')) {
      return '$name से कम बात हो रही है';
    }
    return '$name के साथ रिश्ते में बदलाव दिख रहा है';
  }

  List<String> _generateSuggestedActions(Map<String, double> indicators) {
    final actions = <String>[];

    if (indicators.containsKey('sentiment_decline')) {
      actions.add('गर्मजोशी भरा संदेश भेजें');
    }
    if (indicators.containsKey('frequency_decline')) {
      actions.add('नियमित संपर्क बढ़ाएं');
    }
    if (indicators.containsKey('initiation_imbalance')) {
      actions.add('उनसे पहल करने का इंतजार करें');
    }

    return actions;
  }

  ContactInteraction? _findNextInteraction(
      ContactInteraction current, List<ContactInteraction> all) {
    final currentIndex = all.indexOf(current);
    if (currentIndex < all.length - 1) {
      return all[currentIndex + 1];
    }
    return null;
  }

  double _calculateEngagementScore(ResponseData data) {
    double score = 0.0;

    // Weight their initiations highly
    score += data.theirInitiations * 0.6;

    // Weight quick responses
    if (data.responseTime.isNotEmpty) {
      final avgResponse =
          data.responseTime.fold(Duration.zero, (a, b) => a + b) ~/
              data.responseTime.length;
      score += avgResponse.inHours < 2
          ? 0.4
          : avgResponse.inHours < 6
              ? 0.2
              : 0.1;
    }

    return score;
  }

  Map<int, double> _analyzeDayPatterns(List<ContactInteraction> interactions) {
    final dayScores = <int, double>{};

    for (final interaction in interactions) {
      final day = interaction.timestamp.weekday;
      dayScores[day] = (dayScores[day] ?? 0) + 1;
    }

    return dayScores;
  }

  String _generateContactTimeReasoning(
      List<int> hours, Map<int, double> dayPatterns) {
    final hourText = hours.map((h) => '$h:00').join(', ');
    return 'सबसे अच्छा समय: $hourText बजे';
  }

  double _calculateTimeConfidence(int interactionCount) {
    return math.min(1.0, interactionCount / 30.0);
  }

  DateTime _calculateNextSuggestedContact(
      List<int> hours, Map<int, double> dayPatterns) {
    final now = DateTime.now();
    final nextHour = hours.first;

    var nextContact = DateTime(now.year, now.month, now.day, nextHour);
    if (nextContact.isBefore(now)) {
      nextContact = nextContact.add(const Duration(days: 1));
    }

    return nextContact;
  }

  String _inferRelationshipType(Contact contact) {
    if (contact.tags.contains('परिवार') || contact.tags.contains('family')) {
      return 'family';
    }
    if (contact.tags.contains('काम') || contact.tags.contains('work')) {
      return 'colleague';
    }
    return 'friend';
  }

  String _inferCommunicationStyle(List<ContactInteraction> interactions) {
    final formalCount = interactions
        .where((i) =>
            i.content?.contains('जी') == true ||
            i.content?.contains('sir') == true)
        .length;

    return formalCount > interactions.length * 0.3 ? 'formal' : 'casual';
  }

  List<ConversationStarter> _generateContextBasedStarters(
      Contact contact, List<ContactInteraction> interactions) {
    final starters = <ConversationStarter>[];

    if (contact.daysSinceLastContact > 7) {
      starters.add(ConversationStarter(
        text: '${contact.displayName}, बहुत दिन हो गए बात किए... कैसे हैं आप?',
        category: ConversationCategory.reconnection,
        confidence: 0.8,
        reasoning: 'लंबे समय बाद संपर्क के लिए उपयुक्त',
      ));
    }

    return starters;
  }

  List<ConversationStarter> _generateEmotionalStarters(
      Contact contact, List<ContactInteraction> interactions) {
    final starters = <ConversationStarter>[];

    if (contact.emotionalScore == EmotionalScore.friendlyButFading) {
      starters.add(ConversationStarter(
        text: '${contact.displayName}, आपकी याद आ रही थी... कैसा चल रहा है सब?',
        category: ConversationCategory.emotional,
        confidence: 0.75,
        reasoning: 'रिश्ते में गर्मी लाने के लिए',
      ));
    }

    return starters;
  }

  List<ConversationStarter> _generateCulturalStarters(Contact contact) {
    final starters = <ConversationStarter>[];

    final now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      starters.add(ConversationStarter(
        text: '${contact.displayName} जी, वीकेंड कैसा जा रहा है?',
        category: ConversationCategory.contextual,
        confidence: 0.7,
        reasoning: 'वीकेंड के लिए उपयुक्त',
      ));
    }

    return starters;
  }

  double _getCurrentHealthScore(
      Contact contact, List<ContactInteraction> interactions) {
    // Simplified health score calculation
    double score = 0.5;

    if (contact.daysSinceLastContact < 7) score += 0.2;
    if (contact.emotionalScore == EmotionalScore.veryWarm) score += 0.3;

    return math.min(1.0, score);
  }

  RelationshipTrend _calculateCurrentTrend(
      List<ContactInteraction> interactions) {
    if (interactions.length < 6) return RelationshipTrend.stable;

    final recent = interactions.take(3);
    final older = interactions.skip(3).take(3);

    final recentFreq = recent.length;
    final olderFreq = older.length;

    if (recentFreq > olderFreq) return RelationshipTrend.improving;
    if (recentFreq < olderFreq) return RelationshipTrend.declining;
    return RelationshipTrend.stable;
  }

  double _projectHealthScore(
      double current, RelationshipTrend trend, int days) {
    double projection = current;

    switch (trend) {
      case RelationshipTrend.improving:
        projection += 0.1 * (days / 30.0);
        break;
      case RelationshipTrend.declining:
        projection -= 0.15 * (days / 30.0);
        break;
      case RelationshipTrend.stable:
        // No change
        break;
    }

    return math.max(0.0, math.min(1.0, projection));
  }

  List<String> _identifyFutureMilestones(Contact contact, int days) {
    final milestones = <String>[];

    // Check for upcoming special dates
    final futureDate = DateTime.now().add(Duration(days: days));
    for (final specialDate in contact.specialDates) {
      if (specialDate.isBefore(futureDate) &&
          specialDate.isAfter(DateTime.now())) {
        milestones.add('${contact.displayName} का special date आने वाला है');
      }
    }

    return milestones;
  }

  List<String> _identifyPotentialIssues(
      double projectedHealth, RelationshipTrend trend) {
    final issues = <String>[];

    if (projectedHealth < 0.3) {
      issues.add('रिश्ता खराब होने का खतरा');
    }

    if (trend == RelationshipTrend.declining) {
      issues.add('संपर्क कम होता जा रहा है');
    }

    return issues;
  }

  List<String> _generateForecastRecommendations(
      double projectedHealth, List<String> issues) {
    final recommendations = <String>[];

    if (projectedHealth < 0.5) {
      recommendations.add('तुरंत संपर्क बढ़ाएं');
      recommendations.add('व्यक्तिगत मुलाकात का प्रोग्राम बनाएं');
    }

    return recommendations;
  }

  double _calculateForecastConfidence(int interactionCount) {
    return math.min(0.9, interactionCount / 100.0);
  }
}

// Data Models
class RelationshipHealthPrediction {
  final double overallHealthScore;
  final RelationshipTrajectory trajectory;
  final RiskLevel riskLevel;
  final List<String> riskFactors;
  final List<String> recommendations;
  final double confidenceLevel;
  final Duration timeToAction;
  final List<String> strengths;
  final List<String> warnings;

  RelationshipHealthPrediction({
    required this.overallHealthScore,
    required this.trajectory,
    required this.riskLevel,
    required this.riskFactors,
    required this.recommendations,
    required this.confidenceLevel,
    required this.timeToAction,
    required this.strengths,
    required this.warnings,
  });
}

class RelationshipWarning {
  final WarningType type;
  final WarningSeverity severity;
  final String message;
  final List<String> suggestedActions;
  final DateTime detectedAt;
  final Map<String, double> driftIndicators;

  RelationshipWarning({
    required this.type,
    required this.severity,
    required this.message,
    required this.suggestedActions,
    required this.detectedAt,
    required this.driftIndicators,
  });
}

class OptimalContactTime {
  final List<int> bestHours;
  final List<int> bestDays;
  final double engagementScore;
  final String reasoning;
  final double confidence;
  final DateTime nextSuggestedContact;

  OptimalContactTime({
    required this.bestHours,
    required this.bestDays,
    required this.engagementScore,
    required this.reasoning,
    required this.confidence,
    required this.nextSuggestedContact,
  });
}

class ConversationStarter {
  final String text;
  final ConversationCategory category;
  final double confidence;
  final String reasoning;

  ConversationStarter({
    required this.text,
    required this.category,
    required this.confidence,
    required this.reasoning,
  });
}

class RelationshipForecast {
  final double currentHealth;
  final double projectedHealth;
  final RelationshipTrend trend;
  final double confidence;
  final List<String> milestones;
  final List<String> potentialIssues;
  final List<String> recommendations;
  final int forecastPeriod;

  RelationshipForecast({
    required this.currentHealth,
    required this.projectedHealth,
    required this.trend,
    required this.confidence,
    required this.milestones,
    required this.potentialIssues,
    required this.recommendations,
    required this.forecastPeriod,
  });
}

class ResponseData {
  final int hour;
  int theirInitiations = 0;
  List<Duration> responseTime = [];

  ResponseData(this.hour);
}

// Enums
enum RelationshipTrajectory { improving, stable, declining }

enum RiskLevel { low, medium, high, critical }

enum WarningType {
  sentimentDecline,
  communicationDrop,
  responseDelay,
  initiationImbalance,
  general
}

enum WarningSeverity { low, medium, high, critical }

enum ConversationCategory {
  aiGenerated,
  reconnection,
  emotional,
  contextual,
  cultural
}

enum RelationshipTrend { improving, stable, declining }
