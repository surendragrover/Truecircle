import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:truecircle/services/app_mode_service.dart';
import 'package:truecircle/services/permission_helper.dart';

/// A service to handle fetching contacts from the device.
class ContactService {
  /// Fetches contacts based on the current app mode.
  /// In Privacy Mode (sample mode), returns an empty list.
  /// In Full Mode, requests permissions and fetches from the device.
  static Future<List<Contact>> getContacts(BuildContext context) async {
    final isFull = await AppModeService.isFullMode();
    if (!isFull) {
      // Return empty list in Privacy/Sample mode
      return [];
    }

    // In Full Mode, check for permissions first - with context safety
    if (!context.mounted) return [];
    final hasPermission =
        await PermissionHelper.requestContactsPermission(context);
    if (!hasPermission) {
      // If permission is still not granted, return empty list
      return [];
    }

    // Fetch contacts from the device
    try {
      return await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
    } catch (e) {
      // Handle potential errors during contact fetching
      debugPrint('Error fetching contacts: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not fetch contacts.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    }
  }
}
