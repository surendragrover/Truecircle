import 'package:flutter/foundation.dart';
import '../../core/permission_manager.dart' as tc;
import '../../core/app_config.dart';

/// Contract for OTP verification flows.
abstract class OtpService {
  /// Start a verification flow for the given E.164 phone number.
  /// Offline implementation is a no-op.
  Future<void> startVerification({required String e164Phone});

  /// Verify the user-entered code; returns true on success.
  Future<bool> verifyCode(String code);

  static OtpService create() {
    // Privacy-first: in offline mode, always use offline path regardless of flags.
    if (tc.PermissionManager.isOfflineMode) {
      return OfflineOtpService();
    }
    // Build-time flag can request Firebase; we keep a stub to avoid deps here.
    if (AppConfig.useFirebaseOtp) {
      return PlannedFirebaseOtpService();
    }
    return OfflineOtpService();
  }
}

class OfflineOtpService implements OtpService {
  static const _required = '000000';

  @override
  Future<void> startVerification({required String e164Phone}) async {
    // No-op in offline mode
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<bool> verifyCode(String code) async {
    return code.trim() == _required;
  }
}

/// Placeholder that documents intent without pulling Firebase dependencies.
class PlannedFirebaseOtpService implements OtpService {
  @override
  Future<void> startVerification({required String e164Phone}) async {
    if (kDebugMode) {
      debugPrint('[OTP] Firebase OTP requested for $e164Phone (stub)');
    }
    // Intentionally a no-op in this build.
  }

  @override
  Future<bool> verifyCode(String code) async {
    // Not enabled in this privacy-first build.
    return false;
  }
}
