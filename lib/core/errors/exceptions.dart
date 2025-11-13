/// Base class for all exceptions
class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic data;

  const AppException({
    required this.message,
    this.code,
    this.data,
  });

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.data,
  });

  @override
  String toString() => 'ServerException(message: $message, code: $code)';
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.data,
  });

  @override
  String toString() => 'CacheException(message: $message, code: $code)';
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.data,
  });

  @override
  String toString() => 'NetworkException(message: $message, code: $code)';
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.data,
  });

  @override
  String toString() => 'AuthException(message: $message, code: $code)';
}

/// Validation-related exceptions
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.data,
  });

  @override
  String toString() => 'ValidationException(message: $message, code: $code)';
}

/// Permission-related exceptions
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.data,
  });

  @override
  String toString() => 'PermissionException(message: $message, code: $code)';
}

/// Not found exceptions (404)
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code,
    super.data,
  });

  @override
  String toString() => 'NotFoundException(message: $message, code: $code)';
}

/// Payment-related exceptions
class PaymentException extends AppException {
  const PaymentException({
    required super.message,
    super.code,
    super.data,
  });

  @override
  String toString() => 'PaymentException(message: $message, code: $code)';
}

/// Local storage-related exceptions (renamed to avoid conflict with Supabase StorageException)
class LocalStorageException extends AppException {
  const LocalStorageException({
    required super.message,
    super.code,
    super.data,
  });

  @override
  String toString() => 'LocalStorageException(message: $message, code: $code)';
}

/// Timeout exceptions
class TimeoutException extends AppException {
  const TimeoutException({
    required super.message,
    super.code,
    super.data,
  });

  @override
  String toString() => 'TimeoutException(message: $message, code: $code)';
}

/// Cancelled operation exceptions
class CancelledException extends AppException {
  const CancelledException({
    required super.message,
    super.code,
    super.data,
  });

  @override
  String toString() => 'CancelledException(message: $message, code: $code)';
}
