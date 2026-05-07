import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/comment.dart';
import '../bloc/comment_bloc.dart';
import '../bloc/comment_event.dart';
import '../bloc/comment_state.dart';

class CommentSheet extends StatefulWidget {
  final String highlightId;
  const CommentSheet({super.key, required this.highlightId});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Comment? _replyingTo;
  late AnimationController _entryController;
  late Animation<double> _entryAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _entryAnim =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic);
    _entryController.forward();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    _entryController.dispose();
    super.dispose();
  }

  int _commentTotal(List<Comment> list) {
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

  void _submitComment() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    context.read<CommentBloc>().add(
          AddCommentEvent(
            highlightId: widget.highlightId,
            text: text,
            parentCommentId: _replyingTo?.id,
          ),
        );
    _inputController.clear();
    _focusNode.unfocus();
    setState(() => _replyingTo = null);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) {
        return FadeTransition(
          opacity: _entryAnim,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF141418),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHandle(),
                _buildHeader(),
                Divider(height: 1, color: Colors.white.withOpacity(0.06)),
                if (_replyingTo != null) _buildReplyBanner(),
                Expanded(child: _buildCommentList(scrollController)),
                _buildInput(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReplyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white.withOpacity(0.04),
      child: Row(
        children: [
          const Icon(Icons.reply_rounded, color: AppColors.primaryGreen, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Replying to @${_replyingTo!.username}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _replyingTo = null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Container(
        height: 4,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
      child: Row(
        children: [
          BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              final count = state is CommentsLoaded
                  ? _commentTotal(state.comments)
                  : 0;
              return Row(
                children: [
                  const Text(
                    'Comments',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white54, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentList(ScrollController scrollController) {
    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        if (state is CommentLoading || state is CommentPosting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }
        if (state is CommentError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(state.message,
                  style: const TextStyle(color: Colors.white54)),
            ),
          );
        }

        List<Comment> comments = [];
        if (state is CommentsLoaded) comments = state.comments;

        if (comments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded,
                      color: Colors.white24, size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No comments yet',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Be the first to share your thoughts!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        final authState = context.watch<AuthBloc>().state;
        final uid =
            authState is AuthAuthenticated ? authState.user.id : null;

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            return _CommentBlock(
              comment: comments[index],
              indent: 0,
              highlightId: widget.highlightId,
              currentUserId: uid,
              onReply: (c) => setState(() {
                _replyingTo = c;
                _focusNode.requestFocus();
              }),
            );
          },
        );
      },
    );
  }

  Widget _buildInput(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final avatarUrl = auth is AuthAuthenticated ? auth.user.profileImage : null;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.of(context).viewInsets.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A20),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.primaryGreen,
              backgroundImage:
                  avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.black, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
              decoration: InputDecoration(
                hintText: _replyingTo != null
                    ? 'Write a reply…'
                    : 'Add a comment…',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _submitComment,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, Color(0xFF00E5A0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentBlock extends StatelessWidget {
  final Comment comment;
  final double indent;
  final String highlightId;
  final String? currentUserId;
  final void Function(Comment) onReply;

  const _CommentBlock({
    required this.comment,
    required this.indent,
    required this.highlightId,
    required this.currentUserId,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: indent),
          child: _CommentTile(
            comment: comment,
            highlightId: highlightId,
            currentUserId: currentUserId,
            onReply: () => onReply(comment),
          ),
        ),
        ...comment.replies.map(
          (r) => _CommentBlock(
            comment: r,
            indent: indent + 36,
            highlightId: highlightId,
            currentUserId: currentUserId,
            onReply: onReply,
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;
  final String highlightId;
  final String? currentUserId;
  final VoidCallback onReply;

  const _CommentTile({
    required this.comment,
    required this.highlightId,
    required this.currentUserId,
    required this.onReply,
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
    final canDelete =
        currentUserId != null && comment.userId == currentUserId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
            backgroundImage: comment.profileImage != null &&
                    comment.profileImage!.isNotEmpty
                ? NetworkImage(comment.profileImage!)
                : null,
            child: comment.profileImage == null || comment.profileImage!.isEmpty
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
                    Flexible(
                      child: Text(
                        '@${comment.username}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (comment.userRole != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          comment.userRole!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.read<CommentBloc>().add(
                              ToggleCommentLikeEvent(
                                highlightId: highlightId,
                                commentId: comment.id,
                              ),
                            );
                      },
                      child: Row(
                        children: [
                          Icon(
                            comment.likedByMe
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: comment.likedByMe
                                ? Colors.redAccent
                                : Colors.white30,
                            size: 16,
                          ),
                          if (comment.likes > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '${comment.likes}',
                              style: TextStyle(
                                color: comment.likedByMe
                                    ? Colors.redAccent
                                    : Colors.white30,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: onReply,
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (canDelete) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          context.read<CommentBloc>().add(
                                DeleteCommentEvent(
                                  highlightId: highlightId,
                                  commentId: comment.id,
                                ),
                              );
                        },
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white24,
                          size: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
