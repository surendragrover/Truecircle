import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/app_localization_service.dart';
import 'services/indian_languages_service.dart';
import 'services/translation_api_service.dart';
import 'widgets/localized_app_main.dart';

/// Fully Localized TrueCircle App
/// Supports all major Indian languages
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize services
  await IndianLanguagesService.initialize();
  await AppLocalizationService.instance.initialize();

  // Initialize translation API
  TranslationApiService.instance.initialize("sample_api_key");

  runApp(const LocalizedTrueCircleApp());
}

class LocalizedTrueCircleApp extends StatelessWidget {
  const LocalizedTrueCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLocalizationService.instance,
      builder: (context, child) {
        final localizationService = AppLocalizationService.instance;

        return MaterialApp(
          title: localizationService.translate('app_name'),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.light,
            ),
            appBarTheme: AppBarTheme(
              centerTitle: true,
              backgroundColor: Colors.indigo[100],
              foregroundColor: Colors.black87,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: IndianLanguagesService.instance
                    .getFontFamily(localizationService.currentLanguage),
              ),
            ),
            cardTheme: const CardThemeData(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: TextStyle(
                  fontFamily: IndianLanguagesService.instance
                      .getFontFamily(localizationService.currentLanguage),
                ),
              ),
            ),
            textTheme: TextTheme(
              displayLarge: TextStyle(
                fontFamily: IndianLanguagesService.instance
                    .getFontFamily(localizationService.currentLanguage),
              ),
              displayMedium: TextStyle(
                fontFamily: IndianLanguagesService.instance
                    .getFontFamily(localizationService.currentLanguage),
              ),
              displaySmall: TextStyle(
                fontFamily: IndianLanguagesService.instance
                    .getFontFamily(localizationService.currentLanguage),
              ),
              headlineLarge: TextStyle(
                fontFamily: IndianLanguagesService.instance
                    .getFontFamily(localizationService.currentLanguage),
              ),
              headlineMedium: TextStyle(
                fontFamily: IndianLanguagesService.instance
                    .getFontFamily(localizationService.currentLanguage),
              ),
              headlineSmall: TextStyle(
                fontFamily: IndianLanguagesService.instance
                    .getFontFamily(localizationService.currentLanguage),
              ),
              titleLarge: TextStyle(
                fontFamily: IndianLanguagesService.instance
                    .getFontFamily(localizationService.currentLanguage),
              ),
              titleMedium: TextStyle(
                fontFamily: IndianLanguagesService.instance
                    .getFontFamily(localizationService.currentLanguage),
              ),
              titleSmall: TextStyle(
                fontFamily: IndianLanguagesService.instance
                    .getFontFamily(localizationService.currentLanguage),
              ),
              bodyLarge: TextStyle(
                fontFamily: IndianLanguagesService.instance
                    .getFontFamily(localizationService.currentLanguage),
              ),
              bodyMedium: TextStyle(
                fontFamily: IndianLanguagesService.instance
                    .getFontFamily(localizationService.currentLanguage),
              ),
              bodySmall: TextStyle(
                fontFamily: IndianLanguagesService.instance
                    .getFontFamily(localizationService.currentLanguage),
              ),
              labelLarge: TextStyle(
                fontFamily: IndianLanguagesService.instance
                    .getFontFamily(localizationService.currentLanguage),
              ),
              labelMedium: TextStyle(
                fontFamily: IndianLanguagesService.instance
                    .getFontFamily(localizationService.currentLanguage),
              ),
              labelSmall: TextStyle(
                fontFamily: IndianLanguagesService.instance
                    .getFontFamily(localizationService.currentLanguage),
              ),
            ),
          ),
          home: const LocalizedAppMain(),
          debugShowCheckedModeBanner: false,
          // Set text direction based on current language
          locale: Locale(localizationService.currentLanguage),
        );
      },
    );
  }
}
