import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/scout_preference_model.dart';

abstract class ScoutPreferenceLocalDataSource {
  Future<ScoutPreferenceModel?> read();
  Future<void> write(ScoutPreferenceModel preference);
  Future<void> clear();
}

class ScoutPreferenceLocalDataSourceImpl
    implements ScoutPreferenceLocalDataSource {
  ScoutPreferenceLocalDataSourceImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  static const _key = 'scout_preference_v1';

  final SharedPreferences _prefs;

  @override
  Future<ScoutPreferenceModel?> read() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return ScoutPreferenceModel.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> write(ScoutPreferenceModel preference) async {
    await _prefs.setString(_key, jsonEncode(preference.toJson()));
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
