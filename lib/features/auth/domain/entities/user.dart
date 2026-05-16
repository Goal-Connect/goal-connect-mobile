class User {

  final String id;
  final String email;
  final String role;
  final String username;
  final String profileImage;
  final String position;
  final int age;
  final String country;
  final String fullName;
  final String status;

  /// Football profile document id from `GET /auth/me` → `profile.id` (for `GET /players/:id`).
  final String? playerProfileId;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.username,
    required this.profileImage,
    required this.position,
    required this.age,
    required this.country,
    this.playerProfileId,
    this.fullName = '',
    this.status = 'approved',
  });

  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isPendingApproval => status.toLowerCase() == 'pending';

}
