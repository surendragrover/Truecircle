// lib/core/service_locator_usage_example.dart

import 'package:flutter/material.dart';
import 'package:truecircle/core/service_locator.dart';
import 'package:truecircle/core/app_initialization.dart';
import 'package:truecircle/services/on_device_ai_service.dart';
import 'package:truecircle/services/privacy_service.dart';

/// Service Locator का उपयोग करने के लिए example widgets
/// 
/// यह file दिखाती है कि कैसे विभिन्न widgets में Service Locator का उपयोग करें

/// Example 1: AI Chat Widget जो Service Locator का उपयोग करता है
class AIServiceExample extends StatefulWidget {
  const AIServiceExample({super.key});

  @override
  State<AIServiceExample> createState() => _AIServiceExampleState();
}

class _AIServiceExampleState extends State<AIServiceExample> {
  late OnDeviceAIService _aiService;
  String _response = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    try {
      // Service Locator से AI service प्राप्त करना
      _aiService = ServiceLocator.instance.get<OnDeviceAIService>();
      debugPrint('✅ AI Service loaded from Service Locator');
    } catch (e) {
      debugPrint('❌ AI Service not available: $e');
    }
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final response = await _aiService.generateDrIrisResponse(message);
      setState(() {
        _response = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Service Example',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _sendMessage('मैं तनाव महसूस कर रहा हूँ'),
              child: const Text('Dr. Iris से बात करें'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_response.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_response),
              ),
          ],
        ),
      ),
    );
  }
}

/// Example 2: Privacy Status Widget
class PrivacyStatusExample extends StatelessWidget {
  const PrivacyStatusExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _getPrivacyStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final status = snapshot.data ?? {};
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusRow('Demo Mode', status['is_demo_mode'] ?? false),
                    _buildStatusRow('AI Available', status['ai_available'] ?? false),
                    _buildStatusRow('Privacy Service', status['privacy_service_active'] ?? false),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getPrivacyStatus() async {
    try {
      final serviceLocator = ServiceLocator.instance;
      
      // Privacy Service की जाँच
      final privacyService = serviceLocator.get<PrivacyService>();
      final isDemoMode = privacyService.isDemoMode();
      
      // AI Service की जाँच
      final hasAI = serviceLocator.hasAIService;
      
      return {
        'is_demo_mode': isDemoMode,
        'ai_available': hasAI,
        'privacy_service_active': true,
      };
    } catch (e) {
      return {
        'is_demo_mode': true,
        'ai_available': false,
        'privacy_service_active': false,
        'error': e.toString(),
      };
    }
  }
}

/// Example 3: Service Health Check Widget
class ServiceHealthCheckExample extends StatelessWidget {
  const ServiceHealthCheckExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Services Health Check',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _performHealthCheck(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final healthData = snapshot.data ?? {};
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHealthCard('Service Locator', healthData['service_locator']),
                    _buildHealthCard('Privacy Service', healthData['privacy_service']),
                    _buildHealthCard('AI Service', healthData['ai_service']),
                    _buildHealthCard('JSON Data Service', healthData['json_data_service']),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(String serviceName, Map<String, dynamic>? serviceData) {
    final status = serviceData?['status'] ?? 'unknown';
    final isHealthy = status == 'healthy';
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isHealthy ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isHealthy ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(serviceName),
          Row(
            children: [
              Icon(
                isHealthy ? Icons.check_circle : Icons.error,
                color: isHealthy ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                status,
                style: TextStyle(
                  color: isHealthy ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _performHealthCheck() async {
    try {
      // AppInitialization के health check method का उपयोग
      return await AppInitialization.performHealthCheck();
    } catch (e) {
      return {
        'error': e.toString(),
        'overall_status': 'error',
      };
    }
  }
}

/// Complete example page जो सभी examples को दिखाता है
class ServiceLocatorExamplePage extends StatelessWidget {
  const ServiceLocatorExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Locator Examples'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            AIServiceExample(),
            SizedBox(height: 16),
            PrivacyStatusExample(),
            SizedBox(height: 16),
            ServiceHealthCheckExample(),
          ],
        ),
      ),
    );
  }
}

/// Extension for easier Service Locator access in widgets
extension ServiceLocatorWidget on State {
  ServiceLocator get services => ServiceLocator.instance;
}

/// Mixin for widgets that need service access
mixin ServiceLocatorMixin<T extends StatefulWidget> on State<T> {
  ServiceLocator get serviceLocator => ServiceLocator.instance;
  
  /// Safe service access with error handling
  S? getService<S>() {
    try {
      return serviceLocator.get<S>();
    } catch (e) {
      debugPrint('Service $S not available: $e');
      return null;
    }
  }
  
  /// Check if service is available
  bool hasService<S>() {
    return serviceLocator.isRegistered<S>();
  }
}