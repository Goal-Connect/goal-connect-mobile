import 'package:equatable/equatable.dart';
import 'package:goal_connect/features/auth/domain/entities/scout_account_registration.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class CreateScoutAccountRequested extends AuthEvent {
  final ScoutAccountRegistration registration;

  const CreateScoutAccountRequested(this.registration);

  @override
  List<Object?> get props => [
        registration.fullName,
        registration.email,
        registration.password,
        registration.licencePhotoPath,
        registration.nationalIdFanNo,
        registration.phoneNumber,
        registration.organizationName,
        registration.country,
        registration.yearsExperience,
      ];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class UpdatePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class RegisterRequested extends AuthEvent {}
