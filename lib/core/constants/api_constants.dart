/// Goal Connect backend (see README.md).
abstract final class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://goalconnect-backend-repo-2.onrender.com/api';

  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authUpdatePassword = '/auth/updatepassword';
  static const String authLogout = '/auth/logout';

  /// List / upload videos (see README).
  static const String videos = '/videos';

  /// `GET /players/{id}` — path only; pass id when calling Dio.
  static String playerPath(String playerId) => '/players/$playerId';

  /// `GET /players/{id}/videos` (see README).
  static String playerVideosPath(String playerId) =>
      '/players/$playerId/videos';
}
