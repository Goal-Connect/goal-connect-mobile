import 'player_profile.dart';
import 'scout_profile.dart';

/// Sealed wrapper for the `profile` payload returned by `GET /auth/me`.
/// The concrete shape depends on the user's role:
///  * `player` → [CurrentUserProfilePlayer] wrapping a [PlayerProfile]
///  * `scout` → [CurrentUserProfileScout] wrapping a [ScoutProfile]
///
/// Other roles (admin, academy) currently have no profile payload — the
/// caller will see `null` rather than an instance of this type.
sealed class CurrentUserProfile {
  const CurrentUserProfile();

  /// Convenience: the URL to show in the avatar slot, if any.
  String get profileImageUrl;

  /// Convenience: the display name to show in the header, if any.
  String get displayName;
}

class CurrentUserProfilePlayer extends CurrentUserProfile {
  final PlayerProfile player;

  const CurrentUserProfilePlayer(this.player);

  @override
  String get profileImageUrl => player.profileImageUrl;

  @override
  String get displayName => player.fullName;
}

class CurrentUserProfileScout extends CurrentUserProfile {
  final ScoutProfile scout;

  const CurrentUserProfileScout(this.scout);

  @override
  String get profileImageUrl => scout.profileImageUrl;

  @override
  String get displayName => scout.fullName;
}
