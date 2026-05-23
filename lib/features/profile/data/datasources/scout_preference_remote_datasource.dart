import 'package:dio/dio.dart';
import 'package:goal_connect/core/constants/api_constants.dart';
import 'package:goal_connect/features/profile/data/models/scout_preference_model.dart';

class ScoutPreferenceApiException implements Exception {
  final String message;

  ScoutPreferenceApiException(this.message);

  @override
  String toString() => message;
}

abstract class ScoutPreferenceRemoteDataSource {
  /// Returns the saved preference, or `null` if none exists or the
  /// backend does not expose a GET endpoint (404/405).
  Future<ScoutPreferenceModel?> getPreference();

  Future<ScoutPreferenceModel> savePreference(ScoutPreferenceModel preference);

  Future<ScoutPreferenceModel> updatePreference(
    ScoutPreferenceModel preference,
  );

  Future<void> deletePreference();
}

class ScoutPreferenceRemoteDataSourceImpl
    implements ScoutPreferenceRemoteDataSource {
  ScoutPreferenceRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

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

  ScoutPreferenceModel _parseEnvelope(dynamic body, ScoutPreferenceModel fallback) {
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      final data = map['data'];
      if (data is Map) {
        return ScoutPreferenceModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
    }
    return fallback;
  }

  @override
  Future<ScoutPreferenceModel?> getPreference() async {
    try {
      final response = await _dio.get<dynamic>(ApiConstants.scoutsPreferences);
      final body = response.data;
      if (body is Map) {
        final map = Map<String, dynamic>.from(body);
        final data = map['data'];
        if (data is Map) {
          return ScoutPreferenceModel.fromJson(
            Map<String, dynamic>.from(data),
          );
        }
        // Endpoints sometimes return the payload at the top level.
        return ScoutPreferenceModel.fromJson(map);
      }
      return null;
    } on DioException catch (e) {
      // Treat "not found" / "no preference saved yet" as a soft null
      // instead of an error.
      final status = e.response?.statusCode;
      if (status == 404 || status == 405) return null;
      throw ScoutPreferenceApiException(_messageFromDio(e));
    }
  }

  @override
  Future<ScoutPreferenceModel> savePreference(
    ScoutPreferenceModel preference,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.scoutsPreferences,
        data: preference.toJson(),
      );
      return _parseEnvelope(response.data, preference);
    } on DioException catch (e) {
      throw ScoutPreferenceApiException(_messageFromDio(e));
    }
  }

  @override
  Future<ScoutPreferenceModel> updatePreference(
    ScoutPreferenceModel preference,
  ) async {
    try {
      final response = await _dio.put<dynamic>(
        ApiConstants.scoutsPreferences,
        data: preference.toJson(),
      );
      return _parseEnvelope(response.data, preference);
    } on DioException catch (e) {
      throw ScoutPreferenceApiException(_messageFromDio(e));
    }
  }

  @override
  Future<void> deletePreference() async {
    try {
      await _dio.delete<dynamic>(ApiConstants.scoutsPreferences);
    } on DioException catch (e) {
      throw ScoutPreferenceApiException(_messageFromDio(e));
    }
  }
}
