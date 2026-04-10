import 'dart:math' as math;

import 'package:flutter/material.dart';

class CoinRewardCelebration extends StatefulWidget {
  const CoinRewardCelebration({
    super.key,
    required this.message,
    this.coinAssetPath = 'assets/images/TrueCircle_Coin.png',
  });

  final String message;
  final String coinAssetPath;

  static Future<void> show(
    BuildContext context, {
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => CoinRewardCelebration(message: message),
    );
  }

  @override
  State<CoinRewardCelebration> createState() => _CoinRewardCelebrationState();
}

class _CoinRewardCelebrationState extends State<CoinRewardCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  late final Animation<double> _panelOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
  );
  late final Animation<double> _coinTravel = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.1, 0.88, curve: Curves.easeInOutCubic),
  );
  late final Animation<double> _messageOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future<void>.delayed(const Duration(milliseconds: 2350), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox.expand(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Size size = Size(constraints.maxWidth, constraints.maxHeight);
            final Offset start = Offset(size.width * 0.5, size.height * 0.58);
            final Offset wallet = Offset(size.width - 56, 94);

            return Stack(
              children: <Widget>[
                FadeTransition(
                  opacity: _panelOpacity,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.42),
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => CustomPaint(
                    size: size,
                    painter: _BurstAndRaysPainter(
                      progress: _controller.value,
                      launchOrigin: start,
                      walletTarget: wallet,
                    ),
                  ),
                ),
                Positioned(
                  top: 44,
                  right: 20,
                  child: FadeTransition(
                    opacity: _panelOpacity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.account_balance_wallet_rounded, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Wallet',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    final double t = _coinTravel.value;
                    final Offset p = Offset.lerp(start, wallet, t)!;
                    final double arc = math.sin(t * math.pi) * 132;
                    final Offset coinPos = Offset(p.dx, p.dy - arc);
                    final double spin = (1 - t) * 0.25 + t * 1.0;
                    final double coinSize = 128 - (72 * t);
                    return Positioned(
                      left: coinPos.dx - coinSize / 2,
                      top: coinPos.dy - coinSize / 2,
                      child: Transform.rotate(
                        angle: t * math.pi * 6,
                        child: Transform.scale(
                          scale: spin,
                          child: Container(
                            width: coinSize,
                            height: coinSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.62),
                                  blurRadius: 28,
                                  spreadRadius: 6,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                widget.coinAssetPath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 34,
                  child: FadeTransition(
                    opacity: _messageOpacity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BurstAndRaysPainter extends CustomPainter {
  _BurstAndRaysPainter({
    required this.progress,
    required this.launchOrigin,
    required this.walletTarget,
  });

  final double progress;
  final Offset launchOrigin;
  final Offset walletTarget;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint rayPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFFFF8B5), Color(0xFFFFB300)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final Paint sparklePaint = Paint();
    final double launchPhase = Curves.easeOut.transform(
      progress.clamp(0.0, 0.55) / 0.55,
    );
    const int rays = 34;
    for (int i = 0; i < rays; i++) {
      final double angle = (i / rays) * math.pi * 2;
      final double startR = 16 + (launchPhase * 22);
      final double endR = 50 + (launchPhase * 220);
      final Offset p1 = launchOrigin +
          Offset(math.cos(angle) * startR, math.sin(angle) * startR);
      final Offset p2 = launchOrigin +
          Offset(math.cos(angle) * endR, math.sin(angle) * endR);
      canvas.drawLine(p1, p2, rayPaint);
    }
    final double sparkleSpread = Curves.easeOut.transform(progress);
    for (int i = 0; i < 120; i++) {
      final double seed = i / 120;
      final double angle = (seed * math.pi * 6) + (progress * math.pi * 2);
      final double radius = sparkleSpread * (size.shortestSide * (0.45 + (seed * 1.15)));
      final Offset p = launchOrigin +
          Offset(math.cos(angle) * radius, math.sin(angle) * radius * 0.82);
      final double alpha = (1 - (progress * 0.9)).clamp(0.0, 1.0);
      sparklePaint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(p, 1.1 + (seed * 1.5), sparklePaint);
    }
    final double arrivalGlow = Curves.easeOut.transform(
      ((progress - 0.72) / 0.28).clamp(0.0, 1.0),
    );
    if (arrivalGlow > 0) {
      final Paint arrivalPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.62 * (1 - arrivalGlow))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4;
      final double maxR = 16 + (arrivalGlow * 82);
      canvas.drawCircle(walletTarget, maxR, arrivalPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstAndRaysPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.launchOrigin != launchOrigin ||
        oldDelegate.walletTarget != walletTarget;
  }
}
