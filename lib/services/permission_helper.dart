import 'package:flutter/material.dart';
import 'package:truecircle/services/app_mode_service.dart';
import 'package:truecircle/services/permission_helper_demo.dart' as fallback_helper;
import 'package:truecircle/services/permission_helper_real.dart' as real_helper;

class PermissionHelper {
  static Future<bool> requestContactsPermission(BuildContext context) async {
    final isFull = await AppModeService.isFullMode();
    if (!context.mounted) return false;
    if (isFull) {
      return real_helper.PermissionHelper.requestContactsPermission(context);
    } else {
      return fallback_helper.PermissionHelper.requestContactsPermission(context);
    }
  }

  static Future<bool> requestPhonePermission(BuildContext context) async {
    final isFull = await AppModeService.isFullMode();
    if (!context.mounted) return false;
    if (isFull) {
      return real_helper.PermissionHelper.requestPhonePermission(context);
    } else {
      return fallback_helper.PermissionHelper.requestPhonePermission(context);
    }
  }

  static Future<bool> requestSMSPermission(BuildContext context) async {
    final isFull = await AppModeService.isFullMode();
    if (!context.mounted) return false;
    if (isFull) {
      return real_helper.PermissionHelper.requestSMSPermission(context);
    } else {
      return fallback_helper.PermissionHelper.requestSMSPermission(context);
    }
  }

  static Future<void> showPermissionDeniedDialog(
      BuildContext context, String permissionName) async {
    final isFull = await AppModeService.isFullMode();
    if (!context.mounted) return;
    if (isFull) {
      return real_helper.PermissionHelper.showPermissionDeniedDialog(
          context, permissionName);
    } else {
      return fallback_helper.PermissionHelper.showPermissionDeniedDialog(
          context, permissionName);
    }
  }
}
