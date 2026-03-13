import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/highlight.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../comments/presentation/bloc/comment_bloc.dart';
import '../../../comments/presentation/bloc/comment_event.dart';
import '../../../comments/presentation/widgets/comment_sheet.dart';
import 'fancy_glass_button.dart';

class VideoOverlayContent extends StatelessWidget {
  final Highlight highlight;
  final Animation<double> rotationAnimation;

  const VideoOverlayContent({
    super.key,
    required this.highlight,
    required this.rotationAnimation,
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
                Row(
                  children: [
                    Text(
                      "@${highlight.player.username.toLowerCase()}",
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
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_rounded,
                      color: AppColors.primaryGreen,
                      size: 18,
                    ),
                  ],
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
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        highlight.player.country,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              RotationTransition(
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
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.black,
                    backgroundImage: NetworkImage(
                      highlight.player.profileImage,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              FancyGlassButton(
                icon: Icons.favorite_rounded,
                label: _formatCount(highlight.likes),
                color: Colors.redAccent,
                onTap: () {},
              ),
              const SizedBox(height: 20),
              FancyGlassButton(
                icon: Icons.chat_bubble_rounded,
                label: "Comments",
                color: AppColors.primaryGreen,
                isPulsing: true,
                onTap: () => _openComments(context, highlight.id),
              ),
              const SizedBox(height: 20),
              FancyGlassButton(
                icon: Icons.share_rounded,
                label: "Share",
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openComments(BuildContext context, String highlightId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) =>
            sl<CommentBloc>()..add(GetCommentsEvent(highlightId)),
        child: CommentSheet(highlightId: highlightId),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
