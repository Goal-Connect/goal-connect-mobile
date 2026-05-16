import 'package:dio/dio.dart';
import 'package:goal_connect/core/constants/api_constants.dart';
import '../../domain/entities/players_list_result.dart';
import '../models/player_profile_model.dart';
import '../models/player_stats_model.dart';

abstract class PlayerProfileRemoteDataSource {
  Future<PlayerProfileModel> getPlayerProfile(String playerId);
  Future<bool> toggleFollow(String playerId);

  /// `GET /players` with optional filters (see API docs).
  Future<PlayersListResult> listPlayers({
    required int page,
    required int limit,
    String? search,
    String? position,
    String? strongFoot,
    int? minAge,
    int? maxAge,
    int? minHeight,
    int? maxHeight,
    String? sortBy,
    String? sortOrder,
    String? meta,
  });

  /// `GET /scouts/saved-players` — scout's saved players list.
  Future<List<PlayerProfileModel>> getSavedPlayers();

  /// `POST /scouts/saved-players/{playerId}` — save a player.
  Future<void> savePlayer(String playerId);

  /// `DELETE /scouts/saved-players/{playerId}` — unsave a player.
  Future<void> unsavePlayer(String playerId);
}

class PlayerProfileApiException implements Exception {
  final String message;

  PlayerProfileApiException(this.message);

  @override
  String toString() => message;
}

class PlayerProfileRemoteDataSourceImpl implements PlayerProfileRemoteDataSource {
  PlayerProfileRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Until a follow API exists, keep optimistic local toggles (same as mock).
  final Map<String, bool> _followState = <String, bool>{};

  static String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final msg = map['message'] as String?;
      if (msg != null && msg.isNotEmpty) {
        return msg;
      }
    }
    return e.message ?? 'Something went wrong';
  }

  @override
  Future<PlayerProfileModel> getPlayerProfile(String playerId) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.playerPath(playerId),
      );
      return PlayerProfileModel.fromPlayersEndpoint(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        final data = e.response?.data;
        if (data is Map && data['message'] is String) {
          throw PlayerProfileApiException(data['message'] as String);
        }
        throw PlayerProfileApiException('Player not found');
      }
      throw PlayerProfileApiException(_messageFromDio(e));
    }
  }

  @override
  Future<bool> toggleFollow(String playerId) async {
    final current = _followState[playerId] ?? false;
    _followState[playerId] = !current;
    return !current;
  }

  @override
  Future<PlayersListResult> listPlayers({
    required int page,
    required int limit,
    String? search,
    String? position,
    String? strongFoot,
    int? minAge,
    int? maxAge,
    int? minHeight,
    int? maxHeight,
    String? sortBy,
    String? sortOrder,
    String? meta,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      final searchTrimmed = search?.trim();
      if (searchTrimmed != null && searchTrimmed.isNotEmpty) {
        params['search'] = searchTrimmed;
      }
      final positionTrimmed = position?.trim();
      if (positionTrimmed != null && positionTrimmed.isNotEmpty) {
        params['position'] = positionTrimmed;
      }
      final footTrimmed = strongFoot?.trim();
      if (footTrimmed != null && footTrimmed.isNotEmpty) {
        params['strongFoot'] = footTrimmed;
      }
      if (minAge != null) params['minAge'] = minAge;
      if (maxAge != null) params['maxAge'] = maxAge;
      if (minHeight != null) params['minHeight'] = minHeight;
      if (maxHeight != null) params['maxHeight'] = maxHeight;
      final sortByTrimmed = sortBy?.trim();
      if (sortByTrimmed != null && sortByTrimmed.isNotEmpty) {
        params['sortBy'] = sortByTrimmed;
      }
      final sortOrderTrimmed = sortOrder?.trim();
      if (sortOrderTrimmed != null && sortOrderTrimmed.isNotEmpty) {
        params['sortOrder'] = sortOrderTrimmed;
      }
      final metaTrimmed = meta?.trim();
      if (metaTrimmed != null && metaTrimmed.isNotEmpty) {
        params['meta'] = metaTrimmed;
      }

      final response = await _dio.get<dynamic>(
        ApiConstants.players,
        queryParameters: params,
      );
      final body = response.data;
      if (body is! Map) {
        throw PlayerProfileApiException('Invalid players list response');
      }
      final map = Map<String, dynamic>.from(body);
      if (map['success'] != true) {
        throw PlayerProfileApiException(
          map['message'] as String? ?? 'Failed to load players',
        );
      }
      final raw = map['data'];
      final list = raw is List ? raw : <dynamic>[];
      final players = list
          .whereType<Map>()
          .map((e) => PlayerProfileModel.fromListDocument(
                Map<String, dynamic>.from(e),
              ))
          .toList();

      final pageNum = (map['page'] as num?)?.toInt() ?? page;
      final pagesNum = (map['pages'] as num?)?.toInt() ?? 1;
      final totalNum = (map['total'] as num?)?.toInt() ?? players.length;
      final countNum = (map['count'] as num?)?.toInt() ?? players.length;

      return PlayersListResult(
        players: players,
        page: pageNum,
        pages: pagesNum,
        total: totalNum,
        count: countNum,
      );
    } on DioException catch (e) {
      throw PlayerProfileApiException(_messageFromDio(e));
    }
  }

  @override
  Future<List<PlayerProfileModel>> getSavedPlayers() async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.scoutsSavedPlayers,
      );
      final body = response.data;
      if (body is! Map) {
        throw PlayerProfileApiException('Invalid saved players response');
      }
      final map = Map<String, dynamic>.from(body);
      if (map['success'] != true) {
        throw PlayerProfileApiException(
          map['message'] as String? ?? 'Failed to load saved players',
        );
      }
      final raw = map['data'];
      final list = raw is List ? raw : <dynamic>[];
      return list
          .whereType<Map>()
          .map((e) => PlayerProfileModel.fromListDocument(
                Map<String, dynamic>.from(e),
              ))
          .toList();
    } on DioException catch (e) {
      throw PlayerProfileApiException(_messageFromDio(e));
    }
  }

  @override
  Future<void> savePlayer(String playerId) async {
    try {
      await _dio.post<dynamic>(ApiConstants.scoutsSavedPlayerPath(playerId));
    } on DioException catch (e) {
      throw PlayerProfileApiException(_messageFromDio(e));
    }
  }

  @override
  Future<void> unsavePlayer(String playerId) async {
    try {
      await _dio.delete<dynamic>(ApiConstants.scoutsSavedPlayerPath(playerId));
    } on DioException catch (e) {
      throw PlayerProfileApiException(_messageFromDio(e));
    }
  }
}

class MockPlayerProfileRemoteDataSource implements PlayerProfileRemoteDataSource {
  final Map<String, bool> _followState = {};

  final _mockProfiles = <String, PlayerProfileModel>{};

  MockPlayerProfileRemoteDataSource() {
    final names = [
      'EthioStar_0', 'EthioStar_1', 'EthioStar_2', 'EthioStar_3',
      'EthioStar_4', 'EthioStar_5', 'EthioStar_6', 'EthioStar_7',
      'EthioStar_8', 'EthioStar_9',
    ];

    final bios = [
      'Young forward from Addis Ababa. Dream: top European leagues.',
      'Creative midfielder with elite vision and passing range.',
      'Explosive winger who loves to take on defenders 1v1.',
      'Box-to-box midfielder with incredible stamina.',
      'Clinical striker. Goals are my language.',
      'Defensive rock from the Ethiopian youth academy.',
      'Playmaker with silky dribbling skills.',
      'Versatile attacker comfortable across the front line.',
      'Speed demon on the wing. Nobody catches me.',
      'Captain material. Leader on and off the pitch.',
    ];

    final clubs = [
      'Addis Ababa FC', 'Ethiopian Coffee SC', 'St. George SA',
      'Hawassa Kenema', 'Fasil Kenema', 'Mekelle Kenema',
      'Jimma Aba Jifar', 'Wolaita Dicha', 'Sidama Bunna', 'Dire Dawa FC',
    ];

    for (int i = 0; i < 10; i++) {
      final id = 'player$i';
      final isForward = i % 2 == 0;

      _mockProfiles[id] = PlayerProfileModel(
        id: id,
        username: names[i],
        email: '${names[i].toLowerCase()}@goalconnect.com',
        role: 'player',
        profileImage:
            'https://ui-avatars.com/api/?name=${names[i]}&background=00D084&color=000&size=150',
        position: isForward ? 'Forward' : 'Midfielder',
        age: 15 + (i % 4),
        country: 'Ethiopia',
        bio: bios[i],
        highlightsCount: 8 + (i * 3),
        followersCount: 120 + (i * 47),
        followingCount: 30 + (i * 8),
        totalLikes: 348 + (i * 123),
        isFollowing: false,
        stats: PlayerStatsModel(
          pace: 65 + (i * 3) % 30,
          shooting: 60 + (i * 5) % 30,
          passing: 55 + (i * 4) % 35,
          dribbling: 70 + (i * 2) % 25,
          defending: isForward ? 30 + (i * 3) % 20 : 60 + (i * 3) % 25,
          physical: 55 + (i * 3) % 30,
          preferredFoot: i % 3 == 0 ? 'Left' : 'Right',
          heightCm: 165 + (i * 3) % 20,
          weightKg: 60 + (i * 2) % 15,
          currentClub: clubs[i],
          matchesPlayed: 20 + (i * 7),
          goals: isForward ? 8 + (i * 3) : 2 + i,
          assists: isForward ? 3 + i : 5 + (i * 2),
        ),
      );
    }
  }

  @override
  Future<PlayerProfileModel> getPlayerProfile(String playerId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final profile = _mockProfiles[playerId];
    if (profile == null) throw Exception('Player not found');

    final isFollowing = _followState[playerId] ?? false;

    return PlayerProfileModel(
      id: profile.id,
      username: profile.username,
      email: profile.email,
      role: profile.role,
      profileImage: profile.profileImage,
      position: profile.position,
      age: profile.age,
      country: profile.country,
      bio: profile.bio,
      highlightsCount: profile.highlightsCount,
      followersCount: profile.followersCount + (isFollowing ? 1 : 0),
      followingCount: profile.followingCount,
      totalLikes: profile.totalLikes,
      isFollowing: isFollowing,
      stats: profile.stats,
    );
  }

  @override
  Future<bool> toggleFollow(String playerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final current = _followState[playerId] ?? false;
    _followState[playerId] = !current;
    return !current;
  }

  @override
  Future<PlayersListResult> listPlayers({
    required int page,
    required int limit,
    String? search,
    String? position,
    String? strongFoot,
    int? minAge,
    int? maxAge,
    int? minHeight,
    int? maxHeight,
    String? sortBy,
    String? sortOrder,
    String? meta,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var list = _mockProfiles.values.toList();
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list
          .where(
            (p) =>
                p.username.toLowerCase().contains(q) ||
                (p.bio?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }
    final start = (page - 1) * limit;
    final slice = start < list.length
        ? list.skip(start).take(limit).toList()
        : <PlayerProfileModel>[];
    return PlayersListResult(
      players: slice,
      page: page,
      pages: (list.length / limit).ceil().clamp(1, 999),
      total: list.length,
      count: slice.length,
    );
  }

  final Set<String> _savedIds = <String>{};

  @override
  Future<List<PlayerProfileModel>> getSavedPlayers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _savedIds
        .map((id) => _mockProfiles[id])
        .whereType<PlayerProfileModel>()
        .toList();
  }

  @override
  Future<void> savePlayer(String playerId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _savedIds.add(playerId);
  }

  @override
  Future<void> unsavePlayer(String playerId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _savedIds.remove(playerId);
  }
}
