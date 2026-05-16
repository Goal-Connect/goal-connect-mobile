import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/current_user_profile.dart';
import '../models/player_profile_model.dart';
import '../models/scout_profile_model.dart';
import '../models/user_model.dart';

abstract class AuthUserLocalDataSource {
  Future<void> saveUserAndProfile({
    required UserModel user,
    String? profileJson,
  });

  Future<UserModel?> readCachedUser();

  /// Reads the cached `/auth/me` profile, branched by the cached user's role.
  /// Returns `null` when nothing is cached, role is non-player/scout, or the
  /// payload can't be parsed.
  Future<CurrentUserProfile?> readCachedProfile();

  Future<void> clear();
}

class AuthUserLocalDataSourceImpl implements AuthUserLocalDataSource {
  static const _userJsonKey = 'auth_cached_user_json';
  static const _profileJsonKey = 'auth_cached_me_profile_json';

  final SharedPreferences _prefs;

  AuthUserLocalDataSourceImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  @override
  Future<void> saveUserAndProfile({
    required UserModel user,
    String? profileJson,
  }) async {
    await _prefs.setString(_userJsonKey, jsonEncode(user.toJson()));
    if (profileJson != null && profileJson.isNotEmpty) {
      await _prefs.setString(_profileJsonKey, profileJson);
    } else {
      await _prefs.remove(_profileJsonKey);
    }
  }

  @override
  Future<UserModel?> readCachedUser() async {
    final raw = _prefs.getString(_userJsonKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final map = jsonDecode(raw);
      if (map is! Map) {
        return null;
      }
      return UserModel.fromJson(Map<String, dynamic>.from(map));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CurrentUserProfile?> readCachedProfile() async {
    final raw = _prefs.getString(_profileJsonKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final user = await readCachedUser();
    if (user == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      switch (user.role) {
        case 'player':
          return CurrentUserProfilePlayer(PlayerProfileModel.fromJson(map));
        case 'scout':
          return CurrentUserProfileScout(ScoutProfileModel.fromJson(map));
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_userJsonKey);
    await _prefs.remove(_profileJsonKey);
  }
}
