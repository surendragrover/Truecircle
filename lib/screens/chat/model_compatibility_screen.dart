import 'package:flutter/material.dart';

import '../../services/onnx_three_brain_inference.dart';
import '../../services/three_brain_relay_service.dart';

class ModelCompatibilityScreen extends StatefulWidget {
  const ModelCompatibilityScreen({super.key});

  @override
  State<ModelCompatibilityScreen> createState() =>
      _ModelCompatibilityScreenState();
}

class _ModelCompatibilityScreenState extends State<ModelCompatibilityScreen> {
  final ThreeBrainRelayService _relay = ThreeBrainRelayService.instance;
  late Future<ModelCompatibilityReport> _future;

  @override
  void initState() {
    super.initState();
    _future = _relay.runModelCompatibilityCheck();
  }

  void _refresh() {
    setState(() {
      _future = _relay.runModelCompatibilityCheck();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model I/O Compatibility'),
        actions: <Widget>[
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<ModelCompatibilityReport>(
        future: _future,
        builder: (BuildContext context,
            AsyncSnapshot<ModelCompatibilityReport> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Could not run compatibility check.'),
            );
          }

          final ModelCompatibilityReport report = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(14),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: report.allCompatible
                      ? const Color(0xFFDDF8E4)
                      : const Color(0xFFFFE7D9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  report.allCompatible
                      ? 'All three brains are I/O compatible.'
                      : 'Some brains are not fully compatible. Fallback mode is active for unavailable brains.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (!report.allCompatible) ...<Widget>[
                const SizedBox(height: 8),
                const Text(
                  'Fallback means Dr Iris will continue with built-in CBT guidance where ONNX output is unavailable.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
              const SizedBox(height: 10),
              ...report.results.map(_resultCard),
            ],
          );
        },
      ),
    );
  }

  Widget _resultCard(BrainCompatibilityResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  result.ioCompatible ? Icons.check_circle : Icons.warning_amber,
                  color: result.ioCompatible ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  result.role.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Resolved: ${result.resolved ? "Yes" : "No"}',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Model: ${result.modelPath.isEmpty ? "(none)" : result.modelPath}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              'Output sample: ${result.outputSample.isEmpty ? "(empty)" : result.outputSample}',
              style: const TextStyle(fontSize: 12),
            ),
            if (result.error != null && result.error!.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                'Error: ${result.error}',
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
