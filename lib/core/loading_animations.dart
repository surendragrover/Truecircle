import 'package:flutter/material.dart';

/// Professional Loading Animations - Ultimate User Experience
/// Loading states that feel premium and engaging
class TrueCircleLoadings {
  /// Emotional Wellness Loading - Breathing Animation
  static Widget breathingLoader({Color? color, double size = 40}) {
    return _BreathingLoader(
      color: color ?? const Color(0xFF6366F1),
      size: size,
    );
  }

  /// Heart Beat Loading - For Emotional Features
  static Widget heartBeatLoader({Color? color, double size = 40}) {
    return _HeartBeatLoader(
      color: color ?? const Color(0xFFEC407A),
      size: size,
    );
  }

  /// Gradient Circle Loading - Premium Feel
  static Widget gradientCircleLoader({List<Color>? colors, double size = 40}) {
    return _GradientCircleLoader(
      colors:
          colors ??
          [
            const Color(0xFF6366F1),
            const Color(0xFF14B8A6),
            const Color(0xFF8B5CF6),
          ],
      size: size,
    );
  }

  /// Floating Dots - Meditation Style
  static Widget floatingDotsLoader({Color? color, double size = 40}) {
    return _FloatingDotsLoader(
      color: color ?? const Color(0xFF66BB6A),
      size: size,
    );
  }
}

/// Breathing Animation - Calming and therapeutic
class _BreathingLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _BreathingLoader({required this.color, required this.size});

  @override
  State<_BreathingLoader> createState() => _BreathingLoaderState();
}

class _BreathingLoaderState extends State<_BreathingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.3),
              border: Border.all(color: widget.color, width: 2),
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: widget.color,
              size: widget.size * 0.5,
            ),
          ),
        );
      },
    );
  }
}

/// Heart Beat Animation - For emotional wellness
class _HeartBeatLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _HeartBeatLoader({required this.color, required this.size});

  @override
  State<_HeartBeatLoader> createState() => _HeartBeatLoaderState();
}

class _HeartBeatLoaderState extends State<_HeartBeatLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Icon(
            Icons.favorite_rounded,
            color: widget.color,
            size: widget.size,
          ),
        );
      },
    );
  }
}

/// Gradient Circle Loading - Premium feel
class _GradientCircleLoader extends StatefulWidget {
  final List<Color> colors;
  final double size;

  const _GradientCircleLoader({required this.colors, required this.size});

  @override
  State<_GradientCircleLoader> createState() => _GradientCircleLoaderState();
}

class _GradientCircleLoaderState extends State<_GradientCircleLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: widget.colors,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Floating Dots - Meditation style
class _FloatingDotsLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _FloatingDotsLoader({required this.color, required this.size});

  @override
  State<_FloatingDotsLoader> createState() => _FloatingDotsLoaderState();
}

class _FloatingDotsLoaderState extends State<_FloatingDotsLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    // Stagger the animations
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.translate(
                offset: Offset(0, -10 * _animations[index].value),
                child: Container(
                  width: widget.size * 0.3,
                  height: widget.size * 0.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(
                      alpha: 0.3 + (0.7 * _animations[index].value),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
