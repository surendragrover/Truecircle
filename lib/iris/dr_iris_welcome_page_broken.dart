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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Dr. Iris Welcome Header - Rainbow 🌈
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8B5CF6), // Purple
                      Color(0xFFEC4899), // Pink
                      Color(0xFF3B82F6), // Blue
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🤖 Dr. Iris Welcome! 🌈',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
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
                      Icons.security_rounded,
                      size: 32,
                      color: const Color(0xFF10B981), // Emerald Green 🔒
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '🔒 Your emotions never leave your phone! 🔒',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
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
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF8B5CF6), // Purple
                            Color(0xFFEC4899), // Pink
                          ],
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.psychology_alt,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '💝 Dr. Iris, Your Emotional Companion 💝',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B5CF6),
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

              const SizedBox(height: 24),

              // Navigation Buttons - Rainbow Actions 🌈
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startEmotionalCheckin,
                      icon: const Icon(Icons.favorite_rounded),
                      label: const Text('💖 Start Emotional Check-in'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC4899), // Hot Pink
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to home without check-in
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const RootShell()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('🏠 Skip to Home'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3B82F6), // Sky Blue
                        side: const BorderSide(color: Color(0xFF3B82F6)),
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
