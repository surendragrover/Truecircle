import 'package:flutter/material.dart';

/// Auto-playing video widget with customizable controls
/// Used for TrueCircle coin animation and other promotional videos
class VideoAutoPlayer extends StatelessWidget {
  final String videoPath;
  final bool autoPlay;
  final bool loop;
  final bool showControls;
  final BoxFit fit;
  final double? width;
  final double? height;
  final VoidCallback? onVideoEnd;

  const VideoAutoPlayer({
    super.key,
    required this.videoPath,
    this.autoPlay = true,
    this.loop = true,
    this.showControls = false,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.onVideoEnd,
  });

  @override
  Widget build(BuildContext context) {
    // Lightweight placeholder since in-app videos are not required.
    // Encourage using external (YouTube/SMS) links instead.
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [Colors.grey.shade100, Colors.grey.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_off, size: 36, color: Colors.grey.shade500),
            const SizedBox(height: 6),
            Text(
              'Video shown externally',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// TrueCircle Coin Animation Widget
class TrueCircleCoinAnimation extends StatelessWidget {
  final double size;
  final bool showOnError;

  const TrueCircleCoinAnimation({
    super.key,
    this.size = 120,
    this.showOnError = true,
  });

  @override
  Widget build(BuildContext context) {
    // Replace video with a static coin image to reduce app size
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.1),
      child: Image.asset(
        'assets/images/TrueCircle_Coin.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) {
          return Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(size * 0.1),
            ),
            child: Icon(
              Icons.monetization_on,
              size: size * 0.6,
              color: Colors.amber,
            ),
          );
        },
      ),
    );
  }
}
