import 'package:flutter/material.dart';
import 'dr_iris_page.dart';
import '../cbt/breathing_exercises_page.dart';

class DrIrisWelcomePage extends StatefulWidget {
  final bool autoStartCheckin;
  const DrIrisWelcomePage({super.key, this.autoStartCheckin = false});

  @override
  State<DrIrisWelcomePage> createState() => _DrIrisWelcomePageState();
}

class _DrIrisWelcomePageState extends State<DrIrisWelcomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.autoStartCheckin) {
        final navigator = Navigator.of(context);
        navigator
            .push(
              MaterialPageRoute(builder: (_) => const EmotionalCheckinPage()),
            )
            .then((_) {
              // After check-in, return straight to Home (root)
              if (!mounted) return;
              navigator.popUntil((r) => r.isFirst);
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hint = Theme.of(context).hintColor;
    return Scaffold(
      appBar: AppBar(title: const Text('Meet Dr. Iris')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A calm, offline companion',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                '• Runs entirely on your device (no internet).\n'
                '• Shares neutral, brief, practical nudges.\n'
                '• Educational use only — not medical advice.',
                style: TextStyle(color: hint),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Tips for better replies',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      Text('• Be specific about what you need right now.'),
                      Text('• One small question at a time works best.'),
                      Text('• If stuck, start with “I feel … and I need …”.'),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      final navigator = Navigator.of(context);
                      navigator
                          .push(
                            MaterialPageRoute(
                              builder: (_) => const EmotionalCheckinPage(),
                            ),
                          )
                          .then((_) {
                            // After check-in, return straight to Home (root)
                            if (!mounted) return;
                            navigator.popUntil((r) => r.isFirst);
                          });
                    },
                    icon: const Icon(Icons.emoji_emotions_outlined),
                    label: const Text('Quick Emotional Check‑in'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DrIrisPage()),
                      );
                    },
                    icon: const Icon(Icons.psychology_alt_outlined),
                    label: const Text('Start chatting (Offline)'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
