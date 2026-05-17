import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:goal_connect/core/constants/api_constants.dart';
import 'package:goal_connect/features/auth/data/models/auth_remote_session.dart';
import 'package:goal_connect/features/auth/data/models/player_profile_model.dart';
import 'package:goal_connect/features/auth/data/models/scout_account_registration_model.dart';
import 'package:goal_connect/features/auth/data/models/scout_profile_model.dart';
import 'package:goal_connect/features/auth/data/models/user_model.dart';
import 'package:goal_connect/features/auth/domain/entities/current_user_profile.dart';

class AuthApiException implements Exception {
  final String message;
  final int? statusCode;

  AuthApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

abstract class AuthRemoteDataSource {
  Future<AuthRemoteSession> login({
    required String email,
    required String password,
  });

  Future<AuthRemoteSession> createScoutAccount(
    ScoutAccountRegistrationModel registration,
  );

  /// `GET /auth/me` — returns parsed user, the role-branched profile
  /// (when present), and the raw `profile` JSON for caching.
  Future<({UserModel user, CurrentUserProfile? profile, String? profileJson})>
      getCurrentUser();

  /// `PUT /auth/updatepassword` — returns new session (README: fresh JWT + user).
  Future<AuthRemoteSession> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// `POST /auth/logout` — server acknowledges; client must still clear JWT.
  Future<void> logoutAck();

  /// `POST /auth/forgot-password` — request a password reset email.
  /// Always returns HTTP 200 (anti-enumeration). Returns the server message.
  Future<String> forgotPassword(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<AuthRemoteSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.authLogin,
        data: <String, dynamic>{
          'email': email.trim(),
          'password': password,
        },
      );
      return _parseAuthSuccess(response.data);
    } on DioException catch (e) {
      throw AuthApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AuthRemoteSession> createScoutAccount(
    ScoutAccountRegistrationModel registration,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.authRegister,
        data: registration.toAuthRegisterRequestJson(),
      );
      return _parseAuthSuccess(response.data);
    } on DioException catch (e) {
      throw AuthApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<({UserModel user, CurrentUserProfile? profile, String? profileJson})>
      getCurrentUser() async {
    try {
      final response = await _dio.get<dynamic>(ApiConstants.authMe);
      final body = response.data;
      if (body is! Map) {
        throw AuthApiException('Invalid response from server');
      }
      final map = Map<String, dynamic>.from(body);
      if (map['success'] != true) {
        throw AuthApiException(
          map['message'] as String? ?? 'Request failed',
          statusCode: null,
        );
      }
      final data = map['data'];
      if (data is! Map) {
        throw AuthApiException('Invalid response from server');
      }
      final dataMap = Map<String, dynamic>.from(data);
      final user = UserModel.fromMeEnvelope(dataMap);
      CurrentUserProfile? profile;
      String? profileJson;
      final prof = dataMap['profile'];
      if (prof is Map && prof.isNotEmpty) {
        final profMap = Map<String, dynamic>.from(prof);
        profile = _parseProfileForRole(user.role, profMap);
        profileJson = jsonEncode(profMap);
      }
      return (user: user, profile: profile, profileJson: profileJson);
    } on DioException catch (e) {
      throw AuthApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  CurrentUserProfile? _parseProfileForRole(
    String role,
    Map<String, dynamic> profileJson,
  ) {
    switch (role) {
      case 'player':
        return CurrentUserProfilePlayer(
          PlayerProfileModel.fromJson(profileJson),
        );
      case 'scout':
        return CurrentUserProfileScout(
          ScoutProfileModel.fromJson(profileJson),
        );
      default:
        return null;
    }
  }

  @override
  Future<AuthRemoteSession> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        ApiConstants.authUpdatePassword,
        data: <String, dynamic>{
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      return _parseAuthSuccess(response.data);
    } on DioException catch (e) {
      throw AuthApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> logoutAck() async {
    try {
      await _dio.post<dynamic>(ApiConstants.authLogout);
    } on DioException catch (e) {
      throw AuthApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<String> forgotPassword(String email) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.authForgotPassword,
        data: <String, dynamic>{'email': email},
      );
      final data = response.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
      return 'If an account with that email exists, '
          'a password reset link has been sent.';
    } on DioException catch (e) {
      throw AuthApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  AuthRemoteSession _parseAuthSuccess(dynamic data) {
    if (data is! Map) {
      throw AuthApiException('Invalid response from server');
    }
    final map = Map<String, dynamic>.from(data);
    if (map['success'] != true) {
      final msg = map['message'] as String? ?? 'Request failed';
      throw AuthApiException(msg);
    }
    final token = map['token'] as String? ?? '';
    final user = UserModel.fromAuthSuccessPayload(map);
    return AuthRemoteSession(user: user, token: token);
  }

  String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final msg = map['message'] as String?;
      if (msg != null && msg.isNotEmpty) {
        return msg;
      }
      final errors = map['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;
        if (first is Map && first['msg'] is String) {
          return first['msg'] as String;
        }
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
}
