import 'package:flutter/material.dart';

/// 🔐 Permission Helper - Zero Permission Sample App
/// This is a Sample App that uses sample data only - no real permissions needed
class PermissionHelper {
  /// Sample App - no real permission needed, returns false to use sample data
  static Future<bool> requestContactsPermission(BuildContext context) async {
    await _showSampleDialog(context, 'Contacts Access');
    return false; // Always false for sample mode
  }

  /// Sample App - no real permission needed, returns false to use sample data
  static Future<bool> requestPhonePermission(BuildContext context) async {
    await _showSampleDialog(context, 'Phone Access');
    return false; // Always false for sample mode
  }

  /// Sample App - no real permission needed, returns false to use sample data
  static Future<bool> requestSMSPermission(BuildContext context) async {
    await _showSampleDialog(context, 'SMS Access');
    return false; // Always false for sample mode
  }

  /// Sample App - no real permission needed, returns false to use sample data
  static Future<bool> requestStoragePermission(BuildContext context) async {
    await _showSampleDialog(context, 'Storage Access');
    return false; // Always false for sample mode
  }

  /// Show sample explanation dialog (privacy-first)
  static Future<void> _showSampleDialog(
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
              '🎓 Educational Sample Mode',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            Text('This privacy-first app uses sample data only.'),
            SizedBox(height: 8),
            Text('✅ Zero permissions required'),
            Text('✅ Your privacy is 100% protected'),
            Text('✅ All insights are based on sample data'),
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

  /// Check if permission is granted (always false for sample mode)
  static Future<bool> isPermissionGranted(dynamic permission) async {
    return false; // Sample App doesn't need real permissions
  }

  /// Check contacts permission (always false for sample)
  static Future<bool> hasContactsPermission() async {
    return false; // Sample App uses sample contacts
  }

  /// Check phone permission (always false for sample)
  static Future<bool> hasPhonePermission() async {
    return false; // Sample App uses sample call data
  }

  /// Check SMS permission (always false for sample)
  static Future<bool> hasSmsPermission() async {
    return false; // Sample App uses sample message data
  }

  /// Check storage permission (always false for sample)
  static Future<bool> hasStoragePermission() async {
    return false; // Sample App doesn't need file access
  }

  /// Get all permission status (all false for sample)
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

  /// Show permission info dialog (privacy wording)
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
            Text('Sample Mode'),
          ],
        ),
        content: Text(
          'This privacy-first app uses sample data for $permissionName. '
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
