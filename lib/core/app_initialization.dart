// lib/core/app_initialization.dart

import 'package:flutter/foundation.dart';
import 'package:truecircle/core/service_locator.dart';
import 'package:truecircle/services/privacy_mode_manager.dart';
import 'package:truecircle/services/privacy_service.dart';
import 'package:truecircle/services/json_data_service.dart';

/// ऐप के शुरुआती सेटअप और सेवाओं के इनिशियलाइज़ेशन के लिए मुख्य क्लास
/// 
/// यह क्लास TrueCircle ऐप के सभी मुख्य सेवाओं को सही क्रम में इनिशियलाइज़ करती है
class AppInitialization {
  
  /// ऐप की सभी मुख्य सेवाओं को इनिशियलाइज़ करना
  /// 
  /// यह method main.dart में ऐप शुरू होने से पहले कॉल करें
  static Future<void> initializeApp() async {
    try {
      debugPrint('🚀 TrueCircle ऐप का इनिशियलाइज़ेशन शुरू...');
      
      // 1. Service Locator setup
      debugPrint('📋 Service Locator सेटअप...');
      final serviceLocator = ServiceLocator.instance;
      
      // 2. Privacy Mode Manager इनिशियलाइज़ करना
      debugPrint('🔐 Privacy Mode Manager इनिशियलाइज़...');
      final privacyModeManager = PrivacyModeManager();
      serviceLocator.register<PrivacyModeManager>(privacyModeManager);
      
      // 3. Privacy Service इनिशियलाइज़ करना
      debugPrint('🛡️ Privacy Service इनिशियलाइज़...');
      final privacyService = PrivacyService();
      await privacyService.init();
      serviceLocator.register<PrivacyService>(privacyService);
      
      // 4. JSON Data Service इनिशियलाइज़ करना
      debugPrint('📄 JSON Data Service इनिशियलाइज़...');
      final jsonDataService = JsonDataService.instance;
      serviceLocator.register<JsonDataService>(jsonDataService);
      
      // 5. AI Services सेटअप करना
      debugPrint('🤖 AI Services सेटअप...');
      await serviceLocator.setupAIServices();
      
      // 6. इनिशियलाइज़ेशन की पुष्टि
      debugPrint('✅ सभी सेवाएं सफलतापूर्वक इनिशियलाइज़ हुईं');
      _printInitializationSummary();
      
    } catch (e, stackTrace) {
      debugPrint('❌ ऐप इनिशियलाइज़ेशन में त्रुटि: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Critical error: अगर AI services fail हों तो भी ऐप चलाना
      await _setupFallbackServices();
    }
  }
  
  /// अगर मुख्य इनिशियलाइज़ेशन fail हो तो fallback services सेटअप करना
  static Future<void> _setupFallbackServices() async {
    debugPrint('⚠️ Fallback services सेटअप...');
    
    try {
      final serviceLocator = ServiceLocator.instance;
      
      // Essential services only
      final privacyService = PrivacyService();
      await privacyService.init();
      serviceLocator.register<PrivacyService>(privacyService);
      
      final jsonDataService = JsonDataService.instance;
      serviceLocator.register<JsonDataService>(jsonDataService);
      
      debugPrint('✅ Fallback services सेटअप पूरा');
      
    } catch (e) {
      debugPrint('❌ Fallback services भी fail हुईं: $e');
    }
  }
  
  /// इनिशियलाइज़ेशन का सारांश प्रिंट करना
  static void _printInitializationSummary() {
    final serviceLocator = ServiceLocator.instance;
    
    debugPrint('\n📊 TrueCircle Initialization Summary:');
    debugPrint('====================================');
    
    // Registered services की जानकारी
    final registeredServices = serviceLocator.getRegisteredServices();
    debugPrint('🔧 Registered Services: ${registeredServices.length}');
    registeredServices.forEach((type, implementation) {
      debugPrint('  • $type -> $implementation');
    });
    
    // AI Service status
    final aiStatus = serviceLocator.getAIServiceStatus();
    debugPrint('\n🤖 AI Service Status:');
    aiStatus.forEach((key, value) {
      debugPrint('  • $key: $value');
    });
    
    // Privacy status
    try {
      final privacyService = serviceLocator.get<PrivacyService>();
      final isDemoMode = privacyService.isDemoMode();
      debugPrint('\n🔐 Privacy Status:');
      debugPrint('  • Demo Mode: ${isDemoMode ? "Active" : "Inactive"}');
      debugPrint('  • Privacy-First Architecture: Enabled');
    } catch (e) {
      debugPrint('\n⚠️ Privacy Service not available: $e');
    }
    
    debugPrint('====================================\n');
  }
  
  /// ऐप की health check करना
  static Future<Map<String, dynamic>> performHealthCheck() async {
    final healthStatus = <String, dynamic>{};
    final serviceLocator = ServiceLocator.instance;
    
    try {
      // Service Locator health
      healthStatus['service_locator'] = {
        'status': 'healthy',
        'registered_services': serviceLocator.getRegisteredServices().length,
      };
      
      // Privacy Service health
      if (serviceLocator.isRegistered<PrivacyService>()) {
        final privacyService = serviceLocator.get<PrivacyService>();
        healthStatus['privacy_service'] = {
          'status': 'healthy',
          'demo_mode': privacyService.isDemoMode(),
        };
      } else {
        healthStatus['privacy_service'] = {'status': 'not_registered'};
      }
      
      // AI Service health
      if (serviceLocator.hasAIService) {
        healthStatus['ai_service'] = {
          'status': 'healthy',
          'details': serviceLocator.getAIServiceStatus(),
        };
      } else {
        healthStatus['ai_service'] = {'status': 'not_available'};
      }
      
      // JSON Data Service health
      if (serviceLocator.isRegistered<JsonDataService>()) {
        healthStatus['json_data_service'] = {'status': 'healthy'};
      } else {
        healthStatus['json_data_service'] = {'status': 'not_registered'};
      }
      
      healthStatus['overall_status'] = 'healthy';
      
    } catch (e) {
      healthStatus['overall_status'] = 'error';
      healthStatus['error'] = e.toString();
    }
    
    return healthStatus;
  }
  
  /// Development mode में additional debugging information
  static void enableDevelopmentMode() {
    if (kDebugMode) {
      debugPrint('🔧 Development Mode Enabled');
      
      // Additional logging for services
      final serviceLocator = ServiceLocator.instance;
      debugPrint('Service Locator Instance: ${serviceLocator.hashCode}');
      
      // Print all registered services with more details
      final services = serviceLocator.getRegisteredServices();
      debugPrint('Detailed Service Registry:');
      services.forEach((type, implementation) {
        debugPrint('  📦 $type');
        debugPrint('     Implementation: $implementation');
        debugPrint('     Hash: ${implementation.hashCode}');
      });
    }
  }
}

/// Service Locator के लिए helpful extensions
extension ServiceLocatorQuickAccess on ServiceLocator {
  /// Quick access methods for commonly used services
  
  PrivacyService? get privacyService {
    try {
      return get<PrivacyService>();
    } catch (e) {
      debugPrint('Privacy Service not available: $e');
      return null;
    }
  }
  
  PrivacyModeManager? get privacyModeManager {
    try {
      return get<PrivacyModeManager>();
    } catch (e) {
      debugPrint('Privacy Mode Manager not available: $e');
      return null;
    }
  }
  
  JsonDataService? get jsonDataService {
    try {
      return get<JsonDataService>();
    } catch (e) {
      debugPrint('JSON Data Service not available: $e');
      return null;
    }
  }
}