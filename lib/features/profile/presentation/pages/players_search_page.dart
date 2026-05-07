import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_profile.dart';
import '../bloc/player_search_bloc.dart';
import '../bloc/player_search_event.dart';
import '../bloc/player_search_state.dart';
import 'player_profile_page.dart';

/// Discover tab: horizontal player strip + search via `GET /api/players`.
class PlayersSearchPage extends StatefulWidget {
  const PlayersSearchPage({super.key});

  @override
  State<PlayersSearchPage> createState() => _PlayersSearchPageState();
}

class _PlayersSearchPageState extends State<PlayersSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final off = _scrollController.offset;
    if (max > 0 && off > max - 280) {
      context.read<PlayerSearchBloc>().add(const PlayerSearchLoadMore());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<PlayerSearchBloc>().add(PlayerSearchQuerySubmitted(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A12) : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: BlocConsumer<PlayerSearchBloc, PlayerSearchState>(
          listenWhen: (p, c) =>
              c.errorMessage != null && c.errorMessage != p.errorMessage,
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'Search',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.lightText,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildSearchField(context, isDark)),
                SliverToBoxAdapter(
                  child: _buildFeaturedSection(context, state, isDark),
                ),
                if (state.loadingFeatured && state.featuredPlayers.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primaryGreen),
                    ),
                  )
                else if (state.featuredPlayers.isEmpty && !state.loadingFeatured)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No players to show yet.',
                        style:
                            TextStyle(color: AppColors.gray.withOpacity(0.8)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (state.query.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            'Results',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.lightText,
                            ),
                          ),
                          if (state.loadingSearch) ...[
                            const SizedBox(width: 12),
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (state.loadingSearch && state.searchResults.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryGreen),
                      ),
                    )
                  else if (!state.loadingSearch && state.searchResults.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No players match "${state.query}".',
                          style: TextStyle(
                              color: AppColors.gray.withOpacity(0.85)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.searchResults.length) {
                            if (state.loadingMore) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryGreen,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox(height: 24);
                          }
                          final p = state.searchResults[index];
                          return _PlayerResultTile(
                            profile: p,
                            onTap: () => _openProfile(context, p.id),
                          );
                        },
                        childCount: state.searchResults.length +
                            (state.hasMoreSearch || state.loadingMore ? 1 : 0),
                      ),
                    ),
                ] else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Text(
                        'Search by name or keyword to find players.',
                        style: TextStyle(
                          color: AppColors.gray.withOpacity(0.75),
                          fontSize: 14,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, value, _) {
          return TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: TextStyle(color: isDark ? Colors.white : AppColors.lightText),
            decoration: InputDecoration(
              hintText: 'Search players…',
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.primaryGreen),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSection(
    BuildContext context,
    PlayerSearchState state,
    bool isDark,
  ) {
    if (state.featuredPlayers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(
            'Players',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isDark ? Colors.white : AppColors.lightText,
            ),
          ),
        ),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.featuredPlayers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final p = state.featuredPlayers[index];
              return _FeaturedAvatar(
                profile: p,
                onTap: () => _openProfile(context, p.id),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openProfile(BuildContext context, String playerId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlayerProfilePage(playerId: playerId),
      ),
    );
  }
}

class _FeaturedAvatar extends StatelessWidget {
  final PlayerProfile profile;
  final VoidCallback onTap;

  const _FeaturedAvatar({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(profile.profileImage);
    final ok = profile.profileImage.isNotEmpty &&
        uri != null &&
        uri.hasScheme &&
        uri.host.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.5), width: 2),
              ),
              child: CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
                backgroundImage: ok ? NetworkImage(profile.profileImage) : null,
                child: !ok
                    ? const Icon(Icons.person_rounded,
                        color: AppColors.primaryGreen, size: 32)
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              profile.username,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : AppColors.gray,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerResultTile extends StatelessWidget {
  final PlayerProfile profile;
  final VoidCallback onTap;

  const _PlayerResultTile({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final uri = Uri.tryParse(profile.profileImage);
    final ok = profile.profileImage.isNotEmpty &&
        uri != null &&
        uri.hasScheme &&
        uri.host.isNotEmpty;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
        backgroundImage: ok ? NetworkImage(profile.profileImage) : null,
        child: !ok
            ? const Icon(Icons.person_rounded, color: AppColors.primaryGreen)
            : null,
      ),
      title: Text(
        profile.username,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColors.lightText,
        ),
      ),
      subtitle: Text(
        '${profile.position} · ${profile.age} · ${profile.country}',
        style: TextStyle(color: AppColors.gray.withOpacity(0.9), fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.gray),
    );
  }
}
