class ScoutAccountRegistration {
  final String fullName;
  final String email;
  final String password;
  final String? licencePhotoPath;
  final String nationalIdFanNo;
  final String phoneNumber;
  final String organizationName;
  final String country;
  final int? yearsExperience;

  const ScoutAccountRegistration({
    required this.fullName,
    required this.email,
    required this.password,
    this.licencePhotoPath,
    required this.nationalIdFanNo,
    required this.phoneNumber,
    required this.organizationName,
    required this.country,
    this.yearsExperience,
  });
}
