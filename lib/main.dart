import 'package:flutter/material.dart';
import 'core/hive_initializer.dart';
import 'core/app_theme.dart';
import 'onboarding/onboarding_page.dart';
import 'package:hive/hive.dart';
import 'auth/phone_verification_page.dart';
import 'root_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveInitializer.init();
  runApp(const TrueCircleApp());
}

class TrueCircleApp extends StatelessWidget {
  const TrueCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrueCircle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _StartupGate(),
    );
  }
}

class _StartupGate extends StatelessWidget {
  const _StartupGate();

  Future<(bool needsOnboarding, bool needsPhone)> _gate() async {
    final box = await Hive.openBox('app_prefs');
    final done = box.get('onboarding_done', defaultValue: false) as bool;
    final phone = box.get('phone_verified', defaultValue: false) as bool;
    return (!done, !phone);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(bool, bool)>(
      future: _gate(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: _BrandSplash());
        }
        final data = snap.data ?? (true, false);
        final showOnboarding = data.$1;
        final showPhone = data.$2;
        if (showOnboarding) {
          return const OnboardingPage();
        }
        if (showPhone) {
          return const PhoneVerificationPage();
        }
        return const RootShell();
      },
    );
  }
}

class _BrandSplash extends StatefulWidget {
  const _BrandSplash();

  @override
  State<_BrandSplash> createState() => _BrandSplashState();
}

class _BrandSplashState extends State<_BrandSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _scale = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surface,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Image.asset('assets/images/truecircle_logo.png', height: 88),
          ),
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _fade,
            child: Text(
              'TrueCircle',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _fade,
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: scheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
