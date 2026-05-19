import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/highlight.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../bloc/comment_bloc.dart';
import '../bloc/comment_event.dart';
import '../bloc/comment_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../profile/presentation/bloc/saved_players_bloc.dart';
import '../../../profile/presentation/bloc/saved_players_event.dart';
import '../../../profile/presentation/bloc/saved_players_state.dart';
import 'comment_sheet.dart';
import '../../../profile/presentation/pages/player_profile_page.dart';
import 'fancy_glass_button.dart';
import 'glass_snack_bar.dart';
import '../../../../core/services/video_downloader.dart';

class VideoOverlayContent extends StatelessWidget {
  final Highlight highlight;
  final Animation<double> rotationAnimation;
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final VoidCallback onLikeTap;
  final VoidCallback onOptionsTap;
  final ValueChanged<int> onCommentCountChanged;
  final Future<void> Function(Widget page) onNavigateAway;
  final void Function(Future<void> sheetFuture) onBottomSheetOpened;

  const VideoOverlayContent({
    super.key,
    required this.highlight,
    required this.rotationAnimation,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
    required this.onLikeTap,
    required this.onOptionsTap,
    required this.onCommentCountChanged,
    required this.onNavigateAway,
    required this.onBottomSheetOpened,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _openProfile(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          highlight.player.fullName.isNotEmpty
                              ? highlight.player.fullName
                              : highlight.player.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 10,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.primaryGreen,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  highlight.player.position.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primaryGreen.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  highlight.caption,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),

          SizedBox(
            width: 64,
            child: SingleChildScrollView(
              reverse: true,
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _openProfile(context),
                    child: RotationTransition(
                      turns: rotationAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryGreen.withOpacity(0.8),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Hero(
                          tag: 'avatar_${highlight.player.id}',
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.black,
                            backgroundImage: NetworkImage(highlight.player.profileImage),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _LikeButton(
                    isLiked: isLiked,
                    likeCount: likeCount,
                    onTap: onLikeTap,
                    formatCount: _formatCount,
                  ),
                  const SizedBox(height: 14),
                  FancyGlassButton(
                    icon: Icons.chat_bubble_rounded,
                    label: _formatCount(commentCount),
                    color: AppColors.primaryGreen,
                    isPulsing: true,
                    onTap: () => _openComments(context, highlight.id),
                  ),
                  const SizedBox(height: 14),
                  _DownloadButton(videoUrl: highlight.videoUrl),
                  _ScoutSaveButton(playerId: highlight.player.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openProfile(BuildContext context) {
    onNavigateAway(
      PlayerProfilePage(
        playerId: highlight.player.id,
        heroTag: 'avatar_${highlight.player.id}',
      ),
    );
  }

  void _openComments(BuildContext context, String highlightId) {
    final auth = context.read<AuthBloc>().state;

    if (auth is! AuthAuthenticated) {
      onBottomSheetOpened(Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      ));
      return;
    }

    final bloc = sl<CommentBloc>()..add(GetCommentsEvent(highlightId));
    final sub = bloc.stream.listen((state) {
      if (state is CommentsLoaded) {
        onCommentCountChanged(_countComments(state.comments));
      }
    });

    final future = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: CommentSheet(highlightId: highlightId),
      ),
    );
    onBottomSheetOpened(future.then((_) async {
      await sub.cancel();
      await bloc.close();
    }));
  }

  int _countComments(List<Comment> list) {
    var n = 0;
    void walk(Comment c) {
      n += 1;
      for (final r in c.replies) {
        walk(r);
      }
    }

    for (final c in list) {
      walk(c);
    }
    return n;
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _ScoutSaveButton extends StatelessWidget {
  final String playerId;
  const _ScoutSaveButton({required this.playerId});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated ||
        auth.user.role.toLowerCase() != 'scout') {
      return const SizedBox.shrink();
    }

    return BlocBuilder<SavedPlayersBloc, SavedPlayersState>(
      builder: (context, state) {
        final saved = state.players.any((p) => p.id == playerId);
        final pending = state.pendingIds.contains(playerId);
        return Padding(
          padding: const EdgeInsets.only(top: 14),
          child: FancyGlassButton(
            icon: saved
                ? Icons.bookmark_rounded
                : Icons.bookmark_outline_rounded,
            label: pending
                ? AppLocalizations.of(context).saveActionPending
                : (saved
                    ? AppLocalizations.of(context).saveActionSaved
                    : AppLocalizations.of(context).saveActionSave),
            color: AppColors.primaryGreen,
            isActive: saved,
            onTap: pending
                ? () {}
                : () {
                    final bloc = context.read<SavedPlayersBloc>();
                    if (saved) {
                      bloc.add(SavedPlayerRemoved(playerId));
                    } else {
                      bloc.add(SavedPlayerAdded(playerId));
                    }
                  },
          ),
        );
      },
    );
  }
}

class _DownloadButton extends StatefulWidget {
  final String videoUrl;
  const _DownloadButton({required this.videoUrl});

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  final VideoDownloader _downloader = VideoDownloader();
  bool _downloading = false;
  double _progress = 0;

  Future<void> _onTap() async {
    if (_downloading) return;
    final l = AppLocalizations.of(context);
    if (widget.videoUrl.isEmpty) {
      _showMessage(l.downloadUnavailable, isError: true);
      return;
    }

    setState(() {
      _downloading = true;
      _progress = 0;
    });

    try {
      await _downloader.downloadToGallery(
        widget.videoUrl,
        album: 'Goal Connect',
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (mounted) _showMessage(l.downloadSavedToGallery);
    } on VideoDownloadException catch (e) {
      if (mounted) _showMessage(e.message, isError: true);
    } catch (_) {
      if (mounted) {
        _showMessage(l.downloadCouldNotDownload, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloading = false;
          _progress = 0;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    GlassSnackBar.show(
      context,
      message,
      isError: isError,
      accent: isError ? AppColors.habeshaRed : AppColors.primaryGreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = _downloading
        ? '${(_progress * 100).clamp(0, 100).toStringAsFixed(0)}%'
        : AppLocalizations.of(context).downloadLabel;
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: FancyGlassButton(
        icon: _downloading
            ? Icons.downloading_rounded
            : Icons.download_rounded,
        label: label,
        color: Colors.white,
        isPulsing: _downloading,
        onTap: _onTap,
      ),
    );
  }
}

class _LikeButton extends StatefulWidget {
  final bool isLiked;
  final int likeCount;
  final VoidCallback onTap;
  final String Function(int) formatCount;

  const _LikeButton({
    required this.isLiked,
    required this.likeCount,
    required this.onTap,
    required this.formatCount,
  });

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  final GlobalKey _buttonKey = GlobalKey();
  final math.Random _random = math.Random();
  OverlayEntry? _overlayEntry;

  late final AnimationController _popController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          _removeOverlay();
        }
      });
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      lowerBound: 0,
      upperBound: 1,
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant _LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isLiked && widget.isLiked) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _triggerBurst());
    }
  }

  void _triggerBurst() {
    if (!mounted) return;
    _popController
      ..reset()
      ..forward();
    final renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return;
    final origin = renderBox.localToGlobal(
      Offset(renderBox.size.width / 2, renderBox.size.height / 2),
    );
    final particles = _spawnParticles();
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (_) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ParticlePainter(
              progress: _controller.value,
              particles: particles,
              origin: origin,
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
    _controller
      ..reset()
      ..forward();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  List<_Particle> _spawnParticles() {
    return List.generate(18, (_) {
      final angle =
          -math.pi / 2 + (_random.nextDouble() - 0.5) * math.pi * 1.4;
      final distance = 110 + _random.nextDouble() * 110;
      return _Particle(
        angle: angle,
        distance: distance,
        size: 14 + _random.nextDouble() * 14,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
      );
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _popController,
      builder: (context, child) {
        final t = _popController.value;
        final scale = 1 + math.sin(t * math.pi) * 0.35;
        return Transform.scale(scale: scale, child: child);
      },
      child: FancyGlassButton(
        key: _buttonKey,
        icon: widget.isLiked
            ? Icons.favorite_rounded
            : Icons.favorite_border_rounded,
        label: widget.formatCount(widget.likeCount),
        color: widget.isLiked ? Colors.red : Colors.white,
        isActive: widget.isLiked,
        onTap: widget.onTap,
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final double rotationSpeed;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.rotationSpeed,
  });
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;
  final Offset origin;

  _ParticlePainter({
    required this.progress,
    required this.particles,
    required this.origin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOutCubic.transform(progress);
    final opacity = (1 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final dx = origin.dx + math.cos(p.angle) * p.distance * eased;
      final dy = origin.dy +
          math.sin(p.angle) * p.distance * eased +
          (progress * progress) * 30;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(progress * p.rotationSpeed);
      _drawBall(canvas, p.size, opacity);
      canvas.restore();
    }
  }

  void _drawBall(Canvas canvas, double size, double opacity) {
    final radius = size / 2;
    final white = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    final black = Paint()
      ..color = Colors.black.withOpacity(opacity * 0.85)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset.zero, radius, white);
    canvas.drawCircle(Offset.zero, radius, black);

    final pentagon = Path();
    const sides = 5;
    final inner = radius * 0.45;
    for (var i = 0; i < sides; i++) {
      final a = -math.pi / 2 + i * (2 * math.pi / sides);
      final x = math.cos(a) * inner;
      final y = math.sin(a) * inner;
      if (i == 0) {
        pentagon.moveTo(x, y);
      } else {
        pentagon.lineTo(x, y);
      }
    }
    pentagon.close();
    canvas.drawPath(
      pentagon,
      Paint()
        ..color = Colors.black.withOpacity(opacity * 0.85)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress;
}
