import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../auth/otp_page.dart';
import '../services/otp_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _busy = false;
  final _phoneController = TextEditingController();
  String _selectedCountry = 'IN'; // Default to India
  String _error = '';

  // Comprehensive country data with flag emojis and dial codes
  final Map<String, Map<String, String>> _countries = {
    'IN': {'name': 'India', 'flag': '🇮🇳', 'dial': '+91'},
    'US': {'name': 'United States', 'flag': '🇺🇸', 'dial': '+1'},
    'GB': {'name': 'United Kingdom', 'flag': '🇬🇧', 'dial': '+44'},
    'CA': {'name': 'Canada', 'flag': '🇨🇦', 'dial': '+1'},
    'AU': {'name': 'Australia', 'flag': '🇦🇺', 'dial': '+61'},
    'DE': {'name': 'Germany', 'flag': '🇩🇪', 'dial': '+49'},
    'FR': {'name': 'France', 'flag': '🇫🇷', 'dial': '+33'},
    'JP': {'name': 'Japan', 'flag': '🇯🇵', 'dial': '+81'},
    'CN': {'name': 'China', 'flag': '🇨🇳', 'dial': '+86'},
    'BR': {'name': 'Brazil', 'flag': '🇧🇷', 'dial': '+55'},
    'RU': {'name': 'Russia', 'flag': '🇷🇺', 'dial': '+7'},
    'IT': {'name': 'Italy', 'flag': '🇮🇹', 'dial': '+39'},
    'ES': {'name': 'Spain', 'flag': '🇪🇸', 'dial': '+34'},
    'MX': {'name': 'Mexico', 'flag': '🇲🇽', 'dial': '+52'},
    'AR': {'name': 'Argentina', 'flag': '🇦🇷', 'dial': '+54'},
    'ZA': {'name': 'South Africa', 'flag': '🇿🇦', 'dial': '+27'},
    'EG': {'name': 'Egypt', 'flag': '🇪🇬', 'dial': '+20'},
    'NG': {'name': 'Nigeria', 'flag': '🇳🇬', 'dial': '+234'},
    'KE': {'name': 'Kenya', 'flag': '🇰🇪', 'dial': '+254'},
    'PK': {'name': 'Pakistan', 'flag': '🇵🇰', 'dial': '+92'},
    'BD': {'name': 'Bangladesh', 'flag': '🇧🇩', 'dial': '+880'},
    'ID': {'name': 'Indonesia', 'flag': '🇮🇩', 'dial': '+62'},
    'MY': {'name': 'Malaysia', 'flag': '🇲🇾', 'dial': '+60'},
    'TH': {'name': 'Thailand', 'flag': '🇹🇭', 'dial': '+66'},
    'VN': {'name': 'Vietnam', 'flag': '🇻🇳', 'dial': '+84'},
    'PH': {'name': 'Philippines', 'flag': '🇵🇭', 'dial': '+63'},
    'SG': {'name': 'Singapore', 'flag': '🇸🇬', 'dial': '+65'},
    'KR': {'name': 'South Korea', 'flag': '🇰🇷', 'dial': '+82'},
    'TR': {'name': 'Turkey', 'flag': '🇹🇷', 'dial': '+90'},
    'SA': {'name': 'Saudi Arabia', 'flag': '🇸🇦', 'dial': '+966'},
    'AE': {'name': 'UAE', 'flag': '🇦🇪', 'dial': '+971'},
    'IL': {'name': 'Israel', 'flag': '🇮🇱', 'dial': '+972'},
    'NL': {'name': 'Netherlands', 'flag': '🇳🇱', 'dial': '+31'},
    'BE': {'name': 'Belgium', 'flag': '🇧🇪', 'dial': '+32'},
    'CH': {'name': 'Switzerland', 'flag': '🇨🇭', 'dial': '+41'},
    'AT': {'name': 'Austria', 'flag': '🇦🇹', 'dial': '+43'},
    'SE': {'name': 'Sweden', 'flag': '🇸🇪', 'dial': '+46'},
    'NO': {'name': 'Norway', 'flag': '🇳🇴', 'dial': '+47'},
    'DK': {'name': 'Denmark', 'flag': '🇩🇰', 'dial': '+45'},
    'FI': {'name': 'Finland', 'flag': '🇫🇮', 'dial': '+358'},
    'PL': {'name': 'Poland', 'flag': '🇵🇱', 'dial': '+48'},
    'CZ': {'name': 'Czech Republic', 'flag': '🇨🇿', 'dial': '+420'},
    'HU': {'name': 'Hungary', 'flag': '🇭�', 'dial': '+36'},
    'GR': {'name': 'Greece', 'flag': '🇬�🇷', 'dial': '+30'},
    'PT': {'name': 'Portugal', 'flag': '🇵🇹', 'dial': '+351'},
    'IE': {'name': 'Ireland', 'flag': '🇮🇪', 'dial': '+353'},
    'NZ': {'name': 'New Zealand', 'flag': '🇳🇿', 'dial': '+64'},
  };

  @override
  void initState() {
    super.initState();
    // Detect country automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectUserCountry();
    });
  }

  void _detectUserCountry() {
    try {
      // Try to get from system locale first
      final locale = Localizations.localeOf(context).countryCode;
      if (locale != null && _countries.containsKey(locale)) {
        setState(() => _selectedCountry = locale);
        return;
      }

      // Enhanced fallback logic - prioritize common countries for TrueCircle
      // Check timezone to make better guess
      final now = DateTime.now();
      final offset = now.timeZoneOffset.inHours;

      // India Standard Time (UTC+5:30)
      if (offset == 5 || offset == 6) {
        setState(() => _selectedCountry = 'IN');
        return;
      }

      // US timezones (UTC-5 to UTC-8)
      if (offset >= -8 && offset <= -5) {
        setState(() => _selectedCountry = 'US');
        return;
      }

      // UK timezone (UTC+0 to UTC+1)
      if (offset >= 0 && offset <= 1) {
        setState(() => _selectedCountry = 'GB');
        return;
      }

      // Default to India as primary target market
      setState(() => _selectedCountry = 'IN');
    } catch (e) {
      // Final fallback to India
      setState(() => _selectedCountry = 'IN');
    }
  }

  int _getExpectedPhoneLength(String countryCode) {
    // Define expected phone number lengths for different countries
    switch (countryCode) {
      case 'IN': // India
        return 10;
      case 'US': // United States
      case 'CA': // Canada
        return 10;
      case 'GB': // United Kingdom
        return 11;
      case 'AU': // Australia
        return 9;
      case 'DE': // Germany
        return 11;
      case 'FR': // France
        return 10;
      case 'JP': // Japan
        return 10;
      case 'CN': // China
        return 11;
      case 'BR': // Brazil
        return 11;
      case 'RU': // Russia
        return 10;
      case 'IT': // Italy
        return 10;
      case 'ES': // Spain
        return 9;
      case 'MX': // Mexico
        return 10;
      case 'AR': // Argentina
        return 10;
      case 'ZA': // South Africa
        return 9;
      case 'EG': // Egypt
        return 10;
      case 'NG': // Nigeria
        return 11;
      case 'KE': // Kenya
        return 9;
      case 'PK': // Pakistan
        return 10;
      case 'BD': // Bangladesh
        return 11;
      case 'ID': // Indonesia
        return 10;
      case 'MY': // Malaysia
        return 10;
      case 'TH': // Thailand
        return 9;
      case 'VN': // Vietnam
        return 9;
      case 'PH': // Philippines
        return 10;
      case 'SG': // Singapore
        return 8;
      case 'KR': // South Korea
        return 10;
      case 'TR': // Turkey
        return 10;
      default:
        return 10; // Default fallback
    }
  }

  Future<void> _getOtp() async {
    final phoneNumber = _phoneController.text.trim();

    // Clear any previous error
    setState(() => _error = '');

    // Validation
    if (phoneNumber.isEmpty) {
      setState(() => _error = 'Please enter your phone number');
      return;
    }

    // Validate phone number length based on selected country
    final expectedLength = _getExpectedPhoneLength(_selectedCountry);
    if (phoneNumber.length != expectedLength) {
      setState(
        () => _error = 'Phone number must be exactly $expectedLength digits',
      );
      return;
    }

    // Only digits check
    if (!RegExp(r'^[0-9]+$').hasMatch(phoneNumber)) {
      setState(() => _error = 'Please enter only numbers');
      return;
    }

    setState(() {
      _busy = true;
      _error = '';
    });

    // Send OTP using service
    final fullNumber = '${_countries[_selectedCountry]!['dial']}$phoneNumber';

    try {
      // Try to send OTP
      final otpService = OtpService();
      final otpSent = await otpService.sendOtp(
        fullNumber,
      ); // Show loading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  otpSent ? Icons.check_circle : Icons.sms,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 12),
                Text(
                  otpSent
                      ? 'OTP sent to $fullNumber'
                      : 'Processing $fullNumber...',
                ),
              ],
            ),
            backgroundColor: otpSent ? Colors.green : Colors.blue,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Try to store data but don't fail if it doesn't work
      try {
        final box = await Hive.openBox('app_prefs');
        await box.put('onboarding_done', true);
        await box.put('pending_phone', fullNumber);
      } catch (storageError) {
        // Continue anyway - offline mode doesn't require storage
      }

      // Short delay for user feedback
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      // Always navigate - this is offline mode
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OtpPage(phoneNumber: fullNumber)),
      );
    } catch (e) {
      // Even if there's an error, navigate to OTP page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => OtpPage(phoneNumber: fullNumber)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // Handle Enter key press on phone number field
  void _submitPhoneNumber() {
    if (!_busy) {
      _getOtp();
    }
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Country',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _countries.length,
                itemBuilder: (context, index) {
                  final countryCode = _countries.keys.elementAt(index);
                  final country = _countries[countryCode]!;
                  final isSelected = countryCode == _selectedCountry;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Text(
                        country['flag']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        country['name']!,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        country['dial']!,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCountry = countryCode;
                          // Clear phone number if it doesn't match new country's expected length
                          final currentLength = _phoneController.text.length;
                          final expectedLength = _getExpectedPhoneLength(
                            countryCode,
                          );
                          if (currentLength > 0 &&
                              currentLength != expectedLength) {
                            _phoneController.clear();
                          }
                          // Clear any error message
                          _error = '';
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to TrueCircle')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Logo Section - Pure Inner Circle Only 🌟
              ClipOval(
                child: Image.asset(
                  'assets/images/TrueCircle-Logo.png',
                  height: 140,
                  width: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Beautiful TrueCircle circular fallback
                    return Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.psychology_rounded,
                            size: 45,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'TrueCircle',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TrueCircle',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Emotional Health & Wellness',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              // Phone Input Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter your phone number',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Country Selector + Phone Input
                    Row(
                      children: [
                        // Country Picker Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _showCountryPicker,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _countries[_selectedCountry]!['flag']!,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _countries[_selectedCountry]!['dial']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Phone Number Input
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submitPhoneNumber(),
                            maxLength: _getExpectedPhoneLength(
                              _selectedCountry,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              counterText: '', // Hide the counter
                              hintText: 'Enter phone number',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: (value) {
                              if (_error.isNotEmpty) {
                                setState(() => _error = '');
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 14,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Get OTP Button - Simplified for better responsiveness
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _busy
                            ? null
                            : () {
                                // Add haptic feedback
                                HapticFeedback.lightImpact();
                                // Show immediate feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Button pressed! Processing...',
                                    ),
                                    duration: Duration(milliseconds: 500),
                                  ),
                                );
                                _getOtp();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _busy
                              ? Colors.grey[400]
                              : Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: _busy ? 0 : 4,
                          shadowColor: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.sms_outlined, size: 22),
                        label: Text(
                          _busy ? 'Sending OTP...' : 'Get OTP 📱',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Privacy Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Secure offline app - Your data stays private on your device.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
