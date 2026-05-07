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

  /// `PATCH/DELETE /videos/{id}` — pass id when calling Dio.
  static String videoPath(String videoId) => '/videos/$videoId';

  /// `POST /videos/{id}/like`
  static String videoLikePath(String videoId) => '/videos/$videoId/like';

  /// `GET/POST /videos/{id}/comments`
  static String videoCommentsPath(String videoId) =>
      '/videos/$videoId/comments';

  /// `DELETE /videos/{id}/comments/{commentId}`
  static String videoCommentPath(String videoId, String commentId) =>
      '/videos/$videoId/comments/$commentId';

  /// `POST /videos/{id}/comments/{commentId}/like`
  static String videoCommentLikePath(String videoId, String commentId) =>
      '/videos/$videoId/comments/$commentId/like';

  /// Smart discovery feed (role-filtered `FeedItem` list).
  static const String videosFeed = '/videos/feed';

  /// `GET /players` — list & filter players.
  static const String players = '/players';

  /// `GET /players/{id}` — path only; pass id when calling Dio.
  static String playerPath(String playerId) => '/players/$playerId';

  /// `GET /players/{id}/videos` (see README).
  static String playerVideosPath(String playerId) =>
      '/players/$playerId/videos';
}
