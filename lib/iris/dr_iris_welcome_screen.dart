import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:audioplayers/audioplayers.dart';
import '../emotional_awareness/emotional_awareness_page.dart';
import '../root_shell.dart';
import '../core/video_auto_player.dart';
import 'package:hive/hive.dart';

class DrIrisWelcomeScreen extends StatefulWidget {
  const DrIrisWelcomeScreen({super.key});

  @override
  State<DrIrisWelcomeScreen> createState() => _DrIrisWelcomeScreenState();
}

class _DrIrisWelcomeScreenState extends State<DrIrisWelcomeScreen>
    with TickerProviderStateMixin {
  bool _showButtons = false;
  late AnimationController _animationController;
  late Animation<double> _avatarAnimation;
  late AnimationController _textController;
  late AnimationController _fadeController;
  bool _isPlaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  List<AnimatedText> _animatedTextWidgets = [];
  String _poemContent = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPoemFromAsset();
    _playWelcomeAudio();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _avatarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _textController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animationController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      _textController.forward();
    });

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _showButtons = true;
        });
        _fadeController.forward();
      }
    });
  }

  Future<void> _loadPoemFromAsset() async {
    try {
      _poemContent = await rootBundle.loadString('assets/Dr_Iris.txt');
      final lines = _poemContent
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      _animatedTextWidgets = lines.take(5).map((line) {
        return TyperAnimatedText(
          line.trim(),
          textStyle: const TextStyle(
            fontSize: 18,
            color: Colors.white70,
            fontFamily: 'Nunito',
          ),
          speed: const Duration(milliseconds: 50),
        );
      }).toList();

      if (mounted) setState(() {});
    } catch (e) {
      // Keep default texts if asset loading fails
    }
  }

  Future<void> _playWelcomeAudio() async {
    try {
      await _audioPlayer.play(AssetSource('audio/dr_iris_welcome.mp3'));
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      // Audio not available, continue silently
    }
  }

  void _toggleAudio() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      // Handle audio error
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startEmotionalCheckin() async {
    // Store that user completed Dr. Iris intro
    final box = await Hive.openBox('userPrefs');
    await box.put('completed_iris_intro', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const EmotionalAwarenessPage()),
      );
    }
  }

  void _exploreApp() async {
    // Store that user completed Dr. Iris intro
    final box = await Hive.openBox('userPrefs');
    await box.put('completed_iris_intro', true);

    if (mounted) {
      // Go directly to main app
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A0DAD), // violet
              Color(0xFF1A1A40), // deep indigo-blue
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Dr. Iris Avatar with animation
                AnimatedBuilder(
                  animation: _avatarAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _avatarAnimation.value,
                      child: Opacity(
                        opacity: _avatarAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.asset(
                              'assets/images/dr_iris_avatar.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.psychology_outlined,
                                  size: 60,
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Audio Control Button
                AnimatedBuilder(
                  animation: _avatarAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _avatarAnimation.value,
                      child: FloatingActionButton(
                        onPressed: _toggleAudio,
                        backgroundColor: const Color(0xFFB57EDC),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // TrueCircle Coin Animation Video
                AnimatedBuilder(
                  animation: _avatarAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _avatarAnimation.value * 0.8,
                      child: Opacity(
                        opacity: _avatarAnimation.value,
                        child: const TrueCircleCoinAnimation(size: 100),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Animated Text from the poem (loaded from asset)
                Expanded(
                  child: Center(
                    child: AnimatedTextKit(
                      isRepeatingAnimation: false,
                      animatedTexts: _animatedTextWidgets.isNotEmpty
                          ? _animatedTextWidgets
                          : [
                              // Fallback while poem loads
                              TyperAnimatedText(
                                'Connection verified.',
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white70,
                                  fontFamily: 'Nunito',
                                ),
                                speed: const Duration(milliseconds: 50),
                              ),
                              TyperAnimatedText(
                                'Identity acknowledged.',
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white70,
                                  fontFamily: 'Nunito',
                                ),
                                speed: const Duration(milliseconds: 50),
                              ),
                              TyperAnimatedText(
                                'Calibrating emotional resonance…',
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white70,
                                  fontFamily: 'Nunito',
                                ),
                                speed: const Duration(milliseconds: 50),
                              ),
                            ],
                    ),
                  ),
                ),

                // Action buttons
                if (_showButtons)
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _startEmotionalCheckin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB57EDC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          elevation: 8,
                        ),
                        child: const Text(
                          'Begin with Dr. Iris',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: _exploreApp,
                        child: const Text(
                          'Explore TrueCircle',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
