import 'package:dio/dio.dart';
import 'package:goal_connect/core/constants/api_constants.dart';
import 'package:goal_connect/features/auth/data/models/auth_remote_session.dart';
import 'package:goal_connect/features/auth/data/models/scout_account_registration_model.dart';
import 'package:goal_connect/features/auth/data/models/user_model.dart';

class AuthApiException implements Exception {
  final String message;

  AuthApiException(this.message);

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
      throw AuthApiException(_messageFromDio(e));
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
      throw AuthApiException(_messageFromDio(e));
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
