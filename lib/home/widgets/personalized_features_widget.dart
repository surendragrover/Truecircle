import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../services/json_data_service.dart';
import '../../emotional_awareness/emotional_awareness_page.dart';
import '../../sleep/sleep_tracker_page.dart';
import '../../cbt/cbt_micro_lessons_page.dart';
import '../../cbt/breathing_exercises_page.dart';
import '../../meditation/meditation_guide_page.dart';

/// PersonalizedFeaturesWidget
/// Shows six important features with the user's most recent entry (if any).
class PersonalizedFeaturesWidget extends StatelessWidget {
  const PersonalizedFeaturesWidget({super.key});

  Future<String> _lastEntrySnippet(
    String boxName,
    String fallbackLabel, {
    Future<String> Function()? fallbackLoader,
  }) async {
    try {
      final box = await Hive.openBox(boxName);
      final entries = box.get('entries', defaultValue: <Map>[]) as List;
      if (entries.isNotEmpty) {
        final last = entries.last as Map;
        // Prefer a short text field if available
        final text = (last['text'] ?? last['note'] ?? last['summary'] ?? '')
            .toString();
        if (text.trim().isNotEmpty) {
          return text.length > 120 ? '${text.substring(0, 117)}...' : text;
        }
      }
    } catch (_) {}

    // Fallback to loader (from assets) if provided
    if (fallbackLoader != null) {
      try {
        final demo = await fallbackLoader();
        if (demo.trim().isNotEmpty) {
          return demo.length > 120 ? '${demo.substring(0, 117)}...' : demo;
        }
      } catch (_) {}
    }

    return fallbackLabel;
  }

  Widget _featureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String boxName,
    required Widget Function() pageBuilder,
    Future<String> Function()? demoLoader,
  }) {
    return FutureBuilder<String>(
      future: _lastEntrySnippet(
        boxName,
        'No entries yet — start now',
        fallbackLoader: demoLoader,
      ),
      builder: (context, snap) {
        final snippet = snap.data ?? 'Loading...';
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => pageBuilder()),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),
                Text(
                  snippet,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("Today's conversation — $title"),
                        content: Text(snippet),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Close'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => pageBuilder(),
                                ),
                              );
                            },
                            child: const Text('Open'),
                          ),
                        ],
                      ),
                    ),
                    child: const Text("Today's conversation"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Grid with 2 columns, 6 features
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your recents',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _featureCard(
              context,
              title: 'Emotional Check-in',
              subtitle: 'Track your feelings',
              boxName: 'emotional_checkins',
              pageBuilder: () => const EmotionalAwarenessPage(),
              demoLoader: () async {
                final list = await JsonDataService.instance
                    .getEmotionalAwarenessCategories();
                if (list.isNotEmpty) {
                  return list.first['title'] ?? 'Explore emotions';
                }
                return '';
              },
            ),

            _featureCard(
              context,
              title: 'Mood Journal',
              subtitle: 'Your daily notes',
              boxName: 'mood_journal',
              pageBuilder: () => const MoodJournalPage(),
              demoLoader: () async {
                final list = await JsonDataService.instance
                    .getMoodJournalEntries();
                if (list.isNotEmpty) {
                  return list.first['note'] ?? list.first['text'] ?? '';
                }
                return '';
              },
            ),

            _featureCard(
              context,
              title: 'Sleep Entry',
              subtitle: 'Last sleep log',
              boxName: 'sleep_entries',
              pageBuilder: () => const SleepTrackerPage(),
              demoLoader: () async {
                final list = await JsonDataService.instance
                    .getSleepTrackerEntries();
                if (list.isNotEmpty) {
                  return list.first['notes'] ?? list.first['summary'] ?? '';
                }
                return '';
              },
            ),

            _featureCard(
              context,
              title: 'Breathing',
              subtitle: 'Last exercise',
              boxName: 'breathing_sessions_user',
              pageBuilder: () => const BreathingExercisesPage(),
              demoLoader: () async {
                final list = await JsonDataService.instance
                    .getBreathingSessions();
                if (list.isNotEmpty) {
                  return list.first['description'] ?? '';
                }
                return '';
              },
            ),

            _featureCard(
              context,
              title: 'Meditation',
              subtitle: 'Last guide',
              boxName: 'meditation_sessions_user',
              pageBuilder: () => const MeditationGuidePage(),
              demoLoader: () async {
                final list = await JsonDataService.instance
                    .getMeditationGuides();
                if (list.isNotEmpty) {
                  return list.first['title'] ?? '';
                }
                return '';
              },
            ),

            _featureCard(
              context,
              title: 'CBT Micro Lessons',
              subtitle: 'Last lesson',
              boxName: 'cbt_progress',
              pageBuilder: () => const CBTMicroLessonsPage(),
              demoLoader: () async {
                final list = await JsonDataService.instance
                    .getCbtMicroLessons();
                if (list.isNotEmpty) {
                  return list.first.text;
                }
                return '';
              },
            ),
          ],
        ),
      ],
    );
  }
}
