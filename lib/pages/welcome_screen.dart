import 'package:flutter/material.dart';
import '../home_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String selectedLanguage = 'English'; // Default to English only

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcome_screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // No overlay needed since you have blue gradient background
          decoration: const BoxDecoration(),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Dr. Iris at Top - Main Content
                  Column(
                    children: [
                      // Dr. Iris Avatar - Top Position
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/avatar.jpg',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to logo if avatar not found
                                return Image.asset(
                                  'logo.png',
                                  width: 100,
                                  height: 100,
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Dr. Iris Name - Bigger and Bold
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          selectedLanguage == 'English' ? 'Dr. Iris' : 'डॉ. आइरिस',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 2),
                                blurRadius: 8,
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                              Shadow(
                                offset: const Offset(0, 4),
                                blurRadius: 16,
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Your Emotional Therapist Tagline
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          selectedLanguage == 'English' 
                            ? 'Your Emotional Therapist'
                            : 'आपका भावनात्मक चिकित्सक',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.95),
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 4,
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Description Box - More prominent
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            selectedLanguage == 'English'
                              ? 'Bringing clarity, emotional insight, and a bridge to meaningful relationships. Start your journey to mental wellness with AI-powered guidance.'
                              : 'स्पष्टता, भावनात्मक अंतर्दृष्टि, और सार्थक रिश्तों के लिए एक सेतु। एआई-संचालित मार्गदर्शन के साथ मानसिक कल्याण की अपनी यात्रा शुरू करें।',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[800],
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Language Selector moved down
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.language, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: DropdownButton<String>(
                              value: selectedLanguage,
                              underline: const SizedBox(),
                              items: ['English', 'हिंदी'].map((String language) {
                                return DropdownMenuItem<String>(
                                  value: language,
                                  child: Text(language, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                );
                              }).toList(),
                              onChanged: (String? newLanguage) {
                                setState(() {
                                  selectedLanguage = newLanguage ?? 'English';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Bottom section with button and privacy note
                  Column(
                    children: [
                      // Start Journey Button - English only, proper sizing
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: Colors.blue.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.psychology, size: 22),
                                const SizedBox(width: 12),
                                Text(
                                  selectedLanguage == 'English' ? 'Begin Your Journey' : 'अपनी यात्रा शुरू करें',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                        // Privacy Note with better visibility on blue gradient
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              selectedLanguage == 'English'
                                ? '🔒 100% Private • All data stays on your device'
                                : '🔒 १००% निजी • सभी डेटा आपके डिवाइस पर रहता है',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
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
      ),
    );
  }
}
