import 'package:flutter/material.dart';
import 'dart:math' as math;

class TrueCircleLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isHindi;
  final LogoStyle style;

  const TrueCircleLogo({
    super.key,
    this.size = 100,
    this.showText = true,
    this.isHindi = false,
    this.style = LogoStyle.compass,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case LogoStyle.compass:
        return _buildCompassLogo();
      case LogoStyle.minimal:
        return _buildMinimalLogo();
      case LogoStyle.icon:
        return _buildIconLogo();
      case LogoStyle.text:
        return _buildTextLogo();
    }
  }

  Widget _buildCompassLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo graphic - using actual PNG file
        SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            'assets/images/truecircle_logo.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to programmatic design if image not found
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: size * 0.8,
                    height: size * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: size * 0.1,
                          spreadRadius: size * 0.02,
                        ),
                      ],
                    ),
                  ),

                  // Emotional hearts in compass positions
                  _buildEmotionalHeart(
                    offset: Offset(0, -size * 0.25), // Top
                    color: const Color(0xFF3B82F6), // Blue - Very close
                    emoji: '💙',
                  ),
                  _buildEmotionalHeart(
                    offset: Offset(size * 0.25, 0), // Right
                    color: const Color(0xFFF59E0B), // Orange - Needs attention
                    emoji: '🧡',
                  ),
                  _buildEmotionalHeart(
                    offset: Offset(0, size * 0.25), // Bottom
                    color: const Color(0xFF10B981), // Green - Healthy
                    emoji: '💚',
                  ),
                  _buildEmotionalHeart(
                    offset: Offset(-size * 0.25, 0), // Left
                    color: const Color(0xFFEAB308), // Yellow - Friendly but fading
                    emoji: '💛',
                  ),

                  // Center user point
                  Container(
                    width: size * 0.08,
                    height: size * 0.08,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1E293B),
                      border: Border.all(color: Colors.white, width: size * 0.008),
                    ),
                  ),

                  // Subtle connecting lines
                  _buildConnectionLines(),
                ],
              );
            },
          ),
        ),

        if (showText) ...[
          SizedBox(height: size * 0.1),
          _buildLogoText(),
        ],
      ],
    );
  }

  Widget _buildEmotionalHeart({
    required Offset offset,
    required Color color,
    required String emoji,
  }) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: size * 0.12,
        height: size * 0.12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.3),
          border: Border.all(color: color, width: size * 0.004),
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: size * 0.08),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionLines() {
    return CustomPaint(
      size: Size(size, size),
      painter: ConnectionLinesPainter(size: size),
    );
  }

  Widget _buildMinimalLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // T shape
              Container(
                width: size * 0.6,
                height: size * 0.08,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(size * 0.04),
                ),
              ),
              Container(
                width: size * 0.08,
                height: size * 0.6,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(size * 0.04),
                ),
              ),

              // C shape
              Transform.translate(
                offset: Offset(size * 0.15, size * 0.15),
                child: Container(
                  width: size * 0.3,
                  height: size * 0.3,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFF59E0B),
                      width: size * 0.04,
                    ),
                    borderRadius: BorderRadius.circular(size * 0.15),
                  ),
                  child: ClipPath(
                    clipper: CHalfClipper(),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.1),
          _buildLogoText(),
        ],
      ],
    );
  }

  Widget _buildIconLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF8B5CF6),
            Color(0xFFF59E0B),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Center(
        child: Text(
          isHindi ? 'ट्र' : 'TC',
          style: TextStyle(
            fontSize: size * 0.3,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTextLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isHindi ? 'ट्रू सर्कल' : 'TrueCircle',
          style: TextStyle(
            fontSize: size * 0.2,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
            fontFamily: isHindi ? 'NotoSansDevanagari' : 'Inter',
          ),
        ),
        SizedBox(height: size * 0.05),
        Text(
          isHindi
              ? 'जानिए कौन है आपके दिल के करीब'
              : 'Understand who\'s emotionally close to you',
          style: TextStyle(
            fontSize: size * 0.08,
            color: const Color(0xFF64748B),
            fontFamily: isHindi ? 'NotoSansDevanagari' : 'Inter',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLogoText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isHindi ? 'ट्रू सर्कल' : 'TrueCircle',
          style: TextStyle(
            fontSize: size * 0.12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
            fontFamily: isHindi ? 'NotoSansDevanagari' : 'Inter',
          ),
        ),
        SizedBox(height: size * 0.02),
        Text(
          isHindi
              ? 'जानिए कौन है आपके दिल के करीब'
              : 'Understand who\'s emotionally close to you',
          style: TextStyle(
            fontSize: size * 0.06,
            color: const Color(0xFF64748B),
            fontFamily: isHindi ? 'NotoSansDevanagari' : 'Inter',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class ConnectionLinesPainter extends CustomPainter {
  final double size;

  ConnectionLinesPainter({required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.3)
      ..strokeWidth = size * 0.002
      ..style = PaintingStyle.stroke;

    final center = Offset(size / 2, size / 2);
    final radius = size * 0.25;

    // Draw subtle connecting lines from center to each heart
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) - (math.pi / 2); // Start from top
      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      canvas.drawLine(center, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CHalfClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.7, 0);
    path.arcToPoint(
      Offset(size.width * 0.7, size.height),
      radius: Radius.circular(size.width * 0.35),
      clockwise: false,
    );
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

enum LogoStyle {
  compass, // Main emotional compass logo
  minimal, // Minimal TC design
  icon, // Circular icon for app
  text, // Text-only version
}

// Animated version for splash screens
class AnimatedTrueCircleLogo extends StatefulWidget {
  final double size;
  final bool showText;
  final bool isHindi;

  const AnimatedTrueCircleLogo({
    super.key,
    this.size = 150,
    this.showText = true,
    this.isHindi = false,
  });

  @override
  State<AnimatedTrueCircleLogo> createState() => _AnimatedTrueCircleLogoState();
}

class _AnimatedTrueCircleLogoState extends State<AnimatedTrueCircleLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _scaleController.forward();
    _rotationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _scaleController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: TrueCircleLogo(
              size: widget.size,
              showText: widget.showText,
              isHindi: widget.isHindi,
              style: LogoStyle.compass,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}
