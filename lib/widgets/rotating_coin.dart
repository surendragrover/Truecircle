import 'package:flutter/material.dart';

class RotatingCoin extends StatefulWidget {
  final double size;
  final Color? tint;
  final Duration duration;
  final bool glow;

  const RotatingCoin({
    super.key,
    this.size = 32,
    this.tint,
    this.duration = const Duration(seconds: 3),
    this.glow = true,
  });

  @override
  State<RotatingCoin> createState() => _RotatingCoinState();
}

class _RotatingCoinState extends State<RotatingCoin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coin = Image.asset(
      'assets/images/TrueCircle_Coin.png',
      width: widget.size,
      height: widget.size,
      color: widget.tint,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.monetization_on,
        size: widget.size,
        color: widget.tint ?? Colors.amber,
      ),
    );

    final child = RotationTransition(turns: _c, child: coin);

    if (!widget.glow) return child;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: (widget.tint ?? Colors.amber).withValues(alpha: 0.5),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
