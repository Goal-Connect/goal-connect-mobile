import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/conversation.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'scout':
        return Icons.search_rounded;
      case 'coach':
        return Icons.sports_rounded;
      case 'agent':
        return Icons.handshake_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'scout':
        return AppColors.primaryGreen;
      case 'coach':
        return const Color(0xFF6C63FF);
      case 'agent':
        return AppColors.accentGold;
      default:
        return AppColors.gray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasUnread = conversation.unreadCount > 0;
    final roleClr = _roleColor(conversation.participantRole);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: hasUnread
              ? (isDark
                  ? AppColors.primaryGreen.withOpacity(0.04)
                  : AppColors.primaryGreen.withOpacity(0.03))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: hasUnread
                        ? Border.all(color: AppColors.primaryGreen.withOpacity(0.4), width: 2)
                        : null,
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: roleClr.withOpacity(0.12),
                    backgroundImage: conversation.participantImage != null
                        ? NetworkImage(conversation.participantImage!)
                        : null,
                    child: conversation.participantImage == null
                        ? Icon(Icons.person_rounded, color: roleClr, size: 26)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: roleClr,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkBg : AppColors.lightBg,
                        width: 2,
                      ),
                    ),
                    child: Icon(_roleIcon(conversation.participantRole),
                        size: 9, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.participantName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _timeAgo(conversation.updatedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: hasUnread ? AppColors.primaryGreen : AppColors.gray,
                          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: roleClr.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          conversation.participantRole.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            color: roleClr,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: hasUnread
                                ? theme.colorScheme.onSurface.withOpacity(0.8)
                                : AppColors.gray,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 10),
                        Container(
                          width: 22, height: 22,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${conversation.unreadCount}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
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
      ),
    );
  }
}
