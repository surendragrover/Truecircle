import 'package:flutter/material.dart';

/// Professional Welcome Header - Ultimate User Experience ✨
/// The welcome experience users have been waiting for years
class WelcomeHeaderWidget extends StatefulWidget {
  const WelcomeHeaderWidget({super.key});

  @override
  State<WelcomeHeaderWidget> createState() => _WelcomeHeaderWidgetState();
}

class _WelcomeHeaderWidgetState extends State<WelcomeHeaderWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Fade Animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Scale Animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Shimmer Animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    _shimmerController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6366F1), // TrueCircle Primary - blue (peace)
                  Color(0xFF14B8A6), // Joyful Teal - teal (hope)
                  Color(0xFF8B5CF6), // Hope Purple - purple (creativity)
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Shimmer Effect
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment(_shimmerAnimation.value - 1, 0),
                            end: Alignment(_shimmerAnimation.value, 0),
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Main Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // TrueCircle Logo - Pure Inner Circle 🌟
                    _buildLogo(),
                    const SizedBox(height: 16),

                    // Welcome Title - स्वागत शीर्षक
                    const Text(
                      'Welcome to TrueCircle',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle - उपशीर्षक
                    Text(
                      'Your emotional wellness companion 🌈',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        shadows: const [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black26,
                          ),
                        ],
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

  Widget _buildLogo() {
    return ClipOval(
      child: Image.asset(
        'assets/images/TrueCircle-Logo.png',
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback circular icon - वैकल्पिक आइकन
          return Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF14B8A6)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              size: 40,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
