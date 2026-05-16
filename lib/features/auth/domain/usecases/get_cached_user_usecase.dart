import '../repositories/auth_repository.dart';

class GetCachedUserUsecase {
  final AuthRepository repository;

  GetCachedUserUsecase(this.repository);

  Future<CurrentUserData?> call() => repository.getCachedUser();
}
