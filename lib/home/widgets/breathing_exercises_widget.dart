import 'package:flutter/material.dart';
import '../../cbt/breathing_exercises_page.dart';
import '../../services/json_data_service.dart';

/// Breathing Exercises Widget - Guided breathing patterns
/// Interactive breathing exercises and relaxation techniques for wellness
class BreathingExercisesWidget extends StatefulWidget {
  const BreathingExercisesWidget({super.key});

  @override
  State<BreathingExercisesWidget> createState() =>
      _BreathingExercisesWidgetState();
}

class _BreathingExercisesWidgetState extends State<BreathingExercisesWidget>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  bool _isBreathing = false;
  String _breathingPhase = 'Tap to start';
  int _breathCount = 0;
  Future<List<String>>? _techniquesFuture;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _breathingPhase = 'Exhale';
        });
        _breathingController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _breathingPhase = 'Inhale';
          _breathCount++;
        });
        if (_isBreathing) {
          _breathingController.forward();
        }
      }
    });

    // Preload techniques list from JSON (unique names)
    _techniquesFuture = _loadTechniques();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BreathingExercisesPage()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF00BCD4).withValues(alpha: 0.1),
              const Color(0xFF4FC3F7).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00BCD4).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breathing Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.air_rounded,
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
                        'Breathing Exercises',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Guided breathing and relaxation',
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

            // Breathing Animation Circle
            Center(
              child: AnimatedBuilder(
                animation: _breathingAnimation,
                builder: (context, child) {
                  return Container(
                    width: 100 * _breathingAnimation.value,
                    height: 100 * _breathingAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00BCD4).withValues(alpha: 0.3),
                          const Color(0xFF00BCD4).withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00BCD4).withValues(alpha: 0.2),
                        border: Border.all(
                          color: const Color(0xFF00BCD4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isBreathing
                                  ? Icons.favorite_rounded
                                  : Icons.play_arrow_rounded,
                              size: 16,
                              color: const Color(0xFF00BCD4),
                            ),
                            Text(
                              _breathingPhase,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF00BCD4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Breathing Stats
            if (_isBreathing || _breathCount > 0)
              Container(
                padding: const EdgeInsets.all(12),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBreathingStat(
                      'Breaths',
                      '$_breathCount',
                      Icons.air_rounded,
                    ),
                    _buildBreathingStat(
                      'Duration',
                      '4 sec',
                      Icons.timer_rounded,
                    ),
                    _buildBreathingStat(
                      'Pattern',
                      '4-4-4',
                      Icons.graphic_eq_rounded,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Breathing Techniques
            Container(
              padding: const EdgeInsets.all(12),
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
                  const Text(
                    'Available Techniques',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<String>>(
                    future: _techniquesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final items = snapshot.data ?? const <String>[];
                      if (items.isEmpty) {
                        // Fallback static techniques if no data
                        return Column(
                          children: [
                            _buildTechniqueItem(
                              '4-7-8 Technique',
                              'Inhale 4, Hold 7, Exhale 8',
                              Icons.spa_rounded,
                              Colors.green,
                            ),
                            const SizedBox(height: 8),
                            _buildTechniqueItem(
                              'Box Breathing',
                              'Equal 4-count pattern',
                              Icons.crop_square_rounded,
                              Colors.blue,
                            ),
                            const SizedBox(height: 8),
                            _buildTechniqueItem(
                              'Belly Breathing',
                              'Deep diaphragmatic breathing',
                              Icons.favorite_rounded,
                              Colors.pink,
                            ),
                          ],
                        );
                      }

                      final show = items.take(3).toList(growable: false);
                      return Column(
                        children: [
                          for (int i = 0; i < show.length; i++) ...[
                            _buildTechniqueItem(
                              show[i],
                              _descriptionForTechnique(show[i]),
                              _iconForTechnique(show[i]),
                              _colorForTechnique(show[i]),
                            ),
                            if (i < show.length - 1) const SizedBox(height: 8),
                          ],
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const BreathingExercisesPage(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.list_alt_rounded,
                                size: 16,
                              ),
                              label: const Text('View all exercises'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleBreathing,
                    icon: Icon(
                      _isBreathing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 18,
                    ),
                    label: Text(_isBreathing ? 'Pause' : 'Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _resetBreathing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Icon(Icons.refresh_rounded, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreathingStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF00BCD4)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildTechniqueItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                description,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          size: 16,
          color: Colors.grey.shade400,
        ),
      ],
    );
  }

  void _toggleBreathing() {
    setState(() {
      _isBreathing = !_isBreathing;
      if (_isBreathing) {
        _breathingPhase = 'Inhale';
        _breathingController.forward();
      } else {
        _breathingPhase = 'Paused';
        _breathingController.stop();
      }
    });
  }

  void _resetBreathing() {
    setState(() {
      _isBreathing = false;
      _breathingPhase = 'Tap to start';
      _breathCount = 0;
    });
    _breathingController.reset();
  }

  Future<List<String>> _loadTechniques() async {
    final sessions = await JsonDataService.instance.getBreathingSessions();
    final seen = <String>{};
    final ordered = <String>[];
    for (final s in sessions) {
      final t = (s['technique'] ?? '').toString().trim();
      if (t.isEmpty) continue;
      if (seen.add(t)) ordered.add(t);
    }
    if (ordered.isEmpty) return const [];
    return ordered;
  }

  String _descriptionForTechnique(String t) {
    const map = <String, String>{
      '4-7-8 Breathing': 'Inhale 4, Hold 7, Exhale 8',
      'Box Breathing': 'Equal 4-count pattern',
      'Belly Breathing': 'Deep diaphragmatic breathing',
      'Anulom-Vilom': 'Alternate nostril breathing',
      'Bhramari': 'Humming bee breath',
      'Kapalbhati': 'Active exhale, passive inhale',
      'Bhastrika': 'Bellows breath for energy',
      'Om Chanting Breathing': 'Vibration-focused calming breath',
      'Gayatri Mantra Breathing': 'Rhythmic mantra breathing',
      'Stress Relief Breathing': 'Reduce anxiety and tension',
      'Sleep Induction Breathing': 'Prepare body and mind for sleep',
      'Energy Boost Breathing': 'Activate and energize quickly',
    };
    return map[t] ?? 'Guided breathing technique';
  }

  IconData _iconForTechnique(String t) {
    switch (t) {
      case '4-7-8 Breathing':
        return Icons.spa_rounded;
      case 'Box Breathing':
        return Icons.crop_square_rounded;
      case 'Belly Breathing':
        return Icons.favorite_rounded;
      case 'Anulom-Vilom':
        return Icons.swap_horiz_rounded;
      case 'Bhramari':
        return Icons.hearing_rounded;
      case 'Kapalbhati':
        return Icons.local_fire_department_rounded;
      case 'Bhastrika':
        return Icons.air_rounded;
      case 'Om Chanting Breathing':
        return Icons.self_improvement_rounded;
      case 'Gayatri Mantra Breathing':
        return Icons.music_note_rounded;
      case 'Stress Relief Breathing':
        return Icons.emoji_emotions_rounded;
      case 'Sleep Induction Breathing':
        return Icons.bedtime_rounded;
      case 'Energy Boost Breathing':
        return Icons.bolt_rounded;
      default:
        return Icons.spa_rounded;
    }
  }

  Color _colorForTechnique(String t) {
    switch (t) {
      case '4-7-8 Breathing':
        return Colors.green;
      case 'Box Breathing':
        return Colors.blue;
      case 'Belly Breathing':
        return Colors.pink;
      case 'Anulom-Vilom':
        return Colors.teal;
      case 'Bhramari':
        return Colors.amber;
      case 'Kapalbhati':
        return Colors.deepOrange;
      case 'Bhastrika':
        return Colors.indigo;
      case 'Om Chanting Breathing':
        return Colors.deepPurple;
      case 'Gayatri Mantra Breathing':
        return Colors.brown;
      case 'Stress Relief Breathing':
        return Colors.cyan;
      case 'Sleep Induction Breathing':
        return Colors.blueGrey;
      case 'Energy Boost Breathing':
        return Colors.redAccent;
      default:
        return const Color(0xFF00BCD4);
    }
  }
}
