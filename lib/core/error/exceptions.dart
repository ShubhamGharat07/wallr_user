/// WALLR — Custom Exceptions
///
/// Thrown by DataSource implementations.
/// Repository implementations catch these and map them to [Failure] objects.
///
/// Rule: Exceptions = data layer only.
///       Failures    = domain + presentation layer.

// ─── Server / Remote ──────────────────────────────────────────────────────

/// Thrown when a Firebase / HTTP call returns a non-success status.
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({this.message = 'Server error.', this.statusCode});

  @override
  String toString() =>
      'ServerException(message: $message, statusCode: $statusCode)';
}

/// Thrown when a network call times out.
class TimeoutException implements Exception {
  final String message;
  const TimeoutException({this.message = 'Request timed out.'});

  @override
  String toString() => 'TimeoutException(message: $message)';
}

// ─── Network ──────────────────────────────────────────────────────────────

/// Thrown when the device has no internet connection.
class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No internet connection.'});

  @override
  String toString() => 'NetworkException(message: $message)';
}

// ─── Authentication ───────────────────────────────────────────────────────

/// Thrown when Firebase Auth operations fail (wrong password, user not found).
class AuthException implements Exception {
  final String message;
  final String? code; // Firebase error code, e.g. 'user-not-found'
  const AuthException({this.message = 'Authentication failed.', this.code});

  @override
  String toString() => 'AuthException(code: $code, message: $message)';
}

// ─── Cache / Local Storage ────────────────────────────────────────────────

/// Thrown when SharedPreferences or file I/O operations fail.
class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache read/write failed.'});

  @override
  String toString() => 'CacheException(message: $message)';
}

// ─── Permissions ──────────────────────────────────────────────────────────

/// Thrown when a required OS permission is denied.
class PermissionException implements Exception {
  final String message;
  final bool isPermanentlyDenied;
  const PermissionException({
    this.message = 'Permission denied.',
    this.isPermanentlyDenied = false,
  });

  @override
  String toString() =>
      'PermissionException(message: $message, permanent: $isPermanentlyDenied)';
}

// ─── Premium ──────────────────────────────────────────────────────────────

/// Thrown when premium-only content is accessed by a free user.
class PremiumRequiredException implements Exception {
  final String message;
  const PremiumRequiredException(
      {this.message = 'Premium subscription required.'});

  @override
  String toString() => 'PremiumRequiredException(message: $message)';
}

/// Thrown when a RevenueCat / in-app purchase fails.
class PurchaseException implements Exception {
  final String message;
  const PurchaseException({this.message = 'Purchase failed.'});

  @override
  String toString() => 'PurchaseException(message: $message)';
}

// ─── Not Found ────────────────────────────────────────────────────────────

/// Thrown when a Firestore document or resource does not exist.
class NotFoundException implements Exception {
  final String message;
  const NotFoundException({this.message = 'Resource not found.'});

  @override
  String toString() => 'NotFoundException(message: $message)';
}
