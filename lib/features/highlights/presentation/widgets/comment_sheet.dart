import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _CommentSheetState extends State<CommentSheet> with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Set<String> _likedCommentIds = {};
  late AnimationController _entryController;
  late Animation<double> _entryAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _entryAnim = CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic);
    _entryController.forward();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    context.read<CommentBloc>().add(
          AddCommentEvent(
            highlightId: widget.highlightId,
            userId: 'current_user',
            username: 'yafet10',
            profileImage:
                'https://ui-avatars.com/api/?name=yafet10&background=00D084&color=000&size=150',
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
        return FadeTransition(
          opacity: _entryAnim,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF141418),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                Expanded(child: _buildCommentList(scrollController)),
                _buildInput(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Container(
        height: 4, width: 40,
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
                  ? state.comments.length
                  : state is CommentPosting ? state.currentComments.length : 0;
              return Row(
                children: [
                  const Text('Comments', style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$count', style: const TextStyle(
                      color: AppColors.primaryGreen, fontWeight: FontWeight.w700, fontSize: 12)),
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
                color: Colors.white.withOpacity(0.06), shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentList(ScrollController scrollController) {
    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        if (state is CommentLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
        }
        List<Comment> comments = [];
        if (state is CommentsLoaded) comments = state.comments;
        if (state is CommentPosting) comments = state.currentComments;

        if (comments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04), shape: BoxShape.circle),
                  child: const Icon(Icons.chat_bubble_outline_rounded,
                      color: Colors.white24, size: 40),
                ),
                const SizedBox(height: 16),
                const Text('No comments yet', style: TextStyle(
                  color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('Be the first to share your thoughts!',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13)),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: comments.length + (state is CommentPosting ? 1 : 0),
          itemBuilder: (context, index) {
            if (state is CommentPosting && index == 0 &&
                state.currentComments.length < comments.length) {
              return _buildPostingPlaceholder();
            }
            final comment = comments[index];
            return _CommentTile(
              comment: comment,
              isLiked: _likedCommentIds.contains(comment.id),
              onLike: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _likedCommentIds.contains(comment.id)
                      ? _likedCommentIds.remove(comment.id)
                      : _likedCommentIds.add(comment.id);
                });
              },
              onDelete: comment.userId == 'current_user'
                  ? () => context.read<CommentBloc>().add(DeleteCommentEvent(comment.id))
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildPostingPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const CircleAvatar(radius: 18, backgroundColor: AppColors.primaryGreen,
            child: Icon(Icons.person, color: Colors.black, size: 18)),
          const SizedBox(width: 14),
          Container(height: 14, width: 100, decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(7))),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).viewInsets.bottom + 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A20),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3), width: 2)),
            child: const CircleAvatar(radius: 17, backgroundColor: AppColors.primaryGreen,
              child: Icon(Icons.person, color: Colors.black, size: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _inputController, focusNode: _focusNode,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 1, textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
              decoration: InputDecoration(
                hintText: 'Add a comment...', hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.25), fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none),
                filled: true, fillColor: Colors.white.withOpacity(0.06),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _submitComment,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, Color(0xFF00E5A0)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [BoxShadow(color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback? onDelete;

  const _CommentTile({
    required this.comment, required this.isLiked,
    required this.onLike, this.onDelete,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 18,
            backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
            backgroundImage: comment.profileImage != null
                ? NetworkImage(comment.profileImage!) : null,
            child: comment.profileImage == null
                ? const Icon(Icons.person, color: Colors.white, size: 18) : null),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('@${comment.username}', style: const TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(width: 8),
                  Container(width: 3, height: 3, decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white24)),
                  const SizedBox(width: 8),
                  Text(_timeAgo(comment.createdAt), style: TextStyle(
                    color: Colors.white.withOpacity(0.3), fontSize: 12)),
                ]),
                const SizedBox(height: 6),
                Text(comment.text, style: const TextStyle(
                  color: Colors.white, fontSize: 14, height: 1.45)),
                const SizedBox(height: 8),
                Row(children: [
                  GestureDetector(
                    onTap: onLike,
                    child: Row(children: [
                      Icon(isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isLiked ? Colors.redAccent : Colors.white30, size: 16),
                      if (likeCount > 0) ...[
                        const SizedBox(width: 4),
                        Text('$likeCount', style: TextStyle(
                          color: isLiked ? Colors.redAccent : Colors.white30,
                          fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ]),
                  ),
                  const SizedBox(width: 20),
                  Text('Reply', style: TextStyle(color: Colors.white.withOpacity(0.3),
                    fontSize: 12, fontWeight: FontWeight.w600)),
                  if (onDelete != null) ...[
                    const Spacer(),
                    GestureDetector(onTap: onDelete,
                      child: const Icon(Icons.delete_outline_rounded,
                        color: Colors.white24, size: 16)),
                  ],
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
