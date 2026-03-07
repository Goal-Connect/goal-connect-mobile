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
