// lib/pages/service_locator_demo_page.dart

import 'package:flutter/material.dart';
import '../core/service_locator.dart';
import '../services/on_device_ai_service.dart';
import '../services/privacy_service.dart';
import '../widgets/service_status_widget.dart';

/// Service Locator का उपयोग demonstrate करने के लिए comprehensive demo page
/// 
/// यह page दिखाता है कि कैसे किसी भी widget में Service Locator का उपयोग करके
/// प्लेटफॉर्म की चिंता किए बिना AI services को access कर सकते हैं
class ServiceLocatorDemoPage extends StatefulWidget {
  const ServiceLocatorDemoPage({super.key});

  @override
  State<ServiceLocatorDemoPage> createState() => _ServiceLocatorDemoPageState();
}

class _ServiceLocatorDemoPageState extends State<ServiceLocatorDemoPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _chatMessages = [];
  bool _isLoading = false;

  // 1. Service Locator से AI Service को access करना - प्लेटफॉर्म की चिंता किए बिना
  OnDeviceAIService? _aiService;
  PrivacyService? _privacyService;
  bool _servicesInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  /// Services को initialize करना
  void _initializeServices() {
    try {
      // AI Service को access करना
      _aiService = ServiceLocator.instance.get<OnDeviceAIService>();
      debugPrint('✅ ServiceLocatorDemo: AI Service loaded successfully');
      
      // Privacy Service को access करना
      _privacyService = ServiceLocator.instance.get<PrivacyService>();
      debugPrint('✅ ServiceLocatorDemo: Privacy Service loaded successfully');
      
      _servicesInitialized = true;
      
    } catch (e) {
      debugPrint('❌ ServiceLocatorDemo: Services not available: $e');
      _servicesInitialized = false;
    }
    
    setState(() {}); // UI को update करना
  }

  void _addWelcomeMessage() {
    _chatMessages.add({
      'text': 'स्वागत है! यह Service Locator Demo है। मैं दिखा सकता हूं कि कैसे किसी भी प्लेटफॉर्म पर AI service का उपयोग करते हैं।',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
  }

  /// 2. Message भेजना - Service को call करना (प्लेटफॉर्म की चिंता किए बिना)
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // User message add करना
    setState(() {
      _chatMessages.add({
        'text': message,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _messageController.clear();

    try {
      String response;
      
      if (_servicesInitialized && _aiService != null) {
        // Service Locator के through AI service का उपयोग
        debugPrint('📤 ServiceLocatorDemo: Sending to AI service: $message');
        response = await _aiService!.generateDrIrisResponse(message);
        debugPrint('📥 ServiceLocatorDemo: Received AI response');
        
        // Privacy status भी check करना
        final privacyStatus = _privacyService?.isDemoMode() ?? true;
        if (privacyStatus) {
          response += '\n\n(प्राइवेसी मोड: यह response on-device processing के साथ generated है)';
        }
        
      } else {
        // Fallback response
        response = 'Service Locator Demo: AI service उपलब्ध नहीं है। यह एक fallback response है।';
      }

      // Bot response add करना
      setState(() {
        _chatMessages.add({
          'text': response,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });

    } catch (e) {
      debugPrint('❌ ServiceLocatorDemo: Error: $e');
      
      setState(() {
        _chatMessages.add({
          'text': 'Error: AI service से response नहीं मिल सका। यह demo fallback response है।',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Locator Demo'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _initializeServices();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Services refreshed!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Service Status Card
          const ServiceStatusWidget(),
          
          // Service Information Card
          _buildServiceInfoCard(),
          
          // Chat Messages
          Expanded(
            child: _buildChatList(),
          ),
          
          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildServiceInfoCard() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _servicesInitialized ? Icons.check_circle : Icons.error,
                  color: _servicesInitialized ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Service Locator Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _servicesInitialized
                  ? '✅ AI Service: Available\n✅ Privacy Service: Available\n🎯 प्लेटफॉर्म की चिंता किए बिना services का उपयोग'
                  : '❌ Services not initialized\n⚠️ Fallback mode active',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            FutureBuilder<Map<String, dynamic>>(
              future: _getDetailedServiceStatus(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                
                final status = snapshot.data!;
                return Text(
                  'Platform: ${status['platform']}\nAI Service Type: ${status['ai_service_type']}\nDemo Mode: ${status['demo_mode']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getDetailedServiceStatus() async {
    try {
      final serviceLocator = ServiceLocator.instance;
      final aiStatus = serviceLocator.getAIServiceStatus();
      
      return {
        'platform': aiStatus['platform'] ?? 'Unknown',
        'ai_service_type': aiStatus['ai_service_type'] ?? 'Not Available',
        'demo_mode': _privacyService?.isDemoMode() ?? true,
      };
    } catch (e) {
      return {
        'platform': 'Unknown',
        'ai_service_type': 'Error',
        'demo_mode': true,
      };
    }
  }

  Widget _buildChatList() {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(8.0),
      itemCount: _chatMessages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == 0) {
          return _buildLoadingMessage();
        }
        
        final messageIndex = _isLoading ? index - 1 : index;
        final message = _chatMessages.reversed.toList()[messageIndex];
        
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildLoadingMessage() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('AI service processing...'),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final text = message['text'] as String;
    final timestamp = message['timestamp'] as DateTime;

    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[600] : Colors.grey[200],
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isUser ? Colors.white70 : Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Service Locator को test करने के लिए message भेजें...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (_) => _sendMessage(),
              enabled: !_isLoading,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor: Colors.blue[600],
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Utility extension for easier Service Locator usage
extension ServiceLocatorExtension on State {
  /// Quick access to Service Locator instance
  ServiceLocator get services => ServiceLocator.instance;
  
  /// Safe service access with error handling
  T? getService<T>() {
    try {
      return services.get<T>();
    } catch (e) {
      debugPrint('Service $T not available: $e');
      return null;
    }
  }
  
  /// Check if service is available
  bool hasService<T>() {
    return services.isRegistered<T>();
  }
}