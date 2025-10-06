import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPService {
  static final OTPService _instance = OTPService._internal();
  factory OTPService() => _instance;
  OTPService._internal();

  // Generate a 6-digit OTP
  String generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Simulate sending OTP (in real app, use SMS service like Firebase Auth)
  Future<String> sendOTP(String phoneNumber) async {
    final otp = generateOTP();
    
    // Store OTP temporarily (in real app, this would be server-side)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temp_otp', otp);
    await prefs.setString('temp_phone', phoneNumber);
    await prefs.setInt('otp_timestamp', DateTime.now().millisecondsSinceEpoch);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In real app, you'd send SMS here
    // For testing, we'll return the OTP
    debugPrint('📱 OTP sent to $phoneNumber: $otp');
    return otp;
  }

  // Verify OTP
  Future<OTPVerificationResult> verifyOTP(String phoneNumber, String enteredOTP) async {
    final prefs = await SharedPreferences.getInstance();
    final storedOTP = prefs.getString('temp_otp');
    final storedPhone = prefs.getString('temp_phone');
    final timestamp = prefs.getInt('otp_timestamp') ?? 0;
    
    // Check if OTP exists
    if (storedOTP == null || storedPhone == null) {
      return OTPVerificationResult(
        success: false,
        message: 'OTP not found. Please request a new OTP.',
      );
    }
    
    // Check if phone number matches
    if (storedPhone != phoneNumber) {
      return OTPVerificationResult(
        success: false,
        message: 'Phone number mismatch.',
      );
    }
    
    // Check if OTP expired (5 minutes)
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - timestamp > 300000) { // 5 minutes
      // Clear expired OTP
      await _clearTempOTP();
      return OTPVerificationResult(
        success: false,
        message: 'OTP expired. Please request a new OTP.',
      );
    }
    
    // Verify OTP
    if (storedOTP == enteredOTP) {
      // Clear temporary data and mark as verified
      await _clearTempOTP();
      await prefs.setString('verified_phone', phoneNumber);
      await prefs.setBool('phone_verified', true);
      
      return OTPVerificationResult(
        success: true,
        message: 'Phone number verified successfully!',
      );
    } else {
      return OTPVerificationResult(
        success: false,
        message: 'Invalid OTP. Please try again.',
      );
    }
  }

  // Check if phone is already verified
  Future<bool> isPhoneVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('phone_verified') ?? false;
  }

  // Get verified phone number
  Future<String?> getVerifiedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    if (await isPhoneVerified()) {
      return prefs.getString('verified_phone');
    }
    return null;
  }

  // Clear temporary OTP data
  Future<void> _clearTempOTP() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('temp_otp');
    await prefs.remove('temp_phone');
    await prefs.remove('otp_timestamp');
  }

  // Resend OTP
  Future<String> resendOTP(String phoneNumber) async {
    await _clearTempOTP();
    return await sendOTP(phoneNumber);
  }

  // Clear all verification data (for logout)
  Future<void> clearVerificationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('verified_phone');
    await prefs.remove('phone_verified');
    await _clearTempOTP();
  }

  // Validate phone number format
  bool isValidPhoneNumber(String phone) {
    // Remove all non-digits
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid Indian mobile number
    // Indian mobile numbers: +91 followed by 10 digits starting with 6,7,8,9
    if (digitsOnly.length == 10) {
      // Without country code
      final firstDigit = int.tryParse(digitsOnly[0]);
      return firstDigit != null && firstDigit >= 6 && firstDigit <= 9;
    } else if (digitsOnly.length == 12 && digitsOnly.startsWith('91')) {
      // With country code 91
      final firstDigit = int.tryParse(digitsOnly[2]);
      return firstDigit != null && firstDigit >= 6 && firstDigit <= 9;
    }
    
    return false;
  }

  // Format phone number for display
  String formatPhoneNumber(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length == 10) {
      return '+91 ${digitsOnly.substring(0, 5)} ${digitsOnly.substring(5)}';
    } else if (digitsOnly.length == 12 && digitsOnly.startsWith('91')) {
      final number = digitsOnly.substring(2);
      return '+91 ${number.substring(0, 5)} ${number.substring(5)}';
    }
    
    return phone;
  }

  // Get clean phone number (digits only with country code)
  String getCleanPhoneNumber(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length == 10) {
      return '91$digitsOnly';
    } else if (digitsOnly.length == 12 && digitsOnly.startsWith('91')) {
      return digitsOnly;
    }
    
    return digitsOnly;
  }
}

class OTPVerificationResult {
  final bool success;
  final String message;

  OTPVerificationResult({
    required this.success,
    required this.message,
  });
}

// OTP Verification Widget
class OTPVerificationDialog extends StatefulWidget {
  final String phoneNumber;
  final Function(bool success, String message) onVerificationComplete;
  final bool isHindi;

  const OTPVerificationDialog({
    super.key,
    required this.phoneNumber,
    required this.onVerificationComplete,
    this.isHindi = false,
  });

  @override
  State<OTPVerificationDialog> createState() => _OTPVerificationDialogState();
}

class _OTPVerificationDialogState extends State<OTPVerificationDialog> {
  final TextEditingController _otpController = TextEditingController();
  final OTPService _otpService = OTPService();
  
  bool _isLoading = false;
  bool _isResending = false;
  String _errorMessage = '';
  int _remainingTime = 300; // 5 minutes in seconds
  String _sentOTP = ''; // For testing purposes only

  @override
  void initState() {
    super.initState();
    _sendInitialOTP();
    _startTimer();
  }

  void _sendInitialOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final otp = await _otpService.sendOTP(widget.phoneNumber);
      setState(() {
        _sentOTP = otp; // For testing only - remove in production
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = widget.isHindi 
          ? 'OTP भेजने में त्रुटि। कृपया पुनः प्रयास करें।'
          : 'Error sending OTP. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
        _startTimer();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _verifyOTP() async {
    if (_otpController.text.length != 6) {
      setState(() {
        _errorMessage = widget.isHindi 
          ? 'कृपया 6 अंकों का OTP दर्ज करें'
          : 'Please enter 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _otpService.verifyOTP(
        widget.phoneNumber,
        _otpController.text,
      );

      if (result.success) {
        widget.onVerificationComplete(true, result.message);
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = result.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = widget.isHindi 
          ? 'सत्यापन में त्रुटि। कृपया पुनः प्रयास करें।'
          : 'Verification error. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _resendOTP() async {
    if (_isResending || _remainingTime > 240) return; // Can resend only after 1 minute

    setState(() {
      _isResending = true;
      _errorMessage = '';
    });

    try {
      final otp = await _otpService.resendOTP(widget.phoneNumber);
      setState(() {
        _sentOTP = otp; // For testing only
        _remainingTime = 300;
        _isResending = false;
        _otpController.clear();
      });
      _startTimer();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isHindi 
                ? 'OTP पुनः भेजा गया'
                : 'OTP resent successfully',
            ),
          backgroundColor: Colors.green,
        ),
      );
      }
    } catch (e) {
      setState(() {
        _errorMessage = widget.isHindi 
          ? 'OTP पुनः भेजने में त्रुटि'
          : 'Error resending OTP';
        _isResending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.phone_android, color: Colors.blue, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.isHindi ? 'फोन सत्यापन' : 'Phone Verification',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phone number display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.isHindi 
                      ? 'OTP भेजा गया: ${_otpService.formatPhoneNumber(widget.phoneNumber)}'
                      : 'OTP sent to: ${_otpService.formatPhoneNumber(widget.phoneNumber)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Test OTP display (remove in production)
          if (_sentOTP.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.isHindi 
                        ? 'परीक्षण OTP: $_sentOTP (वास्तविक ऐप में यह नहीं दिखेगा)'
                        : 'Test OTP: $_sentOTP (Hidden in production)',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // OTP input field
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              labelText: widget.isHindi ? '6-अंकीय OTP दर्ज करें' : 'Enter 6-digit OTP',
              border: const OutlineInputBorder(),
              counterText: '',
              prefixIcon: const Icon(Icons.security),
            ),
            onChanged: (value) {
              if (value.length == 6) {
                _verifyOTP();
              }
            },
          ),
          
          const SizedBox(height: 16),
          
          // Timer and resend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isHindi 
                  ? 'समय: ${_formatTime(_remainingTime)}'
                  : 'Time: ${_formatTime(_remainingTime)}',
                style: TextStyle(
                  color: _remainingTime < 60 ? Colors.red : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: _remainingTime <= 240 && !_isResending ? _resendOTP : null,
                child: _isResending 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.isHindi ? 'पुनः भेजें' : 'Resend OTP',
                      style: TextStyle(
                        color: _remainingTime <= 240 ? Colors.blue : Colors.grey,
                      ),
                    ),
              ),
            ],
          ),
          
          // Error message
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            widget.isHindi ? 'रद्द करें' : 'Cancel',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOTP,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: _isLoading 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(widget.isHindi ? 'सत्यापित करें' : 'Verify'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
