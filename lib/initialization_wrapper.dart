import 'package:flutter/material.dart';
import 'services/hive_initializer.dart';
import 'auth_wrapper.dart'; // Corrected: Use AuthWrapper to handle user state

class InitializationWrapper extends StatefulWidget {
  const InitializationWrapper({super.key});

  @override
  State<InitializationWrapper> createState() => _InitializationWrapperState();
}

class _InitializationWrapperState extends State<InitializationWrapper> {
  Future<void>? _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // This is a placeholder for any initial service calls like Hive, etc.
      // For now, we are just ensuring the flow is correct.
      await HiveInitializer.registerAdapters();
      debugPrint('✅ [InitializationWrapper] Services initialized');
    } catch (e) {
      debugPrint("❌ [InitializationWrapper] INITIALIZATION ERROR: $e");
      // Rethrowing the error so the FutureBuilder can catch it.
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            // A more user-friendly and scrollable error screen
            return Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 60),
                          const SizedBox(height: 20),
                          Text(
                            'An error occurred during app startup.',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Please restart the app. If the problem persists, contact support.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Error Details: ${snapshot.error}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          // Correct Navigation: Go to AuthWrapper to decide which screen to show
          return const AuthWrapper();
        }

        // A clean loading screen that respects the app's theme
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 20),
                Text(
                  'Initializing...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}