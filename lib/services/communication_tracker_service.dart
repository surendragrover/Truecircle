import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/communication_entry.dart';
import '../models/relationship_contact.dart';
import '../models/conversation_insight.dart';
import 'coin_reward_service.dart';

class CommunicationTrackerService {
  static const String _contactsBoxName = 'relationship_contacts';
  static const String _entriesBoxName = 'communication_entries';
  static const String _insightsBoxName = 'conversation_insights';

  // Singleton pattern
  static final CommunicationTrackerService _instance =
      CommunicationTrackerService._internal();
  factory CommunicationTrackerService() => _instance;
  CommunicationTrackerService._internal();

  // Lazy box initialization
  Box<RelationshipContact>? _contactsBox;
  Box<CommunicationEntry>? _entriesBox;
  Box<ConversationInsight>? _insightsBox;

  /// Initialize the service and open Hive boxes
  Future<void> initialize() async {
    try {
      _contactsBox = await Hive.openBox<RelationshipContact>(_contactsBoxName);
      _entriesBox = await Hive.openBox<CommunicationEntry>(_entriesBoxName);
      _insightsBox = await Hive.openBox<ConversationInsight>(_insightsBoxName);
    } catch (e) {
      debugPrint('Error initializing CommunicationTrackerService: $e');
    }
  }

  // ===== RELATIONSHIP CONTACTS =====

  /// Add or update a relationship contact
  Future<void> saveContact(RelationshipContact contact) async {
    try {
      await _contactsBox?.put(contact.id, contact);
    } catch (e) {
      debugPrint('Error saving contact: $e');
    }
  }

  /// Get all relationship contacts
  List<RelationshipContact> getAllContacts() {
    try {
      return _contactsBox?.values.toList() ?? [];
    } catch (e) {
      debugPrint('Error getting contacts: $e');
      return [];
    }
  }

  /// Get contacts by relationship type
  List<RelationshipContact> getContactsByType(String relationshipType) {
    try {
      return _contactsBox?.values
              .where((contact) => contact.relationship == relationshipType)
              .toList() ??
          [];
    } catch (e) {
      debugPrint('Error getting contacts by type: $e');
      return [];
    }
  }

  /// Get priority contacts (family, romantic partners)
  List<RelationshipContact> getPriorityContacts() {
    try {
      return _contactsBox?.values
              .where((contact) => contact.isPriority)
              .toList() ??
          [];
    } catch (e) {
      debugPrint('Error getting priority contacts: $e');
      return [];
    }
  }

  /// Get a specific contact by ID
  RelationshipContact? getContact(String id) {
    try {
      return _contactsBox?.get(id);
    } catch (e) {
      debugPrint('Error getting contact: $e');
      return null;
    }
  }

  /// Delete a contact and all related data
  Future<void> deleteContact(String contactId) async {
    try {
      await _contactsBox?.delete(contactId);

      // Also delete related communication entries
      final entriesToDelete =
          _entriesBox?.values
              .where((entry) => entry.contactId == contactId)
              .map((entry) => entry.id)
              .toList() ??
          [];

      for (String entryId in entriesToDelete) {
        await _entriesBox?.delete(entryId);
      }

      // Delete related insights
      final insightsToDelete =
          _insightsBox?.values
              .where((insight) => insight.contactId == contactId)
              .map((insight) => insight.id)
              .toList() ??
          [];

      for (String insightId in insightsToDelete) {
        await _insightsBox?.delete(insightId);
      }
    } catch (e) {
      debugPrint('Error deleting contact: $e');
    }
  }

  // ===== COMMUNICATION ENTRIES =====

  /// Add a new communication entry
  Future<void> saveCommunicationEntry(CommunicationEntry entry) async {
    try {
      await _entriesBox?.put(entry.id, entry);

      // Update contact's last interaction date
      final contact = getContact(entry.contactId);
      if (contact != null) {
        final updatedContact = contact.copyWith(
          lastInteractionDate: entry.conversationDate,
        );
        await saveContact(updatedContact);
      }

      // Generate insights based on this entry
      await _generateInsightsForEntry(entry);

      // 🎉 हर entry के लिए 1 coin reward देते हैं
      try {
        await CoinRewardService.instance.giveEntryReward();
        debugPrint('Entry coin reward दिया गया!');
      } catch (e) {
        debugPrint('Entry coin reward error: $e');
      }
    } catch (e) {
      debugPrint('Error saving communication entry: $e');
    }
  }

  /// Get all communication entries
  List<CommunicationEntry> getAllEntries() {
    try {
      return _entriesBox?.values.toList() ?? [];
    } catch (e) {
      debugPrint('Error getting entries: $e');
      return [];
    }
  }

  /// Get entries for a specific contact
  List<CommunicationEntry> getEntriesForContact(String contactId) {
    try {
      return _entriesBox?.values
              .where((entry) => entry.contactId == contactId)
              .toList() ??
          [];
    } catch (e) {
      debugPrint('Error getting entries for contact: $e');
      return [];
    }
  }

  /// Get recent entries (last 30 days)
  List<CommunicationEntry> getRecentEntries({int days = 30}) {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      return _entriesBox?.values
              .where((entry) => entry.conversationDate.isAfter(cutoffDate))
              .toList() ??
          [];
    } catch (e) {
      debugPrint('Error getting recent entries: $e');
      return [];
    }
  }

  /// Delete a communication entry
  Future<void> deleteEntry(String entryId) async {
    try {
      await _entriesBox?.delete(entryId);
    } catch (e) {
      debugPrint('Error deleting entry: $e');
    }
  }

  // ===== CONVERSATION INSIGHTS =====

  /// Get all insights
  List<ConversationInsight> getAllInsights() {
    try {
      return _insightsBox?.values.toList() ?? [];
    } catch (e) {
      debugPrint('Error getting insights: $e');
      return [];
    }
  }

  /// Get insights for a specific contact
  List<ConversationInsight> getInsightsForContact(String contactId) {
    try {
      return _insightsBox?.values
              .where((insight) => insight.contactId == contactId)
              .toList() ??
          [];
    } catch (e) {
      debugPrint('Error getting insights for contact: $e');
      return [];
    }
  }

  /// Get unread insights
  List<ConversationInsight> getUnreadInsights() {
    try {
      return _insightsBox?.values
              .where((insight) => !insight.isRead)
              .toList() ??
          [];
    } catch (e) {
      debugPrint('Error getting unread insights: $e');
      return [];
    }
  }

  /// Mark insight as read
  Future<void> markInsightAsRead(String insightId) async {
    try {
      final insight = _insightsBox?.get(insightId);
      if (insight != null) {
        final updatedInsight = insight.copyWith(isRead: true);
        await _insightsBox?.put(insightId, updatedInsight);
      }
    } catch (e) {
      debugPrint('Error marking insight as read: $e');
    }
  }

  // ===== ANALYTICS & INSIGHTS GENERATION =====

  /// Generate insights based on a new communication entry
  Future<void> _generateInsightsForEntry(CommunicationEntry entry) async {
    try {
      final contact = getContact(entry.contactId);
      if (contact == null) return;

      final recentEntries = getEntriesForContact(entry.contactId)
          .where(
            (e) => e.conversationDate.isAfter(
              DateTime.now().subtract(const Duration(days: 30)),
            ),
          )
          .toList();

      // Generate different types of insights
      await _checkForRelationshipWarnings(contact, entry, recentEntries);
      await _checkForPositivePatterns(contact, entry, recentEntries);
      await _checkForImprovementOpportunities(contact, entry, recentEntries);
    } catch (e) {
      debugPrint('Error generating insights: $e');
    }
  }

  /// Check for relationship warning signs
  Future<void> _checkForRelationshipWarnings(
    RelationshipContact contact,
    CommunicationEntry entry,
    List<CommunicationEntry> recentEntries,
  ) async {
    try {
      // Check for declining quality pattern
      if (recentEntries.length >= 3) {
        final avgQuality =
            recentEntries.map((e) => e.overallQuality).reduce((a, b) => a + b) /
            recentEntries.length;

        if (avgQuality < 4) {
          final insight = ConversationInsight(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            contactId: contact.id,
            insightType: 'warning',
            title: 'Declining Communication Quality with ${contact.name}',
            description:
                'Recent conversations have been lower quality than usual. This might indicate growing tension or distance in your relationship.',
            recommendations: [
              'Schedule a dedicated time to talk openly about any concerns',
              'Ask ${contact.name} how they\'ve been feeling about your relationship',
              'Consider planning a special activity together to reconnect',
              'Practice active listening during your next conversation',
            ],
            priority: 8,
            analysisData: {
              'avgQuality': avgQuality,
              'entryCount': recentEntries.length,
            },
            relatedEntryIds: recentEntries.map((e) => e.id).toList(),
            isRead: false,
            createdAt: DateTime.now(),
          );

          await _insightsBox?.put(insight.id, insight);
        }
      }

      // Check for frequent conflicts
      final conflictCount = recentEntries.where((e) => e.hadConflict).length;
      if (conflictCount >= 3) {
        final insight = ConversationInsight(
          id: '${DateTime.now().millisecondsSinceEpoch}_conflict',
          contactId: contact.id,
          insightType: 'warning',
          title: 'Frequent Conflicts with ${contact.name}',
          description:
              'You\'ve had $conflictCount conflicts in recent conversations. This pattern suggests underlying issues that need attention.',
          recommendations: [
            'Identify common triggers that lead to conflicts',
            'Take breaks during heated discussions to cool down',
            'Focus on "I" statements instead of "you" accusations',
            'Consider seeking relationship counseling if conflicts persist',
          ],
          priority: 9,
          analysisData: {
            'conflictCount': conflictCount,
            'totalEntries': recentEntries.length,
          },
          relatedEntryIds: recentEntries
              .where((e) => e.hadConflict)
              .map((e) => e.id)
              .toList(),
          isRead: false,
          createdAt: DateTime.now(),
        );

        await _insightsBox?.put(insight.id, insight);
      }
    } catch (e) {
      debugPrint('Error checking relationship warnings: $e');
    }
  }

  /// Check for positive relationship patterns
  Future<void> _checkForPositivePatterns(
    RelationshipContact contact,
    CommunicationEntry entry,
    List<CommunicationEntry> recentEntries,
  ) async {
    try {
      // Check for improving trend
      if (recentEntries.length >= 5) {
        final sortedEntries = recentEntries
          ..sort((a, b) => a.conversationDate.compareTo(b.conversationDate));
        final recentQuality =
            sortedEntries
                .take(3)
                .map((e) => e.overallQuality)
                .reduce((a, b) => a + b) /
            3;
        final olderQuality =
            sortedEntries
                .skip(2)
                .map((e) => e.overallQuality)
                .reduce((a, b) => a + b) /
            (sortedEntries.length - 2);

        if (recentQuality > olderQuality + 1.5) {
          final insight = ConversationInsight(
            id: '${DateTime.now().millisecondsSinceEpoch}_positive',
            contactId: contact.id,
            insightType: 'celebration',
            title: 'Improving Relationship with ${contact.name}! 🎉',
            description:
                'Your conversations have been getting better recently! Keep up the great work building this relationship.',
            recommendations: [
              'Continue doing what you\'re doing - it\'s working!',
              'Consider telling ${contact.name} how much you value the relationship',
              'Plan more quality time together to maintain this positive momentum',
            ],
            priority: 3,
            analysisData: {
              'recentQuality': recentQuality,
              'olderQuality': olderQuality,
            },
            relatedEntryIds: recentEntries.map((e) => e.id).toList(),
            isRead: false,
            createdAt: DateTime.now(),
          );

          await _insightsBox?.put(insight.id, insight);
        }
      }
    } catch (e) {
      debugPrint('Error checking positive patterns: $e');
    }
  }

  /// Check for improvement opportunities
  Future<void> _checkForImprovementOpportunities(
    RelationshipContact contact,
    CommunicationEntry entry,
    List<CommunicationEntry> recentEntries,
  ) async {
    try {
      // Check if haven't talked in a while
      final daysSinceLastContact = DateTime.now()
          .difference(entry.conversationDate)
          .inDays;
      if (daysSinceLastContact > contact.interactionFrequency * 2) {
        final insight = ConversationInsight(
          id: '${DateTime.now().millisecondsSinceEpoch}_reconnect',
          contactId: contact.id,
          insightType: 'suggestion',
          title: 'Time to Reconnect with ${contact.name}',
          description:
              'It\'s been longer than usual since you last spoke. Reaching out could help maintain your relationship.',
          recommendations: [
            'Send a simple "thinking of you" message',
            'Share something that reminded you of them',
            'Suggest meeting for coffee or a video call',
            'Ask about something specific you know they care about',
          ],
          priority: 5,
          analysisData: {
            'daysSinceContact': daysSinceLastContact,
            'normalFrequency': contact.interactionFrequency,
          },
          relatedEntryIds: [entry.id],
          isRead: false,
          createdAt: DateTime.now(),
        );

        await _insightsBox?.put(insight.id, insight);
      }
    } catch (e) {
      debugPrint('Error checking improvement opportunities: $e');
    }
  }

  // ===== STATISTICS =====

  /// Get relationship statistics for dashboard
  Map<String, dynamic> getRelationshipStats() {
    try {
      final contacts = getAllContacts();
      final entries = getAllEntries();
      final insights = getAllInsights();

      final totalContacts = contacts.length;
      final priorityContacts = contacts.where((c) => c.isPriority).length;
      final entriesThisWeek = entries
          .where(
            (e) => e.conversationDate.isAfter(
              DateTime.now().subtract(const Duration(days: 7)),
            ),
          )
          .length;
      final unreadInsights = insights.where((i) => !i.isRead).length;

      return {
        'totalContacts': totalContacts,
        'priorityContacts': priorityContacts,
        'entriesThisWeek': entriesThisWeek,
        'unreadInsights': unreadInsights,
        'averageQuality': entries.isEmpty
            ? 0
            : entries.map((e) => e.overallQuality).reduce((a, b) => a + b) /
                  entries.length,
      };
    } catch (e) {
      debugPrint('Error getting relationship stats: $e');
      return {
        'totalContacts': 0,
        'priorityContacts': 0,
        'entriesThisWeek': 0,
        'unreadInsights': 0,
        'averageQuality': 0.0,
      };
    }
  }
}
