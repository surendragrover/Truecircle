import 'package:flutter/material.dart';

/// 🔐 Permission Helper - Zero Permission Sample App
/// This is a Sample App that uses sample data only - no real permissions needed
class PermissionHelper {
  /// Sample App - no real permission needed, returns false to use sample data
  static Future<bool> requestContactsPermission(BuildContext context) async {
    await _showDemoDialog(context, 'Contacts Access Demo');
    return false; // Always false for demo mode
  }

  /// Sample App - no real permission needed, returns false to use sample data
  static Future<bool> requestPhonePermission(BuildContext context) async {
    await _showDemoDialog(context, 'Phone Access Demo');
    return false; // Always false for demo mode
  }

  /// Sample App - no real permission needed, returns false to use sample data
  static Future<bool> requestSMSPermission(BuildContext context) async {
    await _showDemoDialog(context, 'SMS Access Demo');
    return false; // Always false for demo mode
  }

  /// Sample App - no real permission needed, returns false to use sample data
  static Future<bool> requestStoragePermission(BuildContext context) async {
    await _showDemoDialog(context, 'Storage Access Demo');
    return false; // Always false for demo mode
  }

  /// Show demo explanation dialog
  static Future<void> _showDemoDialog(
      BuildContext context, String title) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info, color: Colors.blue),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎓 Educational Demo Mode',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            Text('This is an educational app that uses sample data only.'),
            SizedBox(height: 8),
            Text('✅ Zero permissions required'),
            Text('✅ Your privacy is 100% protected'),
            Text('✅ All insights are based on demo data'),
            Text('✅ Learn relationship analysis safely'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  /// Check if permission is granted (always false for demo)
  static Future<bool> isPermissionGranted(dynamic permission) async {
    return false; // Sample App doesn't need real permissions
  }

  /// Check contacts permission (always false for demo)
  static Future<bool> hasContactsPermission() async {
    return false; // Sample App uses sample contacts
  }

  /// Check phone permission (always false for demo)
  static Future<bool> hasPhonePermission() async {
    return false; // Sample App uses sample call data
  }

  /// Check SMS permission (always false for demo)
  static Future<bool> hasSmsPermission() async {
    return false; // Sample App uses sample message data
  }

  /// Check storage permission (always false for demo)
  static Future<bool> hasStoragePermission() async {
    return false; // Sample App doesn't need file access
  }

  /// Get all permission status (all false for demo)
  static Future<Map<String, bool>> getAllPermissionStatus() async {
    return {
      'contacts': false,
      'phone': false,
      'sms': false,
      'storage': false,
    };
  }

  /// Open app settings (not needed for Sample App)
  static Future<void> openAppSettings() async {
    // Not implemented for Sample App
    debugPrint('Sample App: No settings needed - zero permissions used');
  }

  /// Show permission denied dialog (modified for demo)
  static Future<void> showPermissionDeniedDialog(
    BuildContext context,
    String permissionName,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Demo Mode'),
          ],
        ),
        content: Text(
          'This is a Sample App that uses sample data for $permissionName. '
          'No real permissions are needed to explore the features safely.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}
