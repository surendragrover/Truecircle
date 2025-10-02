import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'home_page.dart';
import 'pages/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Skip all Firebase and complex initialization for web
  if (kDebugMode) {
    print('🚀 TrueCircle Chrome - Simplified Launch');
  }

  runApp(const TrueCircleApp());
}

class TrueCircleApp extends StatelessWidget {
  const TrueCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrueCircle - Chrome Ready',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        // BLACK TEXT THEME - All buttons will have black text
        textTheme: const TextTheme(
          displayLarge:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          displayMedium:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          displaySmall:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          headlineLarge:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          headlineMedium:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          headlineSmall:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          titleLarge:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          titleMedium:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          titleSmall:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.black, fontSize: 14),
          bodySmall: TextStyle(color: Colors.black, fontSize: 12),
          labelLarge:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          labelMedium:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          labelSmall:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, // BLACK BUTTON TEXT
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
