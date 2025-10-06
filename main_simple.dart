import 'package:flutter/material.dart';

/// Minimal test app for widget tests. No plugins, no async init.
class SimpleTestApp extends StatelessWidget {
  const SimpleTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrueCircle - Simple Test',
      home: Scaffold(
        appBar: AppBar(title: const Text('TrueCircle - Simple Test')),
        body: const Center(child: Text('TrueCircle App Working!')),
      ),
    );
  }
}
