import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;
  final int? code;
  final dynamic data;

  const Failure({
    required this.message,
    this.code,
    this.data,
  });

  @override
  List<Object?> get props => [message, code, data];

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// Validation-related failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// Not found failures (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// Payment-related failures
class PaymentFailure extends Failure {
  const PaymentFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// Storage-related failures
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// Generic failures
class GenericFailure extends Failure {
  const GenericFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// Cancelled operation failures
class CancelledFailure extends Failure {
  const CancelledFailure({
    required super.message,
    super.code,
    super.data,
  });
}
