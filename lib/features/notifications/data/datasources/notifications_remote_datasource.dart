import 'package:dio/dio.dart';
import 'package:goal_connect/core/constants/api_constants.dart';
import 'package:goal_connect/features/notifications/data/models/announcement_model.dart';

class NotificationsApiException implements Exception {
  final String message;
  NotificationsApiException(this.message);
  @override
  String toString() => message;
}

abstract class NotificationsRemoteDataSource {
  /// `GET /notifications` — returns broadcast-type items mapped to
  /// announcements, newest first.
  Future<List<AnnouncementModel>> listBroadcasts();

  /// `PUT /notifications/{id}/read` — mark a notification as read.
  /// Used for both reading a broadcast and dismissing its banner.
  Future<void> markRead(String notificationId);
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<AnnouncementModel>> listBroadcasts() async {
    try {
      final response = await _dio.get<dynamic>(ApiConstants.notifications);
      final body = response.data;
      // Envelope may be either `{ success, data: [...] }` or a raw list.
      List<dynamic>? raw;
      if (body is List) {
        raw = body;
      } else if (body is Map) {
        final map = Map<String, dynamic>.from(body);
        final data = map['data'];
        if (data is List) raw = data;
      }
      if (raw == null) return const [];

      final items = <AnnouncementModel>[];
      for (final entry in raw) {
        if (entry is! Map) continue;
        final m = Map<String, dynamic>.from(entry);
        if (m['type'] != 'broadcast') continue;
        final a = AnnouncementModel.fromJson(m);
        if (a.id.isEmpty) continue;
        items.add(a);
      }
      // Newest first; server should already do this but be defensive.
      items.sort((a, b) {
        final ad = a.createdAt;
        final bd = b.createdAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
      return items;
    } on DioException catch (e) {
      throw NotificationsApiException(_messageFromDio(e));
    }
  }

  @override
  Future<void> markRead(String notificationId) async {
    try {
      final response = await _dio.put<dynamic>(
        ApiConstants.notificationReadPath(notificationId),
      );
      final body = response.data;
      if (body is Map) {
        final map = Map<String, dynamic>.from(body);
        // Some endpoints omit `success`; treat its absence as success.
        if (map.containsKey('success') && map['success'] != true) {
          throw NotificationsApiException(
            map['message'] as String? ?? 'Could not mark as read',
          );
        }
      }
    } on DioException catch (e) {
      throw NotificationsApiException(_messageFromDio(e));
    }
  }

  String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      final msg = m['message'] as String?;
      if (msg != null && msg.isNotEmpty) return msg;
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Could not reach the server. Check your connection.';
    }
    return e.message ?? 'Could not load notifications';
  }
}
