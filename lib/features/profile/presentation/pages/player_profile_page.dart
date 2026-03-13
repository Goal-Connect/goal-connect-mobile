import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
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
import '../widgets/stats_hexagon.dart';
import '../widgets/info_chip.dart';

class PlayerProfilePage extends StatelessWidget {
  final String playerId;
  final String? heroTag;

  const PlayerProfilePage({
    super.key,
    required this.playerId,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<PlayerProfileBloc>()
            ..add(LoadPlayerProfileEvent(playerId)),
        ),
        BlocProvider(
          create: (_) => sl<HighlightBloc>()
            ..add(GetPlayerHighlightsEvent(playerId)),
        ),
      ],
      child: _PlayerProfileView(playerId: playerId, heroTag: heroTag),
    );
  }
}

class _PlayerProfileView extends StatelessWidget {
  final String playerId;
  final String? heroTag;

  const _PlayerProfileView({required this.playerId, this.heroTag});

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
                    child: const Text('Retry',
                        style: TextStyle(color: AppColors.primaryGreen)),
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

          return CustomScrollView(
            slivers: [
              _buildHeader(context, profile, isDark, isToggling),
              SliverToBoxAdapter(child: _buildBody(context, profile, isDark)),
            ],
          );
        },
      ),
    );
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
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 22),
            onPressed: () {},
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
                        ? Hero(
                            tag: heroTag!,
                            child: CircleAvatar(
                              radius: 46,
                              backgroundImage: NetworkImage(profile.profileImage),
                              backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                            ),
                          )
                        : CircleAvatar(
                            radius: 46,
                            backgroundImage: NetworkImage(profile.profileImage),
                            backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
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
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded,
                          color: AppColors.primaryGreen, size: 20),
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
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: isToggling
                                ? null
                                : () => context
                                    .read<PlayerProfileBloc>()
                                    .add(ToggleFollowEvent(profile.id)),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 42,
                              decoration: BoxDecoration(
                                gradient: profile.isFollowing
                                    ? null
                                    : const LinearGradient(
                                        colors: [AppColors.primaryGreen, Color(0xFF00C278)],
                                      ),
                                color: profile.isFollowing
                                    ? (isDark ? Colors.white : Colors.black).withOpacity(0.08)
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: profile.isFollowing
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: AppColors.primaryGreen.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: isToggling
                                    ? const SizedBox(
                                        width: 16, height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: Colors.black54),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            profile.isFollowing
                                                ? Icons.check_rounded
                                                : Icons.person_add_rounded,
                                            color: profile.isFollowing
                                                ? AppColors.primaryGreen
                                                : Colors.black,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            profile.isFollowing ? 'Following' : 'Follow',
                                            style: TextStyle(
                                              color: profile.isFollowing
                                                  ? AppColors.primaryGreen
                                                  : Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
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
                        const SizedBox(width: 10),
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.share_rounded,
                            color: isDark ? Colors.white70 : AppColors.lightText,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
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
    final conversation = Conversation(
      id: 'conv_${profile.id}',
      participantId: profile.id,
      participantName: profile.username,
      participantImage: profile.profileImage,
      participantRole: profile.role,
      lastMessage: '',
      updatedAt: DateTime.now(),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<ChatBloc>(),
          child: ConversationPage(conversation: conversation),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PlayerProfile profile, bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.lightText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              _statColumn(profile.highlightsCount.toString(), 'Highlights', textColor),
              _statColumn(profile.followersCount.toString(), 'Followers', textColor),
              _statColumn(profile.followingCount.toString(), 'Following', textColor),
              _statColumn(profile.totalLikes.toString(), 'Likes', textColor),
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
          if (profile.isPlayer && profile.stats != null) ...[
            _buildPlayerInfo(profile, isDark, textColor),
            const SizedBox(height: 24),
            _buildStatsSection(profile.stats!, isDark, textColor),
            const SizedBox(height: 24),
            _buildMatchStats(profile.stats!, isDark, textColor),
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

  Widget _buildPlayerInfo(PlayerProfile profile, bool isDark, Color textColor) {
    final stats = profile.stats!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Player Info', textColor),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
          children: [
            InfoChip(icon: Icons.cake_rounded, label: 'Age', value: '${profile.age}'),
            InfoChip(icon: Icons.height_rounded, label: 'Height', value: '${stats.heightCm}cm'),
            InfoChip(icon: Icons.fitness_center_rounded, label: 'Weight', value: '${stats.weightKg}kg'),
            InfoChip(
              icon: stats.preferredFoot == 'Left'
                  ? Icons.back_hand_rounded
                  : Icons.front_hand_rounded,
              label: 'Foot',
              value: stats.preferredFoot,
            ),
          ],
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
                const Text(
                  'Current Club',
                  style: TextStyle(color: AppColors.gray, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsSection(PlayerStats stats, bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionTitle('Ability Stats', textColor),
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
                'OVR ${stats.overall}',
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
        _statBar('Pace', stats.pace, isDark),
        _statBar('Shooting', stats.shooting, isDark),
        _statBar('Passing', stats.passing, isDark),
        _statBar('Dribbling', stats.dribbling, isDark),
        _statBar('Defending', stats.defending, isDark),
        _statBar('Physical', stats.physical, isDark),
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

  Widget _buildMatchStats(PlayerStats stats, bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Match Record', textColor),
        const SizedBox(height: 12),
        Row(
          children: [
            _matchStatCard(
              '${stats.matchesPlayed}', 'Matches', Icons.sports_soccer_rounded,
              AppColors.primaryGreen, isDark,
            ),
            const SizedBox(width: 10),
            _matchStatCard(
              '${stats.goals}', 'Goals', Icons.sports_score_rounded,
              AppColors.accentGold, isDark,
            ),
            const SizedBox(width: 10),
            _matchStatCard(
              '${stats.assists}', 'Assists', Icons.handshake_rounded,
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
        _sectionTitle('Highlights', textColor),
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
                    const Text('No highlights yet',
                        style: TextStyle(color: AppColors.gray, fontSize: 13)),
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
