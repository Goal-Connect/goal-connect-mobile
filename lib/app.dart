import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/theme/app_colors.dart';
import 'package:goal_connect/core/theme/theme_cubit.dart';
import 'package:goal_connect/core/theme/theme_state.dart';
import 'package:goal_connect/core/theme/app_theme.dart';
import 'package:goal_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goal_connect/features/highlights/presentation/bloc/highlight_bloc.dart';
import 'package:goal_connect/features/highlights/presentation/pages/highlight_feed_page.dart';
import 'package:goal_connect/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:goal_connect/features/chat/presentation/pages/chat_list_page.dart';
import 'package:goal_connect/features/highlights/presentation/pages/upload_highlight_page.dart';
import 'package:goal_connect/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:goal_connect/features/onboarding/domain/usecases/get_onboarding_status_usecase.dart';
import 'package:goal_connect/features/onboarding/domain/usecases/set_onboarding_shown_usecase.dart';
import 'injection_container.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(sl<LoginUsecase>())),
        BlocProvider(
          create: (_) => OnboardingBloc(
            getStatus: sl<GetOnboardingStatusUsecase>(),
            setShown: sl<SetOnboardingShownUsecase>(),
          ),
        ),
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => sl<HighlightBloc>()),
        BlocProvider(create: (_) => sl<ChatBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            home: const MainPage(),
          );
        },
      ),
    );
  }
}


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Tab order: 0=Highlights, 1=Upload(action), 2=Chat, 3=Profile
  // _selectedTab tracks the visual tab highlight (skip 1 since Upload is an action)
  int _selectedTab = 0;

  Widget get _currentPage {
    switch (_selectedTab) {
      case 0:
        return const HighlightFeedPage();
      case 2:
        return const ChatListPage();
      case 3:
        return const ProfilePage();
      default:
        return const HighlightFeedPage();
    }
  }

  void _onTabTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UploadHighlightPage()),
      );
      return;
    }
    setState(() => _selectedTab = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: _currentPage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.gray,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline_rounded),
            activeIcon: Icon(Icons.play_circle_rounded),
            label: "Highlights",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box_rounded),
            label: "Upload",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}




class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _notificationsEnabled = true;
  bool _publicProfile = true;
  bool _autoPlayVideos = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      endDrawer: _buildSettingsDrawer(context, isDark),
      body: _buildProfileBody(context, theme),
    );
  }

  Widget _buildProfileBody(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? Colors.white : AppColors.lightText;

    return CustomScrollView(
      slivers: [
        // Gradient header
        SliverToBoxAdapter(
          child: Stack(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen.withOpacity(isDark ? 0.25 : 0.15),
                      isDark ? const Color(0xFF0A0A12) : AppColors.lightBg,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.settings_rounded,
                              color: theme.colorScheme.onSurface.withOpacity(0.6), size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Avatar
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryGreen.withOpacity(0.4),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withOpacity(0.15),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.primaryGreen.withOpacity(0.12),
                            child: const Icon(Icons.person_rounded,
                                size: 48, color: AppColors.primaryGreen),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "EthioStar_10",
                          style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900, color: textColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Forward",
                                style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Ethiopia 🇪🇹",
                              style: TextStyle(color: AppColors.gray, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Stats cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _statCard(
                    "12", "Highlights", Icons.play_circle_rounded,
                    isDark, textColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    "348", "Likes", Icons.favorite_rounded,
                    isDark, textColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    "19", "Age", Icons.cake_rounded,
                    isDark, textColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Action buttons
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryGreen, Color(0xFF00C278)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {},
                        child: const Center(
                          child: Text(
                            "Edit Profile",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.share_rounded,
                        color: theme.colorScheme.onSurface.withOpacity(0.5), size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Bio card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.primaryGreen.withOpacity(0.6), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "About",
                        style: TextStyle(
                          color: textColor.withOpacity(0.5),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Young forward from Addis Ababa with a passion for the beautiful game. Dream: play in the top leagues.",
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                  ),
                  child: const Text(
                    "Highlights",
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
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
                      bottom: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "0:24",
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              childCount: 6,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _statCard(
    String value, String label, IconData icon, bool isDark, Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryGreen.withOpacity(0.5), size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w900, color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.gray, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSettingsDrawer(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final currentMode = context.watch<ThemeCubit>().state.themeMode;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? Colors.white : AppColors.lightText;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.primaryGreen.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.settings_rounded, color: Colors.black, size: 22),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Customise your experience",
                    style: TextStyle(color: Colors.black.withOpacity(0.55), fontSize: 13),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _sectionHeader("Appearance", textColor),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
                        ),
                      ),
                      child: Column(
                        children: [
                          _themeOption(context: context, label: "Light", icon: Icons.light_mode_rounded,
                            mode: ThemeMode.light, currentMode: currentMode, surfaceColor: surfaceColor, textColor: textColor, isFirst: true),
                          Divider(height: 1, indent: 48, color: (isDark ? Colors.white : Colors.black).withOpacity(0.04)),
                          _themeOption(context: context, label: "Dark", icon: Icons.dark_mode_rounded,
                            mode: ThemeMode.dark, currentMode: currentMode, surfaceColor: surfaceColor, textColor: textColor),
                          Divider(height: 1, indent: 48, color: (isDark ? Colors.white : Colors.black).withOpacity(0.04)),
                          _themeOption(context: context, label: "System default", icon: Icons.phone_android_rounded,
                            mode: ThemeMode.system, currentMode: currentMode, surfaceColor: surfaceColor, textColor: textColor, isLast: true),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _sectionHeader("Preferences", textColor),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
                        ),
                      ),
                      child: Column(
                        children: [
                          _switchTile(icon: Icons.notifications_outlined, label: "Notifications",
                            subtitle: "Get match & scout alerts", value: _notificationsEnabled,
                            textColor: textColor, surfaceColor: surfaceColor,
                            onChanged: (v) => setState(() => _notificationsEnabled = v)),
                          Divider(height: 1, indent: 48, color: (isDark ? Colors.white : Colors.black).withOpacity(0.04)),
                          _switchTile(icon: Icons.public_rounded, label: "Public Profile",
                            subtitle: "Let scouts find you", value: _publicProfile,
                            textColor: textColor, surfaceColor: surfaceColor,
                            onChanged: (v) => setState(() => _publicProfile = v)),
                          Divider(height: 1, indent: 48, color: (isDark ? Colors.white : Colors.black).withOpacity(0.04)),
                          _switchTile(icon: Icons.play_arrow_rounded, label: "Auto-play Videos",
                            subtitle: "Play highlights automatically", value: _autoPlayVideos,
                            textColor: textColor, surfaceColor: surfaceColor,
                            onChanged: (v) => setState(() => _autoPlayVideos = v)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _sectionHeader("Account", textColor),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
                        ),
                      ),
                      child: Column(
                        children: [
                          _actionTile(icon: Icons.language_rounded, label: "Language", trailing: "English",
                            textColor: textColor, surfaceColor: surfaceColor, onTap: () {}),
                          Divider(height: 1, indent: 48, color: (isDark ? Colors.white : Colors.black).withOpacity(0.04)),
                          _actionTile(icon: Icons.privacy_tip_outlined, label: "Privacy Policy",
                            textColor: textColor, surfaceColor: surfaceColor, onTap: () {}),
                          Divider(height: 1, indent: 48, color: (isDark ? Colors.white : Colors.black).withOpacity(0.04)),
                          _actionTile(icon: Icons.info_outline_rounded, label: "About GoalConnect", trailing: "v1.0.0",
                            textColor: textColor, surfaceColor: surfaceColor, onTap: () {}),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.habeshaRed.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.habeshaRed.withOpacity(0.12)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.logout_rounded, color: AppColors.habeshaRed, size: 18),
                                const SizedBox(width: 10),
                                const Text(
                                  "Sign Out",
                                  style: TextStyle(
                                    color: AppColors.habeshaRed,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label, Color textColor) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.primaryGreen,
          ),
        ),
      );

  Widget _themeOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required Color surfaceColor,
    required Color textColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isSelected = currentMode == mode;
    return InkWell(
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(14) : Radius.zero,
        bottom: isLast ? const Radius.circular(14) : Radius.zero,
      ),
      onTap: () => context.read<ThemeCubit>().setTheme(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primaryGreen : AppColors.gray, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? AppColors.primaryGreen : textColor,
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.black, size: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required Color textColor,
    required Color surfaceColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gray, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.gray)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    String? trailing,
    required Color textColor,
    required Color surfaceColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gray, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
            ),
            if (trailing != null)
              Text(trailing, style: const TextStyle(color: AppColors.gray, fontSize: 12))
            else
              const Icon(Icons.chevron_right_rounded, color: AppColors.gray, size: 20),
          ],
        ),
      ),
    );
  }
}
