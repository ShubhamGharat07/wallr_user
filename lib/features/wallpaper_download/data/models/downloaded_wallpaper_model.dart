import 'dart:convert';

import '../../domain/entities/downloaded_wallpaper_entity.dart';
import '../../../home/domain/entities/wallpaper_entity.dart';

/// Model extending DownloadedWallpaperEntity.
/// Handles serialization/deserialization for SharedPreferences storage.
class DownloadedWallpaperModel extends DownloadedWallpaperEntity {
  const DownloadedWallpaperModel({
    required super.id,
    required super.wallpaperId,
    required super.title,
    required super.cloudinaryUrl,
    required super.localPath,
    required super.downloadedAt,
    required super.fileSize,
  });

  /// Creates a model from the entity.
  factory DownloadedWallpaperModel.fromEntity(DownloadedWallpaperEntity entity) {
    return DownloadedWallpaperModel(
      id: entity.id,
      wallpaperId: entity.wallpaperId,
      title: entity.title,
      cloudinaryUrl: entity.cloudinaryUrl,
      localPath: entity.localPath,
      downloadedAt: entity.downloadedAt,
      fileSize: entity.fileSize,
    );
  }

  /// Converts model to JSON for storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallpaperId': wallpaperId,
      'title': title,
      'cloudinaryUrl': cloudinaryUrl,
      'localPath': localPath,
      'downloadedAt': downloadedAt.toIso8601String(),
      'fileSize': fileSize,
    };
  }

  /// Creates model from JSON (stored data).
  factory DownloadedWallpaperModel.fromJson(Map<String, dynamic> json) {
    return DownloadedWallpaperModel(
      id: json['id'] as String,
      wallpaperId: json['wallpaperId'] as String,
      title: json['title'] as String,
      cloudinaryUrl: json['cloudinaryUrl'] as String,
      localPath: json['localPath'] as String,
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      fileSize: json['fileSize'] as int,
    );
  }

  /// Creates model from JSON string.
  factory DownloadedWallpaperModel.fromJsonString(String jsonString) {
    return DownloadedWallpaperModel.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  /// Converts model to JSON string for storage.
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Converts to WallpaperEntity for display in grid.
  /// Returns a minimal WallpaperEntity with downloaded wallpaper data.
  WallpaperEntity toWallpaperEntity() {
    return WallpaperEntity(
      id: wallpaperId,
      title: title,
      imageUrl: cloudinaryUrl,
      thumbnailUrl: cloudinaryUrl,
      categorySlug: '',
      resolution: 'HD',
      width: 0,
      height: 0,
      viewCount: 0,
      downloadCount: 0,
      isPremium: false,
      isEditorChoice: false,
      isTrendingPinned: false,
      tags: const [],
      authorName: '',
      authorHandle: '',
      authorAvatarUrl: '',
    );
  }
}

