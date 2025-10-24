import 'package:flutter/material.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Offline placeholder. No network calls. Future: curated content, all on-device compliant.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
