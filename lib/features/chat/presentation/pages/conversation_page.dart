import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';
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
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(GetMessagesEvent(widget.conversation.id));
    context
        .read<ChatBloc>()
        .add(MarkConversationReadEvent(widget.conversation.id));
    _inputController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    final text = _inputController.text;
    final show = text.trim().isNotEmpty;
    if (show != _showSendButton) setState(() => _showSendButton = show);
    context.read<ChatBloc>().add(
          TypingNotifiedEvent(
            peerUserId: widget.conversation.id,
            isTyping: show,
          ),
        );
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
            peerThread: widget.conversation,
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

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && context.mounted) {
          context.read<ChatBloc>().add(const LeaveConversationEvent());
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF08080E) : const Color(0xFFF6F7FB),
        body: Column(
          children: [
            _buildAppBar(context, theme, isDark, roleClr),
            Expanded(child: _buildMessageList(context, isDark)),
            _buildInputBar(context, theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, ThemeData theme, bool isDark, Color roleClr) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          8, MediaQuery.of(context).padding.top + 8, 12, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E0E16) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: roleClr.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: roleClr.withOpacity(0.08),
                  backgroundImage:
                      (widget.conversation.participantImage?.isNotEmpty ?? false)
                          ? NetworkImage(
                              widget.conversation.participantImage!)
                          : null,
                  child: (widget.conversation.participantImage?.isNotEmpty ??
                          false)
                      ? null
                      : Icon(Icons.person, color: roleClr, size: 20),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryGreen, Color(0xFF00E896)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF0E0E16)
                          : Colors.white,
                      width: 2,
                    ),
                  ),
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
                    Flexible(
                      child: Text(
                        widget.conversation.participantName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            roleClr.withOpacity(0.15),
                            roleClr.withOpacity(0.05)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        widget.conversation.participantRole.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          color: roleClr,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                BlocBuilder<ChatBloc, ChatState>(
                  buildWhen: (a, b) {
                    final wasTyping =
                        a is MessagesLoaded ? a.peerTyping : false;
                    final isTyping =
                        b is MessagesLoaded ? b.peerTyping : false;
                    return wasTyping != isTyping;
                  },
                  builder: (context, state) {
                    final isTyping =
                        state is MessagesLoaded && state.peerTyping;
                    return Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isTyping
                              ? 'typing…'
                              : AppLocalizations.of(context)
                                  .chatConversationActiveNow,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryGreen.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.videocam_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.more_vert_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, bool isDark) {
    return BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is MessagesLoaded || state is MessageSending) {
              _scrollToBottom();
            }
          },
          builder: (context, state) {
            if (state is ChatLoading) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              );
            }

            if (state is ChatError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.habeshaRed.withOpacity(0.6),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).chatConversationUnableToLoad,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.lightText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: const TextStyle(
                        color: AppColors.gray,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {
                        context.read<ChatBloc>().add(GetMessagesEvent(widget.conversation.id));
                      },
                      child: Text(
                        AppLocalizations.of(context).commonTryAgain,
                        style: const TextStyle(color: AppColors.primaryGreen),
                      ),
                    ),
                  ],
                ),
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
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryGreen.withOpacity(0.1),
                            AppColors.primaryGreen.withOpacity(0.02),
                          ],
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGreen.withOpacity(0.06),
                        ),
                        child: const Text(
                          '\u{1F44B}',
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context).chatConversationStartTitle,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.lightText,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).chatConversationStartSubtitle(widget.conversation.participantName),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.gray.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
              itemCount: messages.length + (isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (isSending && index == messages.length) {
                  return const _SendingIndicator();
                }
                final msg = messages[index];
                final isMine = msg.isMine;
                final showAvatar = !isMine &&
                    (index == 0 ||
                        messages[index - 1].isMine);

                bool showDateHeader = false;
                if (index == 0) {
                  showDateHeader = true;
                } else {
                  final prev = messages[index - 1];
                  showDateHeader =
                      !_isSameDay(prev.createdAt, msg.createdAt);
                }

                return Column(
                  children: [
                    if (showDateHeader)
                      _buildDateHeader(msg.createdAt, isDark),
                    MessageBubble(
                      message: msg,
                      isMine: isMine,
                      showAvatar: showAvatar,
                      avatarUrl: widget.conversation.participantImage,
                    ),
                  ],
                );
              },
            );
          },
        );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDateHeader(DateTime date, bool isDark) {
    final now = DateTime.now();
    final l = AppLocalizations.of(context);
    String label;
    if (_isSameDay(date, now)) {
      label = l.chatDateToday;
    } else if (_isSameDay(
        date, now.subtract(const Duration(days: 1)))) {
      label = l.chatDateYesterday;
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.gray.withOpacity(0.7),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, chatState) {
        return Container(
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0E0E16) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : Colors.black)
                                .withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: AppColors.gray.withOpacity(0.6),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.grey.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.black.withOpacity(0.04),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _inputController,
                                    focusNode: _focusNode,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 14,
                                    ),
                                    maxLines: 4,
                                    minLines: 1,
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => _sendMessage(),
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context).chatConversationInputHint,
                                      hintStyle: TextStyle(
                                        color:
                                            AppColors.gray.withOpacity(0.5),
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                if (!_showSendButton)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 12, bottom: 10),
                                    child: Icon(
                                      Icons.mic_rounded,
                                      color:
                                          AppColors.gray.withOpacity(0.5),
                                      size: 22,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        AnimatedScale(
                          scale: _showSendButton ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryGreen,
                                  Color(0xFF00E896)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen
                                      .withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _sendMessage,
                                customBorder: const CircleBorder(),
                                child: const Center(
                                  child: Icon(Icons.send_rounded,
                                      color: Colors.black, size: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }
}

class _SendingIndicator extends StatelessWidget {
  const _SendingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 56, right: 16, top: 4, bottom: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryGreen.withOpacity(0.2),
                AppColors.primaryGreen.withOpacity(0.1),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(0.5),
              const SizedBox(width: 4),
              _dot(0.35),
              const SizedBox(width: 4),
              _dot(0.2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(double opacity) {
    return SizedBox(
      width: 6,
      height: 6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
