import 'package:goal_connect/features/auth/domain/entities/User.dart';

class UserModel extends User {
  UserModel({required super.id, required super.email, required super.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'role': role};
  }
}
