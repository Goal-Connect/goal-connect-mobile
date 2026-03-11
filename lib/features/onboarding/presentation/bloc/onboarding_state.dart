import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingNotShown extends OnboardingState {}

class OnboardingCompleted extends OnboardingState {}

class OnboardingError extends OnboardingState {}
