import 'package:flutter/material.dart';
import 'package:truecircle/services/app_mode_service.dart';
import 'package:truecircle/services/permission_helper_demo.dart'
    as fallback_helper;
import 'package:truecircle/services/permission_helper_real.dart' as real_helper;

class PermissionHelper {
  static Future<bool> requestContactsPermission(BuildContext context) async {
    final safeContext = context;
    final isFull = await AppModeService.isFullMode();
    if (!safeContext.mounted) return false;
    if (isFull) {
      return real_helper.PermissionHelper.requestContactsPermission(
          safeContext);
    } else {
      return fallback_helper.PermissionHelper.requestContactsPermission(
          safeContext);
    }
  }

  static Future<bool> requestPhonePermission(BuildContext context) async {
    final safeContext = context;
    final isFull = await AppModeService.isFullMode();
    if (!safeContext.mounted) return false;
    if (isFull) {
      return real_helper.PermissionHelper.requestPhonePermission(safeContext);
    } else {
      return fallback_helper.PermissionHelper.requestPhonePermission(
          safeContext);
    }
  }

  static Future<bool> requestSMSPermission(BuildContext context) async {
    final safeContext = context;
    final isFull = await AppModeService.isFullMode();
    if (!safeContext.mounted) return false;
    if (isFull) {
      return real_helper.PermissionHelper.requestSMSPermission(safeContext);
    } else {
      return fallback_helper.PermissionHelper.requestSMSPermission(safeContext);
    }
  }

  static Future<void> showPermissionDeniedDialog(
      BuildContext context, String permissionName) async {
    final safeContext = context;
    final isFull = await AppModeService.isFullMode();
    if (!safeContext.mounted) return;
    if (isFull) {
      return real_helper.PermissionHelper.showPermissionDeniedDialog(
          safeContext, permissionName);
    } else {
      return fallback_helper.PermissionHelper.showPermissionDeniedDialog(
          safeContext, permissionName);
    }
  }
}
