import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/error/fialures.dart' show ValidationFailure;
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
      (failure) => emit(AuthFailure('')),
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
        if (failure is ValidationFailure) {
          emit(const AuthFailure(
            'Fill all required fields, add a licence photo, and use a password of at least 6 characters.',
          ));
        } else {
          emit(const AuthFailure('Could not create scout account'));
        }
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
