import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Auto-playing video widget with customizable controls
/// Used for TrueCircle coin animation and other promotional videos
class VideoAutoPlayer extends StatefulWidget {
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
  State<VideoAutoPlayer> createState() => _VideoAutoPlayerState();
}

class _VideoAutoPlayerState extends State<VideoAutoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _controller = VideoPlayerController.asset(widget.videoPath);

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        _controller!.addListener(() {
          if (_controller!.value.position >= _controller!.value.duration) {
            widget.onVideoEnd?.call();
          }
        });

        if (widget.autoPlay) {
          await _controller!.play();
        }

        if (widget.loop) {
          await _controller!.setLooping(true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Video unavailable',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),

          if (widget.showControls)
            Positioned(
              bottom: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_controller!.value.isPlaying) {
                          _controller!.pause();
                        } else {
                          _controller!.play();
                        }
                      });
                    },
                    icon: Icon(
                      _controller!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _controller!.seekTo(Duration.zero);
                    },
                    icon: const Icon(Icons.replay, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
        ],
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
    return VideoAutoPlayer(
      videoPath: 'assets/images/TrueCircle_Coin.mp4',
      width: size,
      height: size,
      autoPlay: true,
      loop: true,
      fit: BoxFit.contain,
    );
  }
}
