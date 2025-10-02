import 'package:flutter/material.dart';
import 'package:truecircle/home_page.dart';
import 'package:truecircle/services/hive_initializer.dart';

class InitializationWrapper extends StatefulWidget {
  const InitializationWrapper({super.key});

  @override
  State<InitializationWrapper> createState() => _InitializationWrapperState();
}

class _InitializationWrapperState extends State<InitializationWrapper> {
  late final Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeSystem();
  }

  Future<void> _initializeSystem() async {
    try {
      debugPrint('[InitializationWrapper] Starting system initialization...');
      await HiveInitializer.registerAdapters();
      debugPrint('[InitializationWrapper] System initialization complete.');
    } catch (e) {
      debugPrint('❌ [InitializationWrapper] CRITICAL FAILURE during system initialization: $e');
      throw Exception('Failed to initialize critical components.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error?.toString() ?? 'An unknown error occurred.'}\nPlease restart the app.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return const HomePage();
      },
    );
  }
}
