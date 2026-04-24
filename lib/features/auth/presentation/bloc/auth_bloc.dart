import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/error/fialures.dart' as fail;
import 'package:goal_connect/features/auth/domain/usecases/create_scout_account_usecase.dart';
import 'package:goal_connect/features/auth/domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;
  final CreateScoutAccountUsecase createScoutAccountUsecase;

  AuthBloc({
    required this.loginUsecase,
    required this.createScoutAccountUsecase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<CreateScoutAccountRequested>(_onCreateScoutAccountRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUsecase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) {
        if (failure is fail.AuthFailure &&
            (failure.message ?? '').isNotEmpty) {
          emit(AuthFailure(failure.message!));
        } else {
          emit(const AuthFailure('Login failed. Please try again.'));
        }
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onCreateScoutAccountRequested(
    CreateScoutAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await createScoutAccountUsecase(event.registration);

    result.fold(
      (failure) {
        if (failure is fail.ValidationFailure) {
          emit(const AuthFailure(
            'Please enter full name, email, password (at least 6 characters), phone number, and country.',
          ));
        } else if (failure is fail.AuthFailure &&
            (failure.message ?? '').isNotEmpty) {
          emit(AuthFailure(failure.message!));
        } else {
          emit(const AuthFailure('Could not create scout account'));
        }
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
