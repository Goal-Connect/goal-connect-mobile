import 'package:goal_connect/features/auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.role,
    required super.username,
    required super.profileImage,
    required super.position,
    required super.age,
    required super.country,
    super.playerProfileId,
    super.fullName,
    super.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final player = json['player'];
    if (player is Map) {
      final p = Map<String, dynamic>.from(player);
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: p['email'] as String? ?? '',
      role: p['role'] as String? ?? 'player',
      username: p['username'] as String? ?? '',
      profileImage: p['profileImage'] as String? ?? '',
      position: p['position'] as String? ?? '',
      age: (p['age'] is int) ? p['age'] as int : int.tryParse('${p['age']}') ?? 0,
      country: p['country'] as String? ?? '',
      playerProfileId: json['playerProfileId']?.toString(),
    );
    }
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      username: json['username'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
      position: json['position'] as String? ?? '',
      age: (json['age'] is int)
          ? json['age'] as int
          : int.tryParse('${json['age']}') ?? 0,
      country: json['country'] as String? ?? '',
      playerProfileId: json['playerProfileId']?.toString(),
      status: json['status'] as String? ?? 'approved',
    );
  }

  /// Parses `data` from `GET /auth/me` (`user` + optional `profile`). See README.
  factory UserModel.fromMeEnvelope(Map<String, dynamic> data) {
    final userRaw = data['user'];
    if (userRaw is! Map) {
      throw const FormatException('Invalid /auth/me response: missing user');
    }
    final user = Map<String, dynamic>.from(userRaw);
    Map<String, dynamic>? profile;
    final p = data['profile'];
    if (p is Map) {
      profile = Map<String, dynamic>.from(p);
    }
    return UserModel._fromMeUserMap(user, profile);
  }

  static UserModel _fromMeUserMap(
    Map<String, dynamic> user,
    Map<String, dynamic>? profile,
  ) {
    final id = user['id']?.toString() ?? '';
    final email = user['email'] as String? ?? '';
    final role = user['role'] as String? ?? 'user';
    final fullName = profile?['fullName'] as String?;
    final username = (fullName != null && fullName.trim().isNotEmpty)
        ? fullName.trim()
        : (email.contains('@') ? email.split('@').first : (id.isEmpty ? 'user' : id));
    final country = profile?['country'] as String? ?? '';
    String image = '';
    String? playerProfileId;
    if (profile != null) {
      final v = profile['profileImageUrl'] ??
          profile['avatarUrl'] ??
          profile['profileImage'] ??
          profile['photoUrl'];
      if (v != null) {
        image = v.toString();
      }
      playerProfileId =
          profile['id']?.toString() ?? profile['_id']?.toString();
    }
    return UserModel(
      id: id,
      email: email,
      role: role,
      username: username,
      profileImage: image,
      position: profile?['primaryPosition'] as String? ??
          profile?['position'] as String? ??
          _positionFromRole(role),
      age: profile?['age'] is int
          ? profile!['age'] as int
          : int.tryParse('${profile?['age']}') ?? 0,
      country: profile?['nationality'] as String? ??
          profile?['country'] as String? ??
          country,
      playerProfileId: playerProfileId,
      fullName: profile?['fullName'] as String? ?? '',
      status: user['status'] as String? ?? 'approved',
    );
  }

  /// Parses `user` from POST `/auth/login` or `/auth/register` success body.
  factory UserModel.fromAuthSuccessPayload(Map<String, dynamic> body) {
    final raw = body['user'];
    if (raw is! Map) {
      throw FormatException('Invalid auth response: missing user');
    }
    final user = Map<String, dynamic>.from(raw);
    final id = user['id']?.toString() ?? '';
    final email = user['email'] as String? ?? '';
    final role = user['role'] as String? ?? 'user';
    final username = email.contains('@')
        ? email.split('@').first
        : (email.isEmpty ? id : email);
    return UserModel(
      id: id,
      email: email,
      role: role,
      username: username.isEmpty ? 'user' : username,
      profileImage: '',
      position: _positionFromRole(role),
      age: 0,
      country: '',
      playerProfileId: null,
      status: user['status'] as String? ?? 'approved',
    );
  }

  static String _positionFromRole(String role) {
    switch (role) {
      case 'scout':
        return 'Scout';
      case 'academy':
        return 'Academy';
      case 'admin':
        return 'Admin';
      case 'player':
        return 'Player';
      default:
        return role;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'username': username,
      'profileImage': profileImage,
      'position': position,
      'age': age,
      'country': country,
      'status': status,
      if (playerProfileId != null) 'playerProfileId': playerProfileId,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      role: user.role,
      username: user.username,
      profileImage: user.profileImage,
      position: user.position,
      age: user.age,
      country: user.country,
      playerProfileId: user.playerProfileId,
      fullName: user.fullName,
      status: user.status,
    );
  }
}
