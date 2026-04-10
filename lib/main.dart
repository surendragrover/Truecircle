import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/ai/chat_engine.dart';
import 'services/app_language_service.dart';
import 'services/content_seed_service.dart';
import 'services/country_detector_service.dart';
import 'services/sos_service.dart';
import 'screens/app/app_shell.dart';
import 'screens/content/json_content_screen.dart';
import 'screens/intro/dr_iris_intro_screen.dart';
import 'screens/onboarding/language_selection_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'theme/truecircle_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // -------------------------------------------------
  // STEP 1: Model paths (DEBUG + SAFETY)
  // -------------------------------------------------
  final dir = await getApplicationSupportDirectory();
  final modelDir = '${dir.path}\\truecircle_models';

  debugPrint('Model directory: $modelDir');
  debugPrint('Brain A: $modelDir\\braina_lite.onnx');
  debugPrint('Brain 1: $modelDir\\brain1_lite.onnx');
  debugPrint('Brain 2: $modelDir\\brain2_lite.onnx');

  // -------------------------------------------------
  // Local storage (Hive)
  // -------------------------------------------------
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  await Hive.openBox('appBox');
  await Hive.openBox('contentBox');
  await _bootstrapFirstInstallDefaults();
  await AppLanguageService.loadSavedLocale();

  // -------------------------------------------------
  // Orientation lock
  // -------------------------------------------------
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // -------------------------------------------------
  // 🔥 MODEL INITIALIZATION (CRITICAL)
  // -------------------------------------------------
  await ChatEngine.initModel(modelDir);

  // -------------------------------------------------
  // START APP (ONLY ONCE)
  // -------------------------------------------------
  runApp(const TrueCircleApp());
}

Future<void> _bootstrapFirstInstallDefaults() async {
  if (!Hive.isBoxOpen('appBox')) return;
  final Box<dynamic> appBox = Hive.box('appBox');
  final bool alreadyBootstrapped =
      (appBox.get('install_bootstrap_done', defaultValue: false) as bool?) ??
          false;
  if (alreadyBootstrapped) return;

  final String? detected = await CountryDetectorService.detect();
  final String countryCode = (detected == null || detected.trim().isEmpty)
      ? 'IN'
      : detected.toUpperCase();

  await SOSService.saveEmergencyNumbersFor(countryCode);
  await appBox.put('detected_country_code', countryCode);
  await appBox.put('is_online', false);
  if (!appBox.containsKey('app_language_code')) {
    await appBox.put('app_language_code', 'en');
  }
  await appBox.put('language_selection_done', false);
  await appBox.put('install_bootstrap_done', true);
}

class TrueCircleApp extends StatelessWidget {
  const TrueCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageService.localeNotifier,
      builder: (BuildContext context, Locale locale, Widget? child) {
        return MaterialApp(
          title: 'TrueCircle',
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: const <Locale>[
            Locale('en'),
            Locale('hi'),
          ],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: TrueCircleTheme.brandPrimary,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: TrueCircleTheme.surfaceTint,
            appBarTheme: const AppBarTheme(
              backgroundColor: TrueCircleTheme.brandPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            fontFamily: 'Poppins',
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _bootstrapTimer;

  @override
  void initState() {
    super.initState();
    _bootstrapTimer = Timer(
      const Duration(milliseconds: 1200),
      () {
        unawaited(_bootstrap());
      },
    );
  }

  @override
  void dispose() {
    _bootstrapTimer?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;

    // -------------------------------------------------
    // Seed static content (non-blocking)
    // -------------------------------------------------
    try {
      await ContentSeedService().seedFeatureContentIfNeeded();
    } catch (_) {
      // ignore safely
    }

    // -------------------------------------------------
    // App state checks
    // -------------------------------------------------
    final bool hasContactVerification = _isContactVerificationComplete();

    final bool hasSeenDrIrisIntro = Hive.isBoxOpen('appBox')
        ? (Hive.box('appBox').get('dr_iris_intro_complete', defaultValue: false)
                as bool? ??
            false)
        : false;
    final bool hasFirstCheckIn = Hive.isBoxOpen('appBox')
        ? (Hive.box('appBox').get('first_checkin_done', defaultValue: false)
                as bool? ??
            false)
        : false;

    if (!mounted) return;

    if (!_isLanguageSelectionDone()) {
      final bool? selected = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => const LanguageSelectionScreen(),
        ),
      );
      if (!mounted) return;
      if (selected == true) {
        await _bootstrap();
      }
      return;
    }

    // -------------------------------------------------
    // Routing logic
    // -------------------------------------------------
    if (hasContactVerification && hasSeenDrIrisIntro && hasFirstCheckIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const AppShell(),
        ),
      );
      return;
    }

    if (!hasContactVerification) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const OnboardingScreen(),
        ),
      );
      return;
    }

    if (hasContactVerification && hasSeenDrIrisIntro && !hasFirstCheckIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const JsonContentScreen(
            title: 'Emotional Check-In: Emotion Snapshot',
            assetPath: 'assets/data/Feeling_Identification.JSON',
            markFirstCheckInDoneOnSubmit: true,
            navigateToDashboardOnSubmit: true,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const DrIrisIntroScreen(),
      ),
    );
  }

  bool _isLanguageSelectionDone() {
    if (!Hive.isBoxOpen('appBox')) return false;
    final Box<dynamic> appBox = Hive.box('appBox');
    final bool done =
        (appBox.get('language_selection_done', defaultValue: false) as bool?) ??
            false;
    return done;
  }

  bool _isContactVerificationComplete() {
    if (!Hive.isBoxOpen('appBox')) return false;
    final Box<dynamic> appBox = Hive.box('appBox');
    final bool v2Verified =
        (appBox.get('onboarding_v2_verified', defaultValue: false) as bool?) ??
            false;
    final bool contactVerified = (appBox.get('contact_verification_complete',
            defaultValue: false) as bool?) ??
        false;
    final bool legacyOnboarding =
        (appBox.get('onboarding_complete', defaultValue: false) as bool?) ??
            false;
    final String email =
        (appBox.get('user_email', defaultValue: '') as String?)?.trim() ?? '';
    final String mobile =
        (appBox.get('user_mobile', defaultValue: '') as String?)?.trim() ?? '';
    final bool hasIdentity = email.isNotEmpty && mobile.isNotEmpty;
    return (v2Verified || contactVerified || legacyOnboarding) && hasIdentity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: TrueCircleTheme.appBackgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ClipOval(
                child: SizedBox(
                  width: 124,
                  height: 124,
                  child: Image(
                    image: const AssetImage('assets/images/logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'TrueCircle\nLoading...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                ChatEngine.modelReady
                    ? 'Model: ONNX READY'
                    : 'Model: FALLBACK MODE',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
