import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Simple offline auth service for TrueCircle
class TrueCircleAuthService {
  static final _instance = TrueCircleAuthService._internal();
  factory TrueCircleAuthService() => _instance;
  TrueCircleAuthService._internal();

  Box? _userBox;
  String? _currentUserId;
  Map<String, dynamic>? _currentUserData;

  Map<String, dynamic>? get currentUser => _currentUserData;
  String? get currentUserId => _currentUserId;
  bool get isAuthenticated => _currentUserId != null;

  // For backward compatibility with Firebase Auth
  Stream<Map<String, dynamic>?> get authStateChanges =>
      Stream.value(_currentUserData);
  bool get isPhoneVerified => _currentUserData?['phoneNumber'] != null;

  Future<void> initialize() async {
    try {
      _userBox = await Hive.openBox('user_auth');
      _currentUserId = _userBox?.get('current_user_id');
      if (_currentUserId != null) {
        _currentUserData = _userBox?.get('user_$_currentUserId');
      }
    } catch (e) {
      debugPrint('AuthService init failed: $e');
    }
  }

  Future<bool> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    Function(Map<String, dynamic>)? onAutoVerify,
  }) async {
    try {
      final verificationId = 'mock_${DateTime.now().millisecondsSinceEpoch}';
      onCodeSent(verificationId);
      return true;
    } catch (e) {
      onError('Failed to send OTP');
      return false;
    }
  }

  Future<Map<String, dynamic>?> verifyOTP({
    required String verificationId,
    required String otp,
    String? phoneNumber,
  }) async {
    if (otp.length == 6) {
      return await _createUser(
          'user_${DateTime.now().millisecondsSinceEpoch}', phoneNumber);
    }
    throw Exception('Invalid OTP');
  }

  Future<Map<String, dynamic>?> signInAsGuest() async {
    return await _createUser(
        'guest_${DateTime.now().millisecondsSinceEpoch}', null, true);
  }

  Future<void> signOut() async {
    await _userBox?.delete('current_user_id');
    _currentUserId = null;
    _currentUserData = null;
  }

  Future<Map<String, dynamic>> _createUser(String userId, String? phone,
      [bool isGuest = false]) async {
    final userData = {
      'uid': userId,
      'phoneNumber': phone,
      'displayName': isGuest ? 'Guest User' : 'TrueCircle User',
      'isGuest': isGuest,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _userBox?.put('user_$userId', userData);
    await _userBox?.put('current_user_id', userId);

    _currentUserId = userId;
    _currentUserData = userData;

    return userData;
  }
}
