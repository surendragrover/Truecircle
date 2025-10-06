import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home_page.dart';
import 'models/emotion_entry.dart';
import 'models/contact.dart';
import 'models/contact_interaction.dart';
import 'models/privacy_settings.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();

    // Register all adapters
    Hive.registerAdapter(EmotionEntryAdapter());
    Hive.registerAdapter(ContactAdapter());
    Hive.registerAdapter(ContactInteractionAdapter());
    Hive.registerAdapter(InteractionTypeAdapter());
    Hive.registerAdapter(EmotionalScoreAdapter());
    Hive.registerAdapter(ContactStatusAdapter());
    Hive.registerAdapter(PrivacySettingsAdapter());

    // Open boxes
    await Hive.openBox<EmotionEntry>('emotion_entries');
    await Hive.openBox<Contact>('contacts');
    await Hive.openBox<ContactInteraction>('contact_interactions');
    await Hive.openBox<PrivacySettings>('privacy_settings');
  } catch (e) {
    debugPrint('Error initializing Hive: $e');
  }

  runApp(const TrueCircleApp());
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

      home: const HomePage(),
    );
  }
}
