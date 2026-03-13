import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/message_bubble.dart';

class ConversationPage extends StatefulWidget {
  final Conversation conversation;

  const ConversationPage({super.key, required this.conversation});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  static const String _currentUserId = 'current_user';
  static const String _currentUserName = 'yafet10';

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(GetMessagesEvent(widget.conversation.id));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(
          SendMessageEvent(
            conversationId: widget.conversation.id,
            senderId: _currentUserId,
            senderName: _currentUserName,
            text: text,
          ),
        );
    _inputController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
    final roleClr = _roleColor(widget.conversation.participantRole);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leadingWidth: 40,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: roleClr.withOpacity(0.12),
                  backgroundImage: widget.conversation.participantImage != null
                      ? NetworkImage(widget.conversation.participantImage!)
                      : null,
                  child: widget.conversation.participantImage == null
                      ? Icon(Icons.person, color: roleClr, size: 18)
                      : null,
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.participantName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: roleClr.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.conversation.participantRole.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            color: roleClr,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryGreen.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam_rounded, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is MessagesLoaded || state is MessageSending) _scrollToBottom();
              },
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryGreen),
                  );
                }

                List<Message> messages = [];
                bool isSending = false;
                if (state is MessagesLoaded) messages = state.messages;
                if (state is MessageSending) {
                  messages = state.messages;
                  isSending = true;
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.06),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.waving_hand_rounded,
                              size: 36, color: AppColors.primaryGreen.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Say hello to ${widget.conversation.participantName}!',
                          style: TextStyle(color: AppColors.gray, fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  itemCount: messages.length + (isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isSending && index == messages.length) return _SendingIndicator();
                    final msg = messages[index];
                    final isMine = msg.senderId == _currentUserId;
                    final showAvatar = !isMine &&
                        (index == 0 || messages[index - 1].senderId == _currentUserId);
                    return MessageBubble(
                      message: msg,
                      isMine: isMine,
                      showAvatar: showAvatar,
                      avatarUrl: widget.conversation.participantImage,
                    );
                  },
                );
              },
            ),
          ),
          _buildInputBar(context, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 10, 14, MediaQuery.of(context).viewInsets.bottom + 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C0C10) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.add_rounded,
                  color: isDark ? Colors.white38 : Colors.black38, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _focusNode,
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: AppColors.gray, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.08),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, Color(0xFF00C278)],
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
              child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _SendingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 56, right: 12, top: 4, bottom: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.35),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: const SizedBox(
            width: 28, height: 14,
            child: Center(
              child: SizedBox(
                width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black45),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
