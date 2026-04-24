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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      username: json['username'] as String,
      profileImage: json['profileImage'] as String,
      position: json['position'] as String,
      age: json['age'] as int,
      country: json['country'] as String,
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
    );
  }

  static String _positionFromRole(String role) {
    switch (role) {
      case 'scout':
        return 'Scout';
      case 'academy':
        return 'Academy';
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
    );
  }
}
