import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ModelTestPage extends StatelessWidget {
  const ModelTestPage({super.key});

  Future<void> loadModel() async {
    final data = await rootBundle.load(
      'assets/models/model_int8.onnx',
    );
    debugPrint('MODEL LOADED: ${data.lengthInBytes} bytes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Model Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: loadModel,
          child: const Text('Load ONNX Model'),
        ),
      ),
    );
  }
}
