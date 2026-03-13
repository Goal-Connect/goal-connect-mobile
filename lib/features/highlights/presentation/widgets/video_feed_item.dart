import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../domain/entities/highlight.dart';
import '../../../../injection_container.dart';
import '../../domain/usecases/toggle_like_highlight_usecase.dart';
import 'video_overlay_content.dart';
import 'video_options_sheet.dart';

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

  late bool _isLiked;
  late int _likeCount;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
    _likeCount = widget.highlight.likes;
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

  void _toggleLike() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    sl<ToggleLikeHighlightUsecase>()(highlightId: widget.highlight.id);
  }

  void _onDoubleTap() {
    if (!_isLiked) {
      _toggleLike();
    }
    setState(() => _showHeart = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  void _openOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VideoOptionsSheet(
        highlightId: widget.highlight.id,
        playerUsername: widget.highlight.player.username,
        videoUrl: widget.highlight.videoUrl,
      ),
    );
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

        GestureDetector(
          onDoubleTap: _onDoubleTap,
          onLongPress: _openOptions,
          behavior: HitTestBehavior.translucent,
          child: const SizedBox.expand(),
        ),

        VideoOverlayContent(
          highlight: widget.highlight,
          rotationAnimation: _rotationController,
          isLiked: _isLiked,
          likeCount: _likeCount,
          onLikeTap: _toggleLike,
          onOptionsTap: _openOptions,
        ),

        if (_showHeart) const _HeartAnimation(),
      ],
    );
  }
}

class _HeartAnimation extends StatefulWidget {
  const _HeartAnimation();

  @override
  State<_HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<_HeartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: const Icon(
            Icons.favorite_rounded,
            color: Colors.redAccent,
            size: 100,
          ),
        ),
      ),
    );
  }
}
