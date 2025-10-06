import 'package:shared_preferences/shared_preferences.dart';

/// Manages the application's mode (Sample/Privacy vs. Full).
class AppModeService {
  static const String _modeKey = 'app_mode_full';

  /// Checks if the app is in Full Mode.
  static Future<bool> isFullMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_modeKey) ?? false;
  }

  /// Sets the app mode.
  static Future<void> setFullMode(bool isFull) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modeKey, isFull);
  }
}
