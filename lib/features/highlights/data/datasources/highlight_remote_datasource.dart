import 'dart:io';

import 'package:dio/dio.dart';
import 'package:goal_connect/core/constants/api_constants.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';
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

  Future<List<HighlightModel>> getHighlightsFeed();

  Future<List<HighlightModel>> getPlayerHighlights(String playerId);

  Future<bool> toggleLike(String highlightId);

  bool isLiked(String highlightId);
}

class HighlightRemoteDataSourceImpl implements HighlightRemoteDataSource {
  HighlightRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Local optimistic likes (no backend endpoint in README).
  final Set<String> _likedHighlightIds = <String>{};

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

  @override
  Future<List<HighlightModel>> getHighlightsFeed() async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.videos,
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
    // No delete endpoint in README; keep API surface for existing code.
  }

  @override
  Future<bool> toggleLike(String highlightId) async {
    if (_likedHighlightIds.contains(highlightId)) {
      _likedHighlightIds.remove(highlightId);
      return false;
    }
    _likedHighlightIds.add(highlightId);
    return true;
  }

  @override
  bool isLiked(String highlightId) =>
      _likedHighlightIds.contains(highlightId);
}

class MockHighlightRemoteDataSource implements HighlightRemoteDataSource {
  final List<HighlightModel> _highlights = [];
  final Set<String> _likedHighlightIds = {};
  final Map<String, int> _likeCounts = {};

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
  Future<bool> toggleLike(String highlightId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final highlight = _highlights.firstWhere(
      (h) => h.id == highlightId,
      orElse: () => throw Exception('Highlight not found'),
    );
    _likeCounts.putIfAbsent(highlightId, () => highlight.likes);

    if (_likedHighlightIds.contains(highlightId)) {
      _likedHighlightIds.remove(highlightId);
      _likeCounts[highlightId] =
          (_likeCounts[highlightId]! - 1).clamp(0, 999999);
      return false;
    } else {
      _likedHighlightIds.add(highlightId);
      _likeCounts[highlightId] = _likeCounts[highlightId]! + 1;
      return true;
    }
  }

  @override
  bool isLiked(String highlightId) => _likedHighlightIds.contains(highlightId);
}
