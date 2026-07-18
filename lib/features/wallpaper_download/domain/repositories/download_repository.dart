import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/downloaded_wallpaper_entity.dart';

/// Abstract repository for download operations.
/// Defines the contract for downloading wallpapers and managing local files.
abstract class DownloadRepository {
  /// Download a wallpaper from [imageUrl] and save it to device storage.
  /// Returns a stream of download progress (0.0 - 1.0).
  /// Returns Either<Failure, DownloadedWallpaperEntity> on completion.
  Future<Either<Failure, Stream<double>>> downloadWallpaper({
    required String imageUrl,
    required String wallpaperId,
    required String title,
  });

  /// Get all downloaded wallpapers.
  /// Returns Either<Failure, List<DownloadedWallpaperEntity>>
  Future<Either<Failure, List<DownloadedWallpaperEntity>>> getDownloadedWallpapers();

  /// Check if a wallpaper is already downloaded.
  /// Returns Either<Failure, bool>
  Future<Either<Failure, bool>> isDownloaded(String wallpaperId);

  /// Get metadata for a specific downloaded wallpaper.
  /// Returns Either<Failure, DownloadedWallpaperEntity>
  Future<Either<Failure, DownloadedWallpaperEntity>> getDownload(String wallpaperId);

  /// Delete a downloaded wallpaper file and its metadata.
  /// Returns Either<Failure, void>
  Future<Either<Failure, void>> deleteDownload(String wallpaperId);

  /// Get the local file path for a downloaded wallpaper.
  /// Returns Either<Failure, String> where String is the file path
  Future<Either<Failure, String>> getLocalPath(String wallpaperId);
}
