# Service Locator Usage Examples

TrueCircle में Service Locator का उपयोग करके platform-agnostic AI service access के practical examples।

## 🎯 Core Concept

**मुख्य सिद्धांत**: आपको यह जानने की जरूरत नहीं है कि आप किस platform पर हैं। बस Service Locator से `OnDeviceAIService` मांगें।

```dart
// कोई भी widget में - प्लेटफॉर्म की चिंता किए बिना
final OnDeviceAIService aiService = ServiceLocator.instance.get<OnDeviceAIService>();
```

## 📱 Practical Examples

### Example 1: Dr. Iris Chat Screen

```dart
// lib/pages/dr_iris_dashboard.dart

class _DrIrisDashboardState extends State<DrIrisDashboard> {
  // 1. Service को access करना
  OnDeviceAIService? _aiService;
  bool _serviceAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeAIService();
  }

  // 2. Service को initialize करना
  void _initializeAIService() {
    try {
      _aiService = ServiceLocator.instance.get<OnDeviceAIService>();
      _serviceAvailable = true;
      debugPrint('✅ AI Service initialized successfully');
    } catch (e) {
      _serviceAvailable = false;
      debugPrint('⚠️ AI Service not available: $e');
    }
  }

  // 3. Service को use करना
  void _sendPrompt(String text) async {
    try {
      if (_serviceAvailable && _aiService != null) {
        // Platform की चिंता किए बिना AI service का उपयोग
        String response = await _aiService!.generateDrIrisResponse(text);
        _addBotMessage(response);
      } else {
        // Fallback response
        _addBotMessage(_generateSampleResponse(text));
      }
    } catch (e) {
      debugPrint('Error: $e');
      // Handle error gracefully
    }
  }
}
```

### Example 2: Quick Chat Widget

```dart
// Quick chat floating action button
class DrIrisQuickChatFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickChat(context),
      icon: Icon(Icons.psychology),
      label: Text('Dr. Iris'),
    );
  }

  void _showQuickChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => QuickChatBottomSheet(),
    );
  }
}

class QuickChatBottomSheet extends StatefulWidget {
  @override
  State<QuickChatBottomSheet> createState() => _QuickChatBottomSheetState();
}

class _QuickChatBottomSheetState extends State<QuickChatBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() { _isLoading = true; });

    try {
      // Service Locator से AI service प्राप्त करना - प्लेटफॉर्म agnostic
      final aiService = ServiceLocator.instance.get<OnDeviceAIService>();
      final response = await aiService.generateDrIrisResponse(message);
      
      setState(() {
        _response = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _response = 'Dr. Iris: मैं यहाँ आपकी सहायता के लिए हूँ। (Privacy Mode)';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Dr. Iris से पूछें...'),
            onSubmitted: (_) => _sendMessage(),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _sendMessage,
            child: _isLoading 
              ? CircularProgressIndicator() 
              : Text('Send'),
          ),
          if (_response.isNotEmpty) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_response),
            ),
          ],
        ],
      ),
    );
  }
}
```

### Example 3: Emotion Analysis Widget

```dart
class EmotionAnalysisWidget extends StatefulWidget {
  final String emotionText;
  
  const EmotionAnalysisWidget({Key? key, required this.emotionText}) : super(key: key);

  @override
  State<EmotionAnalysisWidget> createState() => _EmotionAnalysisWidgetState();
}

class _EmotionAnalysisWidgetState extends State<EmotionAnalysisWidget> {
  String _analysis = '';
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _analyzeEmotion();
  }

  Future<void> _analyzeEmotion() async {
    setState(() { _isAnalyzing = true; });

    try {
      // Service Locator का उपयोग - प्लेटफॉर्म की चिंता नहीं
      final aiService = ServiceLocator.instance.get<OnDeviceAIService>();
      
      final prompt = 'यह emotion analyze करें: ${widget.emotionText}';
      final analysis = await aiService.generateDrIrisResponse(prompt);
      
      setState(() {
        _analysis = analysis;
        _isAnalyzing = false;
      });
      
    } catch (e) {
      setState(() {
        _analysis = 'Privacy Mode: Emotion analysis using sample patterns';
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Emotion Analysis', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            if (_isAnalyzing)
              Center(child: CircularProgressIndicator())
            else
              Text(_analysis),
          ],
        ),
      ),
    );
  }
}
```

### Example 4: Service Status Integration

```dart
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TrueCircle')),
      body: Column(
        children: [
          // Service status को display करना
          ServiceStatusWidget(),
          
          // Main content
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _buildFeatureCard('Dr. Iris Chat', Icons.psychology, () {
                  Navigator.push(context, 
                    MaterialPageRoute(builder: (_) => DrIrisDashboard())
                  );
                }),
                _buildFeatureCard('Emotion Analysis', Icons.mood, () {
                  _showEmotionAnalysis();
                }),
                // More features...
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: DrIrisQuickChatFAB(), // Quick AI access
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            SizedBox(height: 8),
            Text(title),
          ],
        ),
      ),
    );
  }

  void _showEmotionAnalysis() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emotion Analysis'),
        content: EmotionAnalysisWidget(emotionText: 'आज मैं थोड़ा परेशान हूँ'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
```

## 🛠️ Advanced Usage Patterns

### Using Mixins for Easier Access

```dart
// Service access mixin
mixin ServiceLocatorMixin<T extends StatefulWidget> on State<T> {
  ServiceLocator get serviceLocator => ServiceLocator.instance;
  
  S? getService<S>() {
    try {
      return serviceLocator.get<S>();
    } catch (e) {
      debugPrint('Service $S not available: $e');
      return null;
    }
  }
  
  bool hasService<S>() => serviceLocator.isRegistered<S>();
}

// Using the mixin
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with ServiceLocatorMixin {
  @override
  void initState() {
    super.initState();
    
    // Easy service access
    if (hasService<OnDeviceAIService>()) {
      final aiService = getService<OnDeviceAIService>()!;
      // Use AI service
    }
  }
}
```

### Service Status Monitoring

```dart
class ServiceMonitorWidget extends StatefulWidget {
  @override
  State<ServiceMonitorWidget> createState() => _ServiceMonitorWidgetState();
}

class _ServiceMonitorWidgetState extends State<ServiceMonitorWidget> {
  late Timer _statusTimer;
  Map<String, dynamic> _serviceStatus = {};

  @override
  void initState() {
    super.initState();
    _updateServiceStatus();
    
    // Periodic status updates
    _statusTimer = Timer.periodic(Duration(seconds: 5), (_) {
      _updateServiceStatus();
    });
  }

  @override
  void dispose() {
    _statusTimer.cancel();
    super.dispose();
  }

  void _updateServiceStatus() {
    final serviceLocator = ServiceLocator.instance;
    
    setState(() {
      _serviceStatus = {
        'ai_service_available': serviceLocator.hasAIService,
        'registered_services': serviceLocator.getRegisteredServices().length,
        'ai_service_status': serviceLocator.getAIServiceStatus(),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service Status', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('AI Service: ${_serviceStatus['ai_service_available'] ? '✅' : '❌'}'),
            Text('Services Registered: ${_serviceStatus['registered_services']}'),
            if (_serviceStatus['ai_service_status'] != null)
              Text('Platform: ${_serviceStatus['ai_service_status']['platform']}'),
          ],
        ),
      ),
    );
  }
}
```

## 🧪 Testing Service Locator Usage

### Unit Testing

```dart
// test/service_locator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:truecircle/core/service_locator.dart';
import 'package:truecircle/services/on_device_ai_service.dart';

void main() {
  group('Service Locator Tests', () {
    test('should register and retrieve AI service', () {
      // Arrange
      final serviceLocator = ServiceLocator.instance;
      final mockAIService = MockAIService();
      
      // Act
      serviceLocator.register<OnDeviceAIService>(mockAIService);
      final retrievedService = serviceLocator.get<OnDeviceAIService>();
      
      // Assert
      expect(retrievedService, equals(mockAIService));
      expect(serviceLocator.hasAIService, isTrue);
    });

    test('should handle service not found gracefully', () {
      // Arrange
      final serviceLocator = ServiceLocator.instance;
      serviceLocator.clear(); // Clear all services
      
      // Act & Assert
      expect(() => serviceLocator.get<OnDeviceAIService>(), 
             throwsA(isA<Exception>()));
    });
  });
}
```

### Widget Testing

```dart
// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truecircle/core/service_locator.dart';
import 'package:truecircle/pages/dr_iris_dashboard.dart';

void main() {
  group('Dr Iris Dashboard Widget Tests', () {
    setUp(() {
      // Mock service registration
      final mockAIService = MockAIService();
      ServiceLocator.instance.register<OnDeviceAIService>(mockAIService);
    });

    testWidgets('should display chat interface', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        MaterialApp(home: DrIrisDashboard()),
      );

      // Verify chat interface elements
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('should send message to AI service', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DrIrisDashboard()),
      );

      // Enter message
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Verify message was processed
      expect(find.text('Test message'), findsOneWidget);
    });
  });
}
```

## 🚀 Best Practices

### 1. Error Handling
```dart
// Always handle service availability
try {
  final aiService = ServiceLocator.instance.get<OnDeviceAIService>();
  // Use service
} catch (e) {
  // Fallback behavior
  debugPrint('AI Service not available: $e');
  // Show appropriate UI or use mock data
}
```

### 2. Service Initialization Check
```dart
// Check service availability before use
if (ServiceLocator.instance.hasAIService) {
  final aiService = ServiceLocator.instance.aiService;
  // Use service safely
} else {
  // Handle unavailable service
}
```

### 3. Graceful Degradation
```dart
// Provide fallback functionality
Future<String> getAIResponse(String prompt) async {
  try {
    final aiService = ServiceLocator.instance.get<OnDeviceAIService>();
    return await aiService.generateDrIrisResponse(prompt);
  } catch (e) {
    // Fallback to sample responses
    return _generateSampleResponse(prompt);
  }
}
```

### 4. Performance Considerations
```dart
// Cache service references for better performance
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  OnDeviceAIService? _cachedAIService;

  @override
  void initState() {
    super.initState();
    // Cache service reference
    try {
      _cachedAIService = ServiceLocator.instance.get<OnDeviceAIService>();
    } catch (e) {
      _cachedAIService = null;
    }
  }

  Future<void> useAIService() async {
    if (_cachedAIService != null) {
      // Use cached reference
      await _cachedAIService!.generateDrIrisResponse('prompt');
    }
  }
}
```

यह approach सुनिश्चित करता है कि आपका code platform-agnostic है और Service Locator automatically सही AI service provide करता है, चाहे आप Android, iOS, या किसी अन्य platform पर हों।