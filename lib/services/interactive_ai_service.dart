import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../models/contact_interaction.dart';
import '../models/emotion_entry.dart';
import 'cultural_regional_ai.dart';

/// 🎙️ Interactive AI Service - Voice commands, smart notifications, and mood-based suggestions
/// Provides natural language interaction with TrueCircle AI features
class InteractiveAIService {
  static final StreamController<AINotification> _notificationController =
      StreamController<AINotification>.broadcast();

  static Stream<AINotification> get notificationStream =>
      _notificationController.stream;

  /// 🎙️ Voice Command Processing
  static AIResponse processVoiceCommand(String command, List<Contact> contacts,
      List<ContactInteraction> interactions) {
    final cleanCommand = command.toLowerCase().trim();

    // Hindi voice commands support
    if (cleanCommand.contains('truecircle') ||
        cleanCommand.contains('ट्रू सर्कल')) {
      return _processMainCommand(cleanCommand, contacts, interactions);
    }

    // Direct commands without wake word
    if (cleanCommand.contains('suggest') || cleanCommand.contains('सुझाव')) {
      return _processSuggestionCommand(cleanCommand, contacts, interactions);
    }

    if (cleanCommand.contains('call') || cleanCommand.contains('कॉल')) {
      return _processCallSuggestion(cleanCommand, contacts, interactions);
    }

    if (cleanCommand.contains('message') || cleanCommand.contains('मैसेज')) {
      return _processMessageSuggestion(cleanCommand, contacts, interactions);
    }

    if (cleanCommand.contains('mood') || cleanCommand.contains('मूड')) {
      return _processMoodBasedSuggestion(cleanCommand, contacts, interactions);
    }

    if (cleanCommand.contains('status') || cleanCommand.contains('स्थिति')) {
      return _processStatusQuery(cleanCommand, contacts, interactions);
    }

    return AIResponse(
      type: AIResponseType.error,
      message:
          'माफ करें, मैं इस कमांड को समझ नहीं पाया। / Sorry, I didn\'t understand that command.',
      suggestions: [
        'Try: "TrueCircle, suggest someone to call today"',
        'या कहें: "आज किससे बात करूं?"',
        'या: "Show my relationship status"',
      ],
    );
  }

  /// 🧠 Smart Notification Generation
  static Future<List<AINotification>> generateSmartNotifications(
    List<Contact> contacts,
    List<ContactInteraction> interactions,
    List<EmotionEntry> moodEntries,
  ) async {
    final notifications = <AINotification>[];

    // Check for long-overdue contacts with emotional priority
    for (final contact in contacts) {
      final daysSince = contact.daysSinceLastContact;

      if (daysSince >= 14 &&
          contact.emotionalScore == EmotionalScore.veryWarm) {
        notifications.add(AINotification(
          id: 'overdue_${contact.id}',
          type: NotificationType.relationshipAlert,
          title: '${contact.displayName} के साथ बात नहीं हुई',
          message: '$daysSince days से संपर्क नहीं हुआ - एक quick call करें?',
          priority: NotificationPriority.high,
          actionable: true,
          contact: contact,
          suggestedActions: [
            'Quick Call करें',
            'WhatsApp Message भेजें',
            'Remind me later',
          ],
        ));
      }

      // Family members need extra attention (identify by name patterns or tags)
      if (daysSince >= 7 && _isFamilyContact(contact)) {
        notifications.add(AINotification(
          id: 'family_${contact.id}',
          type: NotificationType.relationshipAlert,
          title: 'Family Connection Alert',
          message:
              '${contact.displayName} (family) - $daysSince days since last contact',
          priority: NotificationPriority.medium,
          actionable: true,
          contact: contact,
          suggestedActions: [
            'Call now',
            'Send loving message',
            'Plan visit',
          ],
        ));
      }

      // Work contacts during weekdays (identify by communication patterns)
      final now = DateTime.now();
      if (now.weekday <= 5 && // Monday to Friday
          daysSince >= 10 &&
          _isWorkContact(contact)) {
        notifications.add(AINotification(
          id: 'work_${contact.id}',
          type: NotificationType.opportunity,
          title: 'Professional Network Maintenance',
          message:
              'Good time to reconnect with ${contact.displayName} (colleague)',
          priority: NotificationPriority.medium,
          actionable: true,
          contact: contact,
          suggestedActions: [
            'Send LinkedIn message',
            'Schedule coffee meet',
            'Share interesting article',
          ],
        ));
      }
    }

    // Festival and cultural reminders
    final festivalReminders =
        await CulturalRegionalAI.generateFestivalReminders(contacts);
    for (final reminder in festivalReminders.take(2)) {
      notifications.add(AINotification(
        id: 'festival_${reminder.festival.name}',
        type: NotificationType.culturalReminder,
        title: '${reminder.festival.hindiName} आ रहा है!',
        message:
            '${reminder.daysUntil} दिन बाकी - ${reminder.priorityContacts.length} लोगों को wishes भेजें',
        priority: reminder.daysUntil <= 3
            ? NotificationPriority.high
            : NotificationPriority.medium,
        actionable: true,
        data: {
          'festival': reminder.festival,
          'contacts': reminder.priorityContacts
        },
        suggestedActions: [
          'Send Festival Messages',
          'Create Group Message',
          'Set Reminder',
        ],
      ));
    }

    // Mood-based suggestions
    if (moodEntries.isNotEmpty) {
      final recentMood = moodEntries.first;
      final moodSuggestion =
          _generateMoodBasedNotification(recentMood, contacts);
      if (moodSuggestion != null) {
        notifications.add(moodSuggestion);
      }
    }

    // Relationship health alerts
    final healthAlerts = _generateHealthAlerts(contacts, interactions);
    notifications.addAll(healthAlerts);

    return notifications
      ..sort((a, b) => b.priority.index.compareTo(a.priority.index));
  }

  /// 🗺️ Visual Relationship Map Data
  static RelationshipMapData generateRelationshipMap(
      List<Contact> contacts, List<ContactInteraction> interactions) {
    final nodes = <RelationshipNode>[];
    final edges = <RelationshipEdge>[];

    // Create center node (user)
    nodes.add(RelationshipNode(
      id: 'user',
      displayName: 'मैं / Me',
      type: NodeType.user,
      size: 1.5,
      color: const Color(0xFF4285F4),
      position: RelationshipPosition(x: 0, y: 0),
    ));

    // Create contact nodes with AI-determined positioning
    final familyContacts = contacts
        .where((c) => c.tags.any((tag) => [
              'family',
              'परिवार',
              'parent',
              'sibling'
            ].contains(tag.toLowerCase())))
        .toList();
    final friendContacts = contacts
        .where((c) => c.tags.any((tag) => [
              'friend',
              'दोस्त',
              'buddy',
              'colleague'
            ].contains(tag.toLowerCase())))
        .toList();
    final workContacts = contacts
        .where((c) => c.tags.any((tag) => [
              'work',
              'काम',
              'office',
              'professional'
            ].contains(tag.toLowerCase())))
        .toList();

    // Position family contacts close to center
    _positionContactGroup(
        familyContacts, nodes, edges, NodeType.family, 2.0, 0.8);

    // Position friends in middle ring
    _positionContactGroup(
        friendContacts, nodes, edges, NodeType.friend, 4.0, 1.0);

    // Position work contacts in outer ring
    _positionContactGroup(workContacts, nodes, edges, NodeType.work, 6.0, 0.6);

    return RelationshipMapData(
      nodes: nodes,
      edges: edges,
      center: nodes.first,
      lastUpdated: DateTime.now(),
    );
  }

  /// 🎯 Mood-Based Contact Suggestions
  static MoodBasedSuggestion generateMoodBasedSuggestion(
    EmotionEntry currentMood,
    List<Contact> contacts,
    List<ContactInteraction> interactions,
  ) {
    final moodIntensity = currentMood.intensity;
    final emotion = currentMood.emotion.toLowerCase();

    List<Contact> suggestedContacts;
    String reasoning;

    if (emotion.contains('sad') ||
        emotion.contains('उदास') ||
        moodIntensity <= 2) {
      // Suggest close, comforting contacts
      suggestedContacts = contacts
          .where((c) =>
              c.emotionalScore == EmotionalScore.veryWarm &&
              c.tags.any((tag) => ['family', 'परिवार', 'close', 'best friend']
                  .contains(tag.toLowerCase())))
          .take(3)
          .toList();
      reasoning =
          'जब मन उदास हो, तो family और close friends से बात करने से मूड अच्छा होता है';
    } else if (emotion.contains('happy') ||
        emotion.contains('खुश') ||
        moodIntensity >= 4) {
      // Suggest people to share happiness with
      suggestedContacts = contacts
          .where((c) =>
              c.daysSinceLastContact >= 7 &&
              c.emotionalScore != EmotionalScore.cold)
          .take(4)
          .toList();
      reasoning =
          'खुशी बांटने से खुशी बढ़ती है! इन लोगों के साथ अपनी खुशी share करें';
    } else if (emotion.contains('stress') ||
        emotion.contains('तनाव') ||
        emotion.contains('angry')) {
      // Suggest calming influences
      suggestedContacts = contacts
          .where((c) =>
                  c.tags.any((tag) => ['calm', 'शांत', 'wise', 'mentor']
                      .contains(tag.toLowerCase())) ||
                  c.averageResponseTime <= 1.0 // Quick responders
              )
          .take(2)
          .toList();
      reasoning = 'तनाव में शांत और समझदार लोगों से बात करना फायदेमंद होता है';
    } else {
      // Default: suggest neglected but important contacts
      suggestedContacts = contacts
          .where((c) =>
              c.daysSinceLastContact >= 5 &&
              c.emotionalScore == EmotionalScore.friendlyButFading)
          .take(3)
          .toList();
      reasoning =
          'इन दोस्तों से कुछ दिनों से बात नहीं हुई - एक quick hello करें?';
    }

    return MoodBasedSuggestion(
      currentMood: currentMood,
      suggestedContacts: suggestedContacts,
      reasoning: reasoning,
      confidence:
          _calculateSuggestionConfidence(currentMood, suggestedContacts),
      actions: _generateMoodBasedActions(emotion, suggestedContacts),
    );
  }

  // Private Helper Methods

  static AIResponse _processMainCommand(String command, List<Contact> contacts,
      List<ContactInteraction> interactions) {
    if (command.contains('suggest') || command.contains('सुझाव')) {
      return _processSuggestionCommand(command, contacts, interactions);
    } else if (command.contains('status') || command.contains('स्थिति')) {
      return _processStatusQuery(command, contacts, interactions);
    } else if (command.contains('help') || command.contains('मदद')) {
      return AIResponse(
        type: AIResponseType.help,
        message: 'मैं आपकी relationship management में मदद कर सकता हूं!',
        suggestions: [
          '"किससे बात करूं?" - Contact suggestions',
          '"मेरा relationship status क्या है?" - Health overview',
          '"आज कौन सा festival है?" - Cultural reminders',
          '"Mood के according suggestion दो" - Mood-based advice',
        ],
      );
    }

    return AIResponse(
      type: AIResponseType.acknowledgment,
      message: 'हाँ, मैं सुन रहा हूँ। आपको क्या चाहिए?',
      suggestions: ['Suggest contacts', 'Show status', 'Help'],
    );
  }

  static AIResponse _processSuggestionCommand(String command,
      List<Contact> contacts, List<ContactInteraction> interactions) {
    final now = DateTime.now();
    final timeOfDay = now.hour;

    // Time-based suggestions
    List<Contact> suggested;
    String reasoning;

    if (timeOfDay >= 9 && timeOfDay <= 11) {
      // Morning: family check-ins
      suggested = contacts
          .where((c) =>
              c.tags.any(
                  (tag) => ['family', 'परिवार'].contains(tag.toLowerCase())) &&
              c.daysSinceLastContact >= 1)
          .take(3)
          .toList();
      reasoning = 'सुबह का समय family से बात करने के लिए perfect है';
    } else if (timeOfDay >= 12 && timeOfDay <= 17) {
      // Afternoon: work and friends
      suggested = contacts
          .where((c) =>
              c.daysSinceLastContact >= 3 &&
              c.emotionalScore != EmotionalScore.cold)
          .take(3)
          .toList();
      reasoning = 'दोपहर में friends और colleagues से quick catch-up करें';
    } else if (timeOfDay >= 18 && timeOfDay <= 21) {
      // Evening: close friends and family
      suggested = contacts
          .where((c) =>
              c.emotionalScore == EmotionalScore.veryWarm &&
              c.daysSinceLastContact >= 2)
          .take(3)
          .toList();
      reasoning = 'शाम का समय close people के साथ बिताने का है';
    } else {
      // Late night: only very close contacts
      suggested = contacts
          .where((c) =>
              c.tags.any((tag) => ['close', 'family', 'best friend']
                  .contains(tag.toLowerCase())) &&
              c.daysSinceLastContact >= 1)
          .take(2)
          .toList();
      reasoning = 'रात का समय है, सिर्फ very close लोगों से बात करें';
    }

    if (suggested.isEmpty) {
      return AIResponse(
        type: AIResponseType.information,
        message:
            'सभी important contacts से recent में बात हो चुकी है! आप great at staying connected हैं 👏',
        suggestions: ['Check festival reminders', 'Review relationship health'],
      );
    }

    return AIResponse(
      type: AIResponseType.suggestion,
      message: reasoning,
      suggestedContacts: suggested,
      suggestions: suggested.map((c) => 'Call ${c.displayName}').toList(),
    );
  }

  static AIResponse _processCallSuggestion(String command,
      List<Contact> contacts, List<ContactInteraction> interactions) {
    final priorityContacts = contacts
        .where((c) =>
            c.daysSinceLastContact >= 5 &&
            c.emotionalScore == EmotionalScore.veryWarm)
        .take(3)
        .toList();

    if (priorityContacts.isEmpty) {
      return AIResponse(
        type: AIResponseType.information,
        message: 'All your close contacts are up to date! 📞✅',
        suggestions: ['Explore new connections', 'Send thank you messages'],
      );
    }

    return AIResponse(
      type: AIResponseType.callSuggestion,
      message: 'ये लोग आपकी call का इंतज़ार कर रहे होंगे:',
      suggestedContacts: priorityContacts,
      suggestions: priorityContacts
          .map((c) =>
              'Call ${c.displayName} (${c.daysSinceLastContact} days ago)')
          .toList(),
    );
  }

  static AIResponse _processMessageSuggestion(String command,
      List<Contact> contacts, List<ContactInteraction> interactions) {
    final messageContacts = contacts
        .where(
            (c) => c.daysSinceLastContact >= 2 && c.daysSinceLastContact <= 10)
        .take(4)
        .toList();

    return AIResponse(
      type: AIResponseType.messageSuggestion,
      message: 'इन लोगों को quick message भेज सकते हैं:',
      suggestedContacts: messageContacts,
      suggestions: messageContacts
          .map(
              (c) => 'Message ${c.displayName} - "${_generateQuickMessage(c)}"')
          .toList(),
    );
  }

  static AIResponse _processMoodBasedSuggestion(String command,
      List<Contact> contacts, List<ContactInteraction> interactions) {
    // This would integrate with current mood - for now, returning general mood advice
    return AIResponse(
      type: AIResponseType.moodSuggestion,
      message: 'आपका mood के according suggestions:',
      suggestions: [
        'Happy mood: Share good news with friends',
        'Sad mood: Call family for comfort',
        'Excited mood: Plan something with close friends',
        'Calm mood: Have deep conversations',
      ],
    );
  }

  static AIResponse _processStatusQuery(String command, List<Contact> contacts,
      List<ContactInteraction> interactions) {
    final totalContacts = contacts.length;
    final recentlyContacted =
        contacts.where((c) => c.daysSinceLastContact <= 7).length;
    final overdueContacts =
        contacts.where((c) => c.daysSinceLastContact > 14).length;
    final healthyRelationships = contacts
        .where((c) => c.emotionalScore == EmotionalScore.veryWarm)
        .length;

    return AIResponse(
      type: AIResponseType.status,
      message: '''रिश्तों का Status Report 📊:
      
• कुल Contacts: $totalContacts
• Recent में contact: $recentlyContacted (इस हफ्ते)
• Overdue contacts: $overdueContacts (2+ weeks)
• Healthy relationships: $healthyRelationships
• Overall health: ${_calculateOverallHealth(contacts)}''',
      suggestions: [
        if (overdueContacts > 0) 'Focus on $overdueContacts overdue contacts',
        'Schedule regular check-ins',
        'Plan upcoming festivals',
      ],
    );
  }

  static void _positionContactGroup(
    List<Contact> contacts,
    List<RelationshipNode> nodes,
    List<RelationshipEdge> edges,
    NodeType type,
    double radius,
    double connectionStrength,
  ) {
    for (int i = 0; i < contacts.length; i++) {
      final contact = contacts[i];
      final angle = (i * 2 * math.pi) / contacts.length;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);

      final node = RelationshipNode(
        id: contact.id,
        displayName: contact.displayName,
        type: type,
        size: _calculateNodeSize(contact),
        color: _getNodeColor(type, contact.emotionalScore),
        position: RelationshipPosition(x: x, y: y),
      );

      nodes.add(node);

      // Create edge to center (user)
      edges.add(RelationshipEdge(
        from: 'user',
        to: contact.id,
        strength: connectionStrength * _calculateConnectionStrength(contact),
        type: edgeTypeFromNodeType(type),
      ));
    }
  }

  static double _calculateNodeSize(Contact contact) {
    switch (contact.emotionalScore) {
      case EmotionalScore.veryWarm:
        return 1.2;
      case EmotionalScore.friendlyButFading:
        return 1.0;
      case EmotionalScore.cold:
        return 0.8;
    }
  }

  static Color _getNodeColor(NodeType type, EmotionalScore score) {
    final baseColors = {
      NodeType.family: const Color(0xFFE53935),
      NodeType.friend: const Color(0xFF43A047),
      NodeType.work: const Color(0xFF1E88E5),
      NodeType.user: const Color(0xFF4285F4),
    };

    final baseColor = baseColors[type]!;

    switch (score) {
      case EmotionalScore.veryWarm:
        return baseColor;
      case EmotionalScore.friendlyButFading:
        return baseColor.withValues(alpha: 0.3);
      case EmotionalScore.cold:
        return baseColor.withValues(alpha: 0.3);
    }
  }

  static double _calculateConnectionStrength(Contact contact) {
    final daysFactor = math.max(0, 1 - (contact.daysSinceLastContact / 30));
    final emotionFactor =
        contact.emotionalScore == EmotionalScore.veryWarm ? 1.0 : 0.5;
    return daysFactor * emotionFactor;
  }

  static AINotification? _generateMoodBasedNotification(
      EmotionEntry mood, List<Contact> contacts) {
    if (mood.intensity <= 2) {
      final comfortContacts = contacts
          .where((c) =>
              c.emotionalScore == EmotionalScore.veryWarm &&
              c.tags.any((tag) =>
                  ['family', 'परिवार', 'close'].contains(tag.toLowerCase())))
          .take(2)
          .toList();

      if (comfortContacts.isNotEmpty) {
        return AINotification(
          id: 'mood_comfort',
          type: NotificationType.moodSuggestion,
          title: 'मूड low लग रहा है',
          message: 'इन special लोगों से बात करके mood बेहतर करें',
          priority: NotificationPriority.medium,
          actionable: true,
          data: {'contacts': comfortContacts},
          suggestedActions:
              comfortContacts.map((c) => 'Call ${c.displayName}').toList(),
        );
      }
    }
    return null;
  }

  static List<AINotification> _generateHealthAlerts(
      List<Contact> contacts, List<ContactInteraction> interactions) {
    final alerts = <AINotification>[];

    final fadingRelationships = contacts
        .where((c) =>
            c.emotionalScore == EmotionalScore.friendlyButFading &&
            c.daysSinceLastContact > 21)
        .toList();

    if (fadingRelationships.isNotEmpty) {
      alerts.add(AINotification(
        id: 'health_fading',
        type: NotificationType.relationshipAlert,
        title: 'रिश्ते fade हो रहे हैं',
        message: '${fadingRelationships.length} relationships need attention',
        priority: NotificationPriority.medium,
        actionable: true,
        data: {'contacts': fadingRelationships},
        suggestedActions: ['Show details', 'Quick reconnect'],
      ));
    }

    return alerts;
  }

  static double _calculateSuggestionConfidence(
      EmotionEntry mood, List<Contact> contacts) {
    if (contacts.isEmpty) return 0.0;

    final relevantContacts =
        contacts.where((c) => c.emotionalScore != EmotionalScore.cold).length;

    return math.min(1.0, relevantContacts / contacts.length + 0.3);
  }

  static List<String> _generateMoodBasedActions(
      String emotion, List<Contact> contacts) {
    if (emotion.contains('happy') || emotion.contains('खुश')) {
      return ['Share good news', 'Plan celebration', 'Express gratitude'];
    } else if (emotion.contains('sad') || emotion.contains('उदास')) {
      return ['Seek comfort', 'Share feelings', 'Ask for support'];
    } else {
      return ['Casual chat', 'Quick check-in', 'Share updates'];
    }
  }

  static String _generateQuickMessage(Contact contact) {
    final templates = [
      'Hey! कैसे हो? Long time!',
      'Hi ${contact.displayName}! आजकल क्या हाल है?',
      'Hope you\'re doing well! मिलना हो तो बताना',
      'Thinking of you! सब ठीक तो है ना?',
    ];
    return templates[math.Random().nextInt(templates.length)];
  }

  static String _calculateOverallHealth(List<Contact> contacts) {
    if (contacts.isEmpty) return 'N/A';

    final warmRelationships = contacts
        .where((c) => c.emotionalScore == EmotionalScore.veryWarm)
        .length;
    final healthPercentage =
        (warmRelationships / contacts.length * 100).round();

    if (healthPercentage >= 70) return 'Excellent ($healthPercentage%)';
    if (healthPercentage >= 50) return 'Good ($healthPercentage%)';
    if (healthPercentage >= 30) return 'Needs Attention ($healthPercentage%)';
    return 'Critical ($healthPercentage%)';
  }

  /// Helper methods for contact categorization
  static bool _isFamilyContact(Contact contact) {
    final name = contact.displayName.toLowerCase();
    final familyKeywords = [
      'mom',
      'dad',
      'mama',
      'papa',
      'mummy',
      'daddy',
      'maa',
      'baba',
      'beta',
      'beta',
      'bhai',
      'behen',
      'sister',
      'brother',
      'uncle',
      'aunt',
      'chacha',
      'chachi',
      'mama',
      'mami',
      'dada',
      'dadi',
      'nana',
      'nani'
    ];

    for (final keyword in familyKeywords) {
      if (name.contains(keyword)) return true;
    }

    // High emotional score and frequent contact might indicate family
    return contact.emotionalScore == EmotionalScore.veryWarm &&
        contact.totalCalls > 20;
  }

  static bool _isWorkContact(Contact contact) {
    final name = contact.displayName.toLowerCase();
    final workKeywords = [
      'sir',
      'madam',
      'manager',
      'boss',
      'colleague',
      'office',
      'work',
      'team',
      'lead',
      'hr',
      'admin'
    ];

    for (final keyword in workKeywords) {
      if (name.contains(keyword)) return true;
    }

    // Business hours communication pattern might indicate work contact
    return contact.averageResponseTime >= 8 &&
        contact.averageResponseTime <= 18; // 9 AM to 6 PM
  }
}

// Data Models

class AIResponse {
  final AIResponseType type;
  final String message;
  final List<Contact>? suggestedContacts;
  final List<String> suggestions;
  final Map<String, dynamic>? data;

  AIResponse({
    required this.type,
    required this.message,
    this.suggestedContacts,
    this.suggestions = const [],
    this.data,
  });
}

class AINotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final NotificationPriority priority;
  final bool actionable;
  final Contact? contact;
  final Map<String, dynamic>? data;
  final List<String> suggestedActions;
  final DateTime timestamp;

  AINotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.priority,
    this.actionable = false,
    this.contact,
    this.data,
    this.suggestedActions = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class RelationshipMapData {
  final List<RelationshipNode> nodes;
  final List<RelationshipEdge> edges;
  final RelationshipNode center;
  final DateTime lastUpdated;

  RelationshipMapData({
    required this.nodes,
    required this.edges,
    required this.center,
    required this.lastUpdated,
  });
}

class RelationshipNode {
  final String id;
  final String displayName;
  final NodeType type;
  final double size;
  final Color color;
  final RelationshipPosition position;

  RelationshipNode({
    required this.id,
    required this.displayName,
    required this.type,
    required this.size,
    required this.color,
    required this.position,
  });
}

class RelationshipEdge {
  final String from;
  final String to;
  final double strength;
  final EdgeType type;

  RelationshipEdge({
    required this.from,
    required this.to,
    required this.strength,
    required this.type,
  });
}

class RelationshipPosition {
  final double x;
  final double y;

  RelationshipPosition({required this.x, required this.y});
}

class MoodBasedSuggestion {
  final EmotionEntry currentMood;
  final List<Contact> suggestedContacts;
  final String reasoning;
  final double confidence;
  final List<String> actions;

  MoodBasedSuggestion({
    required this.currentMood,
    required this.suggestedContacts,
    required this.reasoning,
    required this.confidence,
    required this.actions,
  });
}

// Enums

enum AIResponseType {
  suggestion,
  callSuggestion,
  messageSuggestion,
  moodSuggestion,
  status,
  acknowledgment,
  help,
  information,
  error,
}

enum NotificationType {
  relationshipAlert,
  culturalReminder,
  moodSuggestion,
  healthWarning,
  opportunity,
}

enum NotificationPriority {
  low,
  medium,
  high,
  urgent,
}

enum NodeType {
  user,
  family,
  friend,
  work,
}

enum EdgeType {
  family,
  friendship,
  professional,
}

// Helper method for EdgeType
EdgeType edgeTypeFromNodeType(NodeType nodeType) {
  switch (nodeType) {
    case NodeType.family:
      return EdgeType.family;
    case NodeType.friend:
      return EdgeType.friendship;
    case NodeType.work:
      return EdgeType.professional;
    case NodeType.user:
      return EdgeType.friendship; // Default
  }
}
