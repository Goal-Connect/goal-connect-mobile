import 'package:goal_connect/features/auth/domain/entities/scout_account_registration.dart';

class ScoutAccountRegistrationModel extends ScoutAccountRegistration {
  const ScoutAccountRegistrationModel({
    required super.fullName,
    required super.email,
    required super.password,
    super.licencePhotoPath,
    required super.nationalIdFanNo,
    required super.phoneNumber,
    required super.organizationName,
    required super.country,
    super.yearsExperience,
  });

  factory ScoutAccountRegistrationModel.fromEntity(
    ScoutAccountRegistration entity,
  ) {
    return ScoutAccountRegistrationModel(
      fullName: entity.fullName,
      email: entity.email,
      password: entity.password,
      licencePhotoPath: entity.licencePhotoPath,
      nationalIdFanNo: entity.nationalIdFanNo,
      phoneNumber: entity.phoneNumber,
      organizationName: entity.organizationName,
      country: entity.country,
      yearsExperience: entity.yearsExperience,
    );
  }

  factory ScoutAccountRegistrationModel.fromJson(Map<String, dynamic> json) {
    return ScoutAccountRegistrationModel(
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      licencePhotoPath: json['licence_photo_path'] as String?,
      nationalIdFanNo: json['national_id_fan_no'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      organizationName: json['organization_name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      yearsExperience: json['years_experience'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'password': password,
      'licence_photo_path': licencePhotoPath,
      'national_id_fan_no': nationalIdFanNo,
      'phone_number': phoneNumber,
      'organization_name': organizationName,
      'country': country,
      'years_experience': yearsExperience,
    };
  }
}
