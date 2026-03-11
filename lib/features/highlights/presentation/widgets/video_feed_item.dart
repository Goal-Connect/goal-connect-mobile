import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../domain/entities/highlight.dart';
import 'video_overlay_content.dart';

class VideoFeedItem extends StatefulWidget {
  final Highlight highlight;
  const VideoFeedItem({super.key, required this.highlight});

  @override
  State<VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<VideoFeedItem>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _rotationController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.highlight.videoUrl))
          ..initialize().then((_) {
            setState(() {
              _isInitialized = true;
              _controller.play();
              _controller.setLooping(true);
            });
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _isInitialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            : Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator()),
              ),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
        ),

        VideoOverlayContent(
          highlight: widget.highlight,
          rotationAnimation: _rotationController,
        ),
      ],
    );
  }
}
