import 'package:goal_connect/features/auth/domain/entities/player_application.dart';

class PlayerApplicationModel extends PlayerApplication {
  const PlayerApplicationModel({
    required super.fullName,
    required super.email,
    required super.nationalIdFanNo,
    required super.age,
    required super.phoneNumber,
    required super.address,
    required super.country,
    required super.region,
    required super.primaryPosition,
    super.secondaryPosition,
    required super.academyId,
    super.additionalInfo,
  });

  factory PlayerApplicationModel.fromEntity(PlayerApplication e) {
    return PlayerApplicationModel(
      fullName: e.fullName,
      email: e.email,
      nationalIdFanNo: e.nationalIdFanNo,
      age: e.age,
      phoneNumber: e.phoneNumber,
      address: e.address,
      country: e.country,
      region: e.region,
      primaryPosition: e.primaryPosition,
      secondaryPosition: e.secondaryPosition,
      academyId: e.academyId,
      additionalInfo: e.additionalInfo,
    );
  }

  /// Body for `POST /auth/player-application`.
  Map<String, dynamic> toRequestJson() {
    final json = <String, dynamic>{
      'fullName': fullName.trim(),
      'email': email.trim(),
      'nationalIdFanNo': nationalIdFanNo.trim(),
      'age': age,
      'phoneNumber': phoneNumber.trim(),
      'address': address.trim(),
      'country': country.trim(),
      'region': region.trim(),
      'primaryPosition': primaryPosition,
      'academyId': academyId,
    };
    if (secondaryPosition != null && secondaryPosition!.isNotEmpty) {
      json['secondaryPosition'] = secondaryPosition;
    }
    if (additionalInfo != null && additionalInfo!.trim().isNotEmpty) {
      json['additionalInfo'] = additionalInfo!.trim();
    }
    return json;
  }
}

class PlayerApplicationReceiptModel extends PlayerApplicationReceipt {
  const PlayerApplicationReceiptModel({
    required super.applicationId,
    required super.email,
    required super.status,
    super.submittedAt,
  });

  /// Parses `data` from the 201 envelope:
  /// `{ success, message, data: { applicationId, email, status, submittedAt } }`
  factory PlayerApplicationReceiptModel.fromJson(Map<String, dynamic> json) {
    DateTime? submittedAt;
    final raw = json['submittedAt'];
    if (raw is String && raw.isNotEmpty) {
      submittedAt = DateTime.tryParse(raw);
    }
    return PlayerApplicationReceiptModel(
      applicationId: json['applicationId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      submittedAt: submittedAt,
    );
  }
}
