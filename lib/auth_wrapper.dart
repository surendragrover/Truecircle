import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truecircle/pages/login_signup_page.dart';
import 'package:truecircle/pages/model_download_progress_page.dart';
import 'package:truecircle/pages/how_truecircle_works_page.dart';
import 'package:truecircle/home_page.dart';
import 'package:truecircle/pages/user_onboarding_page.dart'; // Import the onboarding page
import 'package:truecircle/services/auth_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

// This widget acts as a gatekeeper, showing the correct page based on phone verification and AI model download status.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isInitialized = false;
  bool _modelsDownloaded = false;
  bool _hasSeenHowTrueCircleWorks = false;
  String? _currentPhoneNumber;
  bool _isFirstTime = true; // Add a flag for first-time users

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus(); // Check onboarding status first
    _initializeBoxes();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Check for 'is_first_time'. Default to true if not set.
    _isFirstTime = prefs.getBool('is_first_time') ?? true;
  }

  Future<void> _initializeBoxes() async {
    try {
      // Ensure Hive box is opened
      Box box;
      if (Hive.isBoxOpen('truecircle_settings')) {
        box = Hive.box('truecircle_settings');
      } else {
        box = await Hive.openBox('truecircle_settings');
      }
      // Try restore phone if service did not set it yet
      await _authService.restoreFromStorage();
      _currentPhoneNumber = _authService.currentPhoneNumber;

      // Save current phone number to storage
      if (_currentPhoneNumber != null) {
        await box.put('current_phone_number', _currentPhoneNumber);
      }

      // Load user-specific settings
      if (_currentPhoneNumber != null) {
        _modelsDownloaded = box.get('${_currentPhoneNumber}_models_downloaded',
            defaultValue: false) as bool;
        _hasSeenHowTrueCircleWorks = box.get(
            '${_currentPhoneNumber}_seen_how_works',
            defaultValue: false) as bool;
      } else {
        _modelsDownloaded = false;
        _hasSeenHowTrueCircleWorks = false;
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing boxes: $e');
      setState(() {
        _isInitialized = true; // Continue with defaults
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      // If it's the user's first time, show the onboarding page.
      if (_isFirstTime) {
        return const UserOnboardingPage();
      }

      // Mandatory: phone must be verified; no anonymous path allowed now
      if (!_authService.isPhoneVerified || _authService.currentPhoneNumber == null) {
        return const LoginSignupPage();
      }

      // Check if phone number changed - if yes, reload user state
      if (_authService.currentPhoneNumber != _currentPhoneNumber) {
        _currentPhoneNumber = _authService.currentPhoneNumber;
        _initializeBoxes(); // Reload state for new user
      }

      // Wait for initialization
      if (!_isInitialized) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Phone verified, now check if AI models are downloaded
      if (!_modelsDownloaded) {
        return const ModelDownloadProgressPage();
      }

      // Models downloaded, check if user has seen "How TrueCircle Works"
      if (!_hasSeenHowTrueCircleWorks) {
        return const HowTrueCircleWorksPage();
      }

      // Everything is ready, show main app
      return const HomePage();
    } catch (e) {
      // If there's any error, show login page as fallback
      debugPrint('AuthWrapper error: $e');
      return const LoginSignupPage();
    }
  }
}
