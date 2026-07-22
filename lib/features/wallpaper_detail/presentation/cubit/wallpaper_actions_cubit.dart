// lib/features/wallpaper_detail/presentation/cubit/wallpaper_actions_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/services/wallpaper_service.dart';
import '../../../wallpaper_download/domain/repositories/download_repository.dart';
import '../../../wallpaper_favourite/domain/repositories/favorite_repository.dart';
import 'wallpaper_actions_state.dart';

/// Drives the per-wallpaper device actions on the detail screen:
/// setting the wallpaper (home / lock / both), downloading, and favorite toggle.
///
/// Registered as a factory in DI — one instance per detail screen.
class WallpaperActionsCubit extends Cubit<WallpaperActionsState> {
  final WallpaperService _service;
  final DownloadRepository _downloadRepository;
  final FavoriteRepository _favoriteRepository;

  WallpaperActionsCubit({
    required WallpaperService service,
    required DownloadRepository downloadRepository,
    required FavoriteRepository favoriteRepository,
  })  : _service = service,
        _downloadRepository = downloadRepository,
        _favoriteRepository = favoriteRepository,
        super(const WallpaperActionsState());

  Future<void> checkIfFavorited(String wallpaperId) async {
    final result = await _favoriteRepository.isFavorited(wallpaperId);
    result.fold(
      (failure) {
        emit(state.copyWith(isFavourited: false));
      },
      (isFavorited) {
        emit(state.copyWith(isFavourited: isFavorited));
      },
    );
  }

  Future<void> toggleFavourite(String wallpaperId) async {
    final newState = !state.isFavourited;
    emit(state.copyWith(isFavourited: newState));

    if (newState) {
      await _favoriteRepository.addFavorite(wallpaperId);
    } else {
      await _favoriteRepository.removeFavorite(wallpaperId);
    }
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

  /// Downloads the wallpaper to device storage with progress tracking.
  Future<void> downloadWallpaper({
    required String imageUrl,
    required String wallpaperId,
    required String fileName,
  }) async {
    if (state.isBusy) return;

    try {
      // Check if already downloaded
      final isDownloaded = await _downloadRepository.isDownloaded(wallpaperId);
      if (isDownloaded.fold((failure) => false, (downloaded) => downloaded)) {
        emit(state.copyWith(
          status: WallpaperActionStatus.success,
          message: 'Already downloaded.',
          downloadProgress: 1.0,
        ));
        return;
      }

      // Request storage permission
      final permissionStatus = await Permission.photos.request();
      if (!permissionStatus.isGranted) {
        emit(state.copyWith(
          status: WallpaperActionStatus.failure,
          message: 'Storage permission denied.',
        ));
        return;
      }

      // Start download
      emit(state.copyWith(
        status: WallpaperActionStatus.downloading,
        downloadProgress: 0.0,
      ));

      // Start download via repository
      final result = await _downloadRepository.downloadWallpaper(
        imageUrl: imageUrl,
        wallpaperId: wallpaperId,
        title: fileName,
      );

      result.fold(
        (failure) {
          emit(state.copyWith(
            status: WallpaperActionStatus.failure,
            message: 'Download failed. Please try again.',
          ));
        },
        (progressStream) {
          // Listen to progress stream
          progressStream.listen(
            (progress) {
              if (!isClosed) {
                emit(state.copyWith(
                  status: WallpaperActionStatus.downloading,
                  downloadProgress: progress,
                ));
              }
            },
            onError: (error) {
              if (!isClosed) {
                emit(state.copyWith(
                  status: WallpaperActionStatus.failure,
                  message: 'Download failed: ${error.toString()}',
                ));
              }
            },
            onDone: () {
              if (!isClosed) {
                emit(state.copyWith(
                  status: WallpaperActionStatus.success,
                  message: 'Downloaded successfully!',
                  downloadProgress: 1.0,
                ));
              }
            },
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: WallpaperActionStatus.failure,
        message: 'Something went wrong: ${e.toString()}',
      ));
    } finally {
      // Auto-reset after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (!isClosed) {
        emit(state.copyWith(status: WallpaperActionStatus.idle));
      }
    }
  }
}

