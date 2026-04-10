import 'dart:async';

import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../services/country_detector_service.dart';
import '../../services/sos_service.dart';
import '../../theme/truecircle_theme.dart';
import '../content/json_content_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _displayText = '';
  late String _fullText;
  late Timer _typingTimer;
  int _charIndex = 0;
  bool _typingStarted = false;

  @override
  void initState() {
    super.initState();
    _detectCountryAndSaveSOS();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_typingStarted) return;
    _fullText = AppStrings.t(context, 'dr_iris_welcome_message');
    _typingStarted = true;
    _startTypingEffect();
  }

  void _startTypingEffect() {
    const Duration charDelay = Duration(milliseconds: 60);
    _typingTimer = Timer.periodic(charDelay, (_) {
      if (_charIndex < _fullText.length) {
        setState(() {
          _displayText = _fullText.substring(0, _charIndex + 1);
          _charIndex++;
        });
      } else {
        _typingTimer.cancel();
        _continueToCheckIn();
      }
    });
  }

  Future<void> _detectCountryAndSaveSOS() async {
    final String? countryCode = await CountryDetectorService.detect();
    if (countryCode != null) {
      await SOSService.saveEmergencyNumbersFor(countryCode);
    }
  }

  void _continueToCheckIn() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => JsonContentScreen(
          title: AppStrings.t(context, 'checkin_snapshot_title'),
          assetPath: 'assets/data/Feeling_Identification.JSON',
          markFirstCheckInDoneOnSubmit: true,
          navigateToDashboardOnSubmit: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _typingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: TrueCircleTheme.appBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Spacer(flex: 2),
                const CircleAvatar(
                  radius: 36,
                  backgroundImage:
                      AssetImage('assets/images/dr_iris_avatar.png'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Dr Iris',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _displayText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        height: 1.4,
                      ),
                ),
                const Spacer(flex: 3),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
