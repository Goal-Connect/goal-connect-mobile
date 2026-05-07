abstract class Failure {}

class ServerFailure extends Failure {}

class NetworkFailure extends Failure {}

class AuthFailure extends Failure {
  /// Server or client auth error message when available.
  final String? message;

  AuthFailure([this.message]);
}

class CacheFailure extends Failure {}

class ValidationFailure extends Failure {}

/// Chat / DM API or permission error with server message when available.
class ChatFailure extends Failure {
  final String message;

  ChatFailure(this.message);
}
