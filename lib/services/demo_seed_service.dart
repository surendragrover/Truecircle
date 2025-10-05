// lib/services/demo_seed_service.dart
// Seeds richer demo scenario data across Hive boxes (contacts, interactions,
// emotional entries, etc.) only once (idempotent) in sample/privacy mode.

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'privacy_mode_manager.dart';
import '../core/service_locator.dart';
import '../models/contact.dart';
import '../models/contact_interaction.dart';
import 'ai_orchestrator_service.dart';

class DemoSeedService {
  static final DemoSeedService _instance = DemoSeedService._internal();
  DemoSeedService._internal();
  factory DemoSeedService() => _instance;

  static const _seedFlagKey = 'demo_seed_done_v2';

  Future<void> seedIfNeeded() async {
    try {
      final settings = await Hive.openBox('truecircle_settings');
      final already = settings.get(_seedFlagKey, defaultValue: false) as bool;
      if (already) {
        debugPrint('🟡 DemoSeedService: seed already applied, skipping');
        return;
      }

      // Only proceed if app is in sample/privacy-first mode
      final privacyManager = ServiceLocator.instance.get<PrivacyModeManager>();
      if (!privacyManager.isPrivacyMode) {
        debugPrint(
            'ℹ️ DemoSeedService: not in strict privacy/sample mode, skipping seeding');
        return;
      }

      debugPrint('🧪 DemoSeedService: seeding demo scenario data...');
      await _seedContacts();
      await _seedInteractions();
      await _seedEmotionalEntries();
      await _seedAuxiliaryMetrics();

      await settings.put(_seedFlagKey, true);
      debugPrint('✅ DemoSeedService: seeding complete');

      // Refresh orchestrator so new insights activate instantly
      await AIOrchestratorService().startIfPossible();
      await AIOrchestratorService().refresh();
    } catch (e) {
      debugPrint('❌ DemoSeedService error: $e');
    }
  }

  Future<void> _seedContacts() async {
    try {
      final box = await Hive.openBox<Contact>('contacts');
      if (box.values.isNotEmpty) return; // don't overwrite real user data

      final contacts = [
        Contact(
          id: 'c_old_friend',
          displayName: 'Rohit Verma',
          phoneNumbers: const ['+91XXXXXXXXXX'],
          emotionalScore: EmotionalScore.friendlyButFading,
          emotionalScoreValue: 42,
          tags: const ['Friend', 'College'],
          metadata: const {
            'pending_reconnect': true,
            'reason_gap': 'Busy job relocation',
            'mutuality_flag': 'low_inbound'
          },
        ),
        Contact(
          id: 'c_partner',
          displayName: 'Ananya',
          phoneNumbers: const ['+91YYYYYYYYYY'],
          emotionalScore: EmotionalScore.friendlyButFading,
          emotionalScoreValue: 55,
          tags: const ['Partner'],
          metadata: const {
            'relationship_stage': 'long_term',
            'shared_tools': ['calendar'],
          },
        ),
      ];
      for (final c in contacts) {
        await box.put(c.id, c);
      }
      debugPrint('📇 Seeded ${contacts.length} contacts');
    } catch (e) {
      debugPrint('Seed contacts failed: $e');
    }
  }

  Future<void> _seedInteractions() async {
    try {
      final box =
          await Hive.openBox<ContactInteraction>('contact_interactions');
      if (box.values.isNotEmpty) return; // avoid duplicate scenario stacking

      final interactions = [
        // Missed call reminder scenario (old friend)
        ContactInteraction(
            contactId: 'c_old_friend',
            timestamp: DateTime.parse('2025-09-10T09:30:00Z'),
            type: InteractionType.call,
            duration: 0,
            initiatedByMe: true,
            metadata: const {
              'status': 'missed',
              'reminder': 'Not spoken in 120+ days',
              'trigger': 'reconnect_suggestion'
            }),
        // Reconnecting call success
        ContactInteraction(
          contactId: 'c_old_friend',
          timestamp: DateTime.parse('2025-09-12T18:05:00Z'),
          type: InteractionType.call,
          duration: 780,
          initiatedByMe: true,
          content: 'Great to catch up after so long!',
          sentimentScore: 0.65,
          metadata: const {
            'status': 'completed',
            'reconnect_success': true,
            'affinity_boost': 8
          },
        ),
        // Conflict low sentiment
        ContactInteraction(
          contactId: 'c_partner',
          timestamp: DateTime.parse('2025-09-15T20:40:00Z'),
          type: InteractionType.message,
          content: 'We keep misunderstanding schedules.',
          sentimentScore: -0.35,
          metadata: const {
            'conflict': true,
            'topic': 'time_planning',
            'emotional_score_before': 55
          },
        ),
        // Conflict resolution follow up
        ContactInteraction(
          contactId: 'c_partner',
          timestamp: DateTime.parse('2025-09-16T08:10:00Z'),
          type: InteractionType.message,
          content: 'Thank you for adjusting your timing—feels better.',
          sentimentScore: 0.55,
          metadata: const {
            'conflict_resolution': true,
            'action_taken': 'shared_calendar',
            'emotional_score_after': 68
          },
        ),
      ];

      // Store keyed by composite index
      for (int i = 0; i < interactions.length; i++) {
        await box.put('seed_$i', interactions[i]);
      }
      debugPrint('☎️ Seeded ${interactions.length} interactions');
    } catch (e) {
      debugPrint('Seed interactions failed: $e');
    }
  }

  Future<void> _seedEmotionalEntries() async {
    try {
      final box = await Hive.openBox('truecircle_emotional_entries');
      final existing = box.get('entries', defaultValue: <dynamic>[]) as List;
      if (existing.isNotEmpty) return; // do not mix with user entries

      final entries = [
        {
          'timestamp': '2025-10-01T07:45:00Z',
          'mood_score': 4,
          'feelings': 'tired, anxious',
          'notes': 'Rough sleep & work pressure',
          'stress': 'High',
          'analysis': 'Energy dip—prioritize rest + breathing cycle.'
        },
        {
          'timestamp': '2025-10-02T09:10:00Z',
          'mood_score': 5,
          'feelings': 'neutral, focused',
          'notes': 'Breathing session helped',
          'stress': 'Medium',
          'analysis': 'Stabilizing—keep short recovery rituals.'
        },
        {
          'timestamp': '2025-10-03T21:20:00Z',
          'mood_score': 7,
          'feelings': 'calm, optimistic',
          'notes': 'Good meditation & supportive chat',
          'stress': 'Low',
          'analysis': 'Positive momentum—reinforce consistency.'
        }
      ];
      await box.put('entries', entries);
      debugPrint('🧠 Seeded emotional check-in sequence (${entries.length})');
    } catch (e) {
      debugPrint('Seed emotional entries failed: $e');
    }
  }

  Future<void> _seedAuxiliaryMetrics() async {
    try {
      final box = await Hive.openBox('demo_aux_metrics');
      if (box.isNotEmpty) return;
      await box.put('sleep_last_night', {
        'date': '2025-10-03',
        'total_hours': 6.66,
        'awakening_count': 2,
        'restfulness_score': 58,
        'mood_morning': 5
      });
      await box.put('breathing_session', {
        'timestamp': '2025-10-04T14:15:00Z',
        'pattern': '4-7-8',
        'duration_minutes': 5,
        'stress_before': 6,
        'stress_after': 3,
        'effectiveness': 8
      });
      await box.put('meditation_session', {
        'timestamp': '2025-10-04T06:40:00Z',
        'session_type': 'guided_breath_body_scan',
        'duration_minutes': 12,
        'calmness_after': 8,
        'focus_improvement': 6
      });
      await box.put('progress_tracker_snapshot', {
        'period': 'last_7_days',
        'avg_mood': 5.8,
        'avg_stress': 'Medium',
        'checkins': 7,
        'breathing_sessions': 4,
        'meditation_sessions': 3,
        'sleep_avg_hours': 6.5,
        'highlight': 'Reconnection improved emotional stability',
        'risk_flag': 'mild_fatigue'
      });
      await box.put('festival_focus', {
        'festival': 'Diwali',
        'date': '2025-10-29',
        'suggested_greeting_en':
            'Wishing you light, warmth and renewed emotional bonds this Diwali!',
        'suggested_greeting_hi':
            'दीपों का ये त्योहार आपके संबंधों में नई रोशनी लाए!',
        'tips': [
          'Send a warm reconnect message to distant friends',
          'Share a gratitude note with close family'
        ],
        'priority': 'high'
      });
      debugPrint('📊 Seeded auxiliary wellness + festival metrics');
    } catch (e) {
      debugPrint('Seed auxiliary metrics failed: $e');
    }
  }
}
