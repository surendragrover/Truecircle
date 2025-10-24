/// App-wide configuration toggles.
///
/// Defaults keep the app fully offline and privacy-first.
/// You can override values at build time using --dart-define, e.g.:
///   --dart-define=OTP_MODE=firebase
class AppConfig {
  /// OTP mode: 'offline' (default) or 'firebase'.
  /// In sample mode, offline is always forced regardless of this value.
  static const String otpMode =
      String.fromEnvironment('OTP_MODE', defaultValue: 'offline');

  static bool get useFirebaseOtp => otpMode.toLowerCase() == 'firebase';
  static bool get useOfflineOtp => !useFirebaseOtp;
}
