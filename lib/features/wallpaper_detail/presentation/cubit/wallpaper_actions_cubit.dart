// lib/features/wallpaper_detail/presentation/cubit/wallpaper_actions_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/wallpaper_service.dart';
import 'wallpaper_actions_state.dart';

/// Drives the per-wallpaper device actions on the detail screen:
/// setting the wallpaper (home / lock / both) and a local favourite toggle.
///
/// Registered as a factory in DI — one instance per detail screen.
class WallpaperActionsCubit extends Cubit<WallpaperActionsState> {
  final WallpaperService _service;

  WallpaperActionsCubit({required WallpaperService service})
      : _service = service,
        super(const WallpaperActionsState());

  void toggleFavourite() {
    emit(state.copyWith(isFavourited: !state.isFavourited));
  }

  /// Downloads the full image (in a background isolate) and applies it
  /// to the chosen [target].
  Future<void> setWallpaper({
    required String imageUrl,
    required String wallpaperId,
    required WallpaperTarget target,
  }) async {
    if (state.isBusy) return;

    emit(state.copyWith(
      status: WallpaperActionStatus.settingWallpaper,
      activeTarget: target,
    ));

    try {
      final ok = await _service.setWallpaper(
        imageUrl: imageUrl,
        wallpaperId: wallpaperId,
        target: target,
      );

      if (ok) {
        emit(state.copyWith(
          status: WallpaperActionStatus.success,
          message: 'Wallpaper set on ${target.label}.',
        ));
      } else {
        emit(state.copyWith(
          status: WallpaperActionStatus.failure,
          message: 'Couldn\'t set the wallpaper. Please try again.',
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        status: WallpaperActionStatus.failure,
        message: 'Something went wrong while setting the wallpaper.',
      ));
    } finally {
      // Return to idle so the UI button re-enables, keeping favourite state.
      emit(state.copyWith(status: WallpaperActionStatus.idle));
    }
  }

  /// Downloads the wallpaper to device gallery.
  /// (Currently shows "coming soon" — full implementation pending)
  Future<void> downloadWallpaper({
    required String imageUrl,
    required String wallpaperId,
    required String fileName,
  }) async {
    emit(state.copyWith(
      status: WallpaperActionStatus.success,
      message: 'Download feature coming soon.',
    ));

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!isClosed) emit(state.copyWith(status: WallpaperActionStatus.idle));
    });
  }
}
