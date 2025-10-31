import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
// Firebase removed for offline-only build
import 'core/log_service.dart';
// Log console overlay removed from main UI for release / privacy
import 'core/hive_initializer.dart';
import 'core/app_theme.dart';
import 'core/preloading_splash_screen.dart';
import 'package:hive/hive.dart';
import 'auth/phone_verification_page.dart';
// import removed: legacy Dr Iris welcome screen is no longer used
import 'iris/dr_iris_chat_page.dart';
import 'iris/dr_iris_welcome_page.dart';
import 'root_shell.dart';
import 'services/app_data_preloader.dart';
import 'services/geo_service.dart';
import 'services/privacy_guard.dart';
import 'core/reward_listener.dart';
import 'marketplace/marketplace_page.dart';
import 'dream_space/dream_space_page.dart';

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

  // Firebase has been removed. Use local error handling and logging instead.
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log to local LogService so errors are captured in debug overlay/logs
    LogService.instance.log('Flutter Error: ${details.exception}');
    if (kDebugMode) {
      // still print in debug
      debugPrint('Flutter Error: ${details.exception}');
    }
  };

  // Initialize Hive database before enforcing privacy mode so that
  // PrivacyGuard can read persisted flags (force_offline) reliably.
  try {
    await HiveInitializer.init();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Hive initialization failed: $e');
    }
    // Continue without Hive - app should still work with limited functionality
  }

  // Enforce privacy mode on every startup (after Hive init but before runApp)
  // PrivacyGuard reads persisted flags (e.g., 'force_offline') and must be
  // called after Hive initialization above.
  try {
    await PrivacyGuard.enforceIfNeeded();
  } catch (_) {}

  // Pass all uncaught asynchronous errors to local logging (Crashlytics removed).
  PlatformDispatcher.instance.onError = (error, stack) {
    LogService.instance.log('Unhandled async error: $error');
    if (kDebugMode) {
      debugPrint('Unhandled async error: $error');
      debugPrint('$stack');
    }
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

  // Hive has already been initialized earlier in main to ensure privacy
  // enforcement is applied before runApp.

  runApp(const TrueCircleApp());
}

class TrueCircleApp extends StatelessWidget {
  const TrueCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _SafeWrapper(),
      routes: {
        '/iris/chat': (context) => const DrIrisChatPage(),
        '/marketplace': (context) => const MarketplacePage(),
        '/dream-space': (context) => const DreamSpacePage(),
      },

      // Enhanced Material App Configuration
      builder: (context, child) {
        final media = MediaQuery.of(
          context,
        ).copyWith(textScaler: const TextScaler.linear(1.0));
        return MediaQuery(
          data: media,
          child: Stack(
            children: [
              // Wrap the app with RewardListener so any pending coin reward
              // events are handled globally and animation is shown.
              RewardListener(child: child!),
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
                  Text(
                    AppLocalizations.of(context)!.trueCircle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.loading,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
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
                    child: Text(AppLocalizations.of(context)!.retry),
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
      // Attempt to detect user's country by IP once at install/startup and cache it.
      try {
        await GeoService.instance.detectAndStoreCountry();
      } catch (e) {
        debugPrint('Geo detection skipped: $e');
      }

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

  Future<(bool needsPhone, bool needsFirstTimeWelcome)> _gate() async {
    final box = await Hive.openBox('app_prefs');
    final phone = box.get('phone_verified', defaultValue: false) as bool;
    final welcomed = box.get('dr_iris_welcomed', defaultValue: false) as bool;

    if (kDebugMode) {
      debugPrint('Startup Gate Status:');
      debugPrint('Phone verified: $phone');
      debugPrint('Dr Iris welcomed: $welcomed');
      debugPrint(
        'Will show: ${!phone ? "Phone" : !welcomed ? "Dr Iris Welcome" : "Home"}',
      );
    }

    return (!phone, !welcomed);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(bool, bool)>(
      future: _gate(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: _BrandSplash());
        }
        final data = snap.data ?? (true, true);
        final showPhone = data.$1;
        final showWelcome = data.$2;

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
            child: Text(
              AppLocalizations.of(context)!.trueCircle,
              style: const TextStyle(
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
