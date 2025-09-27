
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart'; // Import the new AuthWrapper
import 'models/emotion_entry.dart';
import 'models/contact.dart';
import 'models/contact_interaction.dart';
import 'models/privacy_settings.dart';
import 'l10n/app_localizations.dart';

// Duplicating the main function to ensure all initializations are correctly handled.
// This is a temporary measure to integrate Firebase Auth.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A single, robust initialization for Firebase.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
    // We can decide if the app should run without Firebase.
    // For now, we'll continue, but auth-dependent features will fail.
  }

  // The existing Hive initialization logic.
  try {
    await Hive.initFlutter('truecircle_data');
    debugPrint('✅ Hive path initialized');
    _registerAdapterSafely<EmotionEntry>(0, () => EmotionEntryAdapter());
    _registerAdapterSafely<Contact>(1, () => ContactAdapter());
    _registerAdapterSafely<ContactStatus>(2, () => ContactStatusAdapter());
    _registerAdapterSafely<ContactInteraction>(
        3, () => ContactInteractionAdapter());
    _registerAdapterSafely<InteractionType>(4, () => InteractionTypeAdapter());
    _registerAdapterSafely<EmotionalScore>(5, () => EmotionalScoreAdapter());
    _registerAdapterSafely<PrivacySettings>(6, () => PrivacySettingsAdapter());
    debugPrint('✅ All Hive adapters registered');
  } catch (e) {
    debugPrint('❌ Hive initialization failed: $e');
  }

  runApp(const TrueCircleApp());
}

void _registerAdapterSafely<T>(int typeId, dynamic Function() adapterFactory) {
  try {
    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter(adapterFactory());
      debugPrint('✅ Registered adapter $typeId for ${T.toString()}');
    } else {
      debugPrint('ℹ️ Adapter $typeId already registered for ${T.toString()}');
    }
  } catch (e) {
    debugPrint('❌ Failed to register adapter $typeId: $e');
  }
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
        primarySwatch: Colors.deepPurple, // Changed to deepPurple for consistency
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, // Changed to deepPurple
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple, // Consistent AppBar color
          foregroundColor: Colors.white, // White title for better contrast
          elevation: 2,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple, // Button color
            foregroundColor: Colors.white, // Button text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      // The AuthWrapper is now the entry point of the app.
      home: const AuthWrapper(), 
    );
  }
}
