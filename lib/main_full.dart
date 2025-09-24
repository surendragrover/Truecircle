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
    // Initialize Hive in app directory instead of Documents
    await Hive.initFlutter('truecircle_data');

    // Register all adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(EmotionEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ContactAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ContactInteractionAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(InteractionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(EmotionalScoreAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(ContactStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(PrivacySettingsAdapter());
    }

    // Open boxes with comprehensive error recovery
    await _openHiveBoxSafely<EmotionEntry>('emotion_entries');
    await _openHiveBoxSafely<Contact>('contacts');
    await _openHiveBoxSafely<ContactInteraction>('contact_interactions');
    await _openHiveBoxSafely<PrivacySettings>('privacy_settings');

    debugPrint('✅ Hive initialized successfully');
  } catch (e) {
    debugPrint('❌ Critical error initializing Hive: $e');
    // Continue anyway - app will use fallback storage
  }

  runApp(const TrueCircleApp());
}

Future<void> _openHiveBoxSafely<T>(String boxName) async {
  int attempts = 0;
  const maxAttempts = 3;
  
  while (attempts < maxAttempts) {
    try {
      await Hive.openBox<T>(boxName);
      debugPrint('✅ Opened box: $boxName');
      return;
    } catch (e) {
      attempts++;
      debugPrint('❌ Attempt $attempts failed for $boxName: $e');
      
      if (attempts < maxAttempts) {
        try {
          // Try to delete corrupted box
          await Hive.deleteBoxFromDisk(boxName);
          debugPrint('🗑️ Deleted corrupted box: $boxName');
          
          // Wait a bit before retry
          await Future.delayed(Duration(milliseconds: 500 * attempts));
        } catch (deleteError) {
          debugPrint('⚠️ Could not delete box $boxName: $deleteError');
        }
      } else {
        debugPrint('💥 Failed to open $boxName after $maxAttempts attempts');
        // Create empty box as fallback
        try {
          await Hive.openBox<T>('${boxName}_fallback');
          debugPrint('🔄 Created fallback box for $boxName');
        } catch (fallbackError) {
          debugPrint('💀 Even fallback failed for $boxName: $fallbackError');
        }
      }
    }
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
