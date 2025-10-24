import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';
import 'package:hive/hive.dart';
import '../emotional_awareness/emotional_awareness_page.dart';
import '../root_shell.dart';

class DrIrisWelcomePage extends StatefulWidget {
  final bool isFirstTime;
  const DrIrisWelcomePage({super.key, this.isFirstTime = false});

  @override
  State<DrIrisWelcomePage> createState() => _DrIrisWelcomePageState();
}

class _DrIrisWelcomePageState extends State<DrIrisWelcomePage> {
  @override
  void initState() {
    super.initState();
    // Auto-redirect to emotional check-in after first-time onboarding
    if (widget.isFirstTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _startEmotionalCheckin();
      });
    }
  }

  void _startEmotionalCheckin() async {
    // Mark first-time welcome as complete
    if (widget.isFirstTime) {
      final box = await Hive.openBox('app_prefs');
      await box.put('dr_iris_welcomed', true);
    }

    if (!mounted) return;

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const EmotionalAwarenessPage()))
        .then((_) {
          // After check-in, navigate to home dashboard
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const RootShell()),
            (route) => false,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.isFirstTime
          ? null
          : const TrueCircleAppBar(title: 'Dr. Iris'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Dr. Iris Welcome Header
              Text(
                'Dr. Iris Welcome',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6A5ACD), // TrueCircle Purple
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Privacy Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      size: 32,
                      color: const Color(0xFF4169E1), // TrueCircle Blue
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your emotions never leave your phone.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Dr. Iris Introduction
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(
                        0xFF6A5ACD,
                      ).withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.psychology_alt,
                        size: 40,
                        color: Color(0xFF6A5ACD),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Dr. Iris, Your Emotional Companion',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hello! I\'m Dr. Iris - your emotional companion. I know you are new here, and I\'m here to guide you gently through your thoughts and relationships.',
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.textTheme.bodyMedium?.color,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
            ],
          ),
        ),
      ),
    );
  }
}
