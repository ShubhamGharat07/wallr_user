// lib/core/services/wallpaper_service.dart

import 'dart:async';
import 'dart:io';

import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/isolate_helper.dart';

/// Where the wallpaper should be applied.
enum WallpaperTarget { home, lock, both }

extension WallpaperTargetX on WallpaperTarget {
  /// Maps to the `async_wallpaper` location constants.
  int get location => switch (this) {
        WallpaperTarget.home => AsyncWallpaper.HOME_SCREEN,
        WallpaperTarget.lock => AsyncWallpaper.LOCK_SCREEN,
        WallpaperTarget.both => AsyncWallpaper.BOTH_SCREENS,
      };

  String get label => switch (this) {
        WallpaperTarget.home => 'Home screen',
        WallpaperTarget.lock => 'Lock screen',
        WallpaperTarget.both => 'Home & Lock screen',
      };
}

/// WALLR — Wallpaper Service
///
/// Handles the two device-level operations the detail screen needs:
///   • Download the full-resolution image to a local file (off the UI
///     thread via [IsolateHelper] — the network read + disk write happen
///     in a background isolate so a 8 MB 4K download never janks the UI).
///   • Apply that file as the device wallpaper (home / lock / both) using
///     the native `async_wallpaper` platform channel.
///
/// Throws on failure — callers (cubit) map exceptions to a Failure/message.
class WallpaperService {
  final Dio _dio;

  WallpaperService({Dio? dio}) : _dio = dio ?? Dio();

  /// Downloads [imageUrl] into the app cache and returns the saved [File].
  /// Runs entirely in a background isolate.
  Future<File> downloadToCache({
    required String imageUrl,
    required String wallpaperId,
  }) async {
    final dir = await getTemporaryDirectory();
    final savePath = '${dir.path}/wallr_$wallpaperId.jpg';
    return IsolateHelper.downloadFile(url: imageUrl, savePath: savePath);
  }

  /// Downloads [imageUrl] (in an isolate) then sets it as the wallpaper on
  /// the chosen [target]. Returns `true` if the OS reported success.
  Future<bool> setWallpaper({
    required String imageUrl,
    required String wallpaperId,
    required WallpaperTarget target,
  }) async {
    final file = await downloadToCache(
      imageUrl: imageUrl,
      wallpaperId: wallpaperId,
    );

    return AsyncWallpaper.setWallpaperFromFile(
      filePath: file.path,
      wallpaperLocation: target.location,
      goToHome: false,
    );
  }

  /// Downloads [imageUrl] to device storage with progress tracking.
  /// Returns a Stream<double> that emits progress from 0.0 to 1.0.
  ///
  /// The file is saved to:
  /// - Android: Downloads folder (/storage/emulated/0/Download/)
  /// - iOS: Documents folder
  Stream<double> downloadToDeviceStorage({
    required String imageUrl,
    required String filePath,
  }) {
    return _performDownloadStream(imageUrl, filePath);
  }

  /// Performs the actual download with progress.
  Stream<double> _performDownloadStream(String url, String filePath) {
    final controller = StreamController<double>();

    _download(url, filePath, controller).then((_) {
      if (!controller.isClosed) {
        controller.close();
      }
    }).catchError((e) {
      if (!controller.isClosed) {
        controller.addError(e);
        controller.close();
      }
    });

    return controller.stream;
  }

  Future<void> _download(String url, String filePath, StreamController<double> controller) async {
    try {
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && !controller.isClosed) {
            controller.add(received / total);
          }
        },
      );
      if (!controller.isClosed) {
        controller.add(1.0); // Complete
      }
    } catch (e) {
      // Clean up on error
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
      rethrow;
    }
  }
}

