import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
// import '../iris/dr_iris_welcome_page.dart';
import '../auth/phone_verification_page.dart';
import '../core/permission_manager.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _busy = false;

  Future<void> _complete() async {
    setState(() => _busy = true);
    try {
      final box = await Hive.openBox('app_prefs');
      await box.put('onboarding_done', true);
      if (!mounted) return;
      // Go to dedicated phone verification page with country prefix and picker
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PhoneVerificationPage()),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/truecircle_logo.png',
                      height: 120,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'TrueCircle',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Subtle privacy banner per app policy (keeps tone friendly, not limiting)
              PermissionManager.buildSampleModeBanner(),
              const SizedBox(height: 16),
              _InfoCard(
                icon: Icons.privacy_tip_outlined,
                color: cs.primaryContainer,
                title: 'Privacy‑first',
                text:
                    'Private and on‑device experience. No network calls; no contacts/call/SMS permissions requested.',
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.health_and_safety_outlined,
                color: cs.tertiaryContainer,
                title: 'Safety first',
                text:
                    'If you need immediate support, “Immediate Help” and “Safety Plan” are always available in the app.',
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.psychology_alt_outlined,
                color: cs.secondaryContainer,
                title: 'Dr. Iris (Offline)',
                text:
                    'An on‑device, educational companion — brief and practical nudges. Not a substitute for medical advice.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _complete,
                  icon: _busy
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String text;
  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
