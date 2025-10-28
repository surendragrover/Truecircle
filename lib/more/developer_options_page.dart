import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';
import '../services/dr_iris_ai_service.dart';
import '../services/on_device_ai_service.dart';

class DeveloperOptionsPage extends StatefulWidget {
  const DeveloperOptionsPage({super.key});

  @override
  State<DeveloperOptionsPage> createState() => _DeveloperOptionsPageState();
}

class _DeveloperOptionsPageState extends State<DeveloperOptionsPage> {
  bool _enhancedSupported = false;
  bool _basicSupported = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // No fallback controls in default app; only model status checks
  }

  Future<void> _checkAiStatus() async {
    setState(() => _checking = true);
    try {
      // Check enhanced model
      final enhanced = DrIrisAIService.instance;
      final supported = await enhanced.initialize();

      // Check basic model
      final basic = OnDeviceAIService.instance();
      final basicSupported = await basic.isSupported();
      if (basicSupported) {
        await basic.initialize();
      }

      if (!mounted) return;
      setState(() {
        _enhancedSupported = supported;
        _basicSupported = basicSupported;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _enhancedSupported = false;
        _basicSupported = false;
      });
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'Developer Options'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Fallback controls removed in default app
          Text(
            'AI Model Status',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(
              _enhancedSupported
                  ? Icons.psychology
                  : Icons.psychology_alt_outlined,
              color: _enhancedSupported ? Colors.green : Colors.grey,
            ),
            title: const Text('Enhanced TrueCircle.tflite Model'),
            subtitle: Text(
              _enhancedSupported
                  ? 'Active and initialized'
                  : 'Unavailable / not initialized',
            ),
          ),
          ListTile(
            leading: Icon(
              _basicSupported ? Icons.memory : Icons.memory_outlined,
              color: _basicSupported ? Colors.green : Colors.grey,
            ),
            title: const Text('Basic On-Device AI Service'),
            subtitle: Text(_basicSupported ? 'Supported' : 'Unavailable'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _checking ? null : _checkAiStatus,
            icon: _checking
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            label: Text(_checking ? 'Checking...' : 'Check / Initialize AI'),
          ),
        ],
      ),
    );
  }
}
