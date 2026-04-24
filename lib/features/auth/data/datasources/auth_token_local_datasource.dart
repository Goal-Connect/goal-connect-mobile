import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthTokenLocalDataSource {
  Future<void> saveToken(String token);

  Future<void> clearToken();

  Future<String?> readToken();
}

class AuthTokenLocalDataSourceImpl implements AuthTokenLocalDataSource {
  static const _key = 'goal_connect_auth_jwt';

  final FlutterSecureStorage _storage;

  AuthTokenLocalDataSourceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveToken(String token) async {
    if (token.isEmpty) {
      await clearToken();
      return;
    }
    await _storage.write(key: _key, value: token);
  }

  @override
  Future<void> clearToken() => _storage.delete(key: _key);

  @override
  Future<String?> readToken() => _storage.read(key: _key);
}
