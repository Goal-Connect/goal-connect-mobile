import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../domain/entities/highlight.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import '../../domain/usecases/toggle_like_highlight_usecase.dart';
import 'glass_snack_bar.dart';
import 'video_overlay_content.dart';

class VideoFeedItem extends StatefulWidget {
  final Highlight highlight;
  final VoidCallback? onVideoChanged;

  const VideoFeedItem({
    super.key,
    required this.highlight,
    this.onVideoChanged,
  });

  @override
  State<VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<VideoFeedItem>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late VideoPlayerController _controller;
  late AnimationController _rotationController;
  bool _isInitialized = false;
  bool _isPaused = false;
  bool _showPauseIcon = false;

  late bool _isLiked;
  late int _likeCount;
  late int _commentCount;
  bool _showHeart = false;
  bool _seededLike = false;

  /// Per-session cache of the last fetched comment count, keyed by video id.
  /// Avoids re-hitting `GET /videos/{id}/comments` every time the same item
  /// is rebuilt while scrolling the feed.
  static final Map<String, int> _countCache = <String, int>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_seededLike) {
      final auth = context.read<AuthBloc>().state;
      if (auth is AuthAuthenticated) {
        _isLiked = widget.highlight.likedUserIds.contains(auth.user.id);
      }
      _seededLike = true;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isLiked = false;
    _likeCount = widget.highlight.likes;
    // Prefer the cached count from a prior fetch in this session, then the
    // value the feed payload supplied. If both are zero we'll lazy-fetch
    // below — the feed endpoint currently omits the count.
    final cached = _countCache[widget.highlight.id];
    _commentCount = cached ?? widget.highlight.commentCount;
    if (_commentCount == 0) {
      _maybeFetchCommentCount();
    }
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.highlight.videoUrl))
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _isInitialized = true;
                _controller.play();
                _controller.setLooping(true);
              });
            }
          });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  /// Lazily fetch the comment count from `GET /videos/{id}/comments` because
  /// the videos list endpoint currently doesn't include it. Cached per id so
  /// scrolling back doesn't re-fetch.
  Future<void> _maybeFetchCommentCount() async {
    final id = widget.highlight.id;
    if (id.isEmpty || id == 'unknown') return;
    final result = await sl<GetCommentsUsecase>()(id);
    if (!mounted) return;
    result.fold(
      (_) {/* network/auth error — leave at 0, comments sheet will retry */},
      (comments) {
        // Sum top-level + replies so the badge matches what the user sees.
        var total = comments.length;
        for (final c in comments) {
          total += c.replies.length;
        }
        _countCache[id] = total;
        if (total != _commentCount) {
          setState(() => _commentCount = total);
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Only auto-resume if the user hadn't manually paused.
      if (!_isPaused) _resumeVideo();
    } else {
      // paused / inactive / hidden / detached — stop audio in the background.
      if (_isInitialized && _controller.value.isPlaying) {
        _controller.pause();
        _rotationController.stop();
      }
    }
  }

  void _pauseVideo() {
    if (_isInitialized && _controller.value.isPlaying) {
      _controller.pause();
      _rotationController.stop();
      setState(() => _isPaused = true);
    }
  }

  void _resumeVideo() {
    if (_isInitialized && !_controller.value.isPlaying) {
      _controller.play();
      _rotationController.repeat();
      setState(() => _isPaused = false);
    }
  }

  void _togglePlayPause() {
    HapticFeedback.lightImpact();
    if (_controller.value.isPlaying) {
      _pauseVideo();
    } else {
      _resumeVideo();
    }
    setState(() => _showPauseIcon = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showPauseIcon = false);
    });
  }

  Future<void> _toggleLike() async {
    HapticFeedback.mediumImpact();
    final auth = context.read<AuthBloc>().state;

    if (auth is! AuthAuthenticated) {
      _pauseVideo();
      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      );
      _resumeVideo();
      return;
    }

    final uid = auth.user.id;
    final previousLiked = _isLiked;
    final previousCount = _likeCount;
    setState(() {
      _isLiked = !previousLiked;
      _likeCount = previousCount + (_isLiked ? 1 : -1);
    });

    final result =
        await sl<ToggleLikeHighlightUsecase>()(highlightId: widget.highlight.id);

    if (!mounted) return;
    result.fold(
      (_) {
        setState(() {
          _isLiked = previousLiked;
          _likeCount = previousCount;
        });
        GlassSnackBar.show(
          context,
          AppLocalizations.of(context).highlightsCouldNotLike,
          isError: true,
        );
      },
      (r) {
        setState(() {
          _likeCount = r.likesCount;
          _isLiked = r.likedUserIds.contains(uid);
        });
      },
    );
  }

  Future<void> _onDoubleTap() async {
    if (!_isLiked) {
      await _toggleLike();
    }
    setState(() => _showHeart = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  Future<void> _navigateAway(Widget page) async {
    _pauseVideo();
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    _resumeVideo();
  }

  void _onBottomSheetOpened(Future<void> sheetFuture) {
    _pauseVideo();
    sheetFuture.then((_) => _resumeVideo());
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

        GestureDetector(
          onTap: _togglePlayPause,
          onDoubleTap: _onDoubleTap,
          behavior: HitTestBehavior.translucent,
          child: const SizedBox.expand(),
        ),

        VideoOverlayContent(
          highlight: widget.highlight,
          rotationAnimation: _rotationController,
          isLiked: _isLiked,
          likeCount: _likeCount,
          commentCount: _commentCount,
          onLikeTap: _toggleLike,
          onOptionsTap: () {},
          onCommentCountChanged: (n) {
            _countCache[widget.highlight.id] = n;
            if (!mounted || n == _commentCount) return;
            setState(() => _commentCount = n);
          },
          onNavigateAway: _navigateAway,
          onBottomSheetOpened: _onBottomSheetOpened,
        ),

        if (_showHeart) const _HeartAnimation(),

        if (_showPauseIcon) _buildPauseOverlay(),
      ],
    );
  }

  Widget _buildPauseOverlay() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (_, value, child) => Opacity(
          opacity: value > 0.5 ? (2.0 - value * 2).clamp(0.0, 1.0) : value * 2,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isPaused ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 50,
          ),
        ),
      ),
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
