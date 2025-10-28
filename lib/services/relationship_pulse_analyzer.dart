import 'dart:math';
import 'package:flutter/material.dart';
import '../models/relationship_contact.dart';
import '../models/communication_entry.dart';

/// Advanced relationship analysis and health scoring system
/// Provides comprehensive insights into relationship quality and patterns
class RelationshipPulseAnalyzer {
  /// Calculate overall relationship health score (0-100)
  static RelationshipPulseScore calculatePulseScore(
    RelationshipContact contact,
    List<CommunicationEntry> entries,
  ) {
    if (entries.isEmpty) {
      return RelationshipPulseScore(
        overallScore: contact.relationshipStrength * 10,
        communicationFrequency: 0,
        emotionalConnection: contact.relationshipStrength * 10,
        conflictResolution: 50, // neutral baseline
        growthTrend: 0,
        recommendations: [
          'Start logging conversations to get personalized insights',
          'Regular communication is key to maintaining relationships',
        ],
      );
    }

    final recentEntries = _getRecentEntries(entries, 30); // Last 30 days
    final olderEntries = _getOlderEntries(entries, 30, 60); // 30-60 days ago

    final communicationScore = _calculateCommunicationFrequency(recentEntries);
    final emotionalScore = _calculateEmotionalConnection(recentEntries);
    final conflictScore = _calculateConflictResolution(recentEntries);
    final trendScore = _calculateGrowthTrend(recentEntries, olderEntries);

    final overallScore =
        (communicationScore * 0.3 +
                emotionalScore * 0.3 +
                conflictScore * 0.2 +
                trendScore * 0.2)
            .clamp(0, 100);

    return RelationshipPulseScore(
      overallScore: overallScore.toDouble(),
      communicationFrequency: communicationScore,
      emotionalConnection: emotionalScore,
      conflictResolution: conflictScore,
      growthTrend: trendScore,
      recommendations: _generateRecommendations(
        contact,
        recentEntries,
        overallScore.toDouble(),
      ),
    );
  }

  /// Analyze communication patterns and interaction types
  static CommunicationPatternAnalysis analyzeCommunicationPatterns(
    List<CommunicationEntry> entries,
  ) {
    if (entries.isEmpty) {
      return CommunicationPatternAnalysis.empty();
    }

    final typeDistribution = <String, int>{};
    final qualityTrends = <DateTime, double>{};
    final emotionalTrends = <DateTime, double>{};
    final durationPatterns = <String, List<int>>{};

    for (final entry in entries) {
      // Type distribution
      typeDistribution[entry.conversationType] =
          (typeDistribution[entry.conversationType] ?? 0) + 1;

      // Quality and emotional trends
      qualityTrends[entry.conversationDate] = entry.overallQuality.toDouble();
      emotionalTrends[entry.conversationDate] = entry.emotionalState.toDouble();

      // Duration patterns by type
      durationPatterns[entry.conversationType] =
          (durationPatterns[entry.conversationType] ?? [])
            ..add(entry.conversationDuration);
    }

    final preferredMethod = _getMostPreferredCommunicationMethod(
      typeDistribution,
    );
    final avgQuality = qualityTrends.values.isEmpty
        ? 0.0
        : qualityTrends.values.reduce((a, b) => a + b) /
              qualityTrends.values.length;

    final recentTrend = _calculateRecentTrend(qualityTrends);

    return CommunicationPatternAnalysis(
      preferredCommunicationMethod: preferredMethod,
      averageConversationQuality: avgQuality,
      communicationTypeDistribution: typeDistribution,
      qualityTrend: recentTrend,
      averageDurationByType: _calculateAverageDurations(durationPatterns),
      peakCommunicationHours: _analyzePeakHours(entries),
      emotionalStateProgression: _analyzeEmotionalProgression(emotionalTrends),
    );
  }

  /// Generate personalized relationship insights
  static List<RelationshipInsight> generatePersonalizedInsights(
    RelationshipContact contact,
    List<CommunicationEntry> entries,
    RelationshipPulseScore pulseScore,
  ) {
    final insights = <RelationshipInsight>[];

    // Communication frequency insight
    if (pulseScore.communicationFrequency < 40) {
      insights.add(
        RelationshipInsight(
          type: InsightType.communicationFrequency,
          title: 'Increase Communication Frequency',
          description:
              'Regular communication helps maintain strong relationships. Try reaching out more often.',
          severity: InsightSeverity.medium,
          actionable: true,
          suggestedActions: [
            'Set a weekly reminder to check in',
            'Send a thoughtful message about their interests',
            'Schedule regular catch-up calls',
          ],
        ),
      );
    }

    // Emotional connection insight
    if (pulseScore.emotionalConnection < 50) {
      insights.add(
        RelationshipInsight(
          type: InsightType.emotionalConnection,
          title: 'Deepen Emotional Connection',
          description:
              'Focus on sharing more personal experiences and active listening.',
          severity: InsightSeverity.high,
          actionable: true,
          suggestedActions: [
            'Ask about their feelings and emotions',
            'Share your own vulnerable moments',
            'Practice active listening techniques',
          ],
        ),
      );
    }

    // Conflict resolution insight
    if (pulseScore.conflictResolution < 60) {
      insights.add(
        RelationshipInsight(
          type: InsightType.conflictResolution,
          title: 'Improve Conflict Resolution',
          description: 'Work on addressing disagreements constructively.',
          severity: InsightSeverity.high,
          actionable: true,
          suggestedActions: [
            'Address conflicts directly but kindly',
            'Focus on understanding their perspective',
            'Find common ground and compromise',
          ],
        ),
      );
    }

    // Positive reinforcement
    if (pulseScore.overallScore >= 80) {
      insights.add(
        RelationshipInsight(
          type: InsightType.positive,
          title: 'Relationship Thriving!',
          description:
              'Your relationship with ${contact.name} is in excellent health.',
          severity: InsightSeverity.low,
          actionable: false,
          suggestedActions: [
            'Continue your current communication patterns',
            'Celebrate the strong connection you\'ve built',
          ],
        ),
      );
    }

    return insights;
  }

  // Helper methods
  static List<CommunicationEntry> _getRecentEntries(
    List<CommunicationEntry> entries,
    int days,
  ) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return entries
        .where((entry) => entry.conversationDate.isAfter(cutoffDate))
        .toList();
  }

  static List<CommunicationEntry> _getOlderEntries(
    List<CommunicationEntry> entries,
    int startDays,
    int endDays,
  ) {
    final startDate = DateTime.now().subtract(Duration(days: startDays));
    final endDate = DateTime.now().subtract(Duration(days: endDays));
    return entries
        .where(
          (entry) =>
              entry.conversationDate.isBefore(startDate) &&
              entry.conversationDate.isAfter(endDate),
        )
        .toList();
  }

  static double _calculateCommunicationFrequency(
    List<CommunicationEntry> recentEntries,
  ) {
    if (recentEntries.isEmpty) return 0;

    final daysWithCommunication = recentEntries
        .map(
          (e) => DateTime(
            e.conversationDate.year,
            e.conversationDate.month,
            e.conversationDate.day,
          ),
        )
        .toSet()
        .length;

    final totalPossibleDays = min(
      30,
      DateTime.now()
              .difference(
                recentEntries
                    .map((e) => e.conversationDate)
                    .reduce((a, b) => a.isBefore(b) ? a : b),
              )
              .inDays +
          1,
    );

    return (daysWithCommunication / totalPossibleDays * 100).clamp(0, 100);
  }

  static double _calculateEmotionalConnection(
    List<CommunicationEntry> recentEntries,
  ) {
    if (recentEntries.isEmpty) return 0;

    final avgEmotionalState =
        recentEntries.map((e) => e.emotionalState).reduce((a, b) => a + b) /
        recentEntries.length;

    final avgQuality =
        recentEntries.map((e) => e.overallQuality).reduce((a, b) => a + b) /
        recentEntries.length;

    final specialMoments = recentEntries
        .where((e) => e.hadSpecialMoment)
        .length;
    final specialMomentBonus = (specialMoments / recentEntries.length) * 20;

    return ((avgEmotionalState + avgQuality) * 5 + specialMomentBonus).clamp(
      0,
      100,
    );
  }

  static double _calculateConflictResolution(
    List<CommunicationEntry> recentEntries,
  ) {
    if (recentEntries.isEmpty) return 50; // neutral baseline

    final conflicts = recentEntries.where((e) => e.hadConflict).length;
    final conflictRate = conflicts / recentEntries.length;

    // Lower conflict rate = better score
    return ((1 - conflictRate) * 100).clamp(0, 100);
  }

  static double _calculateGrowthTrend(
    List<CommunicationEntry> recentEntries,
    List<CommunicationEntry> olderEntries,
  ) {
    if (recentEntries.isEmpty && olderEntries.isEmpty) return 50;
    if (olderEntries.isEmpty) return 75; // Assume positive if no older data

    final recentAvgQuality = recentEntries.isEmpty
        ? 0
        : recentEntries.map((e) => e.overallQuality).reduce((a, b) => a + b) /
              recentEntries.length;

    final olderAvgQuality =
        olderEntries.map((e) => e.overallQuality).reduce((a, b) => a + b) /
        olderEntries.length;

    final improvement = (recentAvgQuality - olderAvgQuality) * 10;
    return (50 + improvement).clamp(0, 100);
  }

  static String _getMostPreferredCommunicationMethod(
    Map<String, int> typeDistribution,
  ) {
    if (typeDistribution.isEmpty) return 'in_person';

    return typeDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  static TrendDirection _calculateRecentTrend(
    Map<DateTime, double> qualityTrends,
  ) {
    if (qualityTrends.length < 2) return TrendDirection.stable;

    final sortedEntries = qualityTrends.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final recentHalf = sortedEntries.sublist(sortedEntries.length ~/ 2);
    final olderHalf = sortedEntries.sublist(0, sortedEntries.length ~/ 2);

    final recentAvg =
        recentHalf.map((e) => e.value).reduce((a, b) => a + b) /
        recentHalf.length;
    final olderAvg =
        olderHalf.map((e) => e.value).reduce((a, b) => a + b) /
        olderHalf.length;

    final difference = recentAvg - olderAvg;

    if (difference > 0.5) return TrendDirection.improving;
    if (difference < -0.5) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  static Map<String, double> _calculateAverageDurations(
    Map<String, List<int>> durationPatterns,
  ) {
    final result = <String, double>{};

    for (final entry in durationPatterns.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      result[entry.key] = avg;
    }

    return result;
  }

  static List<int> _analyzePeakHours(List<CommunicationEntry> entries) {
    final hourCounts = List.filled(24, 0);

    for (final entry in entries) {
      final hour = entry.conversationDate.hour;
      hourCounts[hour]++;
    }

    final maxCount = hourCounts.reduce(max);
    final peakHours = <int>[];

    for (int i = 0; i < 24; i++) {
      if (hourCounts[i] == maxCount) {
        peakHours.add(i);
      }
    }

    return peakHours;
  }

  static EmotionalProgression _analyzeEmotionalProgression(
    Map<DateTime, double> emotionalTrends,
  ) {
    if (emotionalTrends.length < 2) {
      return EmotionalProgression.stable;
    }

    final sortedEntries = emotionalTrends.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final first = sortedEntries.first.value;
    final last = sortedEntries.last.value;
    final difference = last - first;

    if (difference > 1.0) return EmotionalProgression.improving;
    if (difference < -1.0) return EmotionalProgression.declining;
    return EmotionalProgression.stable;
  }

  static List<String> _generateRecommendations(
    RelationshipContact contact,
    List<CommunicationEntry> entries,
    double overallScore,
  ) {
    final recommendations = <String>[];

    if (overallScore < 40) {
      recommendations.addAll([
        'Schedule regular check-ins with ${contact.name}',
        'Focus on deep, meaningful conversations',
        'Address any unresolved conflicts openly',
      ]);
    } else if (overallScore < 70) {
      recommendations.addAll([
        'Try new activities together to strengthen your bond',
        'Share more personal experiences and stories',
        'Celebrate positive moments in your relationship',
      ]);
    } else {
      recommendations.addAll([
        'Continue your excellent communication patterns',
        'Consider mentoring others about healthy relationships',
        'Maintain the strong foundation you\'ve built',
      ]);
    }

    // Relationship-specific recommendations
    switch (contact.relationship) {
      case 'romantic_partner':
        recommendations.add('Plan special dates and intimate conversations');
        break;
      case 'family':
        recommendations.add('Share family memories and create new traditions');
        break;
      case 'friend':
        recommendations.add('Engage in shared hobbies and interests');
        break;
    }

    return recommendations;
  }
}

// Data classes for relationship analysis
class RelationshipPulseScore {
  final double overallScore;
  final double communicationFrequency;
  final double emotionalConnection;
  final double conflictResolution;
  final double growthTrend;
  final List<String> recommendations;

  RelationshipPulseScore({
    required this.overallScore,
    required this.communicationFrequency,
    required this.emotionalConnection,
    required this.conflictResolution,
    required this.growthTrend,
    required this.recommendations,
  });

  String get healthCategory {
    if (overallScore >= 80) return 'Excellent';
    if (overallScore >= 60) return 'Good';
    if (overallScore >= 40) return 'Fair';
    return 'Needs Attention';
  }

  Color get categoryColor {
    if (overallScore >= 80) return const Color(0xFF4CAF50);
    if (overallScore >= 60) return const Color(0xFF8BC34A);
    if (overallScore >= 40) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}

class CommunicationPatternAnalysis {
  final String preferredCommunicationMethod;
  final double averageConversationQuality;
  final Map<String, int> communicationTypeDistribution;
  final TrendDirection qualityTrend;
  final Map<String, double> averageDurationByType;
  final List<int> peakCommunicationHours;
  final EmotionalProgression emotionalStateProgression;

  CommunicationPatternAnalysis({
    required this.preferredCommunicationMethod,
    required this.averageConversationQuality,
    required this.communicationTypeDistribution,
    required this.qualityTrend,
    required this.averageDurationByType,
    required this.peakCommunicationHours,
    required this.emotionalStateProgression,
  });

  static CommunicationPatternAnalysis empty() {
    return CommunicationPatternAnalysis(
      preferredCommunicationMethod: 'in_person',
      averageConversationQuality: 0,
      communicationTypeDistribution: {},
      qualityTrend: TrendDirection.stable,
      averageDurationByType: {},
      peakCommunicationHours: [],
      emotionalStateProgression: EmotionalProgression.stable,
    );
  }
}

class RelationshipInsight {
  final InsightType type;
  final String title;
  final String description;
  final InsightSeverity severity;
  final bool actionable;
  final List<String> suggestedActions;

  RelationshipInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    required this.actionable,
    required this.suggestedActions,
  });
}

enum InsightType {
  communicationFrequency,
  emotionalConnection,
  conflictResolution,
  positive,
  growth,
  warning,
}

enum InsightSeverity { low, medium, high }

enum TrendDirection { improving, stable, declining }

enum EmotionalProgression { improving, stable, declining }
