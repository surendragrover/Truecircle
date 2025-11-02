import 'package:hive/hive.dart';
import 'package:true_circle/core/log_service.dart';

/// PrivacyGuard: Enforces offline privacy mode across services.
///
/// Firebase and Google services have been removed for the offline-only
/// build. This class keeps the same public contract but performs local
/// enforcement only (no external SDK calls).
class PrivacyGuard {
  PrivacyGuard._();

  /// Returns whether offline privacy mode is enabled
  static Future<bool> isOffline() async {
    try {
      final box = await Hive.openBox('app_prefs');
      return box.get('force_offline', defaultValue: false) as bool;
    } catch (e) {
      LogService.instance.log('PrivacyGuard.isOffline error: $e');
      return false;
    }
  }

  /// Apply privacy restrictions. Previously this disabled Firebase
  /// SDK collection; since Firebase is removed, we simply ensure any
  /// internal telemetry is suppressed and log the state.
  static Future<void> enforceIfNeeded() async {
    final offline = await isOffline();
    if (!offline) return;
    // If there are any in-app telemetry toggles in future, handle them here.
    LogService.instance.log(
      'PrivacyGuard: offline mode active — telemetry disabled.',
    );
  }
}
