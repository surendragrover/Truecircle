import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/emotion_entry.dart';
import 'models/contact.dart';
import 'models/contact_interaction.dart';
import 'models/privacy_settings.dart';
import 'pages/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive for local data storage
    await Hive.initFlutter('truecircle_data');
    debugPrint('✅ Hive path initialized');

    // Register Hive adapters for TrueCircle models
    _registerAdapterSafely<EmotionEntry>(0, () => EmotionEntryAdapter());
    _registerAdapterSafely<Contact>(1, () => ContactAdapter());
    _registerAdapterSafely<ContactStatus>(2, () => ContactStatusAdapter());
    _registerAdapterSafely<ContactInteraction>(3, () => ContactInteractionAdapter());
    _registerAdapterSafely<InteractionType>(4, () => InteractionTypeAdapter());
    _registerAdapterSafely<EmotionalScore>(5, () => EmotionalScoreAdapter());
    _registerAdapterSafely<PrivacySettings>(6, () => PrivacySettingsAdapter());

    debugPrint('✅ All Hive adapters registered');
  } catch (e) {
    debugPrint('❌ Hive initialization failed: $e');
  }

  runApp(const TrueCircleApp());
}

void _registerAdapterSafely<T>(int typeId, TypeAdapter Function() adapterFactory) {
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
      title: 'TrueCircle - Windows',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}
