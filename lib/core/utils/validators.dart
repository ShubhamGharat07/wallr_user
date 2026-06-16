/// WALLR — Form Validators
///
/// Pure functions — no Flutter/context dependency.
/// Used in: AuthScreen text fields, Settings, Create Collection dialog.
///
/// Returns `null` if valid (Flutter validator contract).
/// Returns an error [String] if invalid.

abstract final class Validators {
  // ─── Email ────────────────────────────────────────────────────

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  /// Returns `null` if email is valid, error string otherwise.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email cannot be empty';
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ─── Password ─────────────────────────────────────────────────

  /// Min 8 characters.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password cannot be empty';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  /// Password confirmation match.
  static String? confirmPassword(String? value, String original) {
    final baseError = password(value);
    if (baseError != null) return baseError;
    if (value != original) return 'Passwords do not match';
    return null;
  }

  // ─── Name ─────────────────────────────────────────────────────

  /// Non-empty, min 2 chars, max 50 chars.
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name cannot be empty';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    if (value.trim().length > 50) return 'Name must be under 50 characters';
    return null;
  }

  // ─── Collection Name ──────────────────────────────────────────

  /// Non-empty, max 50 chars.
  static String? collectionName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Collection name cannot be empty';
    }
    if (value.trim().length > 50) return 'Name must be under 50 characters';
    return null;
  }

  // ─── Generic Non-Empty ────────────────────────────────────────

  /// Simple non-empty check — use as fallback for unspecified fields.
  static String? nonEmpty(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$label cannot be empty';
    return null;
  }
}
