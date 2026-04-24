import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/auth/domain/entities/scout_account_registration.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';
import 'package:goal_connect/features/auth/domain/repositories/auth_repository.dart';
import 'package:goal_connect/features/auth/domain/usecases/create_scout_account_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late CreateScoutAccountUsecase usecase;
  late MockAuthRepository mockRepository;

  final tValid = ScoutAccountRegistration(
    fullName: 'Jane Scout',
    email: 'jane@example.com',
    password: 'secret12',
    licencePhotoPath: '/tmp/licence.jpg',
    nationalIdFanNo: 'FAN-12345',
    phoneNumber: '+251911000000',
    organizationName: 'FC United',
    country: 'Ethiopia',
    yearsExperience: 5,
  );

  final tUser = User(
    id: 'scout_1',
    email: 'jane@example.com',
    role: 'scout',
    username: 'jane_scout',
    profileImage: 'https://example.com/p.jpg',
    position: 'Scout',
    age: 30,
    country: 'Ethiopia',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = CreateScoutAccountUsecase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(tValid);
  });

  test('returns Right(user) when registration is valid and repository succeeds',
      () async {
    when(() => mockRepository.createScoutAccount(any()))
        .thenAnswer((_) async => Right(tUser));

    final result = await usecase(tValid);

    expect(result, Right(tUser));
    verify(() => mockRepository.createScoutAccount(tValid)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns Left(ValidationFailure) without calling repository when fullName is empty',
      () async {
    final bad = ScoutAccountRegistration(
      fullName: '   ',
      email: 'jane@example.com',
      password: 'secret12',
      licencePhotoPath: '/p',
      nationalIdFanNo: 'FAN-1',
      phoneNumber: '+1',
      organizationName: 'Org',
      country: 'ET',
    );

    final result = await usecase(bad);

    expect(result, isA<Left>());
    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('expected Left'),
    );
    verifyNever(() => mockRepository.createScoutAccount(any()));
  });

  test('returns Left(ValidationFailure) when email has no @', () async {
    final bad = ScoutAccountRegistration(
      fullName: 'Jane',
      email: 'notanemail',
      password: 'secret12',
      licencePhotoPath: '/p',
      nationalIdFanNo: 'FAN-1',
      phoneNumber: '+1',
      organizationName: 'Org',
      country: 'ET',
    );

    final result = await usecase(bad);

    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('expected Left'),
    );
    verifyNever(() => mockRepository.createScoutAccount(any()));
  });

  test('returns Left(ValidationFailure) when password is shorter than 6 characters',
      () async {
    final bad = ScoutAccountRegistration(
      fullName: 'Jane',
      email: 'j@e.com',
      password: '12345',
      licencePhotoPath: '/p',
      nationalIdFanNo: 'FAN-1',
      phoneNumber: '+1',
      organizationName: 'Org',
      country: 'ET',
    );

    final result = await usecase(bad);

    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('expected Left'),
    );
    verifyNever(() => mockRepository.createScoutAccount(any()));
  });

  test('returns Left(ValidationFailure) when phone number is empty',
      () async {
    final bad = ScoutAccountRegistration(
      fullName: 'Jane',
      email: 'j@e.com',
      password: '123456',
      licencePhotoPath: '/p',
      nationalIdFanNo: 'FAN-1',
      phoneNumber: '   ',
      organizationName: 'Org',
      country: 'ET',
    );

    final result = await usecase(bad);

    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('expected Left'),
    );
    verifyNever(() => mockRepository.createScoutAccount(any()));
  });

  test('forwards Left(AuthFailure) from repository', () async {
    when(() => mockRepository.createScoutAccount(any()))
        .thenAnswer((_) async => Left(AuthFailure()));

    final result = await usecase(tValid);

    expect(result, isA<Left>());
    result.fold(
      (f) => expect(f, isA<AuthFailure>()),
      (_) => fail('expected Left'),
    );
  });
}
