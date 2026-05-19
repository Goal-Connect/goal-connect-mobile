import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/theme/app_colors.dart';
import 'package:goal_connect/generated/l10n/app_localizations.dart';
import 'package:goal_connect/features/auth/domain/entities/current_user_profile.dart';
import 'package:goal_connect/features/auth/domain/entities/player_profile.dart';
import 'package:goal_connect/features/auth/domain/entities/scout_profile.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_state.dart';
import 'package:goal_connect/features/highlights/presentation/bloc/highlight_bloc.dart';
import 'package:goal_connect/features/highlights/presentation/bloc/highlight_event.dart';
import 'package:goal_connect/features/highlights/presentation/bloc/highlight_state.dart';
import 'package:goal_connect/features/highlights/presentation/pages/single_highlight_page.dart';
import 'package:goal_connect/features/highlights/presentation/pages/upload_highlight_page.dart';
import 'package:goal_connect/features/profile/presentation/pages/settings_page.dart';
import 'package:goal_connect/injection_container.dart';

class CurrentUserProfilePage extends StatelessWidget {
  final bool embeddedInShell;

  const CurrentUserProfilePage({
    super.key,
    this.embeddedInShell = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          );
        }

        final user = state.user;
        final profile = state.profile;
        final profileId = user.playerProfileId ?? user.id;

        return BlocProvider(
          create: (_) => sl<HighlightBloc>()
            ..add(GetPlayerHighlightsEvent(profileId)),
          child: _CurrentUserProfileView(
            user: user,
            profile: profile,
            embeddedInShell: embeddedInShell,
          ),
        );
      },
    );
  }
}

class _CurrentUserProfileView extends StatelessWidget {
  final User user;
  final CurrentUserProfile? profile;
  final bool embeddedInShell;

  const _CurrentUserProfileView({
    required this.user,
    required this.profile,
    required this.embeddedInShell,
  });

  PlayerProfile? get _playerProfile {
    final p = profile;
    return p is CurrentUserProfilePlayer ? p.player : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPlayer = user.role.toLowerCase() == 'player';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context, isDark),
          SliverToBoxAdapter(
            child: _buildBody(context, isDark),
          ),
        ],
      ),
      floatingActionButton: isPlayer
          ? Builder(
              builder: (context) => FloatingActionButton(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.black,
                onPressed: () async {
                  final playerId = user.playerProfileId ?? user.id;
                  final bloc = context.read<HighlightBloc>();
                  final uploaded = await Navigator.of(context).push<bool>(
                    MaterialPageRoute<bool>(
                      builder: (_) => UploadHighlightPage(playerId: playerId),
                    ),
                  );
                  if (uploaded == true) {
                    bloc.add(GetPlayerHighlightsEvent(playerId));
                  }
                },
                child: const Icon(Icons.video_call_rounded),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 280,
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
                  color: Colors.black.withValues(alpha: 0.3),
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
                color: Colors.black.withValues(alpha: 0.3),
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
                    AppColors.primaryGreen.withValues(alpha: 0.3),
                    AppColors.primaryGreen.withValues(alpha: 0.05),
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
                        color: AppColors.primaryGreen.withValues(alpha: 0.5),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.2),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Builder(
                      builder: (_) {
                        final url = (profile?.profileImageUrl.isNotEmpty ?? false)
                            ? profile!.profileImageUrl
                            : user.profileImage;
                        return CircleAvatar(
                          radius: 46,
                          backgroundColor: Colors.black,
                          backgroundImage:
                              url.isNotEmpty ? NetworkImage(url) : null,
                          child: url.isEmpty
                              ? Icon(Icons.person_rounded,
                                  size: 46, color: AppColors.primaryGreen)
                              : null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.lightText,
                        ),
                      ),
                      if (_playerProfile?.verificationStatus == 'verified') ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded,
                            color: AppColors.primaryGreen, size: 20),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user.role.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1,
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

  Widget _buildBody(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.lightText;
    final p = profile;

    final List<Widget> cards;
    switch (p) {
      case CurrentUserProfilePlayer(player: final player):
        cards = _playerCards(context, isDark, textColor, player);
      case CurrentUserProfileScout(scout: final scout):
        cards = _scoutCards(context, isDark, textColor, scout);
      case null:
        cards = [
          _accountCard(context, isDark, textColor),
          const SizedBox(height: 24),
        ];
    }

    final isPlayer = p is CurrentUserProfilePlayer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          ...cards,
          if (isPlayer) ...[
            _buildHighlightsSection(context, isDark, textColor),
            const SizedBox(height: 40),
          ] else
            const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> _playerCards(BuildContext context, bool isDark, Color textColor, PlayerProfile p) {
    final l = AppLocalizations.of(context);
    return [
      if (p.bio.isNotEmpty) ...[
        Text(
          p.bio,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.85),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
      ],
      _statsRow(context, isDark, p),
      const SizedBox(height: 20),
      _playerDetailsCard(context, isDark, textColor, p),
      const SizedBox(height: 20),
      if (p.playingStyleTags.isNotEmpty) ...[
        _tagsCard(isDark, textColor, l.playerProfilePlayingStyle, p.playingStyleTags),
        const SizedBox(height: 20),
      ],
      _disciplinaryCard(context, isDark, textColor, p),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _scoutCards(BuildContext context, bool isDark, Color textColor, ScoutProfile s) {
    return [
      _scoutOrganizationCard(context, isDark, textColor, s),
      const SizedBox(height: 20),
      _scoutPreferencesCard(context, isDark, textColor, s),
      const SizedBox(height: 20),
      _scoutActivityRow(context, isDark, s),
      const SizedBox(height: 24),
    ];
  }

  Widget _scoutOrganizationCard(
      BuildContext context, bool isDark, Color textColor, ScoutProfile s) {
    final l = AppLocalizations.of(context);
    return _sectionCard(
      isDark: isDark,
      title: l.currentUserProfileOrganization,
      children: [
        if (s.fullName.isNotEmpty) _infoRow(l.currentUserProfileName, s.fullName, textColor),
        _infoRow(l.currentUserProfileEmail, user.email, textColor),
        if (s.organization.isNotEmpty)
          _infoRow(l.currentUserProfileOrganization, s.organization, textColor),
        if (s.phone.isNotEmpty) _infoRow(l.currentUserProfilePhone, s.phone, textColor),
        if (s.country.isNotEmpty) _infoRow(l.currentUserProfileCountry, s.country, textColor),
      ],
    );
  }

  Widget _scoutPreferencesCard(
      BuildContext context, bool isDark, Color textColor, ScoutProfile s) {
    final l = AppLocalizations.of(context);
    final range = s.preferredAgeRange;
    String? ageRangeText;
    if (range.hasAny) {
      final lo = range.min?.toString() ?? '—';
      final hi = range.max?.toString() ?? '—';
      ageRangeText = l.currentUserProfileAgeRangeValue(lo, hi);
    }

    final hasAnything = ageRangeText != null ||
        s.interestedPositions.isNotEmpty ||
        s.preferredRegions.isNotEmpty;
    if (!hasAnything) {
      return _sectionCard(
        isDark: isDark,
        title: l.currentUserProfileScoutingPreferences,
        children: [
          Text(
            l.currentUserProfileNoPreferences,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    return _sectionCard(
      isDark: isDark,
      title: l.currentUserProfileScoutingPreferences,
      children: [
        if (ageRangeText != null)
          _infoRow(l.currentUserProfileAgeRange, ageRangeText, textColor),
        if (s.interestedPositions.isNotEmpty) ...[
          const SizedBox(height: 4),
          _miniLabel(l.currentUserProfilePositions, textColor),
          const SizedBox(height: 8),
          _chipWrap(s.interestedPositions, textColor),
        ],
        if (s.preferredRegions.isNotEmpty) ...[
          const SizedBox(height: 12),
          _miniLabel(l.currentUserProfileRegions, textColor),
          const SizedBox(height: 8),
          _chipWrap(s.preferredRegions, textColor),
        ],
      ],
    );
  }

  Widget _scoutActivityRow(BuildContext context, bool isDark, ScoutProfile s) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        _statTile(isDark, label: l.currentUserProfileSaved, value: '${s.savedPlayersCount}'),
        const SizedBox(width: 10),
        _statTile(
            isDark, label: l.currentUserProfileRecentlyViewed, value: '${s.recentlyViewedCount}'),
        const SizedBox(width: 10),
        _statTile(isDark, label: l.currentUserProfileDocuments, value: '${s.documentsCount}'),
      ],
    );
  }

  Widget _miniLabel(String text, Color textColor) {
    return Text(
      text,
      style: TextStyle(
        color: textColor.withValues(alpha: 0.55),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _chipWrap(List<String> items, Color textColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map((t) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
    );
  }

  Widget _accountCard(BuildContext context, bool isDark, Color textColor) {
    final l = AppLocalizations.of(context);
    return _sectionCard(
      isDark: isDark,
      title: l.currentUserProfileUserInfo,
      children: [
        _infoRow(l.currentUserProfileEmail, user.email, textColor),
        _infoRow(l.currentUserProfileRole, user.role, textColor),
        if (user.fullName.isNotEmpty) _infoRow(l.currentUserProfileName, user.fullName, textColor),
      ],
    );
  }

  Widget _statsRow(BuildContext context, bool isDark, PlayerProfile p) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        _statTile(isDark, label: l.playerProfileGoals, value: '${p.totalGoals}'),
        const SizedBox(width: 10),
        _statTile(isDark, label: l.playerProfileAssists, value: '${p.totalAssists}'),
        const SizedBox(width: 10),
        _statTile(isDark, label: l.playerProfileMatches, value: '${p.totalMatches}'),
        const SizedBox(width: 10),
        _statTile(isDark, label: l.currentUserProfileMinutes, value: '${p.totalMinutesPlayed}'),
      ],
    );
  }

  Widget _statTile(bool isDark,
      {required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.gray,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerDetailsCard(BuildContext context, bool isDark, Color textColor, PlayerProfile p) {
    final l = AppLocalizations.of(context);
    final spokes = _radarSpokesFor(context, p);

    final extraRows = <Widget>[
      if (p.fullName.isNotEmpty) _infoRow(l.currentUserProfileName, p.fullName, textColor),
      _infoRow(l.currentUserProfileEmail, user.email, textColor),
      if (p.jerseyNumber != null)
        _infoRow(l.playerProfileJersey, '#${p.jerseyNumber}', textColor),
      if (p.primaryPosition.isNotEmpty)
        _infoRow(l.playerProfilePosition, _capitalize(p.primaryPosition), textColor),
      if ((p.secondaryPosition ?? '').isNotEmpty)
        _infoRow(l.playerProfileSecondary, _capitalize(p.secondaryPosition!), textColor),
      if ((p.strongFoot ?? '').isNotEmpty)
        _infoRow(l.currentUserProfileStrongFoot, _capitalize(p.strongFoot!), textColor),
      if (p.weight != null) _infoRow(l.playerProfileWeight, '${p.weight} kg', textColor),
      if (p.ageYears != null) _infoRow(l.playerProfileAge, '${p.ageYears}', textColor),
      if (p.dateOfBirth != null)
        _infoRow(l.currentUserProfileDateOfBirth, _formatDate(p.dateOfBirth!), textColor),
      if (p.nationality.isNotEmpty)
        _infoRow(l.playerProfileNationality, p.nationality, textColor),
      if (p.availabilityStatus.isNotEmpty)
        _infoRow(l.currentUserProfileAvailability, p.availabilityStatus, textColor),
      if (p.verificationStatus.isNotEmpty)
        _infoRow(l.currentUserProfileVerification, _capitalize(p.verificationStatus), textColor),
    ];

    return _sectionCard(
      isDark: isDark,
      title: l.currentUserProfileDetails,
      children: [
        _RadarChart(spokes: spokes, isDark: isDark, textColor: textColor),
        if (extraRows.isNotEmpty) const SizedBox(height: 18),
        ...extraRows,
      ],
    );
  }

  List<_RadarSpoke> _radarSpokesFor(BuildContext context, PlayerProfile p) {
    final l = AppLocalizations.of(context);
    double clamp01(double v) => v.clamp(0.0, 1.0);

    final cards = p.disciplinaryRecord.yellowCards +
        p.disciplinaryRecord.redCards * 3;
    final discipline = clamp01(1.0 - cards / 15.0);
    final heightScore = p.height == null
        ? 0.0
        : clamp01((p.height! - 150) / 50.0);

    return [
      _RadarSpoke(label: l.currentUserProfileRadarGoals, value: clamp01(p.totalGoals / 30.0), raw: '${p.totalGoals}'),
      _RadarSpoke(label: l.currentUserProfileRadarAssists, value: clamp01(p.totalAssists / 20.0), raw: '${p.totalAssists}'),
      _RadarSpoke(label: l.currentUserProfileRadarMatches, value: clamp01(p.totalMatches / 50.0), raw: '${p.totalMatches}'),
      _RadarSpoke(label: l.currentUserProfileRadarMinutes, value: clamp01(p.totalMinutesPlayed / 4500.0), raw: '${p.totalMinutesPlayed}'),
      _RadarSpoke(label: l.currentUserProfileRadarHeight, value: heightScore, raw: p.height == null ? '—' : '${p.height}cm'),
      _RadarSpoke(label: l.currentUserProfileRadarDiscipline, value: discipline, raw: '${p.disciplinaryRecord.yellowCards}Y/${p.disciplinaryRecord.redCards}R'),
    ];
  }

  Widget _tagsCard(
      bool isDark, Color textColor, String title, List<String> tags) {
    return _sectionCard(
      isDark: isDark,
      title: title,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map((t) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
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

  Widget _disciplinaryCard(BuildContext context, bool isDark, Color textColor, PlayerProfile p) {
    final l = AppLocalizations.of(context);
    return _sectionCard(
      isDark: isDark,
      title: l.playerProfileDisciplinary,
      children: [
        Row(
          children: [
            _cardChip(
              isDark: isDark,
              color: const Color(0xFFFFC107),
              label: l.currentUserProfileCardYellow,
              value: '${p.disciplinaryRecord.yellowCards}',
              textColor: textColor,
            ),
            const SizedBox(width: 10),
            _cardChip(
              isDark: isDark,
              color: const Color(0xFFE53935),
              label: l.currentUserProfileCardRed,
              value: '${p.disciplinaryRecord.redCards}',
              textColor: textColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _cardChip({
    required bool isDark,
    required Color color,
    required String label,
    required String value,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
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
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required bool isDark,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.gray,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
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

  Future<void> _confirmDelete(
      BuildContext context, String highlightId) async {
    final l = AppLocalizations.of(context);
    final bloc = context.read<HighlightBloc>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title:
            Text(l.videoDeleteTitle, style: const TextStyle(color: Colors.white)),
        content: Text(
          l.videoDeleteMessage,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.commonDelete,
                style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    bloc.add(DeleteHighlightEvent(highlightId));
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Widget _buildHighlightsSection(
      BuildContext context, bool isDark, Color textColor) {
    final profileId = user.playerProfileId ?? user.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).currentUserProfileYourHighlights,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        BlocConsumer<HighlightBloc, HighlightState>(
          listener: (context, state) {
            if (state is HighlightDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(AppLocalizations.of(context).videoDeleted),
                ),
              );
              context
                  .read<HighlightBloc>()
                  .add(GetPlayerHighlightsEvent(profileId));
            } else if (state is HighlightError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)
                      .videoDeleteCouldNotDelete),
                ),
              );
              context
                  .read<HighlightBloc>()
                  .add(GetPlayerHighlightsEvent(profileId));
            }
          },
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
                        MaterialPageRoute<void>(
                          builder: (_) => SingleHighlightPage(highlight: h),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.04),
                        ),
                      ),
                      child: Stack(
                      children: [
                        Center(
                          child: Icon(Icons.play_circle_fill_rounded,
                              color: AppColors.primaryGreen.withValues(alpha: 0.4),
                              size: 36),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Text(
                            h.caption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
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
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _confirmDelete(context, h.id),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                  size: 16,
                                ),
                              ),
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
                        color: AppColors.gray.withValues(alpha: 0.3), size: 40),
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
}

class _RadarSpoke {
  final String label;
  final double value; // 0.0–1.0
  final String raw;
  const _RadarSpoke({
    required this.label,
    required this.value,
    required this.raw,
  });
}

class _RadarChart extends StatelessWidget {
  final List<_RadarSpoke> spokes;
  final bool isDark;
  final Color textColor;

  const _RadarChart({
    required this.spokes,
    required this.isDark,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _RadarPainter(
          spokes: spokes,
          isDark: isDark,
          textColor: textColor,
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<_RadarSpoke> spokes;
  final bool isDark;
  final Color textColor;

  _RadarPainter({
    required this.spokes,
    required this.isDark,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Leave room for outer labels.
    final radius = math.min(size.width, size.height) / 2 - 36;
    final n = spokes.length;
    if (n < 3) return;

    // Pointy-top: first spoke straight up.
    final startAngle = -math.pi / 2;
    final step = 2 * math.pi / n;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08);

    final ringFill = Paint()
      ..style = PaintingStyle.fill
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.02);

    // Concentric hex rings at 0.25, 0.5, 0.75, 1.0
    for (final t in [1.0, 0.75, 0.5, 0.25]) {
      final ring = Path();
      for (var i = 0; i < n; i++) {
        final a = startAngle + step * i;
        final p = center + Offset(math.cos(a), math.sin(a)) * (radius * t);
        if (i == 0) {
          ring.moveTo(p.dx, p.dy);
        } else {
          ring.lineTo(p.dx, p.dy);
        }
      }
      ring.close();
      if (t == 1.0) canvas.drawPath(ring, ringFill);
      canvas.drawPath(ring, ringPaint);
    }

    // Spoke lines from center.
    final spokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.07);
    for (var i = 0; i < n; i++) {
      final a = startAngle + step * i;
      final p = center + Offset(math.cos(a), math.sin(a)) * radius;
      canvas.drawLine(center, p, spokePaint);
    }

    // Player polygon.
    final dataPath = Path();
    for (var i = 0; i < n; i++) {
      final a = startAngle + step * i;
      final v = spokes[i].value.clamp(0.0, 1.0);
      final p = center + Offset(math.cos(a), math.sin(a)) * (radius * v);
      if (i == 0) {
        dataPath.moveTo(p.dx, p.dy);
      } else {
        dataPath.lineTo(p.dx, p.dy);
      }
    }
    dataPath.close();

    final dataFill = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryGreen.withValues(alpha: 0.55),
          AppColors.primaryGreen.withValues(alpha: 0.15),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(dataPath, dataFill);

    final dataStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.primaryGreen;
    canvas.drawPath(dataPath, dataStroke);

    // Vertex dots.
    final dotPaint = Paint()..color = AppColors.primaryGreen;
    final dotRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = isDark ? const Color(0xFF0A0A12) : Colors.white;
    for (var i = 0; i < n; i++) {
      final a = startAngle + step * i;
      final v = spokes[i].value.clamp(0.0, 1.0);
      final p = center + Offset(math.cos(a), math.sin(a)) * (radius * v);
      canvas.drawCircle(p, 3.5, dotPaint);
      canvas.drawCircle(p, 3.5, dotRing);
    }

    // Labels around the outside.
    for (var i = 0; i < n; i++) {
      final a = startAngle + step * i;
      final outer = center + Offset(math.cos(a), math.sin(a)) * (radius + 18);

      final labelTp = TextPainter(
        text: TextSpan(
          text: spokes[i].label,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.7),
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 70);

      final valueTp = TextPainter(
        text: TextSpan(
          text: spokes[i].raw,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 70);

      final blockH = labelTp.height + 2 + valueTp.height;
      final blockW = math.max(labelTp.width, valueTp.width);
      final origin = Offset(
        outer.dx - blockW / 2,
        outer.dy - blockH / 2,
      );

      labelTp.paint(
        canvas,
        Offset(origin.dx + (blockW - labelTp.width) / 2, origin.dy),
      );
      valueTp.paint(
        canvas,
        Offset(
          origin.dx + (blockW - valueTp.width) / 2,
          origin.dy + labelTp.height + 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.isDark != isDark ||
      old.textColor != textColor ||
      old.spokes != spokes;
}
