import 'package:flutter/material.dart';
import 'dart:math';

/// SunburstEffect - radial rays that expand and fade.
class SunburstEffect extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const SunburstEffect({
    super.key,
    this.size = 120,
    this.color = Colors.amber,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<SunburstEffect> createState() => _SunburstEffectState();
}

class _SunburstEffectState extends State<SunburstEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _scale = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _opacity = Tween<double>(
      begin: 0.9,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeIn));
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: 0.8 + _scale.value * 1.2,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _SunburstPainter(
                color: widget.color,
                progress: _scale.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SunburstPainter extends CustomPainter {
  final Color color;
  final double progress; // 0..1
  _SunburstPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.6 * (0.5 + progress);
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw radial rays
    final rays = 10;
    for (int i = 0; i < rays; i++) {
      final angle = (i / rays) * 2 * pi + progress * 0.5;
      final path = Path();
      final inner = maxRadius * 0.1;
      final outer = maxRadius * (0.6 + 0.6 * progress);
      final a1 = angle - 0.12;
      final a2 = angle + 0.12;
      path.moveTo(
        center.dx + inner * cos(angle),
        center.dy + inner * sin(angle),
      );
      path.lineTo(center.dx + outer * cos(a1), center.dy + outer * sin(a1));
      path.arcToPoint(
        Offset(center.dx + outer * cos(a2), center.dy + outer * sin(a2)),
        radius: Radius.circular(outer),
        clockwise: false,
      );
      path.close();
      paint.color = color.withValues(
        alpha: (0.4 * (1 - progress)).clamp(0.0, 0.6),
      );
      canvas.drawPath(path, paint);
    }

    // Center glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: (0.6 * (1 - progress)).clamp(0.0, 1.0)),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.6));
    canvas.drawCircle(center, maxRadius * 0.5, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter old) =>
      old.progress != progress || old.color != color;
}
