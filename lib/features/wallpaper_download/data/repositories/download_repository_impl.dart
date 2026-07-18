import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/downloaded_wallpaper_entity.dart';
import '../../domain/repositories/download_repository.dart';
import '../datasources/local_download_datasource.dart';

/// Implementation of DownloadRepository.
/// Handles downloading wallpapers, managing permissions, and storing metadata.
class DownloadRepositoryImpl implements DownloadRepository {
  final LocalDownloadDataSource _localDataSource;
  final Dio _dio;

  DownloadRepositoryImpl({
    required LocalDownloadDataSource localDataSource,
    required Dio dio,
  })  : _localDataSource = localDataSource,
        _dio = dio;

  @override
  Future<Either<Failure, Stream<double>>> downloadWallpaper({
    required String imageUrl,
    required String wallpaperId,
    required String title,
  }) async {
    try {
      // Check if already downloaded
      final isAlreadyDownloaded = await _localDataSource.isDownloaded(wallpaperId);
      if (isAlreadyDownloaded) {
        return Right(Stream.value(1.0));
      }

      // Request storage permission
      final permissionStatus = await _requestStoragePermission();
      if (!permissionStatus) {
        return Left(PermissionFailure('Storage permission denied'));
      }

      // Get download directory
      final downloadDir = await _getDownloadDirectory();
      if (downloadDir == null) {
        return Left(ServerFailure('Could not access storage'));
      }

      // Generate unique filename
      final fileName = _generateFileName(wallpaperId);
      final filePath = '${downloadDir.path}/$fileName';

      // Create progress stream controller
      late StreamController<double> progressController;
      progressController = StreamController<double>();

      // Start download in background
      _performDownload(
        imageUrl: imageUrl,
        wallpaperId: wallpaperId,
        title: title,
        filePath: filePath,
        progressController: progressController,
      ).catchError((e) {
        if (!progressController.isClosed) {
          progressController.addError(e);
          progressController.close();
        }
      });

      return Right(progressController.stream);
    } catch (e) {
      return Left(ServerFailure('Download failed: ${e.toString()}'));
    }
  }

  /// Performs the actual download in the background.
  Future<void> _performDownload({
    required String imageUrl,
    required String wallpaperId,
    required String title,
    required String filePath,
    required StreamController<double> progressController,
  }) async {
    try {
      // Download with progress
      await _dio.download(
        imageUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            if (!progressController.isClosed) {
              progressController.add(progress);
            }
          }
        },
      );

      // Get file info
      final file = File(filePath);
      final fileSize = await file.length();

      // Save metadata
      final download = DownloadedWallpaperEntity(
        id: const Uuid().v4(),
        wallpaperId: wallpaperId,
        title: title,
        cloudinaryUrl: imageUrl,
        localPath: filePath,
        downloadedAt: DateTime.now(),
        fileSize: fileSize,
      );

      await _localDataSource.saveDownload(download);

      // Notify completion
      if (!progressController.isClosed) {
        progressController.add(1.0);
        progressController.close();
      }
    } catch (e) {
      // Cleanup on error
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}

      if (!progressController.isClosed) {
        progressController.addError(e);
        progressController.close();
      }
    }
  }

  @override
  Future<Either<Failure, List<DownloadedWallpaperEntity>>> getDownloadedWallpapers() async {
    try {
      final downloads = await _localDataSource.getAllDownloads();
      // Filter out files that no longer exist on device
      final validDownloads = <DownloadedWallpaperEntity>[];
      for (final download in downloads) {
        final file = File(download.localPath);
        if (await file.exists()) {
          validDownloads.add(download);
        } else {
          // Delete metadata if file doesn't exist
          await _localDataSource.deleteDownload(download.wallpaperId);
        }
      }
      return Right(validDownloads);
    } catch (e) {
      return Left(ServerFailure('Failed to get downloads: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isDownloaded(String wallpaperId) async {
    try {
      final isDownloaded = await _localDataSource.isDownloaded(wallpaperId);
      if (!isDownloaded) {
        return const Right(false);
      }

      // Check if file still exists
      final download = await _localDataSource.getDownload(wallpaperId);
      if (download != null) {
        final file = File(download.localPath);
        if (await file.exists()) {
          return const Right(true);
        } else {
          // File deleted, clean up metadata
          await _localDataSource.deleteDownload(wallpaperId);
          return const Right(false);
        }
      }

      return const Right(false);
    } catch (e) {
      return Left(ServerFailure('Failed to check download: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DownloadedWallpaperEntity>> getDownload(String wallpaperId) async {
    try {
      final download = await _localDataSource.getDownload(wallpaperId);
      if (download == null) {
        return Left(NotFoundFailure('Download not found'));
      }

      // Verify file exists
      final file = File(download.localPath);
      if (!await file.exists()) {
        await _localDataSource.deleteDownload(wallpaperId);
        return Left(NotFoundFailure('File not found'));
      }

      return Right(download);
    } catch (e) {
      return Left(ServerFailure('Failed to get download: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDownload(String wallpaperId) async {
    try {
      final download = await _localDataSource.getDownload(wallpaperId);
      if (download != null) {
        final file = File(download.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      await _localDataSource.deleteDownload(wallpaperId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete download: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> getLocalPath(String wallpaperId) async {
    try {
      final download = await _localDataSource.getDownload(wallpaperId);
      if (download == null) {
        return Left(NotFoundFailure('Download not found'));
      }

      // Verify file exists
      final file = File(download.localPath);
      if (!await file.exists()) {
        await _localDataSource.deleteDownload(wallpaperId);
        return Left(NotFoundFailure('File not found'));
      }

      return Right(download.localPath);
    } catch (e) {
      return Left(ServerFailure('Failed to get path: ${e.toString()}'));
    }
  }

  /// Request storage permission based on Android version.
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+ requires READ_MEDIA_IMAGES instead of READ_EXTERNAL_STORAGE
      final status = await Permission.photos.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true; // Other platforms don't need permission
  }

  /// Get the appropriate download directory for the platform.
  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Android: Download directory
      return Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      // iOS: Documents directory
      return getApplicationDocumentsDirectory();
    }
    // Fallback
    return getTemporaryDirectory();
  }

  /// Generate a unique, safe filename.
  String _generateFileName(String wallpaperId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'wallr_${wallpaperId}_$timestamp.jpg';
  }
}
