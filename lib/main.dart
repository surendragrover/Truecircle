import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/hive_initializer.dart';
import 'core/app_theme.dart';
import 'core/preloading_splash_screen.dart';
import 'onboarding/onboarding_page.dart';
import 'package:hive/hive.dart';
import 'auth/phone_verification_page.dart';
import 'iris/dr_iris_welcome_page.dart';
import 'iris/dr_iris_chat_page.dart';
import 'root_shell.dart';
import 'services/app_data_preloader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Custom error widget to prevent red screen flash
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      color: const Color(
        0xFF6366F1,
      ), // Use TrueCircle primary color instead of red
      alignment: Alignment.center,
      child: const Icon(Icons.refresh, color: Colors.white, size: 48),
    );
  };

  // Initialize Hive database
  await HiveInitializer.init();

  runApp(const TrueCircleApp());
}

class TrueCircleApp extends StatelessWidget {
  const TrueCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrueCircle - Emotional Wellness Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _PreloadingWrapper(),
      routes: {'/iris/chat': (context) => const DrIrisChatPage()},

      // Enhanced Material App Configuration
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}

class _PreloadingWrapper extends StatefulWidget {
  const _PreloadingWrapper();

  @override
  State<_PreloadingWrapper> createState() => _PreloadingWrapperState();
}

class _PreloadingWrapperState extends State<_PreloadingWrapper> {
  bool _isPreloading = true;

  @override
  void initState() {
    super.initState();
    _preloadData();
  }

  Future<void> _preloadData() async {
    try {
      // Preload all JSON data for instant feature access
      await AppDataPreloader.instance.preloadAllData();

      // Keep splash minimal to reduce perceived startup delay
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error during preloading: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPreloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isPreloading
        ? const PreloadingSplashScreen()
        : const _StartupGate();
  }
}

class _StartupGate extends StatelessWidget {
  const _StartupGate();

  Future<(bool needsOnboarding, bool needsPhone, bool needsFirstTimeWelcome)>
  _gate() async {
    final box = await Hive.openBox('app_prefs');
    final done = box.get('onboarding_done', defaultValue: false) as bool;
    final phone = box.get('phone_verified', defaultValue: false) as bool;
    final welcomed = box.get('dr_iris_welcomed', defaultValue: false) as bool;
    return (!done, !phone, !welcomed);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(bool, bool, bool)>(
      future: _gate(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: _BrandSplash());
        }
        final data = snap.data ?? (true, false, true);
        final showOnboarding = data.$1;
        final showPhone = data.$2;
        final showWelcome = data.$3;

        if (showOnboarding) {
          return const OnboardingPage();
        }
        if (showPhone) {
          return const PhoneVerificationPage();
        }
        if (showWelcome) {
          return const DrIrisWelcomePage(isFirstTime: true);
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1), // Primary TrueCircle
            Color(0xFF14B8A6), // Joyful Teal
            Color(0xFF8B5CF6), // Hope Purple
          ],
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Image.asset('assets/images/TrueCircle-Logo.png', height: 88),
          ),
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _fade,
            child: const Text(
              'TrueCircle',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white, // White text on gradient
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _fade,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white, // White loading indicator
              ),
            ),
          ),
        ],
      ),
    );
  }
}
