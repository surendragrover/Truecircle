import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Professional Micro-interactions - Ultimate User Experience
/// The delightful interactions users have been waiting for years
class TrueCircleMicroInteractions {
  /// Haptic Feedback - Professional feel
  static void lightFeedback() {
    HapticFeedback.lightImpact();
  }

  static void mediumFeedback() {
    HapticFeedback.mediumImpact();
  }

  static void heavyFeedback() {
    HapticFeedback.heavyImpact();
  }

  static void selectionFeedback() {
    HapticFeedback.selectionClick();
  }

  /// Animated Button with Professional Interactions
  static Widget animatedButton({
    required String text,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    double? width,
    bool isLoading = false,
  }) {
    return _AnimatedButton(
      text: text,
      onTap: onTap,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
      width: width,
      isLoading: isLoading,
    );
  }

  /// Floating Action Button with Micro-interactions
  static Widget floatingActionButton({
    required VoidCallback onTap,
    required IconData icon,
    Color? backgroundColor,
    String? tooltip,
  }) {
    return _FloatingActionButton(
      onTap: onTap,
      icon: icon,
      backgroundColor: backgroundColor,
      tooltip: tooltip,
    );
  }

  /// Interactive Card with Hover and Tap effects
  static Widget interactiveCard({
    required Widget child,
    required VoidCallback onTap,
    Color? backgroundColor,
    double elevation = 2,
  }) {
    return _InteractiveCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      elevation: elevation,
      child: child,
    );
  }
}

/// Animated Button with Professional Micro-interactions
class _AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final bool isLoading;

  const _AnimatedButton({
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.isLoading = false,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
    TrueCircleMicroInteractions.lightFeedback();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.primaryColor;
    final txtColor = widget.textColor ?? Colors.white;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.isLoading ? null : widget.onTap,
            child: Container(
              width: widget.width,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: bgColor.withValues(alpha: 0.3),
                    blurRadius: 8 + (4 * _glowAnimation.value),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading) ...[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: txtColor,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ] else if (widget.icon != null) ...[
                    Icon(widget.icon, color: txtColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: txtColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Floating Action Button with Professional Micro-interactions
class _FloatingActionButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color? backgroundColor;
  final String? tooltip;

  const _FloatingActionButton({
    required this.onTap,
    required this.icon,
    this.backgroundColor,
    this.tooltip,
  });

  @override
  State<_FloatingActionButton> createState() => _FloatingActionButtonState();
}

class _FloatingActionButtonState extends State<_FloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    TrueCircleMicroInteractions.mediumFeedback();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.primaryColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: FloatingActionButton(
              onPressed: _handleTap,
              backgroundColor: bgColor,
              tooltip: widget.tooltip,
              child: Icon(widget.icon, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

/// Interactive Card with Professional Micro-interactions
class _InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final double elevation;

  const _InteractiveCard({
    required this.child,
    required this.onTap,
    this.backgroundColor,
    this.elevation = 2,
  });

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation + 4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    TrueCircleMicroInteractions.lightFeedback();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) {
              _controller.forward();
            },
            onExit: (_) {
              _controller.reverse();
            },
            child: GestureDetector(
              onTap: _handleTap,
              child: Card(
                color: widget.backgroundColor,
                elevation: _elevationAnimation.value,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
