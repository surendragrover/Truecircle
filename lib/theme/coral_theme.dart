import 'package:flutter/material.dart';

/// Centralized coral theme utilities so gradient / buttons stay consistent.
class CoralTheme {
  CoralTheme._();
  // Core palette
  static const Color light = Color(0xFFFFA385);
  static const Color base = Color(0xFFFF7F50);
  static const Color dark = Color(0xFFFF6233);
  // Therapy / warm earth tones (requested)
  static const Color therapyPeach = Color(0xFFD98E73); // Muted Peach top
  static const Color therapyDeep = Color(0xFF3E1E1C); // Deep Brown bottom
  static const Color therapySun = Color(0xFFE5543C); // Sunset accent circle
  static const Color therapyTerra = Color(0xFFA8573C); // Terracotta wave
  static const Color therapyRust = Color(0xFF6E2E1F); // Rust red deeper wave

  /// Vertical background gradient (full depth)
  static const LinearGradient verticalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [light, base, dark],
  );

  /// AppBar overlay gradient (lighter range)
  static const LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [light, base],
  );

  /// Reusable BoxDecoration for screens.
  static const BoxDecoration background =
      BoxDecoration(gradient: verticalGradient);

  /// New therapeutic soft gradient background (peach -> deep brown)
  static const LinearGradient therapyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [therapyPeach, therapyDeep],
  );

  static const BoxDecoration therapyBackground =
      BoxDecoration(gradient: therapyGradient);

  /// Standard elevated coral button style.
  static ButtonStyle primaryButtonStyle({EdgeInsetsGeometry? padding}) =>
      ElevatedButton.styleFrom(
        backgroundColor: dark,
        foregroundColor: Colors.white,
        padding:
            padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 3,
      );

  /// Light translucent card surface over gradient.
  static BoxDecoration translucentCard(
          {double alpha = 0.15, BorderRadius? radius}) =>
      BoxDecoration(
        color: Colors.white.withValues(alpha: alpha),
        borderRadius: radius ?? BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: alpha + 0.1)),
      );

  /// Coral accent shadow.
  static List<BoxShadow> glowShadow([double opacity = 0.30]) => [
        BoxShadow(
          color: dark.withValues(alpha: opacity),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  /// Subtle grain effect using a shader-friendly DecorationImage fallback (procedural noise approximation via opacity dither blocks).
  static Widget buildGrainOverlay({double opacity = 0.06}) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GrainPainter(opacity: opacity),
        size: Size.infinite,
      ),
    );
  }
}

/// Paints subtle monochrome grain (non-random seeded pattern for performance determinism)
class _GrainPainter extends CustomPainter {
  final double opacity;
  _GrainPainter({required this.opacity});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const cell = 8.0; // coarse grid
    int seed = 17;
    for (double y = 0; y < size.height; y += cell) {
      for (double x = 0; x < size.width; x += cell) {
        seed = 0x1fffff & ((seed * 1103515245 + 12345));
        final v = (seed % 100) / 100.0; // 0..1
        if (v < 0.35) continue; // sparse
        final alpha = (opacity * (0.25 + v * 0.75));
        paint.color = Colors.white.withValues(alpha: alpha * 0.5);
        canvas.drawRect(Rect.fromLTWH(x, y, 1.2, 1.2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) => old.opacity != opacity;
}

/// Organic wave painter stack for therapeutic background layers.
class TherapyWaves extends StatelessWidget {
  final double sunDiameter;
  final bool showGrain;
  const TherapyWaves(
      {super.key, this.sunDiameter = 260, this.showGrain = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(decoration: CoralTheme.therapyBackground),
        // Accent sun circle near top center
        Positioned(
          top: 90,
          left: MediaQuery.of(context).size.width / 2 - sunDiameter / 2,
          child: Container(
            width: sunDiameter,
            height: sunDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CoralTheme.therapySun.withValues(alpha: 0.22),
              gradient: RadialGradient(
                colors: [
                  CoralTheme.therapySun.withValues(alpha: 0.55),
                  CoralTheme.therapySun.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
        // Waves
        CustomPaint(size: Size.infinite, painter: _WavePainter(level: 0)),
        CustomPaint(size: Size.infinite, painter: _WavePainter(level: 1)),
        CustomPaint(size: Size.infinite, painter: _WavePainter(level: 2)),
        if (showGrain) CoralTheme.buildGrainOverlay(opacity: 0.07),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  final int
      level; // 0: far (terra), 1: mid (rust with low opacity), 2: near (deep blend)
  _WavePainter({required this.level});
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final paint = Paint()..style = PaintingStyle.fill;
    final h = size.height;
    final w = size.width;
    // Param settings per layer
    late Color color;
    double yStart;
    switch (level) {
      case 0:
        color = CoralTheme.therapyTerra.withValues(alpha: 0.28);
        yStart = h * 0.55;
        break;
      case 1:
        color = CoralTheme.therapyRust.withValues(alpha: 0.24);
        yStart = h * 0.62;
        break;
      default:
        color = CoralTheme.therapyRust.withValues(alpha: 0.38);
        yStart = h * 0.70;
    }
    path.moveTo(0, yStart);
    // Smooth sine-like curves (manual control points)
    path.quadraticBezierTo(w * 0.20, yStart - 40, w * 0.40, yStart - 10);
    path.quadraticBezierTo(w * 0.55, yStart + 30, w * 0.70, yStart - 5);
    path.quadraticBezierTo(w * 0.85, yStart - 35, w, yStart - 10);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    paint.color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.level != level;
}

/// Convenience widget: drop-in full therapy background behind content.
class TherapyBackground extends StatelessWidget {
  final Widget child;
  final bool showGrain;
  const TherapyBackground(
      {super.key, required this.child, this.showGrain = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TherapyWaves(showGrain: showGrain),
        Positioned.fill(
          child: child,
        )
      ],
    );
  }
}
