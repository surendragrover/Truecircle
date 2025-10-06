// lib/core/service_locator.dart

import 'dart:io';
import 'package:truecircle/services/on_device_ai_service.dart';
import 'package:truecircle/services/android_gemini_nano_service.dart';
import 'package:truecircle/services/ios_coreml_service.dart';
import 'package:truecircle/services/privacy_aware_ai_service_factory.dart';

/// यह एक साधारण Service Locator है जो पूरी ऐप में सेवाओं (Services) को मैनेज करता है।
/// 
/// यह क्लास Flutter ऐप के लिए एक केंद्रीय सेवा प्रबंधक के रूप में काम करती है।
/// ऐप शुरू होने पर यह प्लेटफॉर्म की जाँच करके सही AI सेवा को रजिस्टर करती है।
class ServiceLocator {
  // 1. सभी सेवाओं को रखने के लिए एक निजी मैप (Map)
  final _services = <Type, dynamic>{};

  static final ServiceLocator instance = ServiceLocator._();
  ServiceLocator._();

  /// 2. एक सेवा (Service) को रजिस्टर करना
  /// 
  /// इस method का उपयोग करके आप किसी भी प्रकार की सेवा को रजिस्टर कर सकते हैं
  void register<T>(T service) {
    _services[T] = service;
    // ServiceLocator: ${T.toString()} सेवा रजिस्टर की गई
  }

  /// 3. एक सेवा को एक्सेस करना
  /// 
  /// रजिस्टर की गई सेवा को प्राप्त करने के लिए इस method का उपयोग करें
  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not registered. कृपया पहले इसे रजिस्टर करें।');
    }
    return service;
  }

  /// 4. सेवा रजिस्टर है या नहीं चेक करना
  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// 5. सेवा को अन-रजिस्टर करना
  void unregister<T>() {
    _services.remove(T);
    // ServiceLocator: ${T.toString()} सेवा अन-रजिस्टर की गई
  }

  /// 6. सभी सेवाओं को साफ करना
  void clear() {
    _services.clear();
    // ServiceLocator: सभी सेवाएं साफ की गईं
  }

  /// 7. प्लेटफॉर्म-स्पेसिफिक AI सेवाओं को ऑटो-रजिस्टर करना (Fallback के लिए)
  /// 
  /// यह method केवल fallback के रूप में उपयोग होता है जब main.dart में 
  /// configureServiceLocator() fail हो जाए
  Future<void> setupAIServices() async {
    // ServiceLocator: Fallback AI सेवाओं का सेटअप शुरू...
    
    try {
      // अगर पहले से AI service registered नहीं है तो ही setup करना
      if (!isRegistered<OnDeviceAIService>()) {
        // Privacy-aware AI service factory का उपयोग करके सही सेवा बनाना
        final privacyAwareService = PrivacyAwareAIServiceFactory.createPrivacyAwareService();
        
        // Main AI service को रजिस्टर करना
        register<OnDeviceAIService>(privacyAwareService);
        
        // Initialize the main AI service
        await privacyAwareService.initialize();
        // ServiceLocator: Fallback AI सेवा सफलतापूर्वक रजिस्टर की गई
      } else {
        // ServiceLocator: AI सेवा पहले से रजिस्टर है, fallback की जरूरत नहीं
      }
      
      // Platform-specific services भी रजिस्टर करना (यदि पहले से नहीं हैं)
      if (Platform.isAndroid && !isRegistered<AndroidGeminiNanoService>()) {
        final androidService = AndroidGeminiNanoService();
        register<AndroidGeminiNanoService>(androidService);
        // ServiceLocator: Android Gemini Nano सेवा रजिस्टर की गई
      } else if (Platform.isIOS && !isRegistered<IosCoreMLService>()) {
        final iosService = IosCoreMLService();
        register<IosCoreMLService>(iosService);
        // ServiceLocator: iOS CoreML सेवा रजिस्टर की गई
      } else if (!Platform.isAndroid && !Platform.isIOS && !isRegistered<PrivacyAwareMockAIService>()) {
        final mockService = PrivacyAwareMockAIService();
        register<PrivacyAwareMockAIService>(mockService);
        // ServiceLocator: Mock AI सेवा रजिस्टर की गई (Desktop/Web)
      }
      
      // ServiceLocator: AI सेवाओं का सेटअप पूरा
      
    } catch (e) {
      // ServiceLocator Error: AI सेवाओं के सेटअप में त्रुटि - $e
      
      // Ultimate fallback: Mock service रजिस्टर करना
      try {
        if (!isRegistered<OnDeviceAIService>()) {
          final fallbackService = PrivacyAwareMockAIService();
          register<OnDeviceAIService>(fallbackService);
          await fallbackService.initialize();
          // ServiceLocator: Ultimate fallback Mock AI सेवा रजिस्टर की गई
        }
      } catch (fallbackError) {
        // ServiceLocator Critical Error: Ultimate fallback भी fail हो गई - $fallbackError
      }
    }
  }

  /// 8. सभी रजिस्टर की गई सेवाओं की जानकारी प्राप्त करना
  Map<String, String> getRegisteredServices() {
    final serviceInfo = <String, String>{};
    
    _services.forEach((type, service) {
      serviceInfo[type.toString()] = service.runtimeType.toString();
    });
    
    return serviceInfo;
  }

  /// 9. AI सेवा की स्थिति की जाँच करना
  Map<String, dynamic> getAIServiceStatus() {
    final status = <String, dynamic>{};
    
    try {
      final aiService = get<OnDeviceAIService>();
      status['ai_service_registered'] = true;
      status['ai_service_type'] = aiService.runtimeType.toString();
      status['platform'] = Platform.operatingSystem;
      
      // Platform-specific service status
      if (Platform.isAndroid && isRegistered<AndroidGeminiNanoService>()) {
        status['android_service'] = 'AndroidGeminiNanoService registered';
      } else if (Platform.isIOS && isRegistered<IosCoreMLService>()) {
        status['ios_service'] = 'IosCoreMLService registered';
      } else if (isRegistered<PrivacyAwareMockAIService>()) {
        status['mock_service'] = 'PrivacyAwareMockAIService registered';
      }
      
    } catch (e) {
      status['ai_service_registered'] = false;
      status['error'] = e.toString();
    }
    
    return status;
  }
}

/// Helper extension for easier access to services
extension ServiceLocatorExtension on ServiceLocator {
  /// Quick access to AI service
  OnDeviceAIService get aiService => get<OnDeviceAIService>();
  
  /// Check if AI service is available
  bool get hasAIService => isRegistered<OnDeviceAIService>();
}