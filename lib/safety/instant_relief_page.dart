import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';

class InstantReliefPage extends StatefulWidget {
  const InstantReliefPage({super.key});

  @override
  State<InstantReliefPage> createState() => _InstantReliefPageState();
}

class _InstantReliefPageState extends State<InstantReliefPage>
    with TickerProviderStateMixin {
  late final AnimationController _breathCtrl;
  late final Animation<double> _breath;
  bool _isRunning = false;
  int _cycle = 0;
  String _phase = 'Tap Start';

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _breath = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut));
    _breathCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _phase = 'Exhale');
        _breathCtrl.reverse();
      } else if (s == AnimationStatus.dismissed) {
        setState(() {
          _phase = 'Inhale';
          _cycle++;
        });
        if (_isRunning) _breathCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'Instant Relief'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Breathing bubble
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.air_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Guided Breathing (4-4-6)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ScaleTransition(
                    scale: _breath,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _phase,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cycles: $_cycle',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isRunning = !_isRunning;
                              _phase = _isRunning ? 'Inhale' : 'Paused';
                            });
                            if (_isRunning) {
                              _breathCtrl.forward();
                            } else {
                              _breathCtrl.stop();
                            }
                          },
                          icon: Icon(
                            _isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          label: Text(_isRunning ? 'Pause' : 'Start'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isRunning = false;
                              _cycle = 0;
                              _phase = 'Tap Start';
                            });
                            _breathCtrl.reset();
                          },
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Reset'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 5-4-3-2-1 grounding
          const _ListCard(
            icon: Icons.self_improvement_outlined,
            title: '5‑4‑3‑2‑1 Grounding',
            lines: [
              'Notice 5 things you can see',
              'Feel 4 things you can touch',
              'Listen for 3 sounds around you',
              'Identify 2 smells (or recall favourites)',
              'Notice 1 taste (water or mint gum works)',
            ],
          ),

          const SizedBox(height: 12),

          // Soothing statements
          const _ListCard(
            icon: Icons.spa_outlined,
            title: 'Soothing reminders',
            lines: [
              'This feeling will pass; I am safe right now.',
              'I can breathe slowly and let my body settle.',
              'I only need to focus on the next small step.',
            ],
          ),
        ],
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> lines;
  const _ListCard({
    required this.icon,
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...lines.map(
              (l) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('• $l'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
