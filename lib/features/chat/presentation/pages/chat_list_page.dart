import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/conversation_tile.dart';
import 'conversation_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  static const String _currentUserId = 'current_user';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const GetConversationsEvent(_currentUserId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, isDark),
            _buildSearchBar(isDark),
            Expanded(child: _buildBody(theme, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messages',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Scouts & coaches reach out here',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.edit_square, color: AppColors.primaryGreen, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.lightText,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: const TextStyle(color: AppColors.gray, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gray, size: 20),
          filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (state is ChatError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.habeshaRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline_rounded,
                      color: AppColors.habeshaRed, size: 36),
                ),
                const SizedBox(height: 16),
                Text(state.message, style: const TextStyle(color: AppColors.gray)),
              ],
            ),
          );
        }

        if (state is ConversationsLoaded) {
          final conversations = state.conversations.where((c) {
            if (_searchQuery.isEmpty) return true;
            return c.participantName.toLowerCase().contains(_searchQuery) ||
                c.lastMessage.toLowerCase().contains(_searchQuery);
          }).toList();

          if (state.conversations.isEmpty) return const _EmptyState();
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 48, color: AppColors.gray.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  const Text('No matching conversations',
                      style: TextStyle(color: AppColors.gray, fontSize: 14)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () async {
              context.read<ChatBloc>().add(const GetConversationsEvent(_currentUserId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conv = conversations[index];
                return ConversationTile(
                  conversation: conv,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => sl<ChatBloc>(),
                          child: ConversationPage(conversation: conv),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }

        return const _EmptyState();
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded,
                size: 48, color: AppColors.primaryGreen.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No messages yet',
            style: TextStyle(
              color: AppColors.gray,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scouts and coaches will reach out here',
            style: TextStyle(color: AppColors.gray.withOpacity(0.6), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
