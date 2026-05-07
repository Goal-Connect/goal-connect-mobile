import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Core ──────────────────────────────────────────────────────────────────────
import 'core/constants/api_constants.dart';
import 'core/network/api_logging_interceptor.dart';
import 'core/network/auth_interceptor.dart';
import 'core/theme/theme_cubit.dart';

// ── Auth ──────────────────────────────────────────────────────────────────────
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/datasources/auth_token_local_datasource.dart';
import 'features/auth/data/datasources/auth_user_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/create_scout_account_usecase.dart';
import 'features/auth/domain/usecases/get_cached_user_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/update_password_usecase.dart';

// ── Onboarding ────────────────────────────────────────────────────────────────
import 'features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'features/onboarding/domain/repositories/onboarding_repository.dart';
import 'features/onboarding/domain/usecases/get_onboarding_status_usecase.dart';
import 'features/onboarding/domain/usecases/set_onboarding_shown_usecase.dart';

// ── Highlights ────────────────────────────────────────────────────────────────
import 'features/highlights/data/datasources/highlight_remote_datasource.dart';
import 'features/highlights/data/repositories/highlight_repository_impl.dart';
import 'features/highlights/domain/repositories/highlight_repository.dart';
import 'features/highlights/domain/usecases/delete_highlight_usecase.dart';
import 'features/highlights/domain/usecases/get_highlights_feed_usecase.dart';
import 'features/highlights/domain/usecases/get_player_highlights_usecase.dart';
import 'features/highlights/domain/usecases/upload_highlight_usecase.dart';
import 'features/highlights/domain/usecases/toggle_like_highlight_usecase.dart';
import 'features/highlights/domain/usecases/update_highlight_usecase.dart';
import 'features/highlights/presentation/bloc/highlight_bloc.dart';

// ── Comments (inside highlights) ──────────────────────────────────────────────
import 'features/highlights/data/datasources/comment_remote_datasource.dart';
import 'features/highlights/data/repositories/comment_repository_impl.dart';
import 'features/highlights/domain/repositories/comment_repository.dart';
import 'features/highlights/domain/usecases/get_comments_usecase.dart';
import 'features/highlights/domain/usecases/add_comment_usecase.dart';
import 'features/highlights/domain/usecases/delete_comment_usecase.dart';
import 'features/highlights/domain/usecases/toggle_comment_like_usecase.dart';
import 'features/highlights/presentation/bloc/comment_bloc.dart';

// ── Chat ──────────────────────────────────────────────────────────────────────
import 'features/chat/data/datasources/chat_remote_datasource.dart';
import 'features/chat/data/datasources/conversation_local_datasource.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/data/services/chat_socket_service.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/domain/usecases/get_conversations_usecase.dart';
import 'features/chat/domain/usecases/get_messages_usecase.dart';
import 'features/chat/domain/usecases/send_message_usecase.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';

// ── Profile (Player Profile) ─────────────────────────────────────────────────
import 'features/profile/data/datasources/player_profile_remote_datasource.dart';
import 'features/profile/data/repositories/player_profile_repository_impl.dart';
import 'features/profile/domain/repositories/player_profile_repository.dart';
import 'features/profile/domain/usecases/get_player_profile_usecase.dart';
import 'features/profile/domain/usecases/toggle_follow_usecase.dart';
import 'features/profile/domain/usecases/list_players_usecase.dart';
import 'features/profile/presentation/bloc/player_profile_bloc.dart';
import 'features/profile/presentation/bloc/player_search_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  // ── Shared Preferences ──────────────────────────────────────────────────────
  sl.registerLazySingleton(() => sharedPreferences);

  // ── Theme ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => ThemeCubit(prefs: sl()));

  // ── Auth ────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthTokenLocalDataSource>(
    () => AuthTokenLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthUserLocalDataSource>(
    () => AuthUserLocalDataSourceImpl(prefs: sl()),
  );
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.add(AuthInterceptor(sl()));
    dio.interceptors.add(ApiLoggingInterceptor());
    return dio;
  });
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorage: sl(),
      userCache: sl(),
    ),
  );
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => CreateScoutAccountUsecase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUsecase(sl()));
  sl.registerLazySingleton(() => GetCachedUserUsecase(sl()));
  sl.registerLazySingleton(() => UpdatePasswordUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));

  // ── Onboarding ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetOnboardingStatusUsecase(sl()));
  sl.registerLazySingleton(() => SetOnboardingShownUsecase(sl()));

  // ── Highlights ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<HighlightRemoteDataSource>(
    () => HighlightRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<HighlightRepository>(
    () => HighlightRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => UploadHighlightUsecase(sl()));
  sl.registerLazySingleton(() => DeleteHighlightUsecase(sl()));
  sl.registerLazySingleton(() => UpdateHighlightUsecase(sl()));
  sl.registerLazySingleton(() => GetHighlightsFeedUsecase(sl()));
  sl.registerLazySingleton(() => GetPlayerHighlightsUsecase(sl()));
  sl.registerLazySingleton(() => ToggleLikeHighlightUsecase(sl()));
  sl.registerFactory(
    () => HighlightBloc(
      uploadHighlight: sl(),
      deleteHighlight: sl(),
      getHighlightsFeed: sl(),
      getPlayerHighlights: sl(),
    ),
  );

  // ── Comments (inside highlights feature) ────────────────────────────────────
  sl.registerLazySingleton<CommentRemoteDataSource>(
    () => CommentRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<CommentRepository>(
    () => CommentRepositoryImpl(
      remoteDataSource: sl(),
      userCache: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetCommentsUsecase(sl()));
  sl.registerLazySingleton(() => AddCommentUsecase(sl()));
  sl.registerLazySingleton(() => DeleteCommentUsecase(sl()));
  sl.registerLazySingleton(() => ToggleCommentLikeUsecase(sl()));
  sl.registerFactory(
    () => CommentBloc(
      getComments: sl(),
      addComment: sl(),
      deleteComment: sl(),
      toggleCommentLike: sl(),
    ),
  );

  // ── Chat ─────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ConversationLocalDataSource>(
    () => ConversationLocalDataSourceImpl(prefs: sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ChatSocketService>(
    () => ChatSocketService(tokens: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl(),
      conversationLocal: sl(),
      userLocal: sl(),
      socketService: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetConversationsUsecase(sl()));
  sl.registerLazySingleton(() => GetMessagesUsecase(sl()));
  sl.registerLazySingleton(() => SendMessageUsecase(sl()));
  sl.registerLazySingleton<ChatBloc>(
    () => ChatBloc(
      getConversations: sl(),
      getMessages: sl(),
      sendMessage: sl(),
      getCachedUser: sl(),
      chatRepository: sl(),
      socketService: sl(),
    ),
  );

  // ── Player Profile ────────────────────────────────────────────────────────
  sl.registerLazySingleton<PlayerProfileRemoteDataSource>(
    () => PlayerProfileRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<PlayerProfileRepository>(
    () => PlayerProfileRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetPlayerProfileUsecase(sl()));
  sl.registerLazySingleton(() => ToggleFollowUsecase(sl()));
  sl.registerLazySingleton(() => ListPlayersUsecase(sl()));
  sl.registerFactory(
    () => PlayerProfileBloc(
      getPlayerProfile: sl(),
      toggleFollow: sl(),
    ),
  );
  sl.registerFactory(
    () => PlayerSearchBloc(listPlayers: sl()),
  );
}
