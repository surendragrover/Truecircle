import 'package:flutter/material.dart';

/// मूड ट्रैकर Widget - Quick mood tracking widget
class MoodTrackerWidget extends StatefulWidget {
  const MoodTrackerWidget({super.key});

  @override
  State<MoodTrackerWidget> createState() => _MoodTrackerWidgetState();
}

class _MoodTrackerWidgetState extends State<MoodTrackerWidget> {
  int? selectedMood;

  final List<MoodItem> moods = [
    MoodItem(emoji: '😊', label: 'Happy', color: Color(0xFFF4AB37)),
    MoodItem(emoji: '😌', label: 'Calm', color: Color(0xFF14B8A6)),
    MoodItem(emoji: '😐', label: 'Neutral', color: Color(0xFF64748B)),
    MoodItem(emoji: '😔', label: 'Sad', color: Color(0xFF8B5CF6)),
    MoodItem(emoji: '😰', label: 'Anxious', color: Color(0xFFEC407A)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2A145D), // Deep Purple - गहरा बैंगनी
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF14B8A6).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Mood Selection - responsive layout to avoid overflow on small screens
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 12,
                children: moods.asMap().entries.map((entry) {
                  final index = entry.key;
                  final mood = entry.value;
                  final isSelected = selectedMood == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMood = index;
                      });
                      _showMoodConfirmation(mood);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? mood.color.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? mood.color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            mood.emoji,
                            style: TextStyle(fontSize: isSelected ? 32 : 28),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mood.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? mood.color
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (selectedMood != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: moods[selectedMood!].color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        color: moods[selectedMood!].color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Great! You\'re feeling ${moods[selectedMood!].label.toLowerCase()} today.',
                          style: TextStyle(
                            fontSize: 14,
                            color: moods[selectedMood!].color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showMoodConfirmation(MoodItem mood) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text('Mood logged: ${mood.label}'),
          ],
        ),
        backgroundColor: mood.color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// मूड आइटम - Mood item data class
class MoodItem {
  final String emoji;
  final String label;
  final Color color;

  MoodItem({required this.emoji, required this.label, required this.color});
}
