import 'package:permission_handler/permission_handler.dart';

/// WALLR — Permission Utilities
///
/// Wraps [permission_handler] with clean async helpers.
/// Returns structured [PermissionResult] — no raw booleans scattered in UI.
///
/// Usage:
///   final result = await PermissionUtils.requestStorage();
///   if (result.isGranted) { ... }
///   if (result.isPermanentlyDenied) { openAppSettings(); }

enum PermissionResult {
  granted,
  denied,
  permanentlyDenied,
  restricted, // iOS only
}

extension PermissionResultX on PermissionResult {
  bool get isGranted => this == PermissionResult.granted;
  bool get isDenied => this == PermissionResult.denied;
  bool get isPermanentlyDenied => this == PermissionResult.permanentlyDenied;
}

abstract final class PermissionUtils {
  // ─── Storage ──────────────────────────────────────────────────

  /// Request storage permission for saving wallpapers.
  /// On Android 13+ this maps to [Permission.photos].
  /// On Android ≤12 this maps to [Permission.storage].
  static Future<PermissionResult> requestStorage() async {
    // Android 13+ uses granular media permissions
    final permission = await _storagePermission().request();
    return _map(permission);
  }

  static Future<PermissionResult> checkStorage() async {
    final status = await _storagePermission().status;
    return _map(status);
  }

  static Permission _storagePermission() {
    // permission_handler handles version routing internally via Android SDK check
    return Permission.photos; // covers both old storage & new media
  }

  // ─── Notifications ────────────────────────────────────────────

  /// Request notification permission (Android 13+ / iOS).
  static Future<PermissionResult> requestNotifications() async {
    final status = await Permission.notification.request();
    return _map(status);
  }

  static Future<PermissionResult> checkNotifications() async {
    final status = await Permission.notification.status;
    return _map(status);
  }

  // ─── App Settings ─────────────────────────────────────────────

  /// Opens the OS app settings page — call when permanently denied.
  static Future<bool> openSettings() => openAppSettings();

  // ─── Mapper ───────────────────────────────────────────────────

  static PermissionResult _map(PermissionStatus status) {
    return switch (status) {
      PermissionStatus.granted => PermissionResult.granted,
      PermissionStatus.limited => PermissionResult.granted, // iOS limited
      PermissionStatus.permanentlyDenied => PermissionResult.permanentlyDenied,
      PermissionStatus.restricted => PermissionResult.restricted,
      _ => PermissionResult.denied,
    };
  }
}
