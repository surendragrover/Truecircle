import 'package:flutter/material.dart';
// Removed detailed entry import to keep dashboard minimal
import '../../cbt/breathing_exercises_page.dart';
import '../../cbt/breathing_exercises_page.dart'
    show MoodJournalPage; // reuse list page
import '../../services/json_data_service.dart';

/// Mood Journal Widget
/// Daily mood tracking and journaling feature
class MoodJournalWidget extends StatelessWidget {
  const MoodJournalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: () => _openMoodJournalList(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withValues(alpha: 0.12),
              primaryColor.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Journal Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.book_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mood Journal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'How are you feeling today?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Journal Actions (no inline entry box on dashboard)
            // Note: Journal action buttons removed to keep dashboard minimal
            const SizedBox(height: 16),

            // Recent Entries (from JSON)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Entries',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _openMoodJournalList(context),
                        child: const Text('Open Journal'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: JsonDataService.instance.getMoodJournalEntries(),
                    builder: (context, snapshot) {
                      final items =
                          snapshot.data ?? const <Map<String, dynamic>>[];
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      if (items.isEmpty) {
                        return Text(
                          'No recent entries yet. Tap to open your journal.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        );
                      }
                      final recent = items.take(3).toList();
                      return Column(
                        children: [
                          for (int i = 0; i < recent.length; i++) ...[
                            _buildEntryItem(
                              _emojiForMoodRating(recent[i]['mood_rating']),
                              (recent[i]['title'] ?? 'Entry').toString(),
                              (recent[i]['date'] ?? '').toString(),
                              (recent[i]['description'] ?? '').toString(),
                            ),
                            if (i != recent.length - 1)
                              const SizedBox(height: 8),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryItem(
    String emoji,
    String mood,
    String date,
    String preview,
  ) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    mood,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                preview,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Quick-save removed from dashboard to keep it clean

  void _openMoodJournalList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MoodJournalPage()),
    );
  }

  String _emojiForMoodRating(dynamic rating) {
    final r = int.tryParse(rating?.toString() ?? '') ?? 5;
    if (r >= 8) return '😆';
    if (r >= 6) return '😊';
    if (r >= 4) return '😐';
    if (r >= 2) return '😢';
    return '😠';
  }
}

// Note: Detailed mood selection and entry happens on the full page now.
