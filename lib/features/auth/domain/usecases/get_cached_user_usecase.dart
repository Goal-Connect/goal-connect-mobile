import 'package:goal_connect/features/auth/domain/entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCachedUserUsecase {
  final AuthRepository repository;

  GetCachedUserUsecase(this.repository);

  Future<User?> call() => repository.getCachedUser();
}
