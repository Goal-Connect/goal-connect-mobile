import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckOnboardingStatus extends OnboardingEvent {}

class MarkOnboardingShown extends OnboardingEvent {}
