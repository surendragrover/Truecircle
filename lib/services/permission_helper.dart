import 'package:flutter/material.dart';
import 'package:truecircle/services/app_mode_service.dart';
import 'package:truecircle/services/permission_helper_demo.dart' as DemoHelper;
import 'package:truecircle/services/permission_helper_real.dart' as RealHelper;

class PermissionHelper {
  static Future<bool> requestContactsPermission(BuildContext context) async {
    final isFull = await AppModeService.isFullMode();
    if (isFull) {
      return RealHelper.PermissionHelper.requestContactsPermission(context);
    } else {
      return DemoHelper.PermissionHelper.requestContactsPermission(context);
    }
  }

  static Future<bool> requestPhonePermission(BuildContext context) async {
    final isFull = await AppModeService.isFullMode();
    if (isFull) {
      return RealHelper.PermissionHelper.requestPhonePermission(context);
    } else {
      return DemoHelper.PermissionHelper.requestPhonePermission(context);
    }
  }

  static Future<bool> requestSMSPermission(BuildContext context) async {
    final isFull = await AppModeService.isFullMode();
    if (isFull) {
      return RealHelper.PermissionHelper.requestSMSPermission(context);
    } else {
      return DemoHelper.PermissionHelper.requestSMSPermission(context);
    }
  }

  static Future<void> showPermissionDeniedDialog(
      BuildContext context, String permissionName) async {
    final isFull = await AppModeService.isFullMode();
    if (isFull) {
      return RealHelper.PermissionHelper.showPermissionDeniedDialog(
          context, permissionName);
    } else {
      return DemoHelper.PermissionHelper.showPermissionDeniedDialog(
          context, permissionName);
    }
  }
}
