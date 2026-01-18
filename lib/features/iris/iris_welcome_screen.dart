import 'package:flutter/material.dart';

class IrisWelcomeScreen extends StatelessWidget {
  const IrisWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dr. Iris")),
      body: const Center(
        child: Text("Dr. Iris screen (demo)"),
      ),
    );
  }
}
