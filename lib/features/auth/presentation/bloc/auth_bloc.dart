import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/error/fialures.dart' as fail;
import 'package:goal_connect/features/auth/domain/usecases/create_scout_account_usecase.dart';
import 'package:goal_connect/features/auth/domain/usecases/get_cached_user_usecase.dart';
import 'package:goal_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:goal_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:goal_connect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:goal_connect/features/auth/domain/usecases/update_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;
  final CreateScoutAccountUsecase createScoutAccountUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final GetCachedUserUsecase getCachedUserUsecase;
  final UpdatePasswordUsecase updatePasswordUsecase;
  final LogoutUsecase logoutUsecase;

  AuthBloc({
    required this.loginUsecase,
    required this.createScoutAccountUsecase,
    required this.getCurrentUserUsecase,
    required this.getCachedUserUsecase,
    required this.updatePasswordUsecase,
    required this.logoutUsecase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<CreateScoutAccountRequested>(_onCreateScoutAccountRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LogoutRequested>(_onLogoutRequested);
    on<UpdatePasswordRequested>(_onUpdatePasswordRequested);
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

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getCurrentUserUsecase();
    await result.fold<Future<void>>(
      (failure) async {
        final cached = await getCachedUserUsecase();
        if (cached != null) {
          emit(AuthAuthenticated(cached));
        } else {
          emit(AuthUnauthenticated());
        }
      },
      (user) async {
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await logoutUsecase();
    result.fold(
      (_) => emit(const AuthFailure('Could not sign out')),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onUpdatePasswordRequested(
    UpdatePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await updatePasswordUsecase(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );
    result.fold(
      (failure) {
        if (failure is fail.ValidationFailure) {
          emit(const AuthFailure(
            'Current password is required and new password must be at least 6 characters.',
          ));
        } else if (failure is fail.AuthFailure &&
            (failure.message ?? '').isNotEmpty) {
          emit(AuthFailure(failure.message!));
        } else {
          emit(const AuthFailure('Could not update password'));
        }
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
