import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/theme/app_colors.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_state.dart';
import 'package:goal_connect/features/highlights/presentation/bloc/highlight_bloc.dart';
import 'package:goal_connect/features/highlights/presentation/bloc/highlight_event.dart';
import 'package:goal_connect/features/highlights/presentation/bloc/highlight_state.dart';
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
        final profileId = user.playerProfileId ?? user.id;

        return BlocProvider(
          create: (_) => sl<HighlightBloc>()
            ..add(GetPlayerHighlightsEvent(profileId)),
          child: _CurrentUserProfileView(
            user: user,
            embeddedInShell: embeddedInShell,
          ),
        );
      },
    );
  }
}

class _CurrentUserProfileView extends StatelessWidget {
  final User user;
  final bool embeddedInShell;

  const _CurrentUserProfileView({
    required this.user,
    required this.embeddedInShell,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
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
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.black,
                      backgroundImage: user.profileImage.isNotEmpty
                          ? NetworkImage(user.profileImage)
                          : null,
                      child: user.profileImage.isEmpty
                          ? Icon(Icons.person_rounded,
                              size: 46, color: AppColors.primaryGreen)
                          : null,
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
                      if (user.role == 'verified') ...[
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
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : Colors.black)
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            color: isDark ? Colors.white70 : AppColors.lightText,
                            size: 18,
                          ),
                        ),
                        if (user.role.toLowerCase() == 'player') ...[
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              final profileId = user.playerProfileId ?? user.id;
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => UploadHighlightPage(playerId: profileId),
                                ),
                              );
                            },
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.video_call_rounded,
                                color: isDark ? Colors.white70 : AppColors.lightText,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 10),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : Colors.black)
                                .withValues(alpha: 0.08),
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

  Widget _buildBody(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.lightText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
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
                const Text(
                  'User Information',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                _infoRow('Email:', user.email, textColor),
                const SizedBox(height: 8),
                _infoRow('Role:', user.role, textColor),
                const SizedBox(height: 8),
                _infoRow('Name:', user.fullName, textColor),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildHighlightsSection(context, isDark, textColor),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, Color textColor) {
    return Row(
      children: [
        SizedBox(
          width: 80,
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
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightsSection(
      BuildContext context, bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Highlights',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
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
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
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
                      ],
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
}
