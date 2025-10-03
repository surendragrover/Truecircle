// import 'package:firebase_auth/firebase_auth.dart';  // Temporarily disabled
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
      debugPrint('Mock signup error: $e');
      return null;
    }
  }

  // Sign in an existing user.
  Future<String?> signIn(
      {required String email, required String password}) async {
    try {
      return null; // Mock implementation
    } catch (e) {
      debugPrint('Mock signin error: $e');
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
      } catch (_) {}
      debugPrint('Mock phone authentication successful for: $phoneNumber');
      return true;
    } catch (e) {
      debugPrint('Mock phone auth error: $e');
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
      if (stored != null && stored.isNotEmpty) {
        _currentPhoneNumber = stored;
        _isPhoneVerified = true; // assume previously verified in mock mode
        debugPrint('AuthService: restored phone $stored from storage');
      }
    } catch (e) {
      debugPrint('AuthService: restoreFromStorage failed: $e');
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

      debugPrint('Complete logout successful');
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }
}
