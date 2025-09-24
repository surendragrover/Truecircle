import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/welcome_screen.dart';
import 'models/emotion_entry.dart';
import 'models/contact.dart';
import 'models/contact_interaction.dart';
import 'models/privacy_settings.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive with simpler error handling
    await Hive.initFlutter('truecircle_data');
    debugPrint('✅ Hive path initialized');

    // Register adapters with try-catch for each (FIXED TYPE IDs)
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
    // Continue anyway - app will work without local storage
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

      // Localization support
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,

        // TrueCircle custom theme
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[50],
          foregroundColor: Colors.blue[900],
          elevation: 0,
          centerTitle: true,
        ),

        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
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
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),

      home: const WelcomeScreen(),
    );
  }
}
