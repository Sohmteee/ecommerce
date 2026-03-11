/// Base class for all application failures.
abstract class Failure {
  /// A human-readable message describing the failure.
  final String message;
  Failure(this.message);
}

/// Represents a failure occurring on the server side.
class ServerFailure extends Failure {
  ServerFailure(super.message);
}

/// Represents a failure due to network connectivity issues.
class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

/// Represents a failure related to local caching operations.
class CacheFailure extends Failure {
  CacheFailure(super.message);
}
