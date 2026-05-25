import 'package:goal_connect/features/notifications/domain/entities/announcement.dart';

class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.body,
    required super.isRead,
    super.createdAt,
  });

  /// Parses a single notification item from `GET /notifications`.
  /// Caller filters by `type == 'broadcast'` before invoking.
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'];
    String title = '';
    String body = '';
    if (meta is Map) {
      final m = Map<String, dynamic>.from(meta);
      title = (m['broadcastTitle'] as String?)?.trim() ?? '';
      body = (m['broadcastBody'] as String?)?.trim() ?? '';
    }
    // Fallbacks: server sometimes only sets the top-level `message` field.
    if (title.isEmpty) {
      title = (json['message'] as String?)?.trim() ?? '';
    }
    if (body.isEmpty && title != (json['message'] as String?)) {
      body = (json['message'] as String?)?.trim() ?? '';
    }

    DateTime? createdAt;
    final raw = json['createdAt'];
    if (raw is String && raw.isNotEmpty) {
      createdAt = DateTime.tryParse(raw);
    }

    return AnnouncementModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      title: title,
      body: body,
      isRead: json['isRead'] == true,
      createdAt: createdAt,
    );
  }
}
