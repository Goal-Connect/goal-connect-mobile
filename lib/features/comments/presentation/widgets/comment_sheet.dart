import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/comment_bloc.dart';
import '../bloc/comment_event.dart';
import '../bloc/comment_state.dart';
import '../../domain/entities/comment.dart';

class CommentSheet extends StatefulWidget {
  final String highlightId;
  const CommentSheet({super.key, required this.highlightId});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Set<String> _likedCommentIds = {};

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    context.read<CommentBloc>().add(
          AddCommentEvent(
            highlightId: widget.highlightId,
            userId: 'current_user',
            username: 'yafet10',
            profileImage: 'https://ui-avatars.com/api/?name=yafet10&background=00D084&color=000&size=150',
            text: text,
          ),
        );
    _inputController.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF161616),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ─── Handle ───
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ─── Header ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    BlocBuilder<CommentBloc, CommentState>(
                      builder: (context, state) {
                        final count = state is CommentsLoaded
                            ? state.comments.length
                            : state is CommentPosting
                                ? state.currentComments.length
                                : 0;
                        return Text(
                          '$count Comments',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white54, size: 22),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),

              // ─── Comment List ───
              Expanded(
                child: BlocBuilder<CommentBloc, CommentState>(
                  builder: (context, state) {
                    if (state is CommentLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryGreen),
                      );
                    }

                    List<Comment> comments = [];
                    if (state is CommentsLoaded) comments = state.comments;
                    if (state is CommentPosting) {
                      comments = state.currentComments;
                    }

                    if (comments.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded,
                              color: Colors.white24, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'Be the first to comment!',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 14),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount:
                          comments.length + (state is CommentPosting ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (state is CommentPosting &&
                            index == 0 &&
                            state.currentComments.length < comments.length) {
                          return _buildPostingPlaceholder();
                        }
                        final comment = comments[index];
                        return _CommentTile(
                          comment: comment,
                          isLiked: _likedCommentIds.contains(comment.id),
                          onLike: () {
                            setState(() {
                              if (_likedCommentIds.contains(comment.id)) {
                                _likedCommentIds.remove(comment.id);
                              } else {
                                _likedCommentIds.add(comment.id);
                              }
                            });
                          },
                          onDelete: comment.userId == 'current_user'
                              ? () => context
                                  .read<CommentBloc>()
                                  .add(DeleteCommentEvent(comment.id))
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),

              // ─── Input ───
              _buildInput(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostingPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryGreen,
            child: Icon(Icons.person, color: Colors.black, size: 18),
          ),
          const SizedBox(width: 12),
          Container(
            height: 16,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryGreen,
            child: Icon(Icons.person, color: Colors.black, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle:
                    TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _submitComment,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Comment Tile ────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final Comment comment;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback? onDelete;

  const _CommentTile({
    required this.comment,
    required this.isLiked,
    required this.onLike,
    this.onDelete,
  });

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }

  @override
  Widget build(BuildContext context) {
    final likeCount = comment.likes + (isLiked ? 1 : 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryGreen.withOpacity(0.3),
            backgroundImage: comment.profileImage != null
                ? NetworkImage(comment.profileImage!)
                : null,
            child: comment.profileImage == null
                ? const Icon(Icons.person, color: Colors.white, size: 18)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '@${comment.username}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 6),
                if (onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onLike,
            child: Column(
              children: [
                Icon(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isLiked ? Colors.redAccent : Colors.white38,
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  likeCount > 0 ? likeCount.toString() : '',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
