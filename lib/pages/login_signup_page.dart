
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'gift_marketplace_page.dart';
import '../widgets/truecircle_logo.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController(text: '+91 ');

  // State
  bool _isLoading = false;
  String _phoneNumber = '';
  String _otp = '';
  String _errorMessage = '';
  bool _isOtpSent = false;
  bool _isHindi = false; // Language toggle state



  // Send OTP to phone number
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Here you would implement actual OTP sending
      // For now, we'll simulate OTP sending with demo OTP
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isOtpSent = true;
        _errorMessage = _isHindi 
            ? '✅ OTP सफलतापूर्वक भेजा गया $_phoneNumber पर\n\n🔐 परीक्षण OTP: 123456\n(परीक्षण के लिए इसका उपयोग करें)'
            : '✅ OTP sent successfully to $_phoneNumber\n\n🔐 Test OTP: 123456\n(Use this for testing)';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Verify OTP
  Future<void> _verifyOtp() async {
    debugPrint('Debug: Entered OTP = "$_otp"');
    if (_otp.isEmpty || _otp.length != 6) {
      setState(() {
        _errorMessage = _isHindi 
            ? 'कृपया 6-अंकीय OTP दर्ज करें'
            : 'Please enter 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Here you would implement actual OTP verification
      // For testing, accepting test OTP: 123456
      debugPrint('Debug: Comparing "$_otp" with "123456"');
      if (_otp == '123456') {
        debugPrint('Debug: OTP matched! Logging in user...');
        // Mock successful login - set phone as verified
        bool success = await _authService.signInWithPhoneNumber(_phoneNumber);
        if (success && mounted) {
          debugPrint('Debug: Phone verified successfully');
          // Safer navigation with context check
          try {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const GiftMarketplacePage()),
              (route) => false,
            );
          } catch (navError) {
            debugPrint('Navigation error: $navError');
            // Show success message instead if navigation fails
            setState(() {
              _errorMessage = _isHindi 
                  ? '✅ सफलतापूर्वक लॉग इन हो गए'
                  : '✅ Successfully logged in';
            });
          }
        }
      } else {
        debugPrint('Debug: OTP did not match');
        throw Exception(_isHindi 
            ? 'अमान्य OTP। परीक्षण OTP उपयोग करें: 123456'
            : 'Invalid OTP. Use test OTP: 123456');
      }
    } catch (e) {
      debugPrint('Debug: Exception caught: ${e.toString()}');
      setState(() {
        _errorMessage = _isHindi 
            ? 'अमान्य OTP। कृपया पुनः प्रयास करें।'
            : 'Invalid OTP. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00BFA5), // Brilliant bluish green background
      appBar: AppBar(
        backgroundColor: const Color(0xFF00695C), // Darker teal for AppBar
        elevation: 0,
        actions: [
          // Language Toggle Button
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _isHindi = !_isHindi;
                });
              },
              icon: const Icon(
                Icons.language,
                color: Colors.white,
              ),
              label: Text(
                _isHindi ? 'हिंदी' : 'English',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo Section
                Column(
                  children: [
                    // TrueCircle Professional Logo - Better fallback
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: TrueCircleLogo(
                          size: 150,
                          showText: false,
                          isHindi: _isHindi,
                          style: LogoStyle.compass,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // App Title
                    Text(
                      _isHindi ? 'ट्रू सर्कल' : 'TrueCircle',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Jet black text
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Caption - bringing clarity in relations
                    Text(
                      _isHindi ? 'रिश्तों में स्पष्टता लाना' : 'bringing clarity in relations',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87, // Dark text
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
                const SizedBox(height: 48),

                if (!_isOtpSent) ...[
                  // Phone Number Field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: _isHindi ? 'मोबाइल नंबर' : 'Mobile Number',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintText: '+91 XXXXX XXXXX',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.phone, color: Colors.white70),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty || value == '+91 ') {
                        return _isHindi ? 'कृपया मोबाइल नंबर दर्ज करें' : 'Please enter mobile number';
                      }
                      if (!value.startsWith('+91 ')) {
                        return _isHindi ? 'नंबर +91 से शुरू होना चाहिए' : 'Number should start with +91';
                      }
                      String phoneOnly = value.replaceAll('+91 ', '').replaceAll(' ', '');
                      if (phoneOnly.length != 10) {
                        return _isHindi ? 'वैध 10-अंकीय नंबर दर्ज करें' : 'Enter valid 10-digit number';
                      }
                      return null;
                    },
                    onSaved: (value) => _phoneNumber = value!,
                    onChanged: (value) {
                      // Ensure +91 prefix is always maintained
                      if (value.length < 4 || !value.startsWith('+91 ')) {
                        _phoneController.text = '+91 ';
                        _phoneController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _phoneController.text.length),
                        );
                      }
                      _phoneNumber = _phoneController.text;
                    },
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  // OTP Field with Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    child: ClipOval(
                      child: TrueCircleLogo(
                        size: 80,
                        showText: false,
                        isHindi: _isHindi,
                        style: LogoStyle.compass,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isHindi 
                        ? 'OTP भेजा गया $_phoneNumber पर'
                        : 'OTP sent to $_phoneNumber',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 4),
                    decoration: InputDecoration(
                      labelText: _isHindi ? 'OTP डालें' : 'Enter OTP',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintText: '------',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.security, color: Colors.white70),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    onChanged: (value) => _otp = value,
                  ),
                  const SizedBox(height: 16),
                ],

                // Error/Success Message
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isOtpSent && (_errorMessage.contains('sent') || _errorMessage.contains('भेजा गया'))
                          ? Colors.green.shade50 
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isOtpSent && (_errorMessage.contains('sent') || _errorMessage.contains('भेजा गया'))
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isOtpSent && (_errorMessage.contains('sent') || _errorMessage.contains('भेजा गया'))
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                if (_errorMessage.isNotEmpty) const SizedBox(height: 16),

                // Submit Button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _isOtpSent ? _verifyOtp : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isOtpSent 
                              ? (_isHindi ? 'OTP सत्यापित करें' : 'Verify OTP')
                              : (_isHindi ? 'OTP भेजें' : 'Send OTP'),
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                const SizedBox(height: 16),

                // Resend OTP or Back button
                if (_isOtpSent)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isOtpSent = false;
                            _errorMessage = '';
                            _otp = '';
                          });
                        },
                        child: Text(_isHindi ? 'नंबर बदलें' : 'Change Number', 
                               style: const TextStyle(color: Colors.white70)),
                      ),
                      TextButton(
                        onPressed: _sendOtp,
                        child: Text(_isHindi ? 'फिर भेजें' : 'Resend OTP',
                               style: const TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
