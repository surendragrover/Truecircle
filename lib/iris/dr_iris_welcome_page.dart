import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';

class DrIrisWelcomePage extends StatefulWidget {
  final bool isFirstTime;
  const DrIrisWelcomePage({super.key, this.isFirstTime = false});

  @override
  State<DrIrisWelcomePage> createState() => _DrIrisWelcomePageState();
}

class _DrIrisWelcomePageState extends State<DrIrisWelcomePage>
    with TickerProviderStateMixin {
  bool _showButtons = false;
  final _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playAudio();
    Future.delayed(const Duration(seconds: 13), () {
      if (mounted) {
        setState(() {
          _showButtons = true;
        });
      }
    });
  }

  Future<void> _playAudio() async {
    await _audioPlayer.play(AssetSource('audio/audiobook.mp3'));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Image.asset(
                  'assets/images/dr_iris_avatar.png',
                  height: 180,
                ),
                const SizedBox(height: 32),
                AnimatedTextKit(
                  isRepeatingAnimation: false,
                  animatedTexts: [
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
                    TyperAnimatedText(
                      '\nWelcome to TrueCircle.',
                      textStyle: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Merriweather',
                      ),
                      speed: const Duration(milliseconds: 40),
                    ),
                    TyperAnimatedText(
                      'I’m Dr. Iris — not a voice to command, but a presence to share silence with.',
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                        fontFamily: 'Nunito',
                      ),
                      speed: const Duration(milliseconds: 40),
                    ),
                    TyperAnimatedText(
                      'I don’t keep your words. I hold your meaning.',
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                        fontFamily: 'Nunito',
                      ),
                      speed: const Duration(milliseconds: 40),
                    ),
                    TyperAnimatedText(
                      'Every thought you share will stay in your world — private, sacred, yours alone.',
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                        fontFamily: 'Nunito',
                      ),
                      speed: const Duration(milliseconds: 40),
                    ),
                    TyperAnimatedText(
                      '\nTogether, we’ll learn not just how to think… but how to feel — safely, freely, and fully.',
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      ),
                      speed: const Duration(milliseconds: 40),
                    ),
                  ],
                ),
                const Spacer(flex: 3),
                if (_showButtons)
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/iris/chat');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB57EDC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                        child: const Text(
                          'Begin with Dr. Iris',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          // TODO: Create and navigate to a charter page
                          // For now, just navigate to the chat
                          Navigator.pushReplacementNamed(context, '/iris/chat');
                        },
                        child: const Text(
                          'Learn how she listens',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            decoration: TextDecoration.underline,
                          ),
                        ),
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
}
