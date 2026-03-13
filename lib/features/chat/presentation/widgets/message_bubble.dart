import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMine;
  final bool showAvatar;
  final String? avatarUrl;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.showAvatar = false,
    this.avatarUrl,
  });

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: isMine ? 56 : 12,
        right: isMine ? 12 : 56,
        top: 3,
        bottom: 3,
      ),
      child: Column(
        crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMine && showAvatar) ...[
                CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.person, size: 14, color: AppColors.primaryGreen)
                      : null,
                ),
                const SizedBox(width: 8),
              ] else if (!isMine) ...[
                const SizedBox(width: 38),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: isMine
                        ? const LinearGradient(
                            colors: [AppColors.primaryGreen, Color(0xFF00C278)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isMine
                        ? null
                        : isDark
                            ? const Color(0xFF222228)
                            : const Color(0xFFF0F0F2),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMine ? 20 : 6),
                      bottomRight: Radius.circular(isMine ? 6 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isMine
                            ? AppColors.primaryGreen.withOpacity(0.12)
                            : Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      color: isMine
                          ? Colors.black
                          : isDark
                              ? Colors.white
                              : AppColors.lightText,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              left: !isMine ? 46 : 0,
              top: 4,
              bottom: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(fontSize: 10, color: AppColors.gray.withOpacity(0.7)),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all_rounded,
                      size: 14, color: AppColors.primaryGreen.withOpacity(0.6)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
