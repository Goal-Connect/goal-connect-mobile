import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/core/error/fialures.dart' as core;
import 'package:goal_connect/features/auth/domain/entities/scout_account_registration.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';
import 'package:goal_connect/features/auth/domain/usecases/create_scout_account_usecase.dart';
import 'package:goal_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_event.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockCreateScoutAccountUsecase extends Mock
    implements CreateScoutAccountUsecase {}

void main() {
  late MockLoginUsecase mockLogin;
  late MockCreateScoutAccountUsecase mockCreateScout;

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
    mockLogin = MockLoginUsecase();
    mockCreateScout = MockCreateScoutAccountUsecase();
  });

  setUpAll(() {
    registerFallbackValue(tRegistration);
  });

  AuthBloc buildBloc() => AuthBloc(
        loginUsecase: mockLogin,
        createScoutAccountUsecase: mockCreateScout,
      );

  group('CreateScoutAccountRequested', () {
    test('emits [AuthLoading, AuthAuthenticated] on success', () async {
      when(() => mockCreateScout(any()))
          .thenAnswer((_) async => Right(tUser));

      final bloc = buildBloc();
      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(CreateScoutAccountRequested(tRegistration));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<AuthLoading>(), isA<AuthAuthenticated>()]);
      expect((states[1] as AuthAuthenticated).user, tUser);

      await sub.cancel();
      await bloc.close();
    });

    test('emits [AuthLoading, AuthFailure] with validation message on ValidationFailure',
        () async {
      when(() => mockCreateScout(any()))
          .thenAnswer((_) async => Left(core.ValidationFailure()));

      final bloc = buildBloc();
      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(CreateScoutAccountRequested(tRegistration));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<AuthLoading>(), isA<AuthFailure>()]);
      expect(
        (states[1] as AuthFailure).message,
        'Please enter full name, email, password (at least 6 characters), phone number, and country.',
      );

      await sub.cancel();
      await bloc.close();
    });

    test('emits [AuthLoading, AuthFailure] with generic message on AuthFailure',
        () async {
      when(() => mockCreateScout(any()))
          .thenAnswer((_) async => Left(core.AuthFailure()));

      final bloc = buildBloc();
      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(CreateScoutAccountRequested(tRegistration));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<AuthLoading>(), isA<AuthFailure>()]);
      expect(
        (states[1] as AuthFailure).message,
        'Could not create scout account',
      );

      await sub.cancel();
      await bloc.close();
    });
  });

  group('LoginRequested', () {
    test('emits [AuthLoading, AuthAuthenticated] on success', () async {
      when(() => mockLogin(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(tUser));

      final bloc = buildBloc();
      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoginRequested(email: 'a@b.com', password: '123456'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<AuthLoading>(), isA<AuthAuthenticated>()]);

      await sub.cancel();
      await bloc.close();
    });
  });
}
