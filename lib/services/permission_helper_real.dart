import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// 🔐 Permission Helper - Real Permission Implementation
class PermissionHelper {
  static Future<bool> requestContactsPermission(BuildContext context) async {
    final safeContext = context;
    return await _requestPermission(
        Permission.contacts, 'Contacts', safeContext);
  }

  static Future<bool> requestPhonePermission(BuildContext context) async {
    final safeContext = context;
    return await _requestPermission(Permission.phone, 'Phone', safeContext);
  }

  static Future<bool> requestSMSPermission(BuildContext context) async {
    final safeContext = context;
    return await _requestPermission(Permission.sms, 'SMS', safeContext);
  }

  static Future<bool> _requestPermission(
      Permission permission, String name, BuildContext context) async {
    final safeContext = context;
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }
    final result = await permission.request();
    if (result.isGranted) {
      return true;
    }
    if (result.isPermanentlyDenied) {
      if (safeContext.mounted) {
        await showPermissionDeniedDialog(safeContext, name);
      }
    }
    return false;
  }

  static Future<bool> hasContactsPermission() async {
    return await Permission.contacts.isGranted;
  }

  static Future<bool> hasPhonePermission() async {
    return await Permission.phone.isGranted;
  }

  static Future<bool> hasSmsPermission() async {
    return await Permission.sms.isGranted;
  }

  static Future<Map<String, bool>> getAllPermissionStatus() async {
    final contacts = await hasContactsPermission();
    final phone = await hasPhonePermission();
    final sms = await hasSmsPermission();
    return {
      'contacts': contacts,
      'phone': phone,
      'sms': sms,
    };
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  static Future<void> showPermissionDeniedDialog(
      BuildContext context, String permissionName) async {
    final safeContext = context;
    await showDialog(
      context: safeContext,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Permission Denied'),
        content: Text(
            'To use this feature, please enable the $permissionName permission in the app settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await openAppSettings();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
