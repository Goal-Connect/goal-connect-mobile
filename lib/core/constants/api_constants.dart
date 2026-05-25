abstract final class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://goalconnect-backend-repo-2.onrender.com/api';

  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authUpdatePassword = '/auth/updatepassword';
  static const String authLogout = '/auth/logout';
  static const String authForgotPassword = '/auth/forgot-password';

  /// `POST /auth/player-application` — submit a player application (no login).
  /// See docs/features/player_application.md.
  static const String authPlayerApplication = '/auth/player-application';

  /// `GET /academies` — list approved academies (paginated; supports
  /// `search` and `region` query params).
  static const String academies = '/academies';

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

  /// `GET /players/search` — smart search (name / hybrid / semantic) with
  /// the new filter contract. Returns `{ data, page, pages, total, meta }`.
  /// Prefer this over `/players?search=` for any search UI.
  static const String playersSearch = '/players/search';

  /// `GET /players/suggest` — autocomplete; returns `suggestions.names[]`
  /// and `suggestions.didYouMean`. Debounce client-side (~300ms).
  static const String playersSuggest = '/players/suggest';

  /// `GET /players/{id}/videos` (see README).
  static String playerVideosPath(String playerId) =>
      '/players/$playerId/videos';

  /// `GET /scouts/saved-players` — current scout's saved players.
  static const String scoutsSavedPlayers = '/scouts/saved-players';

  /// `POST/DELETE /scouts/saved-players/{playerId}` — save/unsave a player.
  static String scoutsSavedPlayerPath(String playerId) =>
      '/scouts/saved-players/$playerId';

  /// `POST/PUT/DELETE /scouts/preferences` — scout discovery preference.
  static const String scoutsPreferences = '/scouts/preferences';

  /// `POST /reports` — create a report (authenticated users).
  static const String reports = '/reports';

  /// `GET /messages` — list of conversations with the current user
  /// (peer user + last message + unreadCount). Sending is socket-only.
  static const String messages = '/messages';

  /// `GET /notifications` — current user's notifications. Each item has
  /// `type` ("broadcast", etc.); broadcasts include `metadata.broadcastTitle`
  /// and `metadata.broadcastBody`.
  static const String notifications = '/notifications';

  /// `PUT /notifications/{id}/read` — mark a notification as read (used
  /// for both reading and dismissing broadcasts).
  static String notificationReadPath(String notificationId) =>
      '/notifications/$notificationId/read';

  /// `GET /messages/{userId}` — full thread with that user (oldest first).
  static String messagesWithUserPath(String userId) => '/messages/$userId';

  /// Socket.IO origin (no `/api` path). Example: `https://host:443`
  static String get socketBaseUrl {
    final u = Uri.parse(baseUrl);
    return Uri(
      scheme: u.scheme,
      host: u.host,
      port: u.hasPort ? u.port : null,
    ).toString();
  }
}
