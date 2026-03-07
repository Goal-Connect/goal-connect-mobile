import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email == "test@test.com" && password == "1234") {
      return UserModel(id: "1", email: email, role: "scout");
    } else {
      throw Exception();
    }
  }
}

class MockAuthRemoteDataSource extends AuthRemoteDataSource {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email == "scout@test.com" && password == "123456") {
      return UserModel(id: "1", email: email, role: "scout");
    }

    if (email == "academy@test.com" && password == "123456") {
      return UserModel(id: "2", email: email, role: "academy");
    }

    throw Exception("Invalid credentials");
  }
}
