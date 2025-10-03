// lib/widgets/service_status_widget.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:truecircle/core/service_locator.dart';
import 'package:truecircle/services/on_device_ai_service.dart';
import 'package:truecircle/services/privacy_service.dart';

/// Service Locator की स्थिति दिखाने के लिए एक छोटा widget
/// यह home page या किसी भी page में use कर सकते हैं
class ServiceStatusWidget extends StatelessWidget {
  const ServiceStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'Service Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<Map<String, dynamic>>(
              future: _getServiceStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                
                final status = snapshot.data ?? {};
                return Column(
                  children: [
                    _buildStatusRow(
                      'Privacy Mode',
                      status['privacy_mode'] ?? true,
                      status['privacy_mode'] == true ? Colors.green : Colors.orange,
                    ),
                    _buildStatusRow(
                      'AI Service',
                      status['ai_available'] ?? false,
                      status['ai_available'] == true ? Colors.green : Colors.red,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color, width: 1),
            ),
            child: Text(
              status ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getServiceStatus() async {
    try {
      final serviceLocator = ServiceLocator.instance;
      
      // Privacy Service status
      bool privacyMode = true;
      try {
        final privacyService = serviceLocator.get<PrivacyService>();
  privacyMode = privacyService.isPrivacyMode();
      } catch (e) {
        debugPrint('Privacy service check failed: $e');
      }
      
      // AI Service status
      bool aiAvailable = false;
      try {
        serviceLocator.get<OnDeviceAIService>();
        aiAvailable = true;
      } catch (e) {
        debugPrint('AI service check failed: $e');
      }
      
      return {
        'privacy_mode': privacyMode,
        'ai_available': aiAvailable,
      };
    } catch (e) {
      return {
        'privacy_mode': true,
        'ai_available': false,
        'error': e.toString(),
      };
    }
  }
}

/// Dr. Iris से quick chat के लिए floating action button
class DrIrisQuickChatFAB extends StatelessWidget {
  const DrIrisQuickChatFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickChat(context),
      icon: const Icon(Icons.psychology),
      label: const Text('Dr. Iris'),
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
    );
  }

  void _showQuickChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DrIrisQuickChatBottomSheet(),
    );
  }
}

class DrIrisQuickChatBottomSheet extends StatefulWidget {
  const DrIrisQuickChatBottomSheet({super.key});

  @override
  State<DrIrisQuickChatBottomSheet> createState() => _DrIrisQuickChatBottomSheetState();
}

class _DrIrisQuickChatBottomSheetState extends State<DrIrisQuickChatBottomSheet> {
  final TextEditingController _messageController = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      // Service Locator से AI service प्राप्त करना
      final serviceLocator = ServiceLocator.instance;
      final aiService = serviceLocator.get<OnDeviceAIService>();
      
      final response = await aiService.generateDrIrisResponse(message);
      
      setState(() {
        _response = response;
        _isLoading = false;
      });
      
      _messageController.clear();
    } catch (e) {
      setState(() {
        _response = 'Dr. Iris (Privacy Mode): मैं यहाँ आपकी सहायता के लिए हूँ। सभी बातचीत आपके डिवाइस पर निजी रूप से होती है।';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.purple[600]),
                const SizedBox(width: 8),
                const Text(
                  'Dr. Iris Quick Chat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Message input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Dr. Iris से कुछ पूछें...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            
            // Response area
            if (_response.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Text(
                  _response,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Service Locator Debug Panel (Development के लिए)
class ServiceLocatorDebugPanel extends StatelessWidget {
  const ServiceLocatorDebugPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // केवल debug mode में दिखाना
    if (!kDebugMode) return const SizedBox.shrink();
    
    return ExpansionTile(
      title: const Text('Service Locator Debug'),
      leading: Icon(Icons.bug_report, color: Colors.orange[600]),
      children: [
        FutureBuilder<Map<String, String>>(
          future: _getRegisteredServices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Loading services...'),
              );
            }
            
            final services = snapshot.data ?? {};
            
            return Column(
              children: services.entries.map((entry) {
                return ListTile(
                  dense: true,
                  leading: Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                  title: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<Map<String, String>> _getRegisteredServices() async {
    try {
      final serviceLocator = ServiceLocator.instance;
      return serviceLocator.getRegisteredServices();
    } catch (e) {
      return {'Error': e.toString()};
    }
  }
}