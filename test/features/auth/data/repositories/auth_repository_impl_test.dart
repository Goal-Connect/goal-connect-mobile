import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:goal_connect/features/auth/data/models/scout_account_registration_model.dart';
import 'package:goal_connect/features/auth/data/models/user_model.dart';
import 'package:goal_connect/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:goal_connect/features/auth/domain/entities/scout_account_registration.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemote;

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

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: mockRemote);
  });

  setUpAll(() {
    registerFallbackValue(
      ScoutAccountRegistrationModel.fromEntity(tRegistration),
    );
  });

  group('createScoutAccount', () {
    test('returns Right(user) when remote succeeds', () async {
      when(() => mockRemote.createScoutAccount(any()))
          .thenAnswer((_) async => tUserModel);

      final result = await repository.createScoutAccount(tRegistration);

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('expected Right'),
        (user) => expect(user, tUserModel),
      );
      verify(() => mockRemote.createScoutAccount(any())).called(1);
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
    });
  });
}
