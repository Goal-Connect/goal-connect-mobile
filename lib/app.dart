import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:goal_connect/core/theme/app_colors.dart';
import 'package:goal_connect/core/theme/theme_cubit.dart';
import 'package:goal_connect/core/theme/theme_state.dart';
import 'package:goal_connect/core/theme/app_theme.dart';
import 'package:goal_connect/core/locale/locale_cubit.dart';
import 'package:goal_connect/core/locale/locale_state.dart';
import 'package:goal_connect/generated/l10n/app_localizations.dart';
import 'package:goal_connect/core/connection/internet_connection_cubit.dart';
import 'package:goal_connect/core/connection/internet_connection_state.dart';
import 'package:goal_connect/core/widgets/no_internet_card.dart';
import 'package:goal_connect/features/auth/domain/usecases/create_scout_account_usecase.dart';
import 'package:goal_connect/features/auth/domain/usecases/get_cached_user_usecase.dart';
import 'package:goal_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:goal_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:goal_connect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:goal_connect/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_event.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_state.dart';
import 'package:goal_connect/features/highlights/presentation/bloc/highlight_bloc.dart';
import 'package:goal_connect/features/highlights/presentation/pages/highlight_feed_page.dart';
import 'package:goal_connect/features/chat/data/services/chat_socket_service.dart';
import 'package:goal_connect/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:goal_connect/features/chat/presentation/pages/chat_list_page.dart';
import 'package:goal_connect/features/profile/presentation/pages/players_search_page.dart';
import 'package:goal_connect/features/profile/presentation/pages/saved_players_page.dart';
import 'package:goal_connect/features/profile/presentation/bloc/saved_players_bloc.dart';
import 'package:goal_connect/features/profile/presentation/bloc/saved_players_event.dart';
import 'package:goal_connect/features/auth/presentation/pages/current_user_profile_page.dart';
import 'package:goal_connect/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:goal_connect/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:goal_connect/features/onboarding/domain/usecases/get_onboarding_status_usecase.dart';
import 'package:goal_connect/features/onboarding/domain/usecases/set_onboarding_shown_usecase.dart';
import 'package:goal_connect/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:goal_connect/injection_container.dart';
import 'package:goal_connect/features/profile/presentation/bloc/player_search_bloc.dart';
import 'package:goal_connect/features/profile/presentation/bloc/player_search_event.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            loginUsecase: sl<LoginUsecase>(),
            createScoutAccountUsecase: sl<CreateScoutAccountUsecase>(),
            getCurrentUserUsecase: sl<GetCurrentUserUsecase>(),
            getCachedUserUsecase: sl<GetCachedUserUsecase>(),
            updatePasswordUsecase: sl<UpdatePasswordUsecase>(),
            logoutUsecase: sl<LogoutUsecase>(),
          ),
        ),
        BlocProvider(
          create: (_) => OnboardingBloc(
            getStatus: sl<GetOnboardingStatusUsecase>(),
            setShown: sl<SetOnboardingShownUsecase>(),
          ),
        ),
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => sl<LocaleCubit>()),
        BlocProvider(create: (_) => sl<HighlightBloc>()),
        BlocProvider(create: (_) => sl<ChatBloc>()),
        BlocProvider(create: (_) => sl<SavedPlayersBloc>()),
        BlocProvider(create: (_) => sl<InternetConnectionCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: state.themeMode,
                locale: localeState.locale,
                supportedLocales: LocaleCubit.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  // Material / Cupertino don't ship Oromo translations. The
                  // fallback delegates below force their `en_US` data for any
                  // locale the global delegates don't support, so AppBars,
                  // dialogs, date pickers, etc. still resolve.
                  _FallbackMaterialDelegate(),
                  _FallbackCupertinoDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: BlocBuilder<OnboardingBloc, OnboardingState>(
                  builder: (context, onboardingState) {
                    if (onboardingState is OnboardingNotShown) {
                      return const OnboardingPage();
                    }
                    return const MainPage();
                  },
                ),
              );
            },
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
  // Player tabs: 0=Highlights, 1=Search, 2=Chat, 3=Profile
  // Scout tabs:  0=Highlights, 1=Search, 2=Saved, 3=Chat, 4=Profile
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(CheckAuthStatus());
      }
    });
  }

  Widget _pageForTab(bool isScout) {
    final key = _tabKey(_selectedTab, isScout);
    switch (key) {
      case _Tab.highlights:
        return const HighlightFeedPage();
      case _Tab.search:
        return BlocProvider(
          create: (_) =>
              sl<PlayerSearchBloc>()..add(const PlayerSearchLoadFeatured()),
          child: const PlayersSearchPage(),
        );
      case _Tab.saved:
        return const SavedPlayersPage();
      case _Tab.chat:
        return const ChatListPage();
      case _Tab.profile:
        return const CurrentUserProfilePage(embeddedInShell: true);
    }
  }

  _Tab _tabKey(int index, bool isScout) {
    if (isScout) {
      switch (index) {
        case 0:
          return _Tab.highlights;
        case 1:
          return _Tab.search;
        case 2:
          return _Tab.saved;
        case 3:
          return _Tab.chat;
        case 4:
          return _Tab.profile;
      }
      return _Tab.highlights;
    }
    switch (index) {
      case 0:
        return _Tab.highlights;
      case 1:
        return _Tab.search;
      case 2:
        return _Tab.chat;
      case 3:
        return _Tab.profile;
    }
    return _Tab.highlights;
  }

  void _onTabTapped(int index) {
    setState(() => _selectedTab = index);
  }

  List<_FancyNavItem> _navItems(AppLocalizations l, bool isScout) {
    final highlights = _FancyNavItem(
      icon: Icons.play_circle_outline_rounded,
      activeIcon: Icons.play_circle_rounded,
      label: l.navHighlights,
    );
    final search = _FancyNavItem(
      icon: Icons.search_rounded,
      activeIcon: Icons.search_rounded,
      label: l.navSearch,
    );
    final saved = _FancyNavItem(
      icon: Icons.bookmark_outline_rounded,
      activeIcon: Icons.bookmark_rounded,
      label: l.navSaved,
    );
    final chat = _FancyNavItem(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: l.navChat,
    );
    final profile = _FancyNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: l.navProfile,
    );
    if (isScout) {
      return [highlights, search, saved, chat, profile];
    }
    return [highlights, search, chat, profile];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is! AuthAuthenticated && _selectedTab != 0) {
          setState(() => _selectedTab = 0);
        }
        if (state is AuthAuthenticated) {
          sl<ChatSocketService>().connect();
          if (state.user.role.toLowerCase() == 'scout') {
            context
                .read<SavedPlayersBloc>()
                .add(const SavedPlayersLoaded());
          }
        } else {
          sl<ChatSocketService>().disconnect();
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final authed = authState is AuthAuthenticated;
          final isScout = authed &&
              (authState).user.role.toLowerCase() == 'scout';
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final navItems = _navItems(AppLocalizations.of(context), isScout);
          final maxIndex = navItems.length - 1;

          return Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: authed
                      ? _pageForTab(isScout)
                      : const HighlightFeedPage(),
                ),
                // DIAG: overlay temporarily disabled to isolate the
                // "blank screen when online" bug. Restore once confirmed.
                // BlocBuilder<InternetConnectionCubit, InternetConnectionState>(
                //   builder: (context, connectionState) {
                //     if (connectionState.isConnected) {
                //       return const SizedBox.shrink();
                //     }
                //     return Center(
                //       child: ConstrainedBox(
                //         constraints: const BoxConstraints(maxWidth: 320),
                //         child: const NoInternetCard(),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
            bottomNavigationBar: authed
                ? _FancyBottomNav(
                    items: navItems,
                    currentIndex: _selectedTab.clamp(0, maxIndex),
                    onTap: _onTabTapped,
                    isDark: isDark,
                  )
                : null,
          );
        },
      ),
    );
  }
}

enum _Tab { highlights, search, saved, chat, profile }

class _FancyNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _FancyNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _FancyBottomNav extends StatelessWidget {
  final List<_FancyNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _FancyBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  static const _green = AppColors.primaryGreen;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF0E0E16) : Colors.white;
    final inactive = isDark
        ? Colors.white.withOpacity(0.55)
        : AppColors.lightText.withOpacity(0.55);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final slotWidth = constraints.maxWidth / items.length;
              const underlineWidth = 22.0;
              return Stack(
                children: [
                  Row(
                    children: List.generate(items.length, (i) {
                      final item = items[i];
                      final selected = i == currentIndex;
                      final color = selected ? _green : inactive;
                      return Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => onTap(i),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  selected ? item.activeIcon : item.icon,
                                  size: 24,
                                  color: color,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    bottom: 0,
                    left: slotWidth * currentIndex +
                        (slotWidth - underlineWidth) / 2,
                    child: Container(
                      width: underlineWidth,
                      height: 3,
                      decoration: BoxDecoration(
                        color: _green,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _green.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, -1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Loads `en_US` Material localizations for any locale Material doesn't
/// natively support (e.g. Oromo). Must be listed *before*
/// `GlobalMaterialLocalizations.delegate` so it takes priority for these
/// locales while leaving English/Amharic etc. to the global delegate.
class _FallbackMaterialDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialDelegate();

  static const _supported = {'om'};

  @override
  bool isSupported(Locale locale) => _supported.contains(locale.languageCode);

  @override
  Future<MaterialLocalizations> load(Locale _) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('en', 'US'));

  @override
  bool shouldReload(_FallbackMaterialDelegate old) => false;
}

class _FallbackCupertinoDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _FallbackCupertinoDelegate();

  static const _supported = {'om'};

  @override
  bool isSupported(Locale locale) => _supported.contains(locale.languageCode);

  @override
  Future<CupertinoLocalizations> load(Locale _) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('en', 'US'));

  @override
  bool shouldReload(_FallbackCupertinoDelegate old) => false;
}
