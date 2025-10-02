# Intelligent Service Selection Setup Guide

TrueCircle में प्लेटफॉर्म-आधारित AI सर्विस selection और Service Locator pattern का complete implementation guide।

## 🎯 Overview - समग्र दृष्टिकोण

यह system automatically detect करता है कि आपका ऐप किस platform पर चल रहा है और उसके अनुसार सबसे appropriate AI service को select और register करता है।

### Architecture Flow:
```
ऐप शुरू होता है
    ↓
प्लेटफॉर्म Detection (Android/iOS/Web/Desktop)
    ↓
सही AI Service का Selection
    ↓
Service Locator में Registration
    ↓
Service का Initialization
    ↓
ऐप में उपयोग के लिए तैयार
```

## 🏗️ Core Components

### 1. Service Locator (`lib/core/service_locator.dart`)

```dart
class ServiceLocator {
  // Singleton pattern
  static final ServiceLocator instance = ServiceLocator._();
  
  // Services को register करना
  void register<T>(T service);
  
  // Services को access करना
  T get<T>();
  
  // Platform-specific AI services setup (fallback के लिए)
  Future<void> setupAIServices();
}
```

**Key Features:**
- ✅ Singleton pattern for global access
- ✅ Type-safe service registration
- ✅ Platform-specific service support
- ✅ Fallback mechanism for failed services
- ✅ Service health monitoring

### 2. Platform Detection (`lib/main.dart`)

```dart
Future<void> configureServiceLocator() async {
  OnDeviceAIService aiService;
  
  if (defaultTargetPlatform == TargetPlatform.android) {
    aiService = AndroidGeminiNanoService();
    debugPrint("🤖 AI Config: Android - Gemini Nano");
    
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    aiService = IosCoreMLService();
    debugPrint("🤖 AI Config: iOS - Core ML");
    
  } else {
    // Fallback for other platforms
    await ServiceLocator.instance.setupAIServices();
    return;
  }
  
  // Register और initialize करना
  ServiceLocator.instance.register<OnDeviceAIService>(aiService);
  await aiService.initialize();
}
```

**Platform Mapping:**
- 🤖 **Android**: Gemini Nano (On-device, Privacy-focused)
- 🍎 **iOS**: Core ML Service (On-device, Optimized)
- 🖥️ **Desktop/Web**: Privacy-Aware Mock Service (Fallback)

### 3. App Initialization Integration

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Hive database setup
  await _setupHiveDatabase();
  
  // 2. Platform-based Service Locator configuration
  await configureServiceLocator();
  
  // 3. Initialize remaining services
  await AppInitialization.initializeApp();
  
  // 4. Launch app
  runApp(const TrueCircleApp());
}
```

## 🔧 Implementation Details

### Service Registration Process

#### Step 1: Platform Detection
```dart
// main.dart में platform check
if (defaultTargetPlatform == TargetPlatform.android) {
  // Android-specific AI service
} else if (defaultTargetPlatform == TargetPlatform.iOS) {
  // iOS-specific AI service  
} else {
  // Fallback service
}
```

#### Step 2: Service Creation
```dart
// Platform के अनुसार appropriate service बनाना
OnDeviceAIService aiService = AndroidGeminiNanoService(); // या iOS/Mock
```

#### Step 3: Registration
```dart
// Service Locator में register करना
ServiceLocator.instance.register<OnDeviceAIService>(aiService);
```

#### Step 4: Initialization
```dart
// Service को initialize करना (model loading, etc.)
await aiService.initialize();
```

### Error Handling & Fallbacks

#### Primary Fallback
```dart
try {
  // Primary platform-specific service
  await configureServiceLocator();
} catch (e) {
  // Fallback to AppInitialization.setupAIServices()
  await ServiceLocator.instance.setupAIServices();
}
```

#### Secondary Fallback
```dart
// Service Locator में built-in fallback
try {
  final privacyAwareService = PrivacyAwareAIServiceFactory.createPrivacyAwareService();
  register<OnDeviceAIService>(privacyAwareService);
} catch (e) {
  // Ultimate fallback: Mock service
  final mockService = PrivacyAwareMockAIService();
  register<OnDeviceAIService>(mockService);
}
```

## 💻 Usage in Widgets

### Basic Service Access

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late OnDeviceAIService _aiService;
  
  @override
  void initState() {
    super.initState();
    // Service Locator से AI service प्राप्त करना
    _aiService = ServiceLocator.instance.get<OnDeviceAIService>();
  }
  
  Future<void> _askDrIris(String question) async {
    final response = await _aiService.generateDrIrisResponse(question);
    // Response का उपयोग करना
  }
}
```

### With Error Handling

```dart
class SafeAIWidget extends StatefulWidget {
  @override
  _SafeAIWidgetState createState() => _SafeAIWidgetState();
}

class _SafeAIWidgetState extends State<SafeAIWidget> 
    with ServiceLocatorMixin {
  
  Future<void> _safeAIInteraction(String prompt) async {
    try {
      if (hasService<OnDeviceAIService>()) {
        final aiService = getService<OnDeviceAIService>()!;
        final response = await aiService.generateDrIrisResponse(prompt);
        // Handle response
      } else {
        // AI service not available - show fallback UI
        _showFallbackMessage();
      }
    } catch (e) {
      debugPrint('AI interaction failed: $e');
      _showErrorMessage();
    }
  }
}
```

### Using Service Status Widget

```dart
// home_page.dart में service status दिखाना
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TrueCircle')),
      body: Column(
        children: [
          ServiceStatusWidget(), // Shows AI service status
          // Other widgets...
        ],
      ),
      floatingActionButton: DrIrisQuickChatFAB(), // Quick AI chat
    );
  }
}
```

## 🧪 Testing & Debugging

### Service Health Check

```dart
// Service status की जांच करना
final serviceLocator = ServiceLocator.instance;
final healthStatus = await AppInitialization.performHealthCheck();

print('AI Service Available: ${serviceLocator.hasAIService}');
print('Registered Services: ${serviceLocator.getRegisteredServices()}');
print('Health Status: $healthStatus');
```

### Debug Mode Features

```dart
// Development mode में additional logging
if (kDebugMode) {
  AppInitialization.enableDevelopmentMode();
  
  // Service Locator debug information
  final services = ServiceLocator.instance.getRegisteredServices();
  services.forEach((type, implementation) {
    debugPrint('Service: $type -> $implementation');
  });
}
```

### Platform-specific Testing

```dart
// विभिन्न platforms पर testing
void testPlatformServices() {
  if (Platform.isAndroid) {
    // Android-specific tests
    expect(ServiceLocator.instance.isRegistered<AndroidGeminiNanoService>(), isTrue);
  } else if (Platform.isIOS) {
    // iOS-specific tests  
    expect(ServiceLocator.instance.isRegistered<IosCoreMLService>(), isTrue);
  } else {
    // Desktop/Web fallback tests
    expect(ServiceLocator.instance.isRegistered<PrivacyAwareMockAIService>(), isTrue);
  }
}
```

## 🛠️ Configuration Options

### Custom Service Registration

```dart
// main.dart में custom configuration
Future<void> configureServiceLocator() async {
  // Custom logic for specific requirements
  if (isSpecialBuildVariant()) {
    // Special service for testing/enterprise
    final customService = CustomAIService();
    ServiceLocator.instance.register<OnDeviceAIService>(customService);
  } else {
    // Standard platform-based selection
    await standardPlatformConfiguration();
  }
}
```

### Service Replacement

```dart
// Runtime पर service को replace करना
void replaceAIService(OnDeviceAIService newService) {
  ServiceLocator.instance.unregister<OnDeviceAIService>();
  ServiceLocator.instance.register<OnDeviceAIService>(newService);
}
```

## 🚀 Performance Considerations

### Lazy Loading
- Services केवल जरूरत के समय initialize होती हैं
- Model loading background में होती है
- Memory efficient service management

### Caching
- Service instances cached रहती हैं
- Repeated service calls optimized हैं
- Minimal overhead for service access

### Error Recovery
- Automatic fallback mechanisms
- Graceful degradation on service failures
- User experience maintained even with limited services

## 📊 Service Monitoring

### Real-time Status

```dart
// Service status monitoring widget
Widget buildServiceMonitor() {
  return StreamBuilder<Map<String, dynamic>>(
    stream: ServiceLocator.instance.serviceStatusStream,
    builder: (context, snapshot) {
      final status = snapshot.data ?? {};
      return ServiceHealthCard(status: status);
    },
  );
}
```

यह intelligent service selection system TrueCircle को platform-agnostic बनाता है और बेहतरीन user experience प्रदान करता है, चाहे user किसी भी platform पर हो।