import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:goal_connect/core/constants/api_constants.dart';
import 'package:goal_connect/features/auth/data/models/auth_remote_session.dart';
import 'package:goal_connect/features/auth/data/models/scout_account_registration_model.dart';
import 'package:goal_connect/features/auth/data/models/user_model.dart';

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

  /// `GET /auth/me` — returns parsed user and optional JSON string of `profile`.
  Future<(UserModel user, String? profileJson)> getCurrentUser();

  /// `PUT /auth/updatepassword` — returns new session (README: fresh JWT + user).
  Future<AuthRemoteSession> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
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
  Future<(UserModel, String?)> getCurrentUser() async {
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
      String? profileJson;
      final prof = dataMap['profile'];
      if (prof is Map && prof.isNotEmpty) {
        profileJson = jsonEncode(prof);
      }
      return (user, profileJson);
    } on DioException catch (e) {
      throw AuthApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
      );
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
