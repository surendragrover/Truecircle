import 'dart:async';
import 'package:flutter/material.dart';
import './event_bus.dart';

class RewardListener extends StatefulWidget {
  final Widget child;
  const RewardListener({super.key, required this.child});

  @override
  State<RewardListener> createState() => _RewardListenerState();
}

class _RewardListenerState extends State<RewardListener>
    with TickerProviderStateMixin {
  late StreamSubscription<CoinRewardedEvent> _subscription;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _showCoin = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4), // Total animation time
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.elasticOut), // Appear
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn), // Disappear
      ),
    );

    _subscription = EventBus.instance.on<CoinRewardedEvent>().listen((event) {
      _triggerAnimation();
    });
  }

  void _triggerAnimation() {
    if (mounted) {
      setState(() => _showCoin = true);
      _controller.forward(from: 0.0).whenComplete(() {
        if (mounted) {
          setState(() => _showCoin = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showCoin)
          Center(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: _CoinAndRays(),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _CoinAndRays extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Sun rays effect can be implemented here
        // For now, a simple halo effect
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.5),
                blurRadius: 50,
                spreadRadius: 20,
              ),
            ],
          ),
        ),
        Image.asset(
          'assets/images/TrueCircle_Coin.png',
          height: 100,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.monetization_on, size: 100, color: Colors.amber),
        ),
      ],
    );
  }
}
