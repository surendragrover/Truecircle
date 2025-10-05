import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';
import '../firebase_options.dart';
import 'auth_service.dart';

/// CloudSyncService
/// Lightweight, privacy-aware optional sync layer.
/// Only pushes high-level aggregate / non-sensitive metadata to Firestore.
/// NO raw messages, emotions, contacts, or personally revealing text.
/// Document path: users/{phone_sanitized}/state
class CloudSyncService {
  CloudSyncService._();
  static final CloudSyncService instance = CloudSyncService._();

  bool _initialized = false;
  bool _enableSync = true; // Toggle: set false to fully disable cloud write
  DateTime? _lastSuccessfulSync;
  Map<String, dynamic>? _pendingPayload; // Latest payload waiting retry
  List<String>?
      _lastPayloadKeys; // Keys of last successfully synced payload (for debug UI)
  int _retryAttempt = 0;
  Timer? _retryTimer;
  Timer? _retryCountdownTimer; // counts down seconds until next retry

  // Sync state notifiers for UI feedback
  final ValueNotifier<bool> syncingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<int?> retryCountdownNotifier =
      ValueNotifier<int?>(null); // seconds remaining until retry
  final ValueNotifier<String?> lastErrorNotifier = ValueNotifier<String?>(null);

  // Exposed notifier for UI (last sync changes)
  final ValueNotifier<DateTime?> lastSyncNotifier =
      ValueNotifier<DateTime?>(null);

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      // Attempt phone restore early so sanitizedUserId becomes available
      await AuthService().restoreFromStorage();
      if (Firebase.apps.isEmpty) {
        // Prefer automatic initialization (google-services.json / plist) when not web.
        if (kIsWeb) {
          await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform);
        } else {
          try {
            await Firebase.initializeApp(); // let native config load
            debugPrint('[CloudSync] Firebase auto init (no options) succeeded');
          } catch (autoErr) {
            debugPrint(
                '[CloudSync] Auto init failed ($autoErr) – trying explicit options');
            await Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform);
          }
        }
      }
      _initialized = true;
      debugPrint('[CloudSync] Firebase ready (apps: ${Firebase.apps.length})');
    } catch (e) {
      lastErrorNotifier.value = 'init: $e';
      debugPrint('[CloudSync] Firebase init failed: $e');
    }
  }

  /// Public method to toggle sync at runtime (e.g., user privacy setting)
  void setSyncEnabled(bool value) => _enableSync = value;
  // When enabling sync mid-session, try to flush any pending payload immediately.
  Future<void> enableAndKick({
    int? loyaltyPoints,
    int? featuresCount,
    bool? modelsReady,
    int? aiFestivalMessages,
  }) async {
    if (!_enableSync) return; // only call after setSyncEnabled(true)
    if (loyaltyPoints == null || featuresCount == null) return;
    await syncUserState(
      loyaltyPoints: loyaltyPoints,
      featuresCount: featuresCount,
      modelsReady: modelsReady,
      aiFestivalMessages: aiFestivalMessages,
    );
  }

  Future<void> initialSyncIfPossible({
    int? loyaltyPoints,
    int? featuresCount,
    bool? modelsReady,
    int? aiFestivalMessages,
  }) async {
    if (!_enableSync) return;
    if (loyaltyPoints == null || featuresCount == null) return;
    await _ensureInitialized();
    if (!_initialized) return;
    if (_lastSuccessfulSync != null) return; // already synced once
    await syncUserState(
      loyaltyPoints: loyaltyPoints,
      featuresCount: featuresCount,
      modelsReady: modelsReady,
      aiFestivalMessages: aiFestivalMessages,
    );
  }

  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;

  /// Returns the sanitized user id (phone with non-alphanumerics replaced) or null if no phone.
  String? get sanitizedUserId {
    final phone = AuthService().currentPhoneNumber;
    if (phone == null) return null;
    return phone.replaceAll(RegExp(r'[^0-9A-Za-z]'), '_');
  }

  Future<void> loadLastSyncFromStorage() async {
    try {
      final box = Hive.isBoxOpen('truecircle_settings')
          ? Hive.box('truecircle_settings')
          : await Hive.openBox('truecircle_settings');
      final iso = box.get('last_sync_iso', defaultValue: null) as String?;
      if (iso != null) {
        _lastSuccessfulSync = DateTime.tryParse(iso);
        lastSyncNotifier.value = _lastSuccessfulSync;
      }
    } catch (_) {}
  }

  Future<void> manualSync() async {
    if (!_enableSync) return;
    if (_pendingPayload != null) {
      // Try flushing pending first
      final payload = _pendingPayload!;
      _pendingPayload = null; // prevent double retains
      await _attemptWrite(payload);
    }
  }

  /// Force a test sync (bypasses throttling logic in UI). Returns true if a write attempt was made.
  Future<bool> manualTestSync({
    required int loyaltyPoints,
    required int featuresCount,
    bool? modelsReady,
    int? aiFestivalMessages,
  }) async {
    if (!_enableSync) return false;
    final phone = AuthService().currentPhoneNumber;
    if (phone == null) {
      lastErrorNotifier.value = 'no-phone';
      return false;
    }
    await syncUserState(
      loyaltyPoints: loyaltyPoints,
      featuresCount: featuresCount,
      modelsReady: modelsReady,
      aiFestivalMessages: aiFestivalMessages,
    );
    return true;
  }

  /// High-level state sync (loyalty points, feature counts, model flags)
  Future<void> syncUserState({
    required int loyaltyPoints,
    required int featuresCount,
    bool? modelsReady,
    int? aiFestivalMessages,
  }) async {
    if (!_enableSync) return; // Respect disabled state

    final auth = AuthService();
    final phone = auth.currentPhoneNumber;
    if (phone == null) {
      debugPrint(
          '[CloudSync] Skip: no phone (user not signed in / not restored)');
      return; // No user context
    }

    await _ensureInitialized();
    if (!_initialized) {
      debugPrint('[CloudSync] Skip: Firebase not initialized');
      return; // Failed init
    }

    try {
      final box = Hive.isBoxOpen('truecircle_settings')
          ? Hive.box('truecircle_settings')
          : await Hive.openBox('truecircle_settings');
      final hasSeenHow =
          box.get('${phone}_seen_how_works', defaultValue: false) as bool;
      final modelsDownloaded = modelsReady ??
          box.get('${phone}_models_downloaded', defaultValue: false) as bool;

      final sanitizedId = phone.replaceAll(RegExp(r'[^0-9A-Za-z]'), '_');
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(sanitizedId)
          .collection('meta')
          .doc('state');

      final payload = <String, dynamic>{
        'loyaltyPoints': loyaltyPoints,
        'featuresCount': featuresCount,
        'modelsDownloaded': modelsDownloaded,
        'onboardingSeen': hasSeenHow,
        'festivalMsgCount': aiFestivalMessages,
        'updatedAt': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0-beta',
        'privacyLevel': 'sample-mode',
      }..removeWhere((_, v) => v == null);

      debugPrint(
          '[CloudSync] Preparing write for phone=$sanitizedId payloadKeys=${payload.keys.toList()}');
      await _attemptWriteToDoc(docRef, payload);
    } catch (e) {
      lastErrorNotifier.value = 'sync: $e';
      debugPrint('[CloudSync] Sync failed: $e');
    }
  }

  Future<void> _attemptWriteToDoc(
      DocumentReference<Map<String, dynamic>> docRef,
      Map<String, dynamic> payload) async {
    try {
      syncingNotifier.value = true;
      await docRef.set(payload, SetOptions(merge: true));
      _recordSuccess(payload);
    } catch (e) {
      debugPrint('[CloudSync] Firestore write error, queueing retry: $e');
      lastErrorNotifier.value = 'write: $e';
      _queueRetry(payload);
    } finally {
      syncingNotifier.value = false;
    }
  }

  Future<void> _attemptWrite(Map<String, dynamic> payload) async {
    final auth = AuthService();
    final phone = auth.currentPhoneNumber;
    if (phone == null) return;
    final sanitizedId = phone.replaceAll(RegExp(r'[^0-9A-Za-z]'), '_');
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(sanitizedId)
        .collection('meta')
        .doc('state');
    await _attemptWriteToDoc(docRef, payload);
  }

  void _recordSuccess(Map<String, dynamic> payload) async {
    _retryAttempt = 0;
    _pendingPayload = null;
    _retryTimer?.cancel();
    _retryCountdownTimer?.cancel();
    retryCountdownNotifier.value = null;
    _lastPayloadKeys = payload.keys.toList()..sort();
    _lastSuccessfulSync = DateTime.now();
    lastSyncNotifier.value = _lastSuccessfulSync;
    try {
      final box = Hive.isBoxOpen('truecircle_settings')
          ? Hive.box('truecircle_settings')
          : await Hive.openBox('truecircle_settings');
      await box.put('last_sync_iso', _lastSuccessfulSync!.toIso8601String());
      await box.delete('pending_sync_state');
    } catch (_) {}
    debugPrint(
        '[CloudSync] State synced successfully at ${_lastSuccessfulSync!.toIso8601String()}');
  }

  /// Debug helper: last successfully synced payload keys (sorted)
  List<String>? get lastPayloadKeys => _lastPayloadKeys;

  void _queueRetry(Map<String, dynamic> payload) async {
    _pendingPayload = payload;
    _retryAttempt = min(_retryAttempt + 1, 6); // cap at attempt 6
    final delaySeconds = pow(2, _retryAttempt).toInt(); // 2,4,8,16,32,64
    _retryTimer?.cancel();
    _retryCountdownTimer?.cancel();
    try {
      final box = Hive.isBoxOpen('truecircle_settings')
          ? Hive.box('truecircle_settings')
          : await Hive.openBox('truecircle_settings');
      await box.put('pending_sync_state', payload);
    } catch (_) {}
    debugPrint(
        '[CloudSync] Scheduling retry in ${delaySeconds}s (attempt $_retryAttempt)');
    // Countdown notifier
    int remaining = delaySeconds;
    retryCountdownNotifier.value = remaining;
    _retryCountdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      remaining -= 1;
      if (remaining <= 0) {
        t.cancel();
        retryCountdownNotifier.value = null; // will be cleared when retry fires
      } else {
        retryCountdownNotifier.value = remaining;
      }
    });
    _retryTimer = Timer(Duration(seconds: delaySeconds), () async {
      if (!_enableSync || _pendingPayload == null) return;
      await _attemptWrite(_pendingPayload!);
    });
  }

  /// Permanently deletes the remote metadata document (user can purge cloud copy)
  Future<bool> clearCloudMetadata() async {
    final auth = AuthService();
    final phone = auth.currentPhoneNumber;
    if (phone == null) return false;
    await _ensureInitialized();
    if (!_initialized) return false;
    try {
      final sanitizedId = phone.replaceAll(RegExp(r'[^0-9A-Za-z]'), '_');
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(sanitizedId)
          .collection('meta')
          .doc('state');
      await docRef.delete();
      debugPrint('[CloudSync] Remote metadata cleared by user');
      return true;
    } catch (e) {
      debugPrint('[CloudSync] Failed to clear metadata: $e');
      return false;
    }
  }
}
