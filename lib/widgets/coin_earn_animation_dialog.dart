import 'package:flutter/material.dart';
import 'rotating_coin.dart';
import 'sunburst_effect.dart';

/// Reusable coin earn animation dialog.
/// Plays the 4s sequence and calls [onFinished] when complete.
class CoinEarnAnimationDialog extends StatefulWidget {
  final VoidCallback? onFinished;

  const CoinEarnAnimationDialog({super.key, this.onFinished});

  @override
  State<CoinEarnAnimationDialog> createState() =>
      _CoinEarnAnimationDialogState();
}

class _CoinEarnAnimationDialogState extends State<CoinEarnAnimationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;
  late final Animation<double> _rotate;
  late final Animation<double> _opacityBlink;
  bool _showSunburst = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _slide =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0.8, 0.9),
        ).animate(
          CurvedAnimation(
            parent: _c,
            curve: const Interval(0.75, 1.0, curve: Curves.easeInOutCubic),
          ),
        );

    _scale = Tween<double>(begin: 1.2, end: 0.45).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    _rotate = Tween<double>(
      begin: 0,
      end: 2,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.linear));

    _opacityBlink =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(
              begin: 1.0,
              end: 0.35,
            ).chain(CurveTween(curve: Curves.easeOut)),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: 0.35,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeIn)),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _c,
            curve: const Interval(0.25, 0.75, curve: Curves.easeInOut),
          ),
        );

    _c.addListener(() {
      final t = _c.value;
      final shouldShow = t >= 0.25 && t <= 0.75;
      if (shouldShow != _showSunburst) {
        setState(() => _showSunburst = shouldShow);
      }
    });

    _c.forward();
    _c.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        widget.onFinished?.call();
        if (mounted) Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        width: 260,
        height: 180,
        child: Stack(
          children: [
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  '🎉 You earned a coin!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Align(
              alignment: Alignment(0.95, 0.95),
              child: Icon(
                Icons.account_balance_wallet,
                color: Colors.amber,
                size: 28,
              ),
            ),

            if (_showSunburst)
              Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SunburstEffect(
                        size: 140,
                        color: Colors.amber,
                        duration: const Duration(milliseconds: 2000),
                      ),
                      AnimatedBuilder(
                        animation: _c,
                        builder: (context, _) {
                          final opacity = _opacityBlink.value;
                          return Opacity(
                            opacity: opacity,
                            child: const RotatingCoin(
                              size: 72,
                              tint: Colors.amber,
                              glow: true,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

            AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final t = _c.value;
                if (t < 0.72 && !_showSunburst) {
                  return const Align(
                    alignment: Alignment.center,
                    child: RotatingCoin(
                      size: 56,
                      tint: Colors.amber,
                      glow: true,
                    ),
                  );
                }

                return FractionalTranslation(
                  translation: _slide.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: Transform.rotate(
                      angle: _rotate.value * 3.14159,
                      child: const RotatingCoin(
                        size: 56,
                        tint: Colors.amber,
                        glow: true,
                      ),
                    ),
                  ),
                );
              },
            ),
            const Align(
              alignment: Alignment(0, 0.45),
              child: Text(
                'It will be added to your wallet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
