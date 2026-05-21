import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../../../chat/presentation/pages/conversation_page.dart';
import '../../../chat/domain/entities/conversation.dart';
import '../../../highlights/presentation/bloc/highlight_bloc.dart';
import '../../../highlights/presentation/bloc/highlight_event.dart';
import '../../../highlights/presentation/bloc/highlight_state.dart';
import '../../../highlights/presentation/pages/single_highlight_page.dart';
import '../../domain/entities/player_profile.dart';
import '../../domain/entities/player_stats.dart';
import '../bloc/player_profile_bloc.dart';
import '../bloc/player_profile_event.dart';
import '../bloc/player_profile_state.dart';
import '../bloc/saved_players_bloc.dart';
import '../bloc/saved_players_event.dart';
import '../bloc/saved_players_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/stats_hexagon.dart';
import '../widgets/info_chip.dart';
import 'settings_page.dart';

Widget _networkProfileAvatar({
  required double radius,
  required String imageUrl,
  String? heroTag,
}) {
  final placeholder = Container(
    width: radius * 2,
    height: radius * 2,
    color: AppColors.primaryGreen.withOpacity(0.1),
    child: Icon(Icons.person_rounded,
        size: radius * 1.05, color: AppColors.primaryGreen),
  );
  final uri = Uri.tryParse(imageUrl);
  final useNetwork =
      imageUrl.isNotEmpty && uri != null && uri.hasScheme && uri.host.isNotEmpty;

  Widget image;
  if (!useNetwork) {
    image = placeholder;
  } else {
    image = Image.network(
      imageUrl,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        );
      },
    );
  }

  final clipped = ClipOval(child: image);
  if (heroTag != null) {
    return Hero(tag: heroTag, child: clipped);
  }
  return clipped;
}

class PlayerProfilePage extends StatelessWidget {
  final String playerId;
  final String? heroTag;

  /// When `true`, hides back affordance for use inside main shell tab.
  final bool embeddedInShell;

  /// Set `false` when [HighlightBloc] is already provided above (e.g. main tab).
  final bool provideHighlightBloc;

  const PlayerProfilePage({
    super.key,
    required this.playerId,
    this.heroTag,
    this.embeddedInShell = false,
    this.provideHighlightBloc = true,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<PlayerProfileBloc>()
            ..add(LoadPlayerProfileEvent(playerId)),
        ),
        if (provideHighlightBloc)
          BlocProvider(
            create: (_) => sl<HighlightBloc>()
              ..add(GetPlayerHighlightsEvent(playerId)),
          ),
      ],
      child: _PlayerProfileView(
        playerId: playerId,
        heroTag: heroTag,
        embeddedInShell: embeddedInShell,
      ),
    );
  }
}

class _PlayerProfileView extends StatelessWidget {
  final String playerId;
  final String? heroTag;
  final bool embeddedInShell;

  const _PlayerProfileView({
    required this.playerId,
    this.heroTag,
    this.embeddedInShell = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<PlayerProfileBloc, PlayerProfileState>(
        builder: (context, state) {
          if (state is PlayerProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (state is PlayerProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.habeshaRed, size: 48),
                  const SizedBox(height: 16),
                  Text(state.message, style: const TextStyle(color: AppColors.gray)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context
                        .read<PlayerProfileBloc>()
                        .add(LoadPlayerProfileEvent(playerId)),
                    child: Text(AppLocalizations.of(context).commonRetry,
                        style: const TextStyle(color: AppColors.primaryGreen)),
                  ),
                ],
              ),
            );
          }

          PlayerProfile? profile;
          bool isToggling = false;
          if (state is PlayerProfileLoaded) profile = state.profile;
          if (state is FollowToggling) {
            profile = state.profile;
            isToggling = true;
          }

          if (profile == null) return const SizedBox.shrink();

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () => _onRefresh(context),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildHeader(context, profile, isDark, isToggling),
                SliverToBoxAdapter(child: _buildBody(context, profile, isDark)),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    final profileBloc = context.read<PlayerProfileBloc>();
    final highlightBloc = context.read<HighlightBloc>();

    profileBloc.add(LoadPlayerProfileEvent(playerId));
    highlightBloc.add(GetPlayerHighlightsEvent(playerId));

    await Future.wait([
      profileBloc.stream.firstWhere(
        (s) => s is PlayerProfileLoaded || s is PlayerProfileError,
      ),
      highlightBloc.stream.firstWhere(
        (s) => s is HighlightLoaded || s is HighlightError,
      ),
    ]);
  }

  Widget _buildHeader(
    BuildContext context,
    PlayerProfile profile,
    bool isDark,
    bool isToggling,
  ) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF0A0A12) : Colors.white,
      automaticallyImplyLeading: false,
      leading: embeddedInShell
          ? null
          : GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
      actions: [
        if (embeddedInShell)
          Padding(
            padding: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.settings_rounded,
                    color: Colors.white, size: 22),
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder<void>(
                      pageBuilder: (_, _, _) => const SettingsPage(),
                      transitionsBuilder:
                          (_, animation, _, child) => SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 1),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                )),
                                child: child,
                              ),
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen.withOpacity(0.3),
                    AppColors.primaryGreen.withOpacity(0.05),
                    isDark ? const Color(0xFF0A0A12) : Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.5),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.2),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: heroTag != null
                        ? _networkProfileAvatar(
                            radius: 46,
                            imageUrl: profile.profileImage,
                            heroTag: heroTag,
                          )
                        : _networkProfileAvatar(
                            radius: 46,
                            imageUrl: profile.profileImage,
                          ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '@${profile.username}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.lightText,
                        ),
                      ),
                      if (profile.verificationStatus.toLowerCase() ==
                          'verified') ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded,
                            color: AppColors.primaryGreen, size: 20),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          profile.position.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.location_on_rounded,
                          color: AppColors.gray.withOpacity(0.6), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        profile.country,
                        style: const TextStyle(color: AppColors.gray, fontSize: 13),
                      ),
                    ],
                  ),
                  if (_hasProfileStatus(profile)) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (profile.listingStatus.isNotEmpty)
                            _profileStatusChip(
                              profile.listingStatus,
                              Icons.flag_rounded,
                              isDark,
                            ),
                          if (profile.verificationStatus.isNotEmpty)
                            _profileStatusChip(
                              profile.verificationStatus,
                              Icons.verified_outlined,
                              isDark,
                            ),
                          if (profile.availabilityStatus.isNotEmpty)
                            _profileStatusChip(
                              profile.availabilityStatus,
                              Icons.event_available_rounded,
                              isDark,
                            ),
                          if (profile.academyName != null &&
                              profile.academyName!.isNotEmpty)
                            _profileStatusChip(
                              profile.academyName!,
                              Icons.school_rounded,
                              isDark,
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final isScout = authState is AuthAuthenticated &&
                          authState.user.role.toLowerCase() == 'scout';
                      if (!isScout) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _initiateChat(context, profile),
                              child: Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: isDark ? Colors.white70 : AppColors.lightText,
                                  size: 18,
                                ),
                              ),
                            ),
                            _ScoutSaveProfileButton(
                              playerId: profile.id,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initiateChat(BuildContext context, PlayerProfile profile) {
    final peerId = profile.messagingUserId;
    final conversation = Conversation(
      id: peerId,
      participantId: peerId,
      participantName: profile.username,
      participantImage: profile.profileImage,
      participantRole: profile.role,
      lastMessage: '',
      updatedAt: DateTime.now(),
    );
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ConversationPage(conversation: conversation),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PlayerProfile profile, bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.lightText;
    final l = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              if (_useServerStatsRow(profile)) ...[
                _statColumn(profile.highlightsCount.toString(), l.playerProfileVideos,
                    textColor),
                _statColumn(
                    '${profile.stats?.goals ?? 0}', l.playerProfileGoals, textColor),
                _statColumn(
                    '${profile.stats?.assists ?? 0}', l.playerProfileAssists, textColor),
                _statColumn(
                    '${profile.stats?.matchesPlayed ?? 0}',
                    l.playerProfileMatches,
                    textColor),
              ] else ...[
                _statColumn(profile.highlightsCount.toString(), l.playerProfileHighlights,
                    textColor),
                _statColumn(profile.followersCount.toString(), l.playerProfileFollowers,
                    textColor),
                _statColumn(profile.followingCount.toString(), l.playerProfileFollowing,
                    textColor),
                _statColumn(profile.totalLikes.toString(), l.playerProfileLikes, textColor),
              ],
            ],
          ),
          const SizedBox(height: 20),
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                ),
              ),
              child: Text(
                profile.bio!,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (profile.isPlayer &&
              profile.stats != null &&
              !_shouldHideSyntheticAbilityStats(profile)) ...[
            _buildStatsSection(context, profile.stats!, isDark, textColor),
            const SizedBox(height: 24),
          ],
          if (profile.isPlayer && profile.stats != null) ...[
            _buildPlayerInfo(context, profile, isDark, textColor),
            const SizedBox(height: 24),
            if (profile.playingStyleTags.isNotEmpty) ...[
              _buildTagsCard(
                  l.playerProfilePlayingStyle, profile.playingStyleTags, isDark, textColor),
              const SizedBox(height: 24),
            ],
            if (profile.clubHistory.isNotEmpty) ...[
              _buildTagsCard(
                  l.playerProfileClubHistory, profile.clubHistory, isDark, textColor),
              const SizedBox(height: 24),
            ],
            _buildDisciplinaryCard(context, profile, isDark, textColor),
            const SizedBox(height: 24),
            _buildMatchStats(context, profile.stats!, isDark, textColor),
            const SizedBox(height: 24),
          ],
          _buildHighlightsSection(context, isDark, textColor),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _statColumn(String value, String label, Color textColor) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w900, color: textColor)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.gray, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(BuildContext context, PlayerProfile profile, bool isDark, Color textColor) {
    final l = AppLocalizations.of(context);
    final stats = profile.stats!;
    final height = profile.heightCm ?? stats.heightCm;
    final weight = profile.weightKg ?? stats.weightKg;
    final foot = profile.strongFoot.isNotEmpty
        ? _capitalize(profile.strongFoot)
        : stats.preferredFoot;
    final primary = profile.primaryPosition.isNotEmpty
        ? _capitalize(profile.primaryPosition)
        : profile.position;
    final tiles = <Widget>[
      InfoChip(icon: Icons.cake_rounded, label: l.playerProfileAge, value: '${profile.age}'),
      InfoChip(icon: Icons.height_rounded, label: l.playerProfileHeight, value: '${height}cm'),
      InfoChip(icon: Icons.fitness_center_rounded, label: l.playerProfileWeight, value: '${weight}kg'),
      InfoChip(
        icon: foot == 'Left' ? Icons.back_hand_rounded : Icons.front_hand_rounded,
        label: l.playerProfileFoot,
        value: foot,
      ),
      if (profile.jerseyNumber > 0)
        InfoChip(
          icon: Icons.tag_rounded,
          label: l.playerProfileJersey,
          value: '#${profile.jerseyNumber}',
        ),
      InfoChip(icon: Icons.sports_soccer_rounded, label: l.playerProfilePosition, value: primary),
      if (profile.secondaryPosition.isNotEmpty)
        InfoChip(
          icon: Icons.swap_horiz_rounded,
          label: l.playerProfileSecondary,
          value: _capitalize(profile.secondaryPosition),
        ),
      if (profile.nationality.isNotEmpty)
        InfoChip(
          icon: Icons.flag_rounded,
          label: l.playerProfileNationality,
          value: profile.nationality,
        ),
      if (profile.dateOfBirth != null)
        InfoChip(
          icon: Icons.calendar_today_rounded,
          label: l.playerProfileDob,
          value: _formatDate(profile.dateOfBirth!),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l.playerProfilePlayerInfo, textColor),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.78,
          children: tiles,
        ),
        if (stats.currentClub != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGreen.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded,
                    color: AppColors.primaryGreen, size: 18),
                const SizedBox(width: 10),
                Text(
                  stats.currentClub!,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  l.playerProfileCurrentClub,
                  style: const TextStyle(color: AppColors.gray, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTagsCard(
      String title, List<String> items, bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title, textColor),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((t) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDisciplinaryCard(
      BuildContext context, PlayerProfile profile, bool isDark, Color textColor) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l.playerProfileDisciplinary, textColor),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _cardChip(
                color: const Color(0xFFFFC107),
                label: l.playerProfileYellowCards,
                value: '${profile.yellowCards}',
                textColor: textColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _cardChip(
                color: const Color(0xFFE53935),
                label: l.playerProfileRedCards,
                value: '${profile.redCards}',
                textColor: textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cardChip({
    required Color color,
    required String label,
    required String value,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(width: 10, height: 14, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Widget _buildStatsSection(BuildContext context, PlayerStats stats, bool isDark, Color textColor) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionTitle(l.playerProfileAbilityStats, textColor),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, Color(0xFF00C278)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l.playerProfileOverall(stats.overall),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(child: StatsHexagon(stats: stats)),
        const SizedBox(height: 16),
        _statBar(l.playerProfilePace, stats.pace, isDark),
        _statBar(l.playerProfileShooting, stats.shooting, isDark),
        _statBar(l.playerProfilePassing, stats.passing, isDark),
        _statBar(l.playerProfileDribbling, stats.dribbling, isDark),
        _statBar(l.playerProfileDefending, stats.defending, isDark),
        _statBar(l.playerProfilePhysical, stats.physical, isDark),
      ],
    );
  }

  Widget _statBar(String label, int value, bool isDark) {
    final color = value >= 75
        ? AppColors.primaryGreen
        : value >= 50
            ? AppColors.accentGold
            : AppColors.habeshaRed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(
              color: AppColors.gray, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 99,
                backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.7)),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchStats(BuildContext context, PlayerStats stats, bool isDark, Color textColor) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l.playerProfileMatchRecord, textColor),
        const SizedBox(height: 12),
        Row(
          children: [
            _matchStatCard(
              '${stats.matchesPlayed}', l.playerProfileMatches, Icons.sports_soccer_rounded,
              AppColors.primaryGreen, isDark,
            ),
            const SizedBox(width: 10),
            _matchStatCard(
              '${stats.goals}', l.playerProfileGoals, Icons.sports_score_rounded,
              AppColors.accentGold, isDark,
            ),
            const SizedBox(width: 10),
            _matchStatCard(
              '${stats.assists}', l.playerProfileAssists, Icons.handshake_rounded,
              const Color(0xFF6C63FF), isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _matchStatCard(
    String value, String label, IconData icon, Color accent, bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.lightText,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppColors.gray, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightsSection(BuildContext context, bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(AppLocalizations.of(context).playerProfileHighlights, textColor),
        const SizedBox(height: 12),
        BlocBuilder<HighlightBloc, HighlightState>(
          builder: (context, state) {
            if (state is HighlightLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.primaryGreen),
                ),
              );
            }
            if (state is HighlightLoaded && state.highlights.isNotEmpty) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.highlights.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (_, i) {
                  final h = state.highlights[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SingleHighlightPage(highlight: h),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(Icons.play_circle_fill_rounded,
                                color: AppColors.primaryGreen.withOpacity(0.4), size: 36),
                          ),
                          Positioned(
                            bottom: 8, left: 8, right: 8,
                            child: Text(
                              h.caption,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8, right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.favorite_rounded,
                                      color: Colors.white, size: 10),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${h.likes}',
                                    style: const TextStyle(
                                      color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.videocam_off_rounded,
                        color: AppColors.gray.withOpacity(0.3), size: 40),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(context).highlightsNoHighlightsYet,
                        style: const TextStyle(color: AppColors.gray, fontSize: 13)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _sectionTitle(String text, Color textColor) {
    return Text(
      text,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w800,
        fontSize: 16,
      ),
    );
  }
}

bool _hasProfileStatus(PlayerProfile profile) {
  return profile.listingStatus.isNotEmpty ||
      profile.verificationStatus.isNotEmpty ||
      profile.availabilityStatus.isNotEmpty ||
      (profile.academyName != null && profile.academyName!.isNotEmpty);
}

bool _useServerStatsRow(PlayerProfile profile) {
  return profile.listingStatus.isNotEmpty ||
      profile.verificationStatus.isNotEmpty ||
      profile.availabilityStatus.isNotEmpty;
}

bool _shouldHideSyntheticAbilityStats(PlayerProfile profile) {
  return _useServerStatsRow(profile);
}

Widget _profileStatusChip(String label, IconData icon, bool isDark) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppColors.primaryGreen.withOpacity(0.25),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primaryGreen),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : AppColors.lightText,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _ScoutSaveProfileButton extends StatelessWidget {
  final String playerId;
  final bool isDark;
  const _ScoutSaveProfileButton({
    required this.playerId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated ||
        auth.user.role.toLowerCase() != 'scout') {
      return const SizedBox.shrink();
    }

    return BlocBuilder<SavedPlayersBloc, SavedPlayersState>(
      builder: (context, state) {
        final saved = state.players.any((p) => p.id == playerId);
        final pending = state.pendingIds.contains(playerId);
        final fg = saved
            ? AppColors.primaryGreen
            : (isDark ? Colors.white70 : AppColors.lightText);
        final bg = saved
            ? AppColors.primaryGreen.withOpacity(0.15)
            : (isDark ? Colors.white : Colors.black).withOpacity(0.08);

        return Padding(
          padding: const EdgeInsets.only(left: 10),
          child: GestureDetector(
            onTap: pending
                ? null
                : () {
                    final bloc = context.read<SavedPlayersBloc>();
                    if (saved) {
                      bloc.add(SavedPlayerRemoved(playerId));
                    } else {
                      bloc.add(SavedPlayerAdded(playerId));
                    }
                  },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: saved
                    ? Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.5),
                        width: 1,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: pending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : Icon(
                      saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color: fg,
                      size: 18,
                    ),
            ),
          ),
        );
      },
    );
  }
}
