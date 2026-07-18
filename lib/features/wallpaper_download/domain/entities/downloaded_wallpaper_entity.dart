import 'package:equatable/equatable.dart';

/// Represents a wallpaper that has been downloaded to the device.
/// Tracks metadata for offline access and file management.
class DownloadedWallpaperEntity extends Equatable {
  final String id; // Unique identifier for this download record
  final String wallpaperId; // Reference to the original wallpaper
  final String title; // Wallpaper title
  final String cloudinaryUrl; // Original URL on Cloudinary
  final String localPath; // Full path to downloaded file on device
  final DateTime downloadedAt; // When it was downloaded
  final int fileSize; // File size in bytes

  const DownloadedWallpaperEntity({
    required this.id,
    required this.wallpaperId,
    required this.title,
    required this.cloudinaryUrl,
    required this.localPath,
    required this.downloadedAt,
    required this.fileSize,
  });

  @override
  List<Object> get props => [
        id,
        wallpaperId,
        title,
        cloudinaryUrl,
        localPath,
        downloadedAt,
        fileSize,
      ];
}
