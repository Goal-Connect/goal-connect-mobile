import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const GetConversationsEvent());
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
            _buildHeader(context, theme, isDark),
            _buildSearchBar(context, isDark),
            Expanded(child: _buildBody(context, theme, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).chatListTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                    color: AppColors.primaryGreen,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.grey.withOpacity(0.06),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.04),
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.lightText,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).chatListSearchHint,
            hintStyle: TextStyle(
                color: AppColors.gray.withOpacity(0.6), fontSize: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(Icons.search_rounded,
                  color: AppColors.gray.withOpacity(0.5), size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, bool isDark) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
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
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                      strokeWidth: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).chatListLoading,
                  style: TextStyle(
                    color: AppColors.gray.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is ChatError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.habeshaRed.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wifi_off_rounded,
                      color: AppColors.habeshaRed, size: 32),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context).chatListConnectionIssue,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(state.message,
                    style: TextStyle(
                        color: AppColors.gray.withOpacity(0.7), fontSize: 13)),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => context
                      .read<ChatBloc>()
                      .add(const GetConversationsEvent()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      AppLocalizations.of(context).commonTryAgain,
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
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
                  Icon(Icons.search_off_rounded,
                      size: 48, color: AppColors.gray.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).chatListNoResults,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.lightText,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context).chatListTryDifferentSearch,
                    style: TextStyle(
                        color: AppColors.gray.withOpacity(0.6), fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () async {
              context
                  .read<ChatBloc>()
                      .add(const GetConversationsEvent());
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
              itemCount: conversations.length,
              separatorBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 84),
                child: Divider(
                  height: 1,
                  color: isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.black.withOpacity(0.04),
                ),
              ),
              itemBuilder: (context, index) {
                final conv = conversations[index];
                return ConversationTile(
                  conversation: conv,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            ConversationPage(conversation: conv),
                        transitionsBuilder: (_, animation, __, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          );
                        },
                        transitionDuration:
                            const Duration(milliseconds: 350),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.08),
                  AppColors.primaryGreen.withOpacity(0.02),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withOpacity(0.06),
              ),
              child: Icon(Icons.forum_rounded,
                  size: 36, color: AppColors.primaryGreen.withOpacity(0.5)),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            AppLocalizations.of(context).chatListEmptyTitle,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.lightText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).chatListEmptySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.gray.withOpacity(0.6),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
