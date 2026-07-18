// lib/features/wallpaper_detail/presentation/cubit/wallpaper_actions_state.dart

import 'package:equatable/equatable.dart';

import '../../../../core/services/wallpaper_service.dart';

enum WallpaperActionStatus { idle, settingWallpaper, downloading, success, failure }

class WallpaperActionsState extends Equatable {
  final WallpaperActionStatus status;

  /// Which target the in-progress / last set targeted (for UI feedback).
  final WallpaperTarget? activeTarget;

  /// Local-only favourite toggle (persisted favourites are a future feature).
  final bool isFavourited;

  /// Message to surface in a snackbar — success or error.
  final String? message;

  /// Download progress (0.0 to 1.0) for UI display.
  final double downloadProgress;

  const WallpaperActionsState({
    this.status = WallpaperActionStatus.idle,
    this.activeTarget,
    this.isFavourited = false,
    this.message,
    this.downloadProgress = 0.0,
  });

  bool get isBusy => status == WallpaperActionStatus.settingWallpaper ||
      status == WallpaperActionStatus.downloading;

  WallpaperActionsState copyWith({
    WallpaperActionStatus? status,
    WallpaperTarget? activeTarget,
    bool? isFavourited,
    String? message,
    double? downloadProgress,
  }) {
    return WallpaperActionsState(
      status: status ?? this.status,
      activeTarget: activeTarget ?? this.activeTarget,
      isFavourited: isFavourited ?? this.isFavourited,
      message: message,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  @override
  List<Object?> get props => [status, activeTarget, isFavourited, message, downloadProgress];
}
