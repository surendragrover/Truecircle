import 'dart:math' as math;
import '../models/contact.dart';
import '../models/contact_interaction.dart';
import '../models/emotion_entry.dart';

/// 🚀 Future AI Possibilities Service
/// Advanced AI features for next-generation relationship management
/// Features: Video Call Analysis, Location-Based Insights, Group Dynamics, Mental Health Integration
class FutureAIService {
  /// 📹 Video Call Analysis - Facial expressions से relationship health
  static VideoCallAnalysis analyzeVideoCallHealth(
    Contact contact,
    List<VideoCallSession> sessions,
  ) {
    if (sessions.isEmpty) {
      return VideoCallAnalysis(
        contact: contact,
        overallHealthScore: 0.5,
        emotionalTrends: [],
        insights: ['No video call data available for analysis'],
        recommendations: [
          'Start video calls to enable facial expression analysis'
        ],
      );
    }

    final recentSessions = sessions
        .where((s) =>
            s.date.isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .toList();

    double healthScore = 0.0;
    final emotionalTrends = <EmotionalTrend>[];
    final insights = <String>[];
    final recommendations = <String>[];

    // Analyze facial expression patterns
    for (final session in recentSessions) {
      final avgHappiness = session.facialExpressions
              .where((e) => e.emotion == 'happiness')
              .map((e) => e.confidence)
              .fold(0.0, (a, b) => a + b) /
          session.facialExpressions.length;

      final avgEngagement = session.facialExpressions
              .where((e) => e.emotion == 'interest' || e.emotion == 'attention')
              .map((e) => e.confidence)
              .fold(0.0, (a, b) => a + b) /
          session.facialExpressions.length;

      healthScore += (avgHappiness + avgEngagement) / 2;

      emotionalTrends.add(EmotionalTrend(
        date: session.date,
        happiness: avgHappiness,
        engagement: avgEngagement,
        overallPositivity: (avgHappiness + avgEngagement) / 2,
      ));
    }

    healthScore = healthScore / recentSessions.length;

    // Generate insights based on analysis
    if (healthScore > 0.8) {
      insights.add(
          '${contact.displayName} के साथ video calls में बहुत positive energy है!');
      insights.add('Facial expressions show high engagement and happiness');
    } else if (healthScore > 0.6) {
      insights.add(
          '${contact.displayName} के साथ video calls में moderate engagement है');
      insights.add('कुछ moments में distraction या tiredness दिख रही है');
    } else {
      insights.add(
          '${contact.displayName} के साथ video calls में low engagement दिख रही है');
      insights.add(
          'Possible signs of relationship strain या communication barriers');
    }

    // Generate recommendations
    if (healthScore < 0.6) {
      recommendations.add('Try shorter video calls to improve engagement');
      recommendations.add('Schedule calls when both are free and relaxed');
      recommendations
          .add('Consider if there are underlying relationship issues');
    } else {
      recommendations
          .add('Continue regular video calls - relationship is healthy!');
      recommendations.add('Share fun activities during video calls');
    }

    return VideoCallAnalysis(
      contact: contact,
      overallHealthScore: healthScore,
      emotionalTrends: emotionalTrends,
      insights: insights,
      recommendations: recommendations,
    );
  }

  /// 📍 Location-Based Insights - कहाँ मिलते हैं, frequency क्या है
  static LocationInsights analyzeLocationPatterns(
    Contact contact,
    List<LocationMeeting> meetings,
  ) {
    if (meetings.isEmpty) {
      return LocationInsights(
        contact: contact,
        frequentLocations: [],
        meetingPatterns: {},
        insights: ['No location data available'],
        suggestions: ['Enable location sharing to get location-based insights'],
      );
    }

    final frequentLocations = <FrequentLocation>[];
    final meetingPatterns = <String, MeetingPattern>{};
    final insights = <String>[];
    final suggestions = <String>[];

    // Group meetings by location
    final locationGroups = <String, List<LocationMeeting>>{};
    for (final meeting in meetings) {
      final locationKey = meeting.location.name;
      locationGroups[locationKey] = locationGroups[locationKey] ?? [];
      locationGroups[locationKey]!.add(meeting);
    }

    // Analyze frequent locations
    for (final entry in locationGroups.entries) {
      final location = entry.key;
      final meetingsAtLocation = entry.value;

      if (meetingsAtLocation.length >= 3) {
        final avgDuration = meetingsAtLocation
                .map((m) => m.duration.inMinutes)
                .reduce((a, b) => a + b) /
            meetingsAtLocation.length;

        frequentLocations.add(FrequentLocation(
          name: location,
          visitCount: meetingsAtLocation.length,
          averageDuration: Duration(minutes: avgDuration.round()),
          lastVisit: meetingsAtLocation
              .map((m) => m.date)
              .reduce((a, b) => a.isAfter(b) ? a : b),
          meetingQuality: _analyzeMeetingQuality(meetingsAtLocation),
        ));
      }
    }

    // Analyze meeting patterns
    final homeVsOutside = _analyzeHomeVsOutsideMeetings(meetings);
    meetingPatterns['home_vs_outside'] = homeVsOutside;

    final timePatterns = _analyzeTimePatterns(meetings);
    meetingPatterns['time_preferences'] = timePatterns;

    // Generate insights
    if (frequentLocations.isNotEmpty) {
      final topLocation = frequentLocations.first;
      insights.add(
          '${contact.displayName} के साथ सबसे ज्यादा ${topLocation.name} में मिलते हैं');
      insights.add(
          'Average meeting duration: ${topLocation.averageDuration.inMinutes} minutes');
    }

    final homePercentage =
        (homeVsOutside.homeCount / meetings.length * 100).round();
    if (homePercentage > 60) {
      insights.add(
          '$homePercentage% meetings घर में होती हैं - very close relationship!');
    } else if (homePercentage > 30) {
      insights.add(
          '$homePercentage% meetings घर में होती हैं - good comfort level');
    } else {
      insights.add(
          'ज्यादातर meetings बाहर होती हैं - professional या casual relationship');
    }

    // Generate suggestions
    if (frequentLocations.length < 3) {
      suggestions.add('Try meeting at different locations to strengthen bond');
      suggestions.add('Explore new places together for fresh experiences');
    }

    if (homePercentage < 20) {
      suggestions.add(
          'Consider inviting ${contact.displayName} home for closer connection');
    }

    return LocationInsights(
      contact: contact,
      frequentLocations: frequentLocations,
      meetingPatterns: meetingPatterns,
      insights: insights,
      suggestions: suggestions,
    );
  }

  /// 👥 Group Dynamic Analysis - group conversations में dynamics
  static GroupDynamicAnalysis analyzeGroupDynamics(
    List<Contact> groupMembers,
    List<GroupConversation> conversations,
  ) {
    if (conversations.isEmpty) {
      return GroupDynamicAnalysis(
        groupMembers: groupMembers,
        dominancePatterns: {},
        interactionMatrix: {},
        groupHealth: 0.5,
        insights: ['No group conversation data available'],
        recommendations: ['Start group chats to enable group dynamic analysis'],
      );
    }

    final dominancePatterns = <String, DominanceMetrics>{};
    final interactionMatrix = <String, Map<String, int>>{};
    final insights = <String>[];
    final recommendations = <String>[];

    // Analyze message frequency and patterns for each member
    for (final member in groupMembers) {
      final memberMessages = conversations
          .expand((c) => c.messages)
          .where((m) => m.senderId == member.id)
          .toList();

      final totalMessages = memberMessages.length;
      final avgMessageLength = memberMessages.isEmpty
          ? 0.0
          : memberMessages
                  .map((m) => m.content.length)
                  .reduce((a, b) => a + b) /
              totalMessages;

      // Calculate response patterns
      final responseTimes = <Duration>[];
      for (int i = 1; i < conversations.length; i++) {
        final prev = conversations[i - 1];
        final current = conversations[i];
        if (current.messages.first.senderId == member.id) {
          responseTimes.add(current.startTime.difference(prev.endTime));
        }
      }

      final avgResponseTime = responseTimes.isEmpty
          ? Duration.zero
          : Duration(
              milliseconds: responseTimes
                      .map((d) => d.inMilliseconds)
                      .reduce((a, b) => a + b) ~/
                  responseTimes.length);

      dominancePatterns[member.id] = DominanceMetrics(
        messageCount: totalMessages,
        averageMessageLength: avgMessageLength,
        averageResponseTime: avgResponseTime,
        initiationCount:
            _countConversationInitiations(member.id, conversations),
        dominanceScore: _calculateDominanceScore(
            totalMessages, avgMessageLength, responseTimes.length),
      );

      // Build interaction matrix
      interactionMatrix[member.id] = {};
      for (final otherMember in groupMembers) {
        if (member.id != otherMember.id) {
          interactionMatrix[member.id]![otherMember.id] =
              _countDirectInteractions(
                  member.id, otherMember.id, conversations);
        }
      }
    }

    // Calculate group health score
    final totalMessages = dominancePatterns.values
        .map((d) => d.messageCount)
        .reduce((a, b) => a + b);
    final participationBalance =
        _calculateParticipationBalance(dominancePatterns, totalMessages);
    final responseBalance = _calculateResponseBalance(dominancePatterns);
    final groupHealth = (participationBalance + responseBalance) / 2;

    // Generate insights
    final mostActive = dominancePatterns.entries.reduce(
        (a, b) => a.value.dominanceScore > b.value.dominanceScore ? a : b);
    final leastActive = dominancePatterns.entries.reduce(
        (a, b) => a.value.dominanceScore < b.value.dominanceScore ? a : b);

    final mostActiveName =
        groupMembers.firstWhere((c) => c.id == mostActive.key).displayName;
    final leastActiveName =
        groupMembers.firstWhere((c) => c.id == leastActive.key).displayName;

    insights.add('Group में सबसे active: $mostActiveName');
    insights.add('सबसे कम active: $leastActiveName');

    if (groupHealth > 0.8) {
      insights.add(
          'Group dynamics बहुत healthy हैं - सभी equally participate करते हैं');
    } else if (groupHealth > 0.6) {
      insights.add('Group dynamics अच्छी हैं, लेकिन कुछ members कम active हैं');
    } else {
      insights.add(
          'Group dynamics में imbalance है - कुछ members dominate करते हैं');
    }

    // Generate recommendations
    if (groupHealth < 0.6) {
      recommendations.add('Encourage quiet members to participate more');
      recommendations.add('Try group activities that involve everyone equally');
      recommendations.add('Set up smaller sub-group conversations');
    }

    if (mostActive.value.dominanceScore > 0.8) {
      recommendations.add('$mostActiveName को थोड़ा कम dominate करने को कहें');
    }

    if (leastActive.value.dominanceScore < 0.2) {
      recommendations.add(
          '$leastActiveName को personally encourage करें participate करने के लिए');
    }

    return GroupDynamicAnalysis(
      groupMembers: groupMembers,
      dominancePatterns: dominancePatterns,
      interactionMatrix: interactionMatrix,
      groupHealth: groupHealth,
      insights: insights,
      recommendations: recommendations,
    );
  }

  /// 🧠 Mental Health Integration - relationships का mood पर impact
  static MentalHealthImpactAnalysis analyzeMentalHealthImpact(
    List<Contact> contacts,
    List<ContactInteraction> interactions,
    List<EmotionEntry> moodEntries,
  ) {
    final insights = <String>[];
    final recommendations = <String>[];
    final contactImpacts = <ContactMentalImpact>[];
    final moodTriggers = <MoodTrigger>[];

    // Analyze correlation between interactions and mood changes
    for (final contact in contacts) {
      final contactInteractions =
          interactions.where((i) => i.contactId == contact.id).toList();

      if (contactInteractions.isEmpty) continue;

      double totalMoodChange = 0.0;
      int moodChangesCount = 0;

      for (final interaction in contactInteractions) {
        // Find mood entries within 2 hours of interaction
        final moodBefore = moodEntries
            .where((m) =>
                m.timestamp.isBefore(interaction.timestamp) &&
                interaction.timestamp.difference(m.timestamp).inHours <= 2)
            .lastOrNull;

        final moodAfter = moodEntries
            .where((m) =>
                m.timestamp.isAfter(interaction.timestamp) &&
                m.timestamp.difference(interaction.timestamp).inHours <= 2)
            .firstOrNull;

        if (moodBefore != null && moodAfter != null) {
          final moodChange =
              (moodAfter.intensity - moodBefore.intensity).toDouble();
          totalMoodChange += moodChange;
          moodChangesCount++;

          // Track significant mood changes
          if (moodChange.abs() >= 2) {
            moodTriggers.add(MoodTrigger(
              contact: contact,
              interaction: interaction,
              moodBefore: moodBefore,
              moodAfter: moodAfter,
              impactScore: moodChange,
            ));
          }
        }
      }

      if (moodChangesCount > 0) {
        final avgMoodImpact = totalMoodChange / moodChangesCount;
        contactImpacts.add(ContactMentalImpact(
          contact: contact,
          averageMoodImpact: avgMoodImpact,
          interactionCount: moodChangesCount,
          impactCategory: _categorizeMoodImpact(avgMoodImpact),
        ));
      }
    }

    // Sort contacts by impact
    contactImpacts
        .sort((a, b) => b.averageMoodImpact.compareTo(a.averageMoodImpact));

    // Generate insights
    if (contactImpacts.isNotEmpty) {
      final mostPositive = contactImpacts.first;
      final mostNegative = contactImpacts.last;

      if (mostPositive.averageMoodImpact > 1.0) {
        insights.add(
            '${mostPositive.contact.displayName} के साथ बात करने से mood सबसे ज्यादा अच्छा होता है! 😊');
      }

      if (mostNegative.averageMoodImpact < -1.0) {
        insights.add(
            '${mostNegative.contact.displayName} के साथ interaction के बाद mood खराब होता है 😔');
      }

      final positiveContacts =
          contactImpacts.where((c) => c.averageMoodImpact > 0.5).length;
      final negativeContacts =
          contactImpacts.where((c) => c.averageMoodImpact < -0.5).length;

      insights.add('$positiveContacts contacts आपका mood अच्छा करते हैं');
      insights.add('$negativeContacts contacts के साथ सावधानी बरतें');
    }

    // Analyze mood patterns
    final moodPatternInsights = _analyzeMoodPatterns(moodEntries, interactions);
    insights.addAll(moodPatternInsights);

    // Generate recommendations
    if (contactImpacts.any((c) => c.averageMoodImpact > 1.0)) {
      final positiveContacts = contactImpacts
          .where((c) => c.averageMoodImpact > 1.0)
          .map((c) => c.contact.displayName)
          .take(3)
          .join(', ');
      recommendations.add('जब mood down हो, तो $positiveContacts से बात करें');
    }

    if (contactImpacts.any((c) => c.averageMoodImpact < -0.5)) {
      recommendations
          .add('Negative impact वाले contacts के साथ interaction limit करें');
      recommendations
          .add('या फिर conversation style change करने की कोशिश करें');
    }

    recommendations
        .add('Regular mood tracking continue करें better insights के लिए');
    recommendations
        .add('Mental health professional से भी consult करें if needed');

    return MentalHealthImpactAnalysis(
      contactImpacts: contactImpacts,
      moodTriggers: moodTriggers,
      insights: insights,
      recommendations: recommendations,
      overallMentalHealthScore:
          _calculateOverallMentalHealthScore(contactImpacts, moodEntries),
    );
  }

  // Private Helper Methods

  static double _analyzeMeetingQuality(List<LocationMeeting> meetings) {
    // Simulate meeting quality based on duration and frequency
    final avgDuration =
        meetings.map((m) => m.duration.inMinutes).reduce((a, b) => a + b) /
            meetings.length;

    return math.min(1.0, avgDuration / 120.0); // 2 hours = perfect quality
  }

  static MeetingPattern _analyzeHomeVsOutsideMeetings(
      List<LocationMeeting> meetings) {
    final homeCount = meetings.where((m) => m.location.isHome).length;
    final outsideCount = meetings.length - homeCount;

    return MeetingPattern(
      homeCount: homeCount,
      outsideCount: outsideCount,
      preference: homeCount > outsideCount ? 'home' : 'outside',
    );
  }

  static MeetingPattern _analyzeTimePatterns(List<LocationMeeting> meetings) {
    final morningCount = meetings.where((m) => m.date.hour < 12).length;
    final afternoonCount =
        meetings.where((m) => m.date.hour >= 12 && m.date.hour < 17).length;
    final eveningCount = meetings.where((m) => m.date.hour >= 17).length;

    String preference = 'morning';
    int maxCount = morningCount;

    if (afternoonCount > maxCount) {
      preference = 'afternoon';
      maxCount = afternoonCount;
    }

    if (eveningCount > maxCount) {
      preference = 'evening';
    }

    return MeetingPattern(
      homeCount: morningCount,
      outsideCount: afternoonCount + eveningCount,
      preference: preference,
    );
  }

  static int _countConversationInitiations(
      String memberId, List<GroupConversation> conversations) {
    return conversations
        .where((c) => c.messages.first.senderId == memberId)
        .length;
  }

  static double _calculateDominanceScore(
      int messageCount, double avgLength, int responseCount) {
    final messageScore = messageCount / 100.0; // Normalize
    final lengthScore = math.min(1.0, avgLength / 200.0); // 200 chars = max
    final responseScore = responseCount / 50.0; // Normalize

    return math.min(1.0, (messageScore + lengthScore + responseScore) / 3);
  }

  static int _countDirectInteractions(
      String member1, String member2, List<GroupConversation> conversations) {
    int count = 0;
    for (final conversation in conversations) {
      final messages = conversation.messages;
      for (int i = 1; i < messages.length; i++) {
        if ((messages[i - 1].senderId == member1 &&
                messages[i].senderId == member2) ||
            (messages[i - 1].senderId == member2 &&
                messages[i].senderId == member1)) {
          count++;
        }
      }
    }
    return count;
  }

  static double _calculateParticipationBalance(
      Map<String, DominanceMetrics> patterns, int totalMessages) {
    if (patterns.isEmpty) return 0.0;

    final idealShare = 1.0 / patterns.length;
    double totalDeviation = 0.0;

    for (final metrics in patterns.values) {
      final actualShare = metrics.messageCount / totalMessages;
      totalDeviation += (actualShare - idealShare).abs();
    }

    return math.max(0.0, 1.0 - totalDeviation);
  }

  static double _calculateResponseBalance(
      Map<String, DominanceMetrics> patterns) {
    if (patterns.isEmpty) return 0.0;

    final responseTimes = patterns.values
        .map((p) => p.averageResponseTime.inMinutes)
        .where((t) => t > 0)
        .toList();

    if (responseTimes.isEmpty) return 0.5;

    final avgResponseTime =
        responseTimes.reduce((a, b) => a + b) / responseTimes.length;
    final variance = responseTimes
            .map((t) => math.pow(t - avgResponseTime, 2))
            .reduce((a, b) => a + b) /
        responseTimes.length;

    return math.max(0.0, 1.0 - math.sqrt(variance) / avgResponseTime);
  }

  static MoodImpactCategory _categorizeMoodImpact(double impact) {
    if (impact >= 2.0) return MoodImpactCategory.veryPositive;
    if (impact >= 1.0) return MoodImpactCategory.positive;
    if (impact >= -1.0) return MoodImpactCategory.neutral;
    if (impact >= -2.0) return MoodImpactCategory.negative;
    return MoodImpactCategory.veryNegative;
  }

  static List<String> _analyzeMoodPatterns(
      List<EmotionEntry> moodEntries, List<ContactInteraction> interactions) {
    final insights = <String>[];

    if (moodEntries.length < 7) {
      insights.add('More mood data needed for pattern analysis');
      return insights;
    }

    // Analyze weekly mood trends
    final recentMoods = moodEntries
        .where((m) => m.timestamp
            .isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();

    if (recentMoods.isNotEmpty) {
      final avgMood =
          recentMoods.map((m) => m.intensity).reduce((a, b) => a + b) /
              recentMoods.length;

      if (avgMood >= 4.0) {
        insights.add('इस हफ्ते आपका overall mood बहुत अच्छा रहा! 😊');
      } else if (avgMood >= 3.0) {
        insights.add('इस हफ्ते आपका mood ठीक-ठाक रहा');
      } else {
        insights.add('इस हफ्ते mood कुछ low रहा - self-care की जरूरत है');
      }
    }

    // Analyze interaction-mood correlation
    final interactionDays = interactions
        .where((i) => i.timestamp
            .isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .length;

    if (interactionDays > 0 && recentMoods.isNotEmpty) {
      final avgMood =
          recentMoods.map((m) => m.intensity).reduce((a, b) => a + b) /
              recentMoods.length;

      if (interactionDays >= 5 && avgMood >= 3.5) {
        insights
            .add('Regular social interaction आपके mood को positive रखता है!');
      } else if (interactionDays < 3 && avgMood < 3.0) {
        insights.add('कम social interaction के कारण mood down हो सकता है');
      }
    }

    return insights;
  }

  static double _calculateOverallMentalHealthScore(
      List<ContactMentalImpact> impacts, List<EmotionEntry> moods) {
    if (impacts.isEmpty || moods.isEmpty) return 0.5;

    // Calculate based on positive vs negative contacts and recent mood trend
    final positiveContacts =
        impacts.where((i) => i.averageMoodImpact > 0).length;
    final totalContacts = impacts.length;
    final positiveRatio = positiveContacts / totalContacts;

    final recentMoods = moods
        .where((m) => m.timestamp
            .isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();

    double recentMoodAvg = 0.5;
    if (recentMoods.isNotEmpty) {
      recentMoodAvg =
          recentMoods.map((m) => m.intensity / 5.0).reduce((a, b) => a + b) /
              recentMoods.length;
    }

    return (positiveRatio + recentMoodAvg) / 2;
  }
}

// Data Models for Future AI

class VideoCallAnalysis {
  final Contact contact;
  final double overallHealthScore;
  final List<EmotionalTrend> emotionalTrends;
  final List<String> insights;
  final List<String> recommendations;

  VideoCallAnalysis({
    required this.contact,
    required this.overallHealthScore,
    required this.emotionalTrends,
    required this.insights,
    required this.recommendations,
  });
}

class VideoCallSession {
  final DateTime date;
  final Duration duration;
  final List<FacialExpression> facialExpressions;
  final double averageEngagement;

  VideoCallSession({
    required this.date,
    required this.duration,
    required this.facialExpressions,
    required this.averageEngagement,
  });
}

class FacialExpression {
  final String emotion;
  final double confidence;
  final DateTime timestamp;

  FacialExpression({
    required this.emotion,
    required this.confidence,
    required this.timestamp,
  });
}

class EmotionalTrend {
  final DateTime date;
  final double happiness;
  final double engagement;
  final double overallPositivity;

  EmotionalTrend({
    required this.date,
    required this.happiness,
    required this.engagement,
    required this.overallPositivity,
  });
}

class LocationInsights {
  final Contact contact;
  final List<FrequentLocation> frequentLocations;
  final Map<String, MeetingPattern> meetingPatterns;
  final List<String> insights;
  final List<String> suggestions;

  LocationInsights({
    required this.contact,
    required this.frequentLocations,
    required this.meetingPatterns,
    required this.insights,
    required this.suggestions,
  });
}

class LocationMeeting {
  final DateTime date;
  final Duration duration;
  final MeetingLocation location;

  LocationMeeting({
    required this.date,
    required this.duration,
    required this.location,
  });
}

class MeetingLocation {
  final String name;
  final double latitude;
  final double longitude;
  final bool isHome;

  MeetingLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.isHome,
  });
}

class FrequentLocation {
  final String name;
  final int visitCount;
  final Duration averageDuration;
  final DateTime lastVisit;
  final double meetingQuality;

  FrequentLocation({
    required this.name,
    required this.visitCount,
    required this.averageDuration,
    required this.lastVisit,
    required this.meetingQuality,
  });
}

class MeetingPattern {
  final int homeCount;
  final int outsideCount;
  final String preference;

  MeetingPattern({
    required this.homeCount,
    required this.outsideCount,
    required this.preference,
  });
}

class GroupDynamicAnalysis {
  final List<Contact> groupMembers;
  final Map<String, DominanceMetrics> dominancePatterns;
  final Map<String, Map<String, int>> interactionMatrix;
  final double groupHealth;
  final List<String> insights;
  final List<String> recommendations;

  GroupDynamicAnalysis({
    required this.groupMembers,
    required this.dominancePatterns,
    required this.interactionMatrix,
    required this.groupHealth,
    required this.insights,
    required this.recommendations,
  });
}

class GroupConversation {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final List<GroupMessage> messages;

  GroupConversation({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.messages,
  });
}

class GroupMessage {
  final String senderId;
  final String content;
  final DateTime timestamp;

  GroupMessage({
    required this.senderId,
    required this.content,
    required this.timestamp,
  });
}

class DominanceMetrics {
  final int messageCount;
  final double averageMessageLength;
  final Duration averageResponseTime;
  final int initiationCount;
  final double dominanceScore;

  DominanceMetrics({
    required this.messageCount,
    required this.averageMessageLength,
    required this.averageResponseTime,
    required this.initiationCount,
    required this.dominanceScore,
  });
}

class MentalHealthImpactAnalysis {
  final List<ContactMentalImpact> contactImpacts;
  final List<MoodTrigger> moodTriggers;
  final List<String> insights;
  final List<String> recommendations;
  final double overallMentalHealthScore;

  MentalHealthImpactAnalysis({
    required this.contactImpacts,
    required this.moodTriggers,
    required this.insights,
    required this.recommendations,
    required this.overallMentalHealthScore,
  });
}

class ContactMentalImpact {
  final Contact contact;
  final double averageMoodImpact;
  final int interactionCount;
  final MoodImpactCategory impactCategory;

  ContactMentalImpact({
    required this.contact,
    required this.averageMoodImpact,
    required this.interactionCount,
    required this.impactCategory,
  });
}

class MoodTrigger {
  final Contact contact;
  final ContactInteraction interaction;
  final EmotionEntry moodBefore;
  final EmotionEntry moodAfter;
  final double impactScore;

  MoodTrigger({
    required this.contact,
    required this.interaction,
    required this.moodBefore,
    required this.moodAfter,
    required this.impactScore,
  });
}

enum MoodImpactCategory {
  veryPositive,
  positive,
  neutral,
  negative,
  veryNegative,
}
