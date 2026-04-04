import '../models/scout_account_registration_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> createScoutAccount(
    ScoutAccountRegistrationModel registration,
  );
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

  @override
  Future<UserModel> createScoutAccount(
    ScoutAccountRegistrationModel registration,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final username = registration.fullName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_');
    return UserModel(
      id: 'scout_${DateTime.now().millisecondsSinceEpoch}',
      email: registration.email.trim(),
      role: 'scout',
      username: username.isEmpty ? 'scout' : username,
      profileImage: registration.licencePhotoPath ??
          'https://example.com/scout_licence.jpg',
      position: 'Scout',
      age: 30,
      country: registration.country.trim(),
    );
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

  @override
  Future<UserModel> createScoutAccount(
    ScoutAccountRegistrationModel registration,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final username = registration.fullName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_');
    return UserModel(
      id: 'scout_${DateTime.now().millisecondsSinceEpoch}',
      email: registration.email.trim(),
      role: 'scout',
      username: username.isEmpty ? 'scout' : username,
      profileImage: registration.licencePhotoPath ??
          'https://example.com/scout_licence.jpg',
      position: 'Scout',
      age: 30,
      country: registration.country.trim(),
    );
  }
}
