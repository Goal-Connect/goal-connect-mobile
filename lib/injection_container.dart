import 'package:get_it/get_it.dart';
import 'package:goal_connect/features/highlights/data/datasources/highlight_remote_datasource.dart';
import 'package:goal_connect/features/highlights/data/repositories/highlight_repository_impl.dart';
import 'package:goal_connect/features/highlights/domain/repositories/highlight_repository.dart';
import 'package:goal_connect/features/highlights/domain/usecases/delete_highlight_usecase.dart';
import 'package:goal_connect/features/highlights/domain/usecases/get_highlights_feed_usecase.dart';
import 'package:goal_connect/features/highlights/domain/usecases/get_player_highlights_usecase.dart';
import 'package:goal_connect/features/highlights/domain/usecases/upload_highlight_usecase.dart';
import 'package:goal_connect/features/highlights/presentation/bloc/highlight_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'features/onboarding/domain/repositories/onboarding_repository.dart';
import 'features/onboarding/domain/usecases/get_onboarding_status_usecase.dart';
import 'features/onboarding/domain/usecases/set_onboarding_shown_usecase.dart';
import 'core/theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => ThemeCubit(prefs: sl()));

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => MockAuthRemoteDataSource(),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => LoginUsecase(sl()));

  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetOnboardingStatusUsecase(sl()));

  sl.registerLazySingleton(() => SetOnboardingShownUsecase(sl()));

  sl.registerLazySingleton<HighlightRemoteDataSource>(
    () => MockHighlightRemoteDataSource(),
  );

  sl.registerLazySingleton<HighlightRepository>(
    () => HighlightRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => UploadHighlightUsecase(sl()));

  sl.registerLazySingleton(() => DeleteHighlightUsecase(sl()));

  sl.registerLazySingleton(() => GetHighlightsFeedUsecase(sl()));

  sl.registerLazySingleton(() => GetPlayerHighlightsUsecase(sl()));

  sl.registerFactory(
    () => HighlightBloc(
      uploadHighlight: sl(),
      deleteHighlight: sl(),
      getHighlightsFeed: sl(),
      getPlayerHighlights: sl(),
    ),
  );
}
