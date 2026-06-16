import 'package:equatable/equatable.dart';

/// WALLR — Failure Classes
///
/// All repository/usecase errors are wrapped in a [Failure] subclass.
/// UI layer consumes these — never raw exceptions.
///
/// Pattern: Either<Failure, Success>  (dartz)

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// ─── Server / Remote ──────────────────────────────────────────────────────

/// Firebase / REST API returned an error response.
final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred.']);
}

/// The remote request timed out.
final class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'The request timed out.']);
}

// ─── Network ──────────────────────────────────────────────────────────────

/// Device is offline or has no internet connection.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

// ─── Authentication ───────────────────────────────────────────────────────

/// Firebase Auth or sign-in related error.
final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

/// The user is not signed in but a protected resource was accessed.
final class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure([super.message = 'User is not authenticated.']);
}

// ─── Cache / Local Storage ────────────────────────────────────────────────

/// SharedPreferences / local file read-write error.
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local data could not be accessed.']);
}

// ─── Permissions ──────────────────────────────────────────────────────────

/// A required OS permission was denied (storage, notifications, etc.).
final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission was denied.']);
}

/// A required OS permission is permanently denied.
final class PermissionPermanentlyDeniedFailure extends Failure {
  const PermissionPermanentlyDeniedFailure(
      [super.message = 'Permission permanently denied. Please enable it in Settings.']);
}

// ─── Validation ───────────────────────────────────────────────────────────

/// Input validation failed (email, password length, etc.).
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// ─── Premium / Paywall ────────────────────────────────────────────────────

/// User tried to access premium content without a subscription.
final class PremiumRequiredFailure extends Failure {
  const PremiumRequiredFailure(
      [super.message = 'This content requires a Premium subscription.']);
}

/// In-app purchase / RevenueCat error.
final class PurchaseFailure extends Failure {
  const PurchaseFailure([super.message = 'Purchase could not be completed.']);
}

// ─── Not Found ────────────────────────────────────────────────────────────

/// Requested resource (wallpaper, collection, etc.) was not found.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested item was not found.']);
}

// ─── Unknown ─────────────────────────────────────────────────────────────

/// Catch-all for unexpected errors.
final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
