import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/error/fialures.dart' as fail;
import 'package:goal_connect/features/auth/domain/entities/academy.dart';
import 'package:goal_connect/features/auth/domain/entities/player_application.dart';
import 'package:goal_connect/features/auth/domain/usecases/list_academies_usecase.dart';
import 'package:goal_connect/features/auth/domain/usecases/submit_player_application_usecase.dart';

// ── Events ────────────────────────────────────────────────────────────────

abstract class PlayerApplicationEvent extends Equatable {
  const PlayerApplicationEvent();
  @override
  List<Object?> get props => [];
}

class AcademiesRequested extends PlayerApplicationEvent {
  final String? search;
  const AcademiesRequested({this.search});
  @override
  List<Object?> get props => [search];
}

class PlayerApplicationSubmitted extends PlayerApplicationEvent {
  final PlayerApplication application;
  const PlayerApplicationSubmitted(this.application);
  @override
  List<Object?> get props => [
        application.fullName,
        application.email,
        application.nationalIdFanNo,
        application.age,
        application.phoneNumber,
        application.address,
        application.country,
        application.region,
        application.primaryPosition,
        application.secondaryPosition,
        application.academyId,
        application.additionalInfo,
      ];
}

// ── State ─────────────────────────────────────────────────────────────────

enum PlayerApplicationStatus {
  initial,
  loadingAcademies,
  ready,
  submitting,
  submitted,
  failure,
}

class PlayerApplicationState extends Equatable {
  final PlayerApplicationStatus status;
  final List<Academy> academies;
  final PlayerApplicationReceipt? receipt;
  final String? errorMessage;

  const PlayerApplicationState({
    this.status = PlayerApplicationStatus.initial,
    this.academies = const [],
    this.receipt,
    this.errorMessage,
  });

  PlayerApplicationState copyWith({
    PlayerApplicationStatus? status,
    List<Academy>? academies,
    PlayerApplicationReceipt? receipt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PlayerApplicationState(
      status: status ?? this.status,
      academies: academies ?? this.academies,
      receipt: receipt ?? this.receipt,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, academies, receipt, errorMessage];
}

// ── Bloc ──────────────────────────────────────────────────────────────────

class PlayerApplicationBloc
    extends Bloc<PlayerApplicationEvent, PlayerApplicationState> {
  final ListAcademiesUsecase listAcademies;
  final SubmitPlayerApplicationUsecase submitApplication;

  PlayerApplicationBloc({
    required this.listAcademies,
    required this.submitApplication,
  }) : super(const PlayerApplicationState()) {
    on<AcademiesRequested>(_onAcademiesRequested);
    on<PlayerApplicationSubmitted>(_onSubmitted);
  }

  Future<void> _onAcademiesRequested(
    AcademiesRequested event,
    Emitter<PlayerApplicationState> emit,
  ) async {
    emit(state.copyWith(
      status: PlayerApplicationStatus.loadingAcademies,
      clearError: true,
    ));
    final result = await listAcademies(search: event.search);
    result.fold(
      (failure) => emit(state.copyWith(
        status: PlayerApplicationStatus.failure,
        errorMessage: _messageFor(failure, fallback: 'Could not load academies'),
      )),
      (list) => emit(state.copyWith(
        status: PlayerApplicationStatus.ready,
        academies: list,
        clearError: true,
      )),
    );
  }

  Future<void> _onSubmitted(
    PlayerApplicationSubmitted event,
    Emitter<PlayerApplicationState> emit,
  ) async {
    emit(state.copyWith(
      status: PlayerApplicationStatus.submitting,
      clearError: true,
    ));
    final result = await submitApplication(event.application);
    result.fold(
      (failure) {
        if (failure is fail.ValidationFailure) {
          emit(state.copyWith(
            status: PlayerApplicationStatus.failure,
            errorMessage:
                'Please complete every required field with valid information.',
          ));
        } else {
          emit(state.copyWith(
            status: PlayerApplicationStatus.failure,
            errorMessage: _messageFor(
              failure,
              fallback: 'Could not submit your application',
            ),
          ));
        }
      },
      (receipt) => emit(state.copyWith(
        status: PlayerApplicationStatus.submitted,
        receipt: receipt,
        clearError: true,
      )),
    );
  }

  String _messageFor(fail.Failure failure, {required String fallback}) {
    if (failure is fail.AuthFailure &&
        (failure.message ?? '').isNotEmpty) {
      return failure.message!;
    }
    return fallback;
  }
}
