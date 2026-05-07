import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/theme/app_colors.dart';
import 'package:goal_connect/core/theme/theme_cubit.dart';
import 'package:goal_connect/core/theme/theme_state.dart';
import 'package:goal_connect/core/theme/app_theme.dart';
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
import 'package:goal_connect/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:goal_connect/features/chat/presentation/pages/chat_list_page.dart';
import 'package:goal_connect/features/profile/presentation/pages/players_search_page.dart';
import 'package:goal_connect/features/highlights/presentation/pages/upload_highlight_page.dart';
import 'package:goal_connect/features/highlights/presentation/bloc/highlight_event.dart';
import 'package:goal_connect/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:goal_connect/features/onboarding/domain/usecases/get_onboarding_status_usecase.dart';
import 'package:goal_connect/features/onboarding/domain/usecases/set_onboarding_shown_usecase.dart';
import 'injection_container.dart';
import 'package:goal_connect/features/profile/presentation/pages/player_profile_page.dart';
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
  // Tab order: 0=Highlights, 1=Search, 2=Chat, 3=Profile
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

  Widget _pageForTab() {
    switch (_selectedTab) {
      case 0:
        return const HighlightFeedPage();
      case 1:
        return BlocProvider(
          create: (_) => sl<PlayerSearchBloc>()
            ..add(const PlayerSearchLoadFeatured()),
          child: const PlayersSearchPage(),
        );
      case 2:
        return const ChatListPage();
      case 3:
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final playerId = state is AuthAuthenticated
                ? (state.user.playerProfileId ?? state.user.id)
                : '';
            return BlocProvider(
              key: ValueKey<String>(playerId),
              create: (_) {
                final bloc = sl<HighlightBloc>();
                if (playerId.isNotEmpty) {
                  bloc.add(GetPlayerHighlightsEvent(playerId));
                }
                return bloc;
              },
              child: const ProfilePage(),
            );
          },
        );
      default:
        return const HighlightFeedPage();
    }
  }

  void _onTabTapped(int index) {
    setState(() => _selectedTab = index);
  }

  static const _navItemsFull = [
    BottomNavigationBarItem(
      icon: Icon(Icons.play_circle_outline_rounded),
      activeIcon: Icon(Icons.play_circle_rounded),
      label: 'Highlights',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search_rounded),
      activeIcon: Icon(Icons.search_rounded),
      label: 'Search',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline_rounded),
      activeIcon: Icon(Icons.chat_bubble_rounded),
      label: 'Chat',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_rounded),
      activeIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is! AuthAuthenticated && _selectedTab != 0) {
          setState(() => _selectedTab = 0);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final authed = authState is AuthAuthenticated;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Scaffold(
            body: authed ? _pageForTab() : const HighlightFeedPage(),
            bottomNavigationBar: authed
                ? BottomNavigationBar(
                    currentIndex: _selectedTab.clamp(0, 3),
                    onTap: _onTabTapped,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    selectedItemColor: AppColors.primaryGreen,
                    unselectedItemColor: AppColors.gray,
                    showUnselectedLabels: true,
                    items: _navItemsFull,
                  )
                : null,
          );
        },
      ),
    );
  }
}




class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
        final profileId =
            state.user.playerProfileId ?? state.user.id;
        return Scaffold(
          body: PlayerProfilePage(
            playerId: profileId,
            embeddedInShell: true,
            provideHighlightBloc: false,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => UploadHighlightPage(playerId: profileId),
                ),
              );
            },
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.black,
            icon: const Icon(Icons.video_call_rounded),
            label: const Text('Upload highlight'),
          ),
        );
      },
    );
  }
}
