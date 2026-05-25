import 'package:dio/dio.dart';
import 'package:goal_connect/core/constants/api_constants.dart';
import '../../domain/entities/toggle_like_result.dart';
import '../models/comment_model.dart';

class CommentApiException implements Exception {
  final String message;
  CommentApiException(this.message);
  @override
  String toString() => message;
}

abstract class CommentRemoteDataSource {
  Future<List<CommentModel>> getComments(
    String videoId, {
    String? currentUserId,
  });

  Future<CommentModel> addComment({
    required String videoId,
    required String text,
    String? parentCommentId,
  });

  Future<void> deleteComment({
    required String videoId,
    required String commentId,
  });

  Future<CommentLikeToggleResult> toggleCommentLike({
    required String videoId,
    required String commentId,
  });
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  CommentRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  static String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final msg = map['message'] as String?;
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return e.message ?? 'Something went wrong';
  }

  @override
  Future<List<CommentModel>> getComments(
    String videoId, {
    String? currentUserId,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.videoCommentsPath(videoId),
      );
      final body = response.data;
      if (body is! Map) {
        throw CommentApiException('Invalid response');
      }
      final map = Map<String, dynamic>.from(body);
      if (map['success'] != true) {
        throw CommentApiException(
          map['message'] as String? ?? 'Failed to load comments',
        );
      }
      final raw = map['data'];
      if (raw is! List) {
        return [];
      }
      return raw
          .map((e) {
            if (e is! Map) return null;
            return CommentModel.fromApiMap(
              Map<String, dynamic>.from(e),
              currentUserId: currentUserId,
            );
          })
          .whereType<CommentModel>()
          .toList();
    } on DioException catch (e) {
      throw CommentApiException(_messageFromDio(e));
    }
  }

  @override
  Future<CommentModel> addComment({
    required String videoId,
    required String text,
    String? parentCommentId,
  }) async {
    final payload = <String, dynamic>{'text': text};
    if (parentCommentId != null) {
      payload['parentComment'] = parentCommentId;
    }
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.videoCommentsPath(videoId),
        data: payload,
      );
      final body = response.data;
      if (body is! Map) {
        throw CommentApiException('Invalid response');
      }
      final map = Map<String, dynamic>.from(body);
      if (map['success'] != true) {
        throw CommentApiException(
          map['message'] as String? ?? 'Failed to post comment',
        );
      }
      final raw = map['data'];
      // Server may return either:
      //   • a single object (canonical POST response), or
      //   • the full list of comments (some backend versions echo GET).
      // Both shapes mean success — pick the matching/newest comment.
      Map<String, dynamic>? created;
      if (raw is Map) {
        created = Map<String, dynamic>.from(raw);
      } else if (raw is List && raw.isNotEmpty) {
        final maps = raw
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList();
        // Prefer the comment whose text matches what we just sent — robust
        // against ordering / clock skew.
        created = maps.firstWhere(
          (m) {
            final t = m['text'];
            return t is String && t == text;
          },
          orElse: () => maps.first,
        );
      }
      if (created == null) {
        throw CommentApiException('Invalid comment response');
      }
      return CommentModel.fromApiMap(created);
    } on DioException catch (e) {
      throw CommentApiException(_messageFromDio(e));
    }
  }

  @override
  Future<void> deleteComment({
    required String videoId,
    required String commentId,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        ApiConstants.videoCommentPath(videoId, commentId),
      );
      final body = response.data;
      if (body is Map) {
        final map = Map<String, dynamic>.from(body);
        if (map['success'] != true) {
          throw CommentApiException(
            map['message'] as String? ?? 'Failed to delete comment',
          );
        }
      }
    } on DioException catch (e) {
      throw CommentApiException(_messageFromDio(e));
    }
  }

  @override
  Future<CommentLikeToggleResult> toggleCommentLike({
    required String videoId,
    required String commentId,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.videoCommentLikePath(videoId, commentId),
      );
      final body = response.data;
      if (body is! Map) {
        throw CommentApiException('Invalid response');
      }
      final map = Map<String, dynamic>.from(body);
      final data = map['data'];
      if (data is! Map) {
        throw CommentApiException('Invalid like response');
      }
      final d = Map<String, dynamic>.from(data);
      final likesRaw = d['likes'];
      final ids = <String>[];
      if (likesRaw is List) {
        for (final e in likesRaw) {
          if (e is String) {
            ids.add(e);
          } else if (e is Map) {
            final v = e['user'] ?? e['userId'] ?? e['_id'] ?? e['id'];
            if (v != null) ids.add(v.toString());
          }
        }
      }
      final count = d['likesCount'];
      final likesCount = count is int
          ? count
          : int.tryParse(count?.toString() ?? '') ?? ids.length;
      return CommentLikeToggleResult(likesCount: likesCount, likedUserIds: ids);
    } on DioException catch (e) {
      throw CommentApiException(_messageFromDio(e));
    }
  }
}

/// Offline / demo comments (used in tests when mock is registered).
class MockCommentRemoteDataSource implements CommentRemoteDataSource {
  final Map<String, List<CommentModel>> _commentsByHighlight = {};

  List<CommentModel> _seed(String videoId) {
    return [
      CommentModel(
        id: '${videoId}_c1',
        userId: 'u1',
        username: 'DemoUser',
        profileImage: null,
        text: 'Incredible footwork!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 3,
      ),
    ];
  }

  @override
  Future<List<CommentModel>> getComments(
    String videoId, {
    String? currentUserId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _commentsByHighlight.putIfAbsent(videoId, () => _seed(videoId));
    return List.from(_commentsByHighlight[videoId]!);
  }

  @override
  Future<CommentModel> addComment({
    required String videoId,
    required String text,
    String? parentCommentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final c = CommentModel(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'local',
      username: 'You',
      text: text,
      createdAt: DateTime.now(),
      likes: 0,
      parentCommentId: parentCommentId,
    );
    _commentsByHighlight.putIfAbsent(videoId, () => []);
    _commentsByHighlight[videoId]!.insert(0, c);
    return c;
  }

  @override
  Future<void> deleteComment({
    required String videoId,
    required String commentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final list = _commentsByHighlight[videoId];
    list?.removeWhere((c) => c.id == commentId);
  }

  @override
  Future<CommentLikeToggleResult> toggleCommentLike({
    required String videoId,
    required String commentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return const CommentLikeToggleResult(likesCount: 1, likedUserIds: ['local']);
  }
}
