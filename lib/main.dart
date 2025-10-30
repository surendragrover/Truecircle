import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'core/log_service.dart';
import 'widgets/log_console_overlay.dart';
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

  // Initialize LogService early so logs are captured from startup
  await LogService.instance.init();
  // Mirror all debugPrint calls into our LogService
  final originalDebugPrint = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) {
      // Fire-and-forget log write; no await for performance
      LogService.instance.log(message);
    }
    // Also print to console in debug/dev
    originalDebugPrint(message, wrapWidth: wrapWidth);
  };

  try {
    // Initialize Firebase with proper options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  } catch (e) {
    // Firebase initialization failed - continue without Firebase
    if (kDebugMode) {
      debugPrint('Firebase initialization failed: $e');
    }
    // Set basic error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        debugPrint('Flutter Error: ${details.exception}');
      }
    };
  }

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

  // Initialize Hive database with error handling
  try {
    await HiveInitializer.init();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Hive initialization failed: $e');
    }
    // Continue without Hive - app should still work with limited functionality
  }

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
      home: const _SafeWrapper(),
      routes: {'/iris/chat': (context) => const DrIrisChatPage()},

      // Enhanced Material App Configuration
      builder: (context, child) {
        final media = MediaQuery.of(
          context,
        ).copyWith(textScaler: const TextScaler.linear(1.0));
        return MediaQuery(
          data: media,
          child: Stack(
            children: [
              child!,
              // Floating toggle button
              Positioned(
                right: 12,
                top: 12,
                child: SafeArea(
                  top: true,
                  bottom: false,
                  left: false,
                  right: true,
                  child: GestureDetector(
                  onTap: () {
                    final v = LogService.instance.overlayVisible.value;
                    LogService.instance.overlayVisible.value = !v;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      'LOG',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ),
                ),
              ),
              // Live Log console overlay
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ValueListenableBuilder<bool>(
                  valueListenable: LogService.instance.overlayVisible,
                  builder: (context, visible, _) {
                    if (!visible) return const SizedBox.shrink();
                    return SizedBox(
                      height: 280,
                      child: const LogConsoleOverlay(),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SafeWrapper extends StatelessWidget {
  const _SafeWrapper();

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return const _PreloadingWrapper();
        } catch (e) {
          // Emergency fallback UI
          return Scaffold(
            backgroundColor: const Color(0xFF6366F1),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.refresh, color: Colors.white, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'TrueCircle',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // Try to restart the app
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const _PreloadingWrapper(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6366F1),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
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

      // Skip artificial delay to avoid pending timers in tests and speed up boot
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

    // Note: Do NOT reset persisted flags here. Keeping values ensures
    // users don't get asked for phone/OTP on every restart.

    final done = box.get('onboarding_done', defaultValue: false) as bool;
    final phone = box.get('phone_verified', defaultValue: false) as bool;
    final welcomed = box.get('dr_iris_welcomed', defaultValue: false) as bool;

    // Debug information
    if (kDebugMode) {
      debugPrint('Startup Gate Status:');
      debugPrint('Onboarding done: $done');
      debugPrint('Phone verified: $phone');
      debugPrint('Dr Iris welcomed: $welcomed');
      debugPrint(
        'Will show: ${!done
            ? "Onboarding"
            : !phone
            ? "Phone"
            : !welcomed
            ? "Dr Iris Welcome"
            : "Home"}',
      );
    }

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
