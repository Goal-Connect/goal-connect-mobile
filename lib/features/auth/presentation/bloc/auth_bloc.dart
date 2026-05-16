import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/error/fialures.dart' as fail;
import 'package:goal_connect/features/auth/domain/entities/user.dart';
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

    await result.fold<Future<void>>(
      (failure) async {
        if (failure is fail.AuthFailure &&
            (failure.message ?? '').isNotEmpty) {
          emit(AuthFailure(failure.message!));
        } else {
          emit(const AuthFailure('Login failed. Please try again.'));
        }
      },
      (user) async {
        if (_requiresApproval(user)) {
          await _signOutForPending(emit, user, justRegistered: false);
          return;
        }
        emit(AuthAuthenticated(user));
        await _hydrateProfile(emit);
      },
    );
  }

  Future<void> _hydrateProfile(Emitter<AuthState> emit) async {
    final me = await getCurrentUserUsecase();
    await me.fold<Future<void>>(
      (_) async {},
      (data) async {
        if (_requiresApproval(data.user)) {
          await _signOutForPending(emit, data.user, justRegistered: false);
          return;
        }
        emit(AuthAuthenticated(data.user, profile: data.profile));
      },
    );
  }

  bool _requiresApproval(User user) {
    return user.role.toLowerCase() == 'scout' && !user.isApproved;
  }

  Future<void> _signOutForPending(
    Emitter<AuthState> emit,
    User user, {
    required bool justRegistered,
  }) async {
    await logoutUsecase();
    emit(AuthPendingApproval(
      email: user.email,
      role: user.role,
      justRegistered: justRegistered,
    ));
  }

  Future<void> _onCreateScoutAccountRequested(
    CreateScoutAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await createScoutAccountUsecase(event.registration);

    await result.fold<Future<void>>(
      (failure) async {
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
      (user) async {
        if (_requiresApproval(user)) {
          await _signOutForPending(emit, user, justRegistered: true);
          return;
        }
        emit(AuthAuthenticated(user));
        await _hydrateProfile(emit);
      },
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
        if (cached == null) {
          emit(AuthUnauthenticated());
          return;
        }
        if (_requiresApproval(cached.user)) {
          await _signOutForPending(emit, cached.user, justRegistered: false);
          return;
        }
        emit(AuthAuthenticated(cached.user, profile: cached.profile));
      },
      (data) async {
        if (_requiresApproval(data.user)) {
          await _signOutForPending(emit, data.user, justRegistered: false);
          return;
        }
        emit(AuthAuthenticated(data.user, profile: data.profile));
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
    await result.fold<Future<void>>(
      (failure) async {
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
      (user) async {
        emit(AuthAuthenticated(user));
        await _hydrateProfile(emit);
      },
    );
  }
}
