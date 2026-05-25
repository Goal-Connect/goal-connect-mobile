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
import 'report_sheet.dart';
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
            width: 56,
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
                              blurRadius: 14,
                              spreadRadius: 1.5,
                            ),
                          ],
                        ),
                        child: Hero(
                          tag: 'avatar_${highlight.player.id}',
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.black,
                            backgroundImage:
                                NetworkImage(highlight.player.profileImage),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _LikeButton(
                    isLiked: isLiked,
                    likeCount: likeCount,
                    onTap: onLikeTap,
                    formatCount: _formatCount,
                  ),
                  const SizedBox(height: 12),
                  FancyGlassButton(
                    icon: Icons.chat_bubble_rounded,
                    label: _formatCount(commentCount),
                    color: AppColors.primaryGreen,
                    isPulsing: true,
                    onTap: () => _openComments(context, highlight.id),
                  ),
                  const SizedBox(height: 12),
                  HighlightDownloadButton(highlight: highlight),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final isScout = authState is AuthAuthenticated &&
                          authState.user.role.toLowerCase() == 'scout';
                      if (!isScout) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _MoreOptionsButton(
                          highlight: highlight,
                          onBottomSheetOpened: onBottomSheetOpened,
                        ),
                      );
                    },
                  ),
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

/// Sidebar download button. Exposes its [VideoDownloader] dependency so
/// widget tests can inject a fake; production callers omit it and get the
/// real downloader.
@visibleForTesting
class HighlightDownloadButton extends StatefulWidget {
  final Highlight highlight;
  final VideoDownloader? downloader;

  const HighlightDownloadButton({
    super.key,
    required this.highlight,
    this.downloader,
  });

  @override
  State<HighlightDownloadButton> createState() =>
      _HighlightDownloadButtonState();
}

class _HighlightDownloadButtonState extends State<HighlightDownloadButton> {
  late final VideoDownloader _downloader =
      widget.downloader ?? VideoDownloader();
  bool _downloading = false;
  double _progress = 0;

  Future<void> _onTap() async {
    if (_downloading) return;
    final l = AppLocalizations.of(context);
    final videoUrl = widget.highlight.videoUrl;
    if (videoUrl.isEmpty) {
      GlassSnackBar.show(
        context,
        l.downloadUnavailable,
        isError: true,
        accent: AppColors.habeshaRed,
      );
      return;
    }

    setState(() {
      _downloading = true;
      _progress = 0;
    });
    GlassSnackBar.show(
      context,
      l.downloadInProgress,
      accent: AppColors.primaryGreen,
    );

    try {
      await _downloader.downloadToGallery(
        videoUrl,
        album: 'Goal Connect',
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (!mounted) return;
      GlassSnackBar.show(
        context,
        l.downloadSavedToGallery,
        accent: AppColors.primaryGreen,
      );
    } on VideoDownloadException catch (e) {
      if (!mounted) return;
      GlassSnackBar.show(
        context,
        e.message,
        isError: true,
        accent: AppColors.habeshaRed,
      );
    } catch (_) {
      if (!mounted) return;
      GlassSnackBar.show(
        context,
        l.downloadCouldNotDownload,
        isError: true,
        accent: AppColors.habeshaRed,
      );
    } finally {
      if (mounted) {
        setState(() {
          _downloading = false;
          _progress = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FancyGlassButton(
      icon: _downloading
          ? Icons.downloading_rounded
          : Icons.download_rounded,
      label: _downloading ? '${(_progress * 100).round()}%' : '',
      color: Colors.tealAccent,
      onTap: _onTap,
    );
  }
}

class _MoreOptionsButton extends StatelessWidget {
  final Highlight highlight;
  final void Function(Future<void> sheetFuture) onBottomSheetOpened;

  const _MoreOptionsButton({
    required this.highlight,
    required this.onBottomSheetOpened,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FancyGlassButton(
      icon: Icons.more_horiz_rounded,
      label: l.videoOptionsTitle,
      color: Colors.white,
      onTap: () => _openSheet(context),
    );
  }

  void _openSheet(BuildContext context) {
    final future = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        // Reuse the caller's SavedPlayersBloc so the toggle reflects /
        // updates the real saved-players state.
        value: context.read<SavedPlayersBloc>(),
        child: _HighlightActionSheet(highlight: highlight),
      ),
    );
    onBottomSheetOpened(future);
  }
}

/// Bottom sheet that consolidates Download (everyone), Save (scouts), and
/// Report (scouts) into a single more-options menu.
class _HighlightActionSheet extends StatefulWidget {
  final Highlight highlight;

  const _HighlightActionSheet({required this.highlight});

  @override
  State<_HighlightActionSheet> createState() => _HighlightActionSheetState();
}

class _HighlightActionSheetState extends State<_HighlightActionSheet> {
  bool get _isScout {
    final auth = context.read<AuthBloc>().state;
    return auth is AuthAuthenticated &&
        auth.user.role.toLowerCase() == 'scout';
  }

  Future<void> _onReport() async {
    final l = AppLocalizations.of(context);
    final messengerContext = context;
    Navigator.of(context).pop();
    final submitted = await showModalBottomSheet<bool>(
      context: messengerContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportSheet(highlightId: widget.highlight.id),
    );
    if (submitted == true && messengerContext.mounted) {
      GlassSnackBar.show(
        messengerContext,
        l.videoOptionsReportSubmitted,
        accent: AppColors.primaryGreen,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141418),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 6),
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Row(
                children: [
                  const Icon(Icons.more_horiz_rounded,
                      color: Colors.white54, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    l.videoOptionsTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            if (_isScout) ...[
              BlocBuilder<SavedPlayersBloc, SavedPlayersState>(
                builder: (context, state) {
                  final playerId = widget.highlight.player.id;
                  final saved = state.players.any((p) => p.id == playerId);
                  final pending = state.pendingIds.contains(playerId);
                  return _HighlightActionTile(
                    icon: saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: AppColors.primaryGreen,
                    label: l.videoOptionsSave,
                    subtitle: pending
                        ? l.saveActionPending
                        : (saved
                            ? l.saveActionSaved
                            : l.videoOptionsSaveSubtitle),
                    onTap: pending
                        ? null
                        : () {
                            final bloc = context.read<SavedPlayersBloc>();
                            if (saved) {
                              bloc.add(SavedPlayerRemoved(playerId));
                            } else {
                              bloc.add(SavedPlayerAdded(playerId));
                            }
                            Navigator.of(context).pop();
                          },
                  );
                },
              ),
              _HighlightActionTile(
                icon: Icons.flag_outlined,
                color: Colors.redAccent,
                label: l.videoOptionsReport,
                subtitle: l.videoOptionsReportSubtitle,
                onTap: _onReport,
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _HighlightActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  const _HighlightActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: disabled ? 0.06 : 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: disabled ? Colors.white24 : color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: disabled ? Colors.white38 : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
