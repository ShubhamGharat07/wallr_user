import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/downloaded_wallpaper_entity.dart';
import '../models/downloaded_wallpaper_model.dart';

/// Abstract data source for local download metadata storage.
abstract class LocalDownloadDataSource {
  /// Save download metadata locally.
  Future<void> saveDownload(DownloadedWallpaperEntity download);

  /// Get all downloaded wallpapers metadata.
  Future<List<DownloadedWallpaperEntity>> getAllDownloads();

  /// Get metadata for a specific download.
  Future<DownloadedWallpaperEntity?> getDownload(String wallpaperId);

  /// Delete download metadata and file.
  Future<void> deleteDownload(String wallpaperId);

  /// Check if a wallpaper is downloaded.
  Future<bool> isDownloaded(String wallpaperId);
}

/// Implementation of LocalDownloadDataSource using SharedPreferences.
/// Each downloaded wallpaper is stored with key: "download_{wallpaperId}"
class LocalDownloadDataSourceImpl implements LocalDownloadDataSource {
  static const String _prefix = 'download_';

  final SharedPreferences _prefs;

  LocalDownloadDataSourceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<void> saveDownload(DownloadedWallpaperEntity download) async {
    final model = DownloadedWallpaperModel.fromEntity(download);
    final key = '$_prefix${download.wallpaperId}';
    await _prefs.setString(key, model.toJsonString());
  }

  @override
  Future<List<DownloadedWallpaperEntity>> getAllDownloads() async {
    final downloads = <DownloadedWallpaperEntity>[];
    final keys = _prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_prefix)) {
        final jsonString = _prefs.getString(key);
        if (jsonString != null) {
          try {
            final model = DownloadedWallpaperModel.fromJsonString(jsonString);
            downloads.add(model);
          } catch (_) {
            // Corrupted data, skip
          }
        }
      }
    }

    return downloads;
  }

  @override
  Future<DownloadedWallpaperEntity?> getDownload(String wallpaperId) async {
    final key = '$_prefix$wallpaperId';
    final jsonString = _prefs.getString(key);

    if (jsonString == null) return null;

    try {
      return DownloadedWallpaperModel.fromJsonString(jsonString);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteDownload(String wallpaperId) async {
    final key = '$_prefix$wallpaperId';
    await _prefs.remove(key);
  }

  @override
  Future<bool> isDownloaded(String wallpaperId) async {
    final key = '$_prefix$wallpaperId';
    return _prefs.containsKey(key);
  }
}
