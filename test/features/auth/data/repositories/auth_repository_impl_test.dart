import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:goal_connect/features/auth/data/datasources/auth_token_local_datasource.dart';
import 'package:goal_connect/features/auth/data/datasources/auth_user_local_datasource.dart';
import 'package:goal_connect/features/auth/data/models/auth_remote_session.dart';
import 'package:goal_connect/features/auth/data/models/scout_account_registration_model.dart';
import 'package:goal_connect/features/auth/data/models/user_model.dart';
import 'package:goal_connect/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:goal_connect/features/auth/domain/entities/scout_account_registration.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthTokenLocalDataSource extends Mock
    implements AuthTokenLocalDataSource {}

class MockAuthUserLocalDataSource extends Mock
    implements AuthUserLocalDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemote;
  late MockAuthTokenLocalDataSource mockToken;
  late MockAuthUserLocalDataSource mockUserCache;

  final tRegistration = ScoutAccountRegistration(
    fullName: 'Jane Scout',
    email: 'jane@example.com',
    password: 'secret12',
    licencePhotoPath: '/tmp/licence.jpg',
    nationalIdFanNo: 'FAN-12345',
    phoneNumber: '+251911000000',
    organizationName: 'FC United',
    country: 'Ethiopia',
  );

  final tUserModel = UserModel(
    id: 'scout_1',
    email: 'jane@example.com',
    role: 'scout',
    username: 'jane_scout',
    profileImage: '/tmp/licence.jpg',
    position: 'Scout',
    age: 30,
    country: 'Ethiopia',
  );

  final tSession = AuthRemoteSession(user: tUserModel, token: 'jwt-token');

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockToken = MockAuthTokenLocalDataSource();
    mockUserCache = MockAuthUserLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemote,
      tokenStorage: mockToken,
      userCache: mockUserCache,
    );
    when(() => mockToken.saveToken(any())).thenAnswer((_) async {});
    when(
      () => mockUserCache.saveUserAndProfile(
        user: any(named: 'user'),
        profileJson: any(named: 'profileJson'),
      ),
    ).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue('');
    registerFallbackValue(
      ScoutAccountRegistrationModel.fromEntity(tRegistration),
    );
    registerFallbackValue(tUserModel);
  });

  group('createScoutAccount', () {
    test('returns Right(user) when remote succeeds and saves token + cache',
        () async {
      when(() => mockRemote.createScoutAccount(any()))
          .thenAnswer((_) async => tSession);

      final result = await repository.createScoutAccount(tRegistration);

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('expected Right'),
        (user) => expect(user, tUserModel),
      );
      verify(() => mockRemote.createScoutAccount(any())).called(1);
      verify(() => mockToken.saveToken('jwt-token')).called(1);
      verify(
        () => mockUserCache.saveUserAndProfile(
          user: tUserModel,
          profileJson: null,
        ),
      ).called(1);
    });

    test('returns Left(AuthFailure) when remote throws', () async {
      when(() => mockRemote.createScoutAccount(any()))
          .thenThrow(Exception('network'));

      final result = await repository.createScoutAccount(tRegistration);

      expect(result, isA<Left>());
      result.fold(
        (f) => expect(f, isA<AuthFailure>()),
        (_) => fail('expected Left'),
      );
      verifyNever(() => mockToken.saveToken(any()));
      verifyNever(
        () => mockUserCache.saveUserAndProfile(
          user: any(named: 'user'),
          profileJson: any(named: 'profileJson'),
        ),
      );
    });
  });

  group('getCurrentUser', () {
    test('caches user and profile on success', () async {
      when(() => mockRemote.getCurrentUser()).thenAnswer(
        (_) async => (tUserModel, '{"x":1}'),
      );

      final result = await repository.getCurrentUser();

      expect(result, isA<Right>());
      verify(
        () => mockUserCache.saveUserAndProfile(
          user: tUserModel,
          profileJson: '{"x":1}',
        ),
      ).called(1);
    });

    test('clears session on 401', () async {
      when(() => mockRemote.getCurrentUser()).thenThrow(
        AuthApiException('Unauthorized', statusCode: 401),
      );
      when(() => mockToken.clearToken()).thenAnswer((_) async {});
      when(() => mockUserCache.clear()).thenAnswer((_) async {});

      final result = await repository.getCurrentUser();

      expect(result, isA<Left>());
      verify(() => mockToken.clearToken()).called(1);
      verify(() => mockUserCache.clear()).called(1);
    });
  });

  group('updatePassword', () {
    test('persists new session', () async {
      when(
        () => mockRemote.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => tSession);

      final result = await repository.updatePassword(
        currentPassword: 'a',
        newPassword: 'b',
      );

      expect(result, isA<Right>());
      verify(() => mockToken.saveToken('jwt-token')).called(1);
      verify(
        () => mockUserCache.saveUserAndProfile(
          user: tUserModel,
          profileJson: null,
        ),
      ).called(1);
    });
  });

  group('logout', () {
    test('clears token and cache', () async {
      when(() => mockToken.clearToken()).thenAnswer((_) async {});
      when(() => mockUserCache.clear()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result, const Right(null));
      verify(() => mockToken.clearToken()).called(1);
      verify(() => mockUserCache.clear()).called(1);
    });
  });
}
