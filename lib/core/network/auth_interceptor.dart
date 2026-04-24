import 'package:dio/dio.dart';
import 'package:goal_connect/features/auth/data/datasources/auth_token_local_datasource.dart';

/// Attaches `Authorization: Bearer <token>` when a JWT is stored.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens);

  final AuthTokenLocalDataSource _tokens;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokens.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
