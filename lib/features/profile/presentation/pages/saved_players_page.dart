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
      body: BlocConsumer<SavedPlayersBloc, SavedPlayersState>(
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
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _SavedPlayersHeader(
                  isDark: isDark,
                  count: state.players.length,
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
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final p = state.players[index];
                          final removing = state.pendingIds.contains(p.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _SavedPlayerCard(
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

class _SavedPlayersHeader extends StatelessWidget {
  final bool isDark;
  final int count;

  const _SavedPlayersHeader({required this.isDark, required this.count});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, topPadding + 18, 20, 22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF14241B),
                    Color(0xFF0A0A12),
                  ]
                : [
                    AppColors.primaryGreen.withValues(alpha: 0.08),
                    AppColors.lightBg,
                  ],
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bookmark_rounded,
                    color: AppColors.primaryGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.savedPlayersTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          letterSpacing: -0.3,
                          color: isDark ? Colors.white : AppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.savedPlayersSubtitle,
                        style: TextStyle(
                          color: AppColors.gray.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.primaryGreen.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      l.savedPlayersCount(count),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
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
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryGreen.withValues(alpha: 0.18),
                    AppColors.primaryGreen.withValues(alpha: 0.04),
                  ],
                ),
              ),
              child: const Icon(
                Icons.bookmark_outline_rounded,
                color: AppColors.primaryGreen,
                size: 46,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppLocalizations.of(context).savedPlayersEmptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.lightText,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).savedPlayersEmptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray.withValues(alpha: 0.85),
                height: 1.45,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedPlayerCard extends StatelessWidget {
  final PlayerProfile profile;
  final bool removing;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SavedPlayerCard({
    required this.profile,
    required this.removing,
    required this.isDark,
    required this.onTap,
    required this.onRemove,
  });

  bool get _hasValidImage {
    final uri = Uri.tryParse(profile.profileImage);
    return profile.profileImage.isNotEmpty &&
        uri != null &&
        uri.hasScheme &&
        uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final surface = isDark ? const Color(0xFF14141C) : Colors.white;
    final borderColor =
        (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06);
    final textColor = isDark ? Colors.white : AppColors.lightText;

    final hasPosition = profile.position.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: isDark ? 0.35 : 0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Accent strip at the top for visual interest.
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryGreen,
                      Color(0xFF27AE60),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GradientAvatar(
                      imageUrl: _hasValidImage ? profile.profileImage : null,
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
                                  profile.username,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: AppColors.primaryGreen,
                              ),
                            ],
                          ),
                          if (hasPosition) ...[
                            const SizedBox(height: 6),
                            Text(
                              profile.position.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _RemoveButton(
                      removing: removing,
                      tooltip: l.savedPlayersRemoveTooltip,
                      onRemove: onRemove,
                    ),
                  ],
                ),
              ),
              if (_hasStatLine) ...[
                Divider(
                  height: 1,
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.04),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCell(
                          label: l.savedPlayersStatHighlights,
                          value: _formatCount(profile.highlightsCount),
                          textColor: textColor,
                        ),
                      ),
                      _StatDivider(isDark: isDark),
                      Expanded(
                        child: _StatCell(
                          label: l.savedPlayersStatFollowers,
                          value: _formatCount(profile.followersCount),
                          textColor: textColor,
                        ),
                      ),
                      _StatDivider(isDark: isDark),
                      Expanded(
                        child: _StatCell(
                          label: l.savedPlayersStatLikes,
                          value: _formatCount(profile.totalLikes),
                          textColor: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasStatLine =>
      profile.highlightsCount > 0 ||
      profile.followersCount > 0 ||
      profile.totalLikes > 0;

  static String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _GradientAvatar extends StatelessWidget {
  final String? imageUrl;
  const _GradientAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen,
            Color(0xFF27AE60),
          ],
        ),
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.2),
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
        child: imageUrl == null
            ? const Icon(
                Icons.person_rounded,
                color: AppColors.primaryGreen,
                size: 30,
              )
            : null,
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final bool removing;
  final String tooltip;
  final VoidCallback onRemove;

  const _RemoveButton({
    required this.removing,
    required this.tooltip,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (removing) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Padding(
          padding: EdgeInsets.all(11),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryGreen,
          ),
        ),
      );
    }
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.bookmark_rounded,
          color: AppColors.primaryGreen,
          size: 18,
        ),
      ),
      onPressed: onRemove,
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;

  const _StatCell({
    required this.label,
    required this.value,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: AppColors.gray.withValues(alpha: 0.75),
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  final bool isDark;
  const _StatDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 26,
      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
    );
  }
}
