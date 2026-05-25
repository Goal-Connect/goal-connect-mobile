/// A minimal approved-academy item from `GET /academies`.
///
/// Only the fields the player-application picker and the scout-search list
/// need are modeled; fuller academy detail screens can extend this later.
class Academy {
  final String id;
  final String name;
  final String? region;
  final String? woreda;
  final String? address;

  /// `user` field from the API — the ObjectId of the academy's owning user.
  /// Used as `participantId` when a scout opens a direct chat with the
  /// academy from the search screen.
  final String? userId;

  final String? ownerName;
  final String? contactPhone;

  /// Number of players currently associated with this academy (server
  /// returns `playerCount` on the list endpoint).
  final int playerCount;

  const Academy({
    required this.id,
    required this.name,
    this.region,
    this.woreda,
    this.address,
    this.userId,
    this.ownerName,
    this.contactPhone,
    this.playerCount = 0,
  });
}
