import 'package:goal_connect/features/auth/data/models/user_model.dart';

/// Result of [AuthRemoteDataSource.login] or [AuthRemoteDataSource.createScoutAccount].
class AuthRemoteSession {
  final UserModel user;
  final String token;

  const AuthRemoteSession({
    required this.user,
    required this.token,
  });
}
