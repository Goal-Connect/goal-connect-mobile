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
      return UserModel(
        id: "1",
        email: email,
        role: "scout",
        username: "scout_1",
        profileImage: "https://example.com/scout.jpg",
        position: "Scout",
        age: 30,
        country: "Ethiopia",
      );
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
      return UserModel(
        id: "1",
        email: email,
        role: "scout",
        username: "scout_master",
        profileImage: "https://example.com/scout.jpg",
        position: "Scout",
        age: 35,
        country: "Ethiopia",
      );
    }

    if (email == "academy@test.com" && password == "123456") {
      return UserModel(
        id: "2",
        email: email,
        role: "academy",
        username: "academy_admin",
        profileImage: "https://example.com/academy.jpg",
        position: "Coach",
        age: 40,
        country: "Ethiopia",
      );
    }

    throw Exception("Invalid credentials");
  }
}
