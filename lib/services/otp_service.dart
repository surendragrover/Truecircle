class OtpService {
  static final OtpService _instance = OtpService._internal();
  factory OtpService() => _instance;
  OtpService._internal();

  // In offline mode, we accept 000000 as valid OTP
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    // Remove any spaces or special characters
    final cleanOtp = otp.replaceAll(RegExp(r'[^0-9]'), '');

    // Check for empty input
    if (cleanOtp.isEmpty) {
      return false;
    }

    // Check length requirement
    if (cleanOtp.length != 6) {
      return false;
    }

    // For offline mode, accept 000000 or 123456
    final validCodes = ['000000', '123456'];
    final isValid = validCodes.contains(cleanOtp);

    // Add extra delay to simulate processing
    await Future.delayed(const Duration(milliseconds: 300));

    return isValid;
  }

  Future<bool> sendOtp(String phoneNumber) async {
    // Add small delay to simulate real service
    await Future.delayed(const Duration(milliseconds: 500));

    // In offline mode, we just simulate sending
    // Always return true for offline mode
    return true;
  }
}
