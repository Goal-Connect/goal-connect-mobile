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

class _ProfilePageState extends State<ProfilePage> {
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
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "PROFILE",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined,
                color: theme.colorScheme.onSurface),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: _buildSettingsDrawer(context, isDark),
      body: _buildProfileBody(context, theme),
    );
  }

  Widget _buildProfileBody(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? Colors.white : AppColors.lightText;
    final subColor = AppColors.gray;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Avatar
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
            child: const Icon(
              Icons.person_rounded,
              size: 52,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            "EthioStar_10",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Forward · Ethiopia 🇪🇹",
            style: TextStyle(color: subColor, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statItem("12", "Highlights", textColor, subColor),
                _divider(isDark),
                _statItem("348", "Likes", textColor, subColor),
                _divider(isDark),
                _statItem("19", "Age", textColor, subColor),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Edit profile button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGreen),
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Edit Profile",
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Highlights grid placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "My Highlights",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemBuilder: (_, i) => Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: AppColors.primaryGreen,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _statItem(
      String value, String label, Color textColor, Color subColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: subColor, fontSize: 12)),
      ],
    );
  }

  Widget _divider(bool isDark) => Container(
        height: 32,
        width: 1,
        color: isDark ? Colors.white12 : Colors.black12,
      );


  Widget _buildSettingsDrawer(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final currentMode = context.watch<ThemeCubit>().state.themeMode;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? Colors.white : AppColors.lightText;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.settings_rounded,
                      color: Colors.black, size: 28),
                  const SizedBox(height: 10),
                  const Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    "Customise your experience",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // ── Appearance ──
                  _sectionHeader("Appearance", textColor),

                  _themeOption(
                    context: context,
                    label: "Light",
                    icon: Icons.light_mode_rounded,
                    mode: ThemeMode.light,
                    currentMode: currentMode,
                    surfaceColor: surfaceColor,
                    textColor: textColor,
                  ),
                  _themeOption(
                    context: context,
                    label: "Dark",
                    icon: Icons.dark_mode_rounded,
                    mode: ThemeMode.dark,
                    currentMode: currentMode,
                    surfaceColor: surfaceColor,
                    textColor: textColor,
                  ),
                  _themeOption(
                    context: context,
                    label: "System default",
                    icon: Icons.phone_android_rounded,
                    mode: ThemeMode.system,
                    currentMode: currentMode,
                    surfaceColor: surfaceColor,
                    textColor: textColor,
                  ),

                  const SizedBox(height: 8),
                  Divider(color: isDark ? Colors.white10 : Colors.black12),

                  // ── Preferences ──
                  _sectionHeader("Preferences", textColor),

                  _switchTile(
                    icon: Icons.notifications_outlined,
                    label: "Notifications",
                    subtitle: "Get match & scout alerts",
                    value: _notificationsEnabled,
                    textColor: textColor,
                    surfaceColor: surfaceColor,
                    onChanged: (v) =>
                        setState(() => _notificationsEnabled = v),
                  ),
                  _switchTile(
                    icon: Icons.public_rounded,
                    label: "Public Profile",
                    subtitle: "Let scouts find you",
                    value: _publicProfile,
                    textColor: textColor,
                    surfaceColor: surfaceColor,
                    onChanged: (v) => setState(() => _publicProfile = v),
                  ),
                  _switchTile(
                    icon: Icons.play_arrow_rounded,
                    label: "Auto-play Videos",
                    subtitle: "Play highlights automatically",
                    value: _autoPlayVideos,
                    textColor: textColor,
                    surfaceColor: surfaceColor,
                    onChanged: (v) => setState(() => _autoPlayVideos = v),
                  ),

                  const SizedBox(height: 8),
                  Divider(color: isDark ? Colors.white10 : Colors.black12),

                  // ── Account ──
                  _sectionHeader("Account", textColor),

                  _actionTile(
                    icon: Icons.language_rounded,
                    label: "Language",
                    trailing: "English",
                    textColor: textColor,
                    surfaceColor: surfaceColor,
                    onTap: () {},
                  ),
                  _actionTile(
                    icon: Icons.privacy_tip_outlined,
                    label: "Privacy Policy",
                    textColor: textColor,
                    surfaceColor: surfaceColor,
                    onTap: () {},
                  ),
                  _actionTile(
                    icon: Icons.info_outline_rounded,
                    label: "About GoalConnect",
                    trailing: "v1.0.0",
                    textColor: textColor,
                    surfaceColor: surfaceColor,
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),

                  // Sign out
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.habeshaRed),
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded,
                          color: AppColors.habeshaRed, size: 18),
                      label: const Text(
                        "Sign Out",
                        style: TextStyle(
                          color: AppColors.habeshaRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _sectionHeader(String label, Color textColor) => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
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
  }) {
    final isSelected = currentMode == mode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: isSelected
            ? AppColors.primaryGreen.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => context.read<ThemeCubit>().setTheme(mode),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon,
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.gray,
                    size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primaryGreen
                          : textColor,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primaryGreen, size: 20),
              ],
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        leading: Icon(icon, color: AppColors.gray, size: 22),
        title: Text(
          label,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.gray),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryGreen,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        leading: Icon(icon, color: AppColors.gray, size: 22),
        title: Text(
          label,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
        ),
        trailing: trailing != null
            ? Text(trailing,
                style: const TextStyle(
                    color: AppColors.gray, fontSize: 13))
            : const Icon(Icons.chevron_right_rounded,
                color: AppColors.gray),
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
