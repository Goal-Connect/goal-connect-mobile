import 'dart:io';

import 'package:dio/dio.dart';
import 'package:goal_connect/core/constants/api_constants.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';
import 'package:goal_connect/features/highlights/domain/entities/toggle_like_result.dart';
import '../models/highlight_model.dart';

class VideoApiException implements Exception {
  final String message;

  VideoApiException(this.message);

  @override
  String toString() => message;
}

abstract class HighlightRemoteDataSource {
  Future<HighlightModel> uploadHighlight({
    required String playerId,
    required String videoPath,
    required String caption,
  });

  Future<void> deleteHighlight(String highlightId);

  Future<HighlightModel> updateHighlight({
    required String highlightId,
    String? title,
    String? description,
    String? privacy,
    String? drillType,
  });

  Future<List<HighlightModel>> getHighlightsFeed();

  Future<List<HighlightModel>> getPlayerHighlights(String playerId);

  Future<ToggleLikeResult> toggleLike(String highlightId);
}

class HighlightRemoteDataSourceImpl implements HighlightRemoteDataSource {
  HighlightRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  static String _basename(String path) {
    final i = path.lastIndexOf('/');
    final j = path.lastIndexOf(r'\');
    final start = (i > j ? i : j) + 1;
    return start > 0 ? path.substring(start) : path;
  }

  static String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final msg = map['message'] as String?;
      if (msg != null && msg.isNotEmpty) {
        return msg;
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Could not reach the server. Check your connection.';
    }
    return e.message ?? 'Something went wrong';
  }

  static ToggleLikeResult _parseToggleLikeResponse(dynamic body) {
    if (body is! Map) {
      throw VideoApiException('Invalid like response');
    }
    final map = Map<String, dynamic>.from(body);
    final data = map['data'];
    if (data is! Map) {
      throw VideoApiException('Invalid like response');
    }
    final d = Map<String, dynamic>.from(data);
    final likesRaw = d['likes'];
    final ids = likesRaw is List
        ? likesRaw.map((e) => e.toString()).toList()
        : <String>[];
    final count = d['likesCount'];
    final likesCount = count is int
        ? count
        : int.tryParse(count?.toString() ?? '') ?? ids.length;
    return ToggleLikeResult(likesCount: likesCount, likedUserIds: ids);
  }

  List<HighlightModel> _parseVideoList(dynamic data) {
    if (data is! Map) {
      throw VideoApiException('Invalid response from server');
    }
    final map = Map<String, dynamic>.from(data);
    if (map['success'] != true) {
      throw VideoApiException(
        map['message'] as String? ?? 'Failed to load videos',
      );
    }
    final raw = map['data'];
    if (raw is! List) {
      return [];
    }
    return raw
        .map((e) {
          if (e is! Map) {
            return null;
          }
          return HighlightModel.fromVideoApiMap(
            Map<String, dynamic>.from(e),
          );
        })
        .whereType<HighlightModel>()
        .toList();
  }

  List<HighlightModel> _parseFeedList(dynamic data) {
    if (data is! Map) {
      throw VideoApiException('Invalid response from server');
    }
    final map = Map<String, dynamic>.from(data);
    if (map['success'] != true) {
      throw VideoApiException(
        map['message'] as String? ?? 'Failed to load feed',
      );
    }
    final raw = map['data'];
    if (raw is! List) {
      return [];
    }
    return raw
        .map((e) {
          if (e is! Map) {
            return null;
          }
          try {
            return HighlightModel.fromFeedItemMap(
              Map<String, dynamic>.from(e),
            );
          } on FormatException {
            return null;
          }
        })
        .whereType<HighlightModel>()
        .toList();
  }

  @override
  Future<List<HighlightModel>> getHighlightsFeed() async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.videosFeed,
        queryParameters: <String, dynamic>{
          'page': 1,
          'limit': 20,
        },
      );
      return _parseFeedList(response.data);
    } on DioException catch (e) {
      throw VideoApiException(_messageFromDio(e));
    }
  }

  @override
  Future<List<HighlightModel>> getPlayerHighlights(String playerId) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.playerVideosPath(playerId),
        queryParameters: <String, dynamic>{
          'page': 1,
          'limit': 20,
          'videoType': 'highlight',
        },
      );
      return _parseVideoList(response.data);
    } on DioException catch (e) {
      throw VideoApiException(_messageFromDio(e));
    }
  }

  @override
  Future<HighlightModel> uploadHighlight({
    required String playerId,
    required String videoPath,
    required String caption,
  }) async {
    if (!File(videoPath).existsSync()) {
      throw VideoApiException('Video file not found');
    }
    final title = caption.trim().isEmpty ? 'Highlight' : caption.trim();
    final formData = FormData.fromMap(<String, dynamic>{
      'video': await MultipartFile.fromFile(
        videoPath,
        filename: _basename(videoPath),
      ),
      'title': title,
      'videoType': 'highlight',
    });

    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.videos,
        data: formData,
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 5),
        ),
      );
      final body = response.data;
      if (body is! Map) {
        throw VideoApiException('Invalid response from server');
      }
      final map = Map<String, dynamic>.from(body);
      if (map['success'] != true) {
        throw VideoApiException(
          map['message'] as String? ?? 'Upload failed',
        );
      }
      final raw = map['data'];
      if (raw is! Map) {
        throw VideoApiException('Invalid upload response');
      }
      return HighlightModel.fromVideoApiMap(
        Map<String, dynamic>.from(raw),
      );
    } on DioException catch (e) {
      throw VideoApiException(_messageFromDio(e));
    }
  }

  @override
  Future<void> deleteHighlight(String highlightId) async {
    try {
      final response = await _dio.delete<dynamic>(
        ApiConstants.videoPath(highlightId),
      );
      final body = response.data;
      if (body is Map) {
        final map = Map<String, dynamic>.from(body);
        if (map['success'] != true) {
          throw VideoApiException(
            map['message'] as String? ?? 'Failed to delete video',
          );
        }
      }
    } on DioException catch (e) {
      throw VideoApiException(_messageFromDio(e));
    }
  }

  @override
  Future<HighlightModel> updateHighlight({
    required String highlightId,
    String? title,
    String? description,
    String? privacy,
    String? drillType,
  }) async {
    final payload = <String, dynamic>{};
    if (title != null) payload['title'] = title;
    if (description != null) payload['description'] = description;
    if (privacy != null) payload['privacy'] = privacy;
    if (drillType != null) payload['drillType'] = drillType;

    try {
      final response = await _dio.patch<dynamic>(
        ApiConstants.videoPath(highlightId),
        data: payload,
      );
      final body = response.data;
      if (body is! Map) {
        throw VideoApiException('Invalid response from server');
      }
      final map = Map<String, dynamic>.from(body);
      if (map['success'] != true) {
        throw VideoApiException(
          map['message'] as String? ?? 'Failed to update video',
        );
      }
      final raw = map['data'];
      if (raw is! Map) {
        throw VideoApiException('Invalid update response');
      }
      return HighlightModel.fromVideoApiMap(
        Map<String, dynamic>.from(raw),
      );
    } on DioException catch (e) {
      throw VideoApiException(_messageFromDio(e));
    }
  }

  @override
  Future<ToggleLikeResult> toggleLike(String highlightId) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.videoLikePath(highlightId),
      );
      final body = response.data;
      return _parseToggleLikeResponse(body);
    } on DioException catch (e) {
      throw VideoApiException(_messageFromDio(e));
    }
  }
}

class MockHighlightRemoteDataSource implements HighlightRemoteDataSource {
  final List<HighlightModel> _highlights = [];
  final Map<String, ToggleLikeResult> _likeState = {};

  final List<String> mockVideos = [
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
  ];

  MockHighlightRemoteDataSource() {
    final List<String> captions = [
      "Ball control drills in Addis 🇪🇹 #FutureStar",
      "Cone work on a Sunday morning ⚽",
      "Fast feet, faster dreams. #Agility",
      "Scouting day in Ethiopia! 🇪🇹",
      "Dribbling masterclass by our Forward.",
      "Young talent showing off skills 🎯",
      "Warm-up before the big match.",
      "Focus. Determination. Football. #Drills",
      "Elite footwork from the academy ⚽🔥",
      "Keep grinding, the world is watching 🌍",
    ];

    for (var i = 0; i < mockVideos.length; i++) {
      _highlights.add(
        HighlightModel(
          id: i.toString(),
          player: User(
            id: "player${i % 10}",
            email: "player${i % 10}@test.com",
            role: "player",
            username: "EthioStar_${i % 10}",
            profileImage:
                "https://ui-avatars.com/api/?name=EthioStar+${i % 10}&background=00D084&color=000&size=150",
            position: i % 2 == 0 ? "Forward" : "Midfielder",
            age: 15 + (i % 4),
            country: "Ethiopia",
          ),
          videoUrl: mockVideos[i],
          caption: captions[i % captions.length],
          likes: (i * 15) + 10,
          commentCount: 12,
          createdAt: DateTime.now().subtract(Duration(hours: i * 3)),
        ),
      );
    }
  }

  @override
  Future<HighlightModel> uploadHighlight({
    required String playerId,
    required String videoPath,
    required String caption,
  }) async {
    final highlight = HighlightModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      player: User(
        id: playerId,
        email: "player@test.com",
        role: "player",
        username: "yafet10",
        profileImage: "https://example.com/profile.jpg",
        position: "Forward",
        age: 19,
        country: "Ethiopia",
      ),
      videoUrl: videoPath,
      caption: caption,
      likes: 0,
      createdAt: DateTime.now(),
    );

    _highlights.insert(0, highlight);
    return highlight;
  }

  @override
  Future<void> deleteHighlight(String highlightId) async {
    _highlights.removeWhere((h) => h.id == highlightId);
  }

  @override
  Future<HighlightModel> updateHighlight({
    required String highlightId,
    String? title,
    String? description,
    String? privacy,
    String? drillType,
  }) async {
    final i = _highlights.indexWhere((h) => h.id == highlightId);
    if (i < 0) throw VideoApiException('Not found');
    final old = _highlights[i];
    final updated = HighlightModel(
      id: old.id,
      player: old.player,
      videoUrl: old.videoUrl,
      caption: title ?? old.caption,
      likes: old.likes,
      likedUserIds: old.likedUserIds,
      commentCount: old.commentCount,
      createdAt: old.createdAt,
      description: description ?? old.description,
      privacy: privacy ?? old.privacy,
      drillType: drillType ?? old.drillType,
      videoType: old.videoType,
      thumbnailUrl: old.thumbnailUrl,
      uploadedById: old.uploadedById,
    );
    _highlights[i] = updated;
    return updated;
  }

  @override
  Future<List<HighlightModel>> getHighlightsFeed() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _highlights;
  }

  @override
  Future<List<HighlightModel>> getPlayerHighlights(String playerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _highlights.where((h) => h.player.id == playerId).toList();
  }

  @override
  Future<ToggleLikeResult> toggleLike(String highlightId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final highlight = _highlights.firstWhere(
      (h) => h.id == highlightId,
      orElse: () => throw VideoApiException('Highlight not found'),
    );
    final prev = _likeState[highlightId] ??
        ToggleLikeResult(
          likesCount: highlight.likes,
          likedUserIds: List<String>.from(highlight.likedUserIds),
        );
    const me = 'local_user';
    final had = prev.likedUserIds.contains(me);
    final nextIds = List<String>.from(prev.likedUserIds);
    if (had) {
      nextIds.remove(me);
    } else {
      nextIds.add(me);
    }
    final next = ToggleLikeResult(
      likesCount: nextIds.length,
      likedUserIds: nextIds,
    );
    _likeState[highlightId] = next;
    return next;
  }
}
