import 'package:flutter/material.dart';

class MeditationDetailPage extends StatelessWidget {
  final Map<String, dynamic> session;

  const MeditationDetailPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final title = (session['title'] ?? 'Meditation Session').toString();
    final type = (session['type'] ?? '').toString();
    final minutes = (session['duration_minutes'] ?? '').toString();
    final difficulty = (session['difficulty'] ?? '').toString();
    final effect = (session['mood_effect'] ?? '').toString();
    final description = (session['description'] ?? '').toString();

    final sections = _buildSections(type);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overview Card
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
                  children: [
                    const Icon(
                      Icons.self_improvement_rounded,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type.isEmpty ? 'Meditation' : type,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (minutes.isNotEmpty)
                      _chip(Icons.timer_outlined, '$minutes min'),
                    const SizedBox(width: 8),
                    if (difficulty.isNotEmpty)
                      _chip(Icons.leaderboard_outlined, difficulty),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                  ),
                ],
                if (effect.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.mood_rounded,
                        size: 18,
                        color: Colors.teal,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          effect,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Detailed Sections
          ...sections
              .map((s) => _SectionCard(title: s.title, points: s.points))
              .expand((w) => [w, const SizedBox(height: 12)]),

          // Optional Mantra Practice with precise text and counts where relevant
          if (_shouldSuggestMantra(type, title)) ...[
            _optionalMantraCard(type, title),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 8),
          Text(
            'Tip: If you feel discomfort (dizziness, strain), pause and breathe normally. Adapt counts and posture as needed.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.deepPurple),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldSuggestMantra(String type, String title) {
    final t = '${type.toLowerCase()} ${title.toLowerCase()}';
    return t.contains('mantra') ||
        t.contains('pranayama') ||
        t.contains('mindfulness');
  }

  Widget _optionalMantraCard(String type, String title) {
    final combined = '${type.toLowerCase()} ${title.toLowerCase()}';

    if (combined.contains('gayatri')) {
      return const _SectionCard(
        title: 'Gayatri Mantra Practice',
        points: [
          'Mantra (transliteration): Om Bhur Bhuvah Svaha, Tat Savitur Varenyam, Bhargo Devasya Dhimahi, Dhiyo Yo Nah Prachodayat.',
          'Counts: 108 • 54 • 27. Keep pace gentle and sustainable; use a mala if you like.',
          'Breath: natural nasal breathing. If helpful, softly time a mantra per exhale.',
        ],
      );
    }

    if (combined.contains('om chanting') || combined.contains('om')) {
      return const _SectionCard(
        title: 'Om Chanting Practice',
        points: [
          'Mantra: Om (A–U–M). Let the sound gently resonate, especially on the “M”.',
          'Counts: 108 • 54 • 27. Choose a calm, unforced tempo; sit upright and relaxed.',
          'Breath: inhale softly; chant Om on the exhale with relaxed jaw and throat.',
        ],
      );
    }

    // Generic optional suggestion for other meditation styles
    return const _SectionCard(
      title: 'Optional Mantra Practice',
      points: [
        'Simple option: chant Om (A–U–M) or mindfully repeat a calming phrase that resonates with you.',
        'Counts: 27 to start; increase to 54 or 108 as comfortable. Keep breath relaxed throughout.',
        'Prefer silence? Try breath-counting: inhale 1, exhale 1 … up to 10, then restart.',
      ],
    );
  }

  List<_Section> _buildSections(String type) {
    final t = type.toLowerCase();
    if (t.contains('pranayama')) {
      return [
        const _Section(
          title: 'Setup',
          points: [
            'Sit upright on a cushion/chair; lengthen spine; relax shoulders/jaw.',
            'Keep eyes softly closed or half-open; place hands on thighs or in a comfortable mudra.',
          ],
        ),
        const _Section(
          title: 'Breathing Pattern (example: Box Breathing 4-4-4-4)',
          points: [
            'Inhale 4 counts (nose).',
            'Hold 4 counts (gentle, no strain).',
            'Exhale 4 counts (nose).',
            'Hold 4 counts; then repeat for 8–12 cycles.',
          ],
        ),
        const _Section(
          title: 'Progression',
          points: [
            'If comfortable, extend to 5-5-5-5. Avoid discomfort or breath hunger.',
            'Use a soft mental count; if thoughts wander, restart the count at 1.',
          ],
        ),
        const _Section(
          title: 'Closure',
          points: [
            'Return to natural breath for 1–2 minutes; notice sensations and mood.',
          ],
        ),
      ];
    } else if (t.contains('mindfulness')) {
      return [
        const _Section(
          title: 'Setup',
          points: [
            'Choose a quiet spot; sit or lie down comfortably with a neutral spine.',
            'Set a timer (e.g., 10–15 min) so you can relax into practice.',
          ],
        ),
        const _Section(
          title: 'Anchor & Awareness',
          points: [
            'Pick an anchor: breath at nostrils, belly rise/fall, or sounds in the room.',
            'Notice sensations on each inhale and exhale; label thoughts “thinking” and gently return.',
          ],
        ),
        const _Section(
          title: 'Noting Technique',
          points: [
            'If strong feelings arise, note them: “anger”, “sadness”, “worry”, without judgment.',
            'Let labels be light; keep coming back to the anchor kindly.',
          ],
        ),
        const _Section(
          title: 'Closure',
          points: [
            'Open eyes slowly; take a deep breath; notice one positive shift in your state.',
          ],
        ),
      ];
    } else if (t.contains('body scan')) {
      return [
        const _Section(
          title: 'Setup',
          points: [
            'Lie down or sit with full support; keep the body warm and still.',
            'Allow eyes to close; place hands where comfortable.',
          ],
        ),
        const _Section(
          title: 'Scan Path',
          points: [
            'Start at the crown; move attention forehead → eyes → jaw → neck → shoulders.',
            'Continue arms → chest → belly → hips → thighs → knees → calves → feet.',
            'Spend ~10–20 seconds per region; notice tension vs. ease; invite softening.',
          ],
        ),
        const _Section(
          title: 'Dealing with Distraction',
          points: [
            'If mind wanders, acknowledge gently and guide it back to the current region.',
            'If restlessness appears, try a slower exhale for a few breaths.',
          ],
        ),
        const _Section(
          title: 'Closure',
          points: [
            'Take two deeper breaths; roll to the side or sit up slowly before resuming activity.',
          ],
        ),
      ];
    }

    // Default generic guidance
    return const [
      _Section(
        title: 'Setup',
        points: [
          'Find a comfortable position; keep spine neutral; silence notifications.',
        ],
      ),
      _Section(
        title: 'Practice',
        points: [
          'Gently place attention on your chosen anchor (breath/body/sound).',
          'When the mind wanders, return with kindness.',
        ],
      ),
      _Section(
        title: 'Closure',
        points: [
          'Take one slow breath and notice how you feel; stand up gradually.',
        ],
      ),
    ];
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<String> points;

  const _SectionCard({required this.title, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...points.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      p,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section {
  final String title;
  final List<String> points;
  const _Section({required this.title, required this.points});
}
