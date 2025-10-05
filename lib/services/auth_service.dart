// import 'package:firebase_auth/firebase_auth.dart';  // Temporarily disabled
import 'package:hive_flutter/hive_flutter.dart';

import 'logging_service.dart';

// This service will handle all user authentication logic (login, signup, logout).
class AuthService {
  // final FirebaseAuth _auth = FirebaseAuth.instance;  // Temporarily disabled

  // Mock authentication for now
  Stream<String?> get userStream => Stream.value(null);

  // A helper to get the current logged-in user's ID.
  String? get currentUserId => null; // Mock implementation

  // Sign up a new user with email and password.
  Future<String?> signUp(
      {required String email, required String password}) async {
    try {
      return null; // Mock implementation
    } catch (e) {
      LoggingService.error(
        'Mock signup error: $e',
        messageHi: 'मॉक साइनअप त्रुटि: $e',
      );
      return null;
    }
  }

  // Sign in an existing user.
  Future<String?> signIn(
      {required String email, required String password}) async {
    try {
      return null; // Mock implementation
    } catch (e) {
      LoggingService.error(
        'Mock signin error: $e',
        messageHi: 'मॉक साइनइन त्रुटि: $e',
      );
      return null;
    }
  }

  // Sign out the current user.
  Future<void> signOut() async {
    // Mock signOut implementation
  }

  // Simple flag for test phone authentication
  static bool _isPhoneVerified = false;
  static String? _currentPhoneNumber;

  // Get phone verification status
  bool get isPhoneVerified => _isPhoneVerified;

  // Get current phone number
  String? get currentPhoneNumber => _currentPhoneNumber;

  // Mock phone authentication for testing purposes - no Firebase needed
  Future<bool> signInWithPhoneNumber(String phoneNumber) async {
    try {
      // Reset verification state first for new login
      _isPhoneVerified = false;
      _currentPhoneNumber = null;

      // Simulate verification delay
      await Future.delayed(const Duration(milliseconds: 500));
      _isPhoneVerified = true;
      _currentPhoneNumber = phoneNumber;
      try {
        final box = Hive.isBoxOpen('truecircle_settings')
            ? Hive.box('truecircle_settings')
            : await Hive.openBox('truecircle_settings');
        await box.put('current_phone_number', phoneNumber);
        await box.put('current_phone_verified',
            true); // persist verified state explicitly
      } catch (_) {}
      LoggingService.success(
        'Mock phone authentication successful for $phoneNumber',
        messageHi: '$phoneNumber के लिए मॉक फोन प्रमाणीकरण सफल रहा',
      );
      return true;
    } catch (e) {
      LoggingService.error(
        'Mock phone auth error: $e',
        messageHi: 'मॉक फोन सत्यापन में त्रुटि: $e',
      );
      _isPhoneVerified = false;
      _currentPhoneNumber = null;
      return false;
    }
  }

  // Attempt to restore persisted phone number (for app restarts)
  static bool _restoreAttempted = false;
  Future<void> restoreFromStorage() async {
    if (_restoreAttempted) return;
    _restoreAttempted = true;
    try {
      final box = Hive.isBoxOpen('truecircle_settings')
          ? Hive.box('truecircle_settings')
          : await Hive.openBox('truecircle_settings');
      final stored = box.get('current_phone_number') as String?;
      final wasVerified =
          box.get('current_phone_verified', defaultValue: false) as bool;
      if (stored != null && stored.isNotEmpty) {
        _currentPhoneNumber = stored;
        _isPhoneVerified =
            wasVerified; // only mark verified if explicit flag present
        LoggingService.info(
          'AuthService restored phone $stored (verified=$wasVerified) from storage',
          messageHi:
              'AuthService ने संग्रह से $stored (सत्यापित=$wasVerified) पुनर्स्थापित किया',
        );
      }
    } catch (e) {
      LoggingService.error(
        'AuthService restoreFromStorage failed: $e',
        messageHi: 'AuthService संग्रह से पुनर्स्थापन विफल: $e',
      );
    }
  }

  // Reset verification for logout
  void resetPhoneVerification() {
    _isPhoneVerified = false;
    _currentPhoneNumber = null;
  }

  // Complete logout - clear all user state
  Future<void> completeLogout() async {
    try {
      _isPhoneVerified = false;
      _currentPhoneNumber = null;

      // Clear current phone number from storage
      final box = await Hive.openBox('truecircle_settings');
      await box.delete('current_phone_number');
      await box.delete('current_phone_verified');

      LoggingService.success(
        'Complete logout successful',
        messageHi: 'पूर्ण लॉगआउट सफल रहा',
      );
    } catch (e) {
      LoggingService.error(
        'Error during logout: $e',
        messageHi: 'लॉगआउट के दौरान त्रुटि: $e',
      );
    }
  }
}
