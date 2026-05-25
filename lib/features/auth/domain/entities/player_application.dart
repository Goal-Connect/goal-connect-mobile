/// Submission payload for `POST /auth/player-application`.
///
/// This is an **application form**, not an account signup — no password is
/// collected here. The contract is documented in
/// `docs/features/player_application.md`.
class PlayerApplication {
  final String fullName;
  final String email;
  final String nationalIdFanNo;
  final int age;
  final String phoneNumber;
  final String address;
  final String country;
  final String region;
  final String primaryPosition;
  final String? secondaryPosition;
  final String academyId;
  final String? additionalInfo;

  const PlayerApplication({
    required this.fullName,
    required this.email,
    required this.nationalIdFanNo,
    required this.age,
    required this.phoneNumber,
    required this.address,
    required this.country,
    required this.region,
    required this.primaryPosition,
    this.secondaryPosition,
    required this.academyId,
    this.additionalInfo,
  });
}

/// Server acknowledgement returned on a successful 201 application submit.
class PlayerApplicationReceipt {
  final String applicationId;
  final String email;
  final String status;
  final DateTime? submittedAt;

  const PlayerApplicationReceipt({
    required this.applicationId,
    required this.email,
    required this.status,
    this.submittedAt,
  });
}
