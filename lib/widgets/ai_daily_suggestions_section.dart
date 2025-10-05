import 'package:flutter/material.dart';
import '../theme/coral_theme.dart';

class AIDailySuggestionsSection extends StatelessWidget {
  final bool isHindi;
  final Map<String, dynamic>? breathingSuggestion;
  final Map<String, dynamic>? meditationSuggestion;
  final List<Map<String, String>> festivalMessages;
  final String? eventPlanningTipEn;
  final String? eventPlanningTipHi;

  const AIDailySuggestionsSection({
    super.key,
    required this.isHindi,
    required this.breathingSuggestion,
    required this.meditationSuggestion,
    required this.festivalMessages,
    required this.eventPlanningTipEn,
    required this.eventPlanningTipHi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CoralTheme.translucentCard(
              alpha: 0.18, radius: BorderRadius.circular(18))
          .copyWith(
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isHindi ? 'AI दैनिक सुझाव' : 'AI Daily Suggestions',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (breathingSuggestion != null)
            _miniSuggestionCard(
              title: isHindi ? 'आज का श्वास अभ्यास' : "Today's Breathing",
              emoji: '💨',
              body: isHindi
                  ? (breathingSuggestion!['technique_hindi'] ??
                      breathingSuggestion!['technique'] ??
                      '')
                  : (breathingSuggestion!['technique'] ??
                      breathingSuggestion!['technique_hindi'] ??
                      ''),
              footer: isHindi
                  ? '${breathingSuggestion!['duration_minutes']} मिनट'
                  : '${breathingSuggestion!['duration_minutes']} min',
            ),
          if (meditationSuggestion != null)
            _miniSuggestionCard(
              title: isHindi ? 'आज का ध्यान' : "Today's Meditation",
              emoji: '🧘',
              body: isHindi
                  ? (meditationSuggestion!['title_hindi'] ??
                      meditationSuggestion!['title'] ??
                      '')
                  : (meditationSuggestion!['title'] ??
                      meditationSuggestion!['title_hindi'] ??
                      ''),
              footer: isHindi
                  ? '${meditationSuggestion!['duration_minutes']} मिनट'
                  : '${meditationSuggestion!['duration_minutes']} min',
            ),
          if (festivalMessages.isNotEmpty) ...[
            _miniSuggestionCard(
              title: isHindi ? 'त्योहार संदेश' : 'Festival Messages',
              emoji: '🪔',
              body: (isHindi
                      ? festivalMessages.first['message_hi']
                      : festivalMessages.first['message_en']) ??
                  '',
              footer: isHindi
                  ? (festivalMessages.first['festival_hi'] ?? '')
                  : (festivalMessages.first['festival_en'] ?? ''),
            ),
            if (festivalMessages.length > 1)
              _miniSuggestionCard(
                title: '',
                emoji: '🎉',
                body: (isHindi
                        ? festivalMessages[1]['message_hi']
                        : festivalMessages[1]['message_en']) ??
                    '',
                footer: isHindi
                    ? (festivalMessages[1]['festival_hi'] ?? '')
                    : (festivalMessages[1]['festival_en'] ?? ''),
              ),
          ],
          if (eventPlanningTipEn != null)
            _miniSuggestionCard(
              title: isHindi ? 'इवेंट प्लानिंग टिप' : 'Event Planning Tip',
              emoji: '🗓️',
              body:
                  isHindi ? eventPlanningTipHi ?? '' : eventPlanningTipEn ?? '',
              footer: isHindi ? 'रिश्ते बेहतर बनाएं' : 'Strengthen bonds',
            ),
        ],
      ),
    );
  }

  Widget _miniSuggestionCard(
      {required String title,
      required String emoji,
      required String body,
      required String footer}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          if (title.isNotEmpty) const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                footer,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                'AI',
                style: TextStyle(
                  color: Colors.orange.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
