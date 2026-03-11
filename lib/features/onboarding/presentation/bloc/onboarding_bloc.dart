import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/features/onboarding/domain/usecases/get_onboarding_status_usecase.dart';
import 'package:goal_connect/features/onboarding/domain/usecases/set_onboarding_shown_usecase.dart';
import 'package:goal_connect/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:goal_connect/features/onboarding/presentation/bloc/onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingStatusUsecase getStatus;
  final SetOnboardingShownUsecase setShown;

  OnboardingBloc({required this.getStatus, required this.setShown})
    : super(OnboardingInitial()) {
    on<CheckOnboardingStatus>((event, emit) async {
      emit(OnboardingLoading());

      final result = await getStatus();

      result.fold(
        (failure) => emit(OnboardingError()),
        (info) =>
            emit(info.isShown ? OnboardingCompleted() : OnboardingNotShown()),
      );
    });

    on<MarkOnboardingShown>((event, emit) async {
      await setShown();
      emit(OnboardingCompleted());
    });

    add(CheckOnboardingStatus());
  }
}
