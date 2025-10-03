import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization with fallback strategy
  try {
    try {
      await Firebase.initializeApp(); // prefer auto (uses google-services.json / plist)
      debugPrint('✅ [main] Firebase auto initialized');
    } catch (autoErr) {
      debugPrint('ℹ️ [main] Auto init failed ($autoErr) – trying explicit options');
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      debugPrint('✅ [main] Firebase initialized with explicit options');
    }
  } catch (e) {
    debugPrint('❌ [main] Firebase initialization ultimately failed: $e');
  }

  try {
    await Hive.initFlutter('truecircle_data');
    debugPrint('✅ [main] Hive path initialized successfully.');
  } catch (e) {
    debugPrint('❌ [main] Hive initialization failed: $e');
  }

  runApp(const TrueCircleApp());
}

class TrueCircleApp extends StatelessWidget {
  const TrueCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrueCircle',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
