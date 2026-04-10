import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../l10n/app_strings.dart';
import '../../services/reward_service.dart';
import '../../services/country_detector_service.dart';
import '../../services/sos_service.dart';
import '../../theme/truecircle_theme.dart';
import '../intro/dr_iris_intro_screen.dart';
import '../../widgets/coin_reward_celebration.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const String _testOtp = '123456';
  static const String _otpSupportWhatsappHandle = 'wa.me/918690888121';

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileOtpController = TextEditingController();
  final TextEditingController _emailOtpController = TextEditingController();

  bool _mobileOtpSent = false;
  bool _emailOtpSent = false;
  bool _isVerifying = false;
  String _countryCode = 'IN';
  String _phonePrefix = '+91';
  final RewardService _rewardService = RewardService();

  @override
  void initState() {
    super.initState();
    _bootstrapCountryPrefix();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _emailController.dispose();
    _mobileOtpController.dispose();
    _emailOtpController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapCountryPrefix() async {
    final String? detected = await CountryDetectorService.detect();
    final String code = (detected == null || detected.trim().isEmpty)
        ? 'IN'
        : detected.toUpperCase();
    if (!mounted) return;
    setState(() {
      _countryCode = code;
      _phonePrefix = _dialingPrefixForCountry(code);
    });
  }

  String _dialingPrefixForCountry(String code) {
    switch (code) {
      case 'US':
        return '+1';
      case 'UK':
      case 'GB':
        return '+44';
      case 'IN':
      default:
        return '+91';
    }
  }

  bool _isValidMobile(String value) {
    return RegExp(r'^[0-9]{7,15}$').hasMatch(value.trim());
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  }

  void _sendMobileOtp() {
    if (!_isValidMobile(_mobileController.text)) {
      _showSnack(AppStrings.t(context, 'enter_valid_mobile'));
      return;
    }
    setState(() {
      _mobileOtpSent = true;
    });
    _showSnack(
      AppStrings.t(
        context,
        'mobile_otp_routed',
        args: <String, String>{'handle': _otpSupportWhatsappHandle},
      ),
    );
  }

  void _sendEmailOtp() {
    if (!_isValidEmail(_emailController.text)) {
      _showSnack(AppStrings.t(context, 'enter_valid_email'));
      return;
    }
    setState(() {
      _emailOtpSent = true;
    });
    _showSnack(AppStrings.t(context, 'email_otp_sent'));
  }

  Future<void> _verifyAndContinue() async {
    if (!_mobileOtpSent || !_emailOtpSent) {
      _showSnack(AppStrings.t(context, 'send_both_otps'));
      return;
    }

    if (_mobileOtpController.text.trim() != _testOtp ||
        _emailOtpController.text.trim() != _testOtp) {
      _showSnack(AppStrings.t(context, 'invalid_otp_test'));
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    final String localMobile = _mobileController.text.trim();
    final String fullMobile = '$_phonePrefix$localMobile';

    final String? detected = await CountryDetectorService.detect();
    final String code = (detected == null || detected.trim().isEmpty)
        ? _countryCode
        : detected.toUpperCase();
    await SOSService.saveEmergencyNumbersFor(code);

    if (Hive.isBoxOpen('appBox')) {
      await Hive.box('appBox').put('contact_verification_complete', true);
      await Hive.box('appBox').put('onboarding_complete', true);
      await Hive.box('appBox').put('onboarding_v2_verified', true);
      await Hive.box('appBox').put('user_country_code', code);
      await Hive.box('appBox').put('user_phone_prefix', _phonePrefix);
      await Hive.box('appBox').put('user_mobile_local', localMobile);
      await Hive.box('appBox').put('user_mobile', fullMobile);
      await Hive.box('appBox').put('user_email', _emailController.text.trim());
      await Hive.box('appBox').put('user_whatsapp', fullMobile);
      await Hive.box(
        'appBox',
      ).put('otp_whatsapp_destination', _otpSupportWhatsappHandle);
      await Hive.box(
        'appBox',
      ).put('contact_verification_ts_iso', DateTime.now().toIso8601String());
      // Default internet door closed after verification; user can toggle later.
      await Hive.box('appBox').put('is_online', false);
    }
    final RewardGrantResult reward = await _rewardService.grantEntryFormCoin(
      formId: 'verification',
    );

    if (!mounted) return;
    await CoinRewardCelebration.show(
      context,
      message: AppStrings.t(
        context,
        'coin_earned_verification',
        args: <String, String>{'balance': reward.balance.toString()},
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const DrIrisIntroScreen()),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppStrings.t(context, 'verify_account')),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: TrueCircleTheme.appBackgroundGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Center(
              child: ClipOval(
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              AppStrings.t(context, 'welcome_truecircle'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.t(context, 'verify_mobile_email'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 22),
            _buildSectionCard(
              title: AppStrings.t(context, 'mobile_verification'),
              icon: Icons.phone_android,
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    maxLength: 15,
                    decoration: InputDecoration(
                      labelText: AppStrings.t(context, 'mobile_number'),
                      hintText: AppStrings.t(context, 'enter_mobile_number'),
                      prefixText: '$_phonePrefix ',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _mobileOtpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: AppStrings.t(context, 'mobile_otp'),
                            hintText: '123456',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: _sendMobileOtp,
                        child: Text(
                          _mobileOtpSent
                              ? AppStrings.t(context, 'resend')
                              : AppStrings.t(context, 'send_otp'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildSectionCard(
              title: AppStrings.t(context, 'email_verification'),
              icon: Icons.email_outlined,
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: AppStrings.t(context, 'email_address'),
                      hintText: 'you@example.com',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _emailOtpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: AppStrings.t(context, 'email_otp'),
                            hintText: '123456',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: _sendEmailOtp,
                        child: Text(
                          _emailOtpSent
                              ? AppStrings.t(context, 'resend')
                              : AppStrings.t(context, 'send_otp'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isVerifying ? null : _verifyAndContinue,
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _isVerifying
                    ? AppStrings.t(context, 'verifying')
                    : AppStrings.t(context, 'verify_continue'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.t(context, 'test_otp_both'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
