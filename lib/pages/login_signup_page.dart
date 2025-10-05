import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/global_navigation_bar.dart';
import '../widgets/truecircle_logo.dart';
import 'how_truecircle_works_page.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController =
      TextEditingController(text: '+91 ');

  bool _isLoading = false;
  bool _isOtpSent = false;
  String _phoneNumber = '';
  String _otp = '';
  String _errorMessage = '';
  final bool _isHindi = false;

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();
    _phoneNumber = _phoneController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isOtpSent = true;
        _errorMessage =
            '✅ OTP भेज दिया गया: $_phoneNumber\n🔐 Test OTP: 123456 (demo)';
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

  Future<void> _verifyOtp() async {
    if (_otp.length != 6) {
      setState(() {
        _errorMessage = 'कृपया 6 अंकों का OTP दर्ज करें';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_otp == '123456') {
        final success = await _authService.signInWithPhoneNumber(_phoneNumber);
        if (success && mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HowTrueCircleWorksPage(),
            ),
            (route) => false,
          );
        }
      } else {
        throw Exception('Invalid OTP');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'OTP मान्य नहीं है, दोबारा प्रयास करें';
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
    const coralDark = Color(0xFFFF6233);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFA385),
                Color(0xFFFF7F50),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            tooltip: 'How TrueCircle Works',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HowTrueCircleWorksPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFA385),
              Color(0xFFFF7F50),
              Color(0xFFFF6233),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.95),
                      border: Border.all(
                        color: coralDark.withValues(alpha: 0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: coralDark.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const ClipOval(
                      child: TrueCircleLogo(size: 150, showText: false),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isHindi ? 'ट्रू सर्कल' : 'TrueCircle',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isHindi
                        ? 'रिश्तों में स्पष्टता और भरोसा'
                        : 'Bringing clarity in relationships',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!_isOtpSent)
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: _isHindi ? 'मोबाइल नंबर' : 'Mobile Number',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: '+91 XXXXX XXXXX',
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon:
                            const Icon(Icons.phone, color: Colors.white70),
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
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return _isHindi
                              ? 'कृपया मोबाइल नंबर दर्ज करें'
                              : 'Please enter mobile number';
                        }
                        if (!value.startsWith('+91 ')) {
                          return _isHindi
                              ? 'नंबर +91 के साथ शुरू होना चाहिए'
                              : 'Number should start with +91';
                        }
                        final digits =
                            value.replaceAll('+91 ', '').replaceAll(' ', '');
                        if (digits.length != 10) {
                          return _isHindi
                              ? '10 अंकों का वैध नंबर दर्ज करें'
                              : 'Enter a valid 10-digit number';
                        }
                        return null;
                      },
                      onSaved: (value) => _phoneNumber = value ?? '',
                      onChanged: (value) {
                        if (!value.startsWith('+91 ')) {
                          _phoneController.text = '+91 ';
                          _phoneController.selection =
                              TextSelection.fromPosition(
                            TextPosition(offset: _phoneController.text.length),
                          );
                        }
                      },
                    )
                  else ...[
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.95),
                        border: Border.all(
                          color: coralDark.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: coralDark.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const ClipOval(
                        child: TrueCircleLogo(size: 80, showText: false),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isHindi
                          ? 'OTP भेजा गया: $_phoneNumber'
                          : 'OTP sent to $_phoneNumber',
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        letterSpacing: 4,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: _isHindi ? 'OTP दर्ज करें' : 'Enter OTP',
                        labelStyle: const TextStyle(color: Colors.white70),
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
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                      ),
                      onChanged: (value) => _otp = value.trim(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _errorMessage.contains('✅')
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _errorMessage.contains('✅')
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      child: Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _errorMessage.contains('✅')
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  if (_errorMessage.isNotEmpty) const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _isOtpSent ? _verifyOtp : _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: coralDark,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            _isOtpSent
                                ? (_isHindi
                                    ? 'OTP सत्यापित करें'
                                    : 'Verify OTP')
                                : (_isHindi ? 'OTP भेजें' : 'Send OTP'),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                  if (_isOtpSent) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isOtpSent = false;
                              _otp = '';
                              _errorMessage = '';
                            });
                          },
                          child: Text(
                            _isHindi ? 'नंबर बदलें' : 'Change Number',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        TextButton(
                          onPressed: _sendOtp,
                          child: Text(
                            _isHindi ? 'OTP पुनः भेजें' : 'Resend OTP',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                  GlobalNavigationBar(
                    isHindi: _isHindi,
                    onBack: () => Navigator.maybePop(context),
                    onNext: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HowTrueCircleWorksPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
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
