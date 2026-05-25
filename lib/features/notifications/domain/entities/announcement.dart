/// A broadcast announcement surfaced from `GET /notifications` where
/// `type == "broadcast"`. The server stores the human-readable copy under
/// `metadata.broadcastTitle` / `metadata.broadcastBody`.
class Announcement {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
  });

  Announcement copyWith({
    String? id,
    String? title,
    String? body,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
