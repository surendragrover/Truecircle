import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../services/model_setup_service.dart';
import '../../theme/truecircle_theme.dart';
import '../app/app_shell.dart';
import '../content/json_content_screen.dart';

class DrIrisIntroScreen extends StatefulWidget {
  const DrIrisIntroScreen({super.key});

  @override
  State<DrIrisIntroScreen> createState() => _DrIrisIntroScreenState();
}

class _DrIrisIntroScreenState extends State<DrIrisIntroScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxPrepareAttempts = 2;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();
  final ModelSetupService _modelSetupService = ModelSetupService();

  String _fullText = '';
  String _visibleText = '';
  int _textIndex = 0;
  Timer? _typewriterTimer;
  Timer? _slowTimer;
  bool _showLongWaitMessage = false;

  bool _isPreparing = true;
  bool _isFadingOut = false;
  double _progress = 0.0;
  String _status =
      'I am preparing your personal intelligence. Please stay with me for a few moments.';
  String? _errorMessage;
  int _prepareAttempts = 0;

  @override
  void initState() {
    super.initState();
    _startIntroFlow();
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _slowTimer?.cancel();
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startIntroFlow() async {
    await _loadIntroText();
    await _startAudio();
    _startTypewriter();
    _startLongWaitTimer();
    unawaited(_prepareModels());
  }

  Future<void> _loadIntroText() async {
    String text;
    try {
      text =
          (await rootBundle.loadString('assets/audio/Dr_Iris_transcript.txt'))
              .trim();
    } catch (_) {
      try {
        text = (await rootBundle
                .loadString('assets/data/Welcome to TrueCircle.txt'))
            .trim();
      } catch (_) {
        text =
            'Hello, I am Dr Iris. I am here with you. Share what you are feeling, I will listen softly.';
      }
    }
    if (!mounted) return;
    setState(() {
      _fullText = text;
      _visibleText = '';
      _textIndex = 0;
    });
  }

  Future<void> _startAudio() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(0.22);
    await _audioPlayer.play(AssetSource('audio/Dr_Iris.mp3'));
  }

  void _startTypewriter() {
    if (_fullText.isEmpty) return;
    _typewriterTimer?.cancel();
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 36), (_) {
      if (!mounted || _textIndex >= _fullText.length) {
        _typewriterTimer?.cancel();
        return;
      }

      setState(() {
        _textIndex += 1;
        _visibleText = _fullText.substring(0, _textIndex);
      });
      _scrollToBottomSmoothly();
    });
  }

  void _startLongWaitTimer() {
    _slowTimer = Timer(const Duration(seconds: 12), () {
      if (!mounted || !_isPreparing) return;
      setState(() {
        _showLongWaitMessage = true;
      });
    });
  }

  Future<void> _prepareModels() async {
    _prepareAttempts += 1;
    try {
      await _modelSetupService.prepareModels(
        onProgress: (double progress) {
          if (!mounted) return;
          setState(() {
            _progress = progress;
          });
        },
        onStatus: (String status) {
          if (!mounted) return;
          setState(() {
            _status = status;
          });
        },
      );

      if (!mounted) return;
      if (Hive.isBoxOpen('appBox')) {
        await Hive.box('appBox').put('dr_iris_intro_complete', true);
      }

      setState(() {
        _isPreparing = false;
        _progress = 1.0;
      });
      await _finishAndNavigate();
    } catch (_) {
      if (!mounted) return;
      final bool canRetry = _prepareAttempts < _maxPrepareAttempts;
      setState(() {
        _isPreparing = false;
        _errorMessage = canRetry
            ? 'Setup failed due to unstable connection. Tap "Try Again" to continue.'
            : 'Setup could not complete right now. You can continue and finish setup later.';
      });
    }
  }

  Future<void> _retryPrepare() async {
    if (!mounted) return;
    setState(() {
      _isPreparing = true;
      _errorMessage = null;
      _status = 'Retrying setup...';
      _progress = 0.0;
    });
    await _prepareModels();
  }

  Future<void> _skipForNow() async {
    await _audioPlayer.setVolume(0.0);
    await _audioPlayer.stop();
    if (!mounted) return;

    if (Hive.isBoxOpen('appBox')) {
      await Hive.box('appBox').put('dr_iris_intro_complete', true);
    }

    await _goNextAfterIntro();
  }

  Future<void> _finishAndNavigate() async {
    await _audioPlayer.setVolume(0.0);
    await _audioPlayer.stop();
    if (!mounted) return;

    setState(() {
      _isFadingOut = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    await _goNextAfterIntro(withFade: true);
  }

  Future<void> _goNextAfterIntro({bool withFade = false}) async {
    if (!mounted) return;
    final bool firstDone = Hive.isBoxOpen('appBox')
        ? (Hive.box('appBox').get('first_checkin_done', defaultValue: false)
                as bool? ??
            false)
        : false;

    final Widget next = firstDone
        ? const AppShell()
        : const JsonContentScreen(
            title: 'Emotional Check-In: Emotion Snapshot',
            assetPath: 'assets/data/Feeling_Identification.JSON',
            markFirstCheckInDoneOnSubmit: true,
            navigateToDashboardOnSubmit: true,
          );

    if (!withFade) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => next),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _scrollToBottomSmoothly() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildTypewriterContent() {
    if (_visibleText.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<String> parts = _visibleText.split('Dr Iris');
    if (parts.length == 1) {
      return Text(
        _visibleText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
          fontFamily: 'Lato',
        ),
      );
    }

    final List<InlineSpan> spans = <InlineSpan>[];
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(
          TextSpan(
            text: parts[i],
          ),
        );
      }
      if (i < parts.length - 1) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const CircleAvatar(
                  radius: 8,
                  backgroundImage:
                      AssetImage('assets/images/dr_iris_avatar.png'),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Dr Iris',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Lato',
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
          fontFamily: 'Lato',
        ),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: TrueCircleTheme.appBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 252,
                  height: 252,
                  child: Center(
                    child: ClipOval(
                      child: SizedBox(
                        width: 188,
                        height: 188,
                        child: Image.asset(
                          'assets/images/dr_iris_avatar.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: AnimatedOpacity(
                    opacity: _isFadingOut ? 0 : 1,
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.11),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: _buildTypewriterContent(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_showLongWaitMessage) ...<Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 11,
                        backgroundImage: const AssetImage(
                            'assets/images/dr_iris_avatar.png'),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'I am preparing your personal intelligence. Please stay with me for a few moments.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Lato',
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(999),
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.3,
                    fontFamily: 'Lato',
                  ),
                ),
                if (_isPreparing) const SizedBox(height: 6),
                if (_isPreparing)
                  const Text(
                    'Please keep this app open while I set everything up.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontFamily: 'Lato',
                    ),
                  ),
                if (!_isPreparing && _errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _prepareAttempts < _maxPrepareAttempts
                                ? _retryPrepare
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white70),
                            ),
                            child: const Text('Try Again'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: _skipForNow,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2A1636),
                            ),
                            child: const Text('Skip for now'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
