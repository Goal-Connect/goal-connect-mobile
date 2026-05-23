import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../domain/entities/player_profile.dart';
import '../bloc/saved_players_bloc.dart';
import '../bloc/saved_players_event.dart';
import '../bloc/saved_players_state.dart';
import 'player_profile_page.dart';

class SavedPlayersPage extends StatefulWidget {
  const SavedPlayersPage({super.key});

  @override
  State<SavedPlayersPage> createState() => _SavedPlayersPageState();
}

class _SavedPlayersPageState extends State<SavedPlayersPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A12) : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: BlocConsumer<SavedPlayersBloc, SavedPlayersState>(
          listenWhen: (p, c) =>
              c.errorMessage != null && c.errorMessage != p.errorMessage,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          },
          builder: (context, state) {
            return RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: () async {
                context
                    .read<SavedPlayersBloc>()
                    .add(const SavedPlayersRefreshed());
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context).savedPlayersTitle,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.lightText,
                            ),
                          ),
                          const Spacer(),
                          if (state.players.isNotEmpty)
                            Text(
                              '${state.players.length}',
                              style: TextStyle(
                                color: AppColors.gray.withOpacity(0.85),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (state.loading && state.players.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    )
                  else if (state.players.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(isDark: isDark),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final p = state.players[index];
                            final removing = state.pendingIds.contains(p.id);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: _SavedPlayerTile(
                                profile: p,
                                removing: removing,
                                isDark: isDark,
                                onTap: () => _openProfile(context, p.id),
                                onRemove: () => context
                                    .read<SavedPlayersBloc>()
                                    .add(SavedPlayerRemoved(p.id)),
                              ),
                            );
                          },
                          childCount: state.players.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
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

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withOpacity(0.12),
              ),
              child: const Icon(
                Icons.bookmark_outline_rounded,
                color: AppColors.primaryGreen,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).savedPlayersEmptyTitle,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.lightText,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).savedPlayersEmptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray.withOpacity(0.85),
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedPlayerTile extends StatelessWidget {
  final PlayerProfile profile;
  final bool removing;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SavedPlayerTile({
    required this.profile,
    required this.removing,
    required this.isDark,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(profile.profileImage);
    final ok = profile.profileImage.isNotEmpty &&
        uri != null &&
        uri.hasScheme &&
        uri.host.isNotEmpty;

    final subtitleParts = <String>[
      if (profile.position.isNotEmpty) profile.position,
      if (profile.age > 0) '${profile.age}',
      if (profile.country.isNotEmpty) profile.country,
    ];

    final base = (isDark ? Colors.white : Colors.black).withOpacity(0.03);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen.withOpacity(isDark ? 0.10 : 0.06),
            base,
            base,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
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
        subtitle: subtitleParts.isEmpty
            ? null
            : Text(
                subtitleParts.join(' · '),
                style: TextStyle(
                  color: AppColors.gray.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
        trailing: removing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryGreen,
                ),
              )
            : IconButton(
                tooltip:
                    AppLocalizations.of(context).savedPlayersRemoveTooltip,
                icon: const Icon(
                  Icons.bookmark_rounded,
                  color: AppColors.primaryGreen,
                ),
                onPressed: onRemove,
              ),
      ),
    );
  }
}
