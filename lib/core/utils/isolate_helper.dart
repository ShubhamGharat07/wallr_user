import 'dart:isolate';
import 'dart:io';

/// WALLR — Isolate Helper
///
/// Utility functions for running heavy operations off the main UI thread.
/// All Isolate operations return a Future — BLoC awaits them normally.
///
/// When to use Isolates:
///   ✅ File download + write to disk
///   ✅ Directory scan (Downloads screen)
///   ✅ Bulk file delete
///   ✅ Wallpaper set operation (large image decode)
///   ❌ UI updates, BLoC emits — must stay on main isolate

abstract final class IsolateHelper {
  // ─── Generic Compute ──────────────────────────────────────────

  /// Runs [computation] with [message] in a separate isolate.
  /// Equivalent to Flutter's `compute()` but explicit for clarity.
  ///
  /// ```dart
  /// final result = await IsolateHelper.run(heavyFunction, inputData);
  /// ```
  static Future<R> run<Q, R>(
    Future<R> Function(Q message) computation,
    Q message,
  ) {
    return Isolate.run(() => computation(message));
  }

  // ─── File Download ────────────────────────────────────────────

  /// Downloads a file from [url] and saves it to [savePath].
  /// Returns the saved [File] on success.
  /// Throws on network / IO error — caller maps to [Failure].
  static Future<File> downloadFile({
    required String url,
    required String savePath,
  }) {
    return Isolate.run(() => _downloadFileTask(url: url, savePath: savePath));
  }

  static Future<File> _downloadFileTask({
    required String url,
    required String savePath,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Download failed: HTTP ${response.statusCode}');
      }

      final file = File(savePath);
      await file.create(recursive: true);
      await response.pipe(file.openWrite());
      return file;
    } finally {
      client.close();
    }
  }

  // ─── Directory Scan ───────────────────────────────────────────

  /// Scans [directoryPath] and returns all file paths inside it.
  /// Used in Downloads screen to list locally saved wallpapers.
  static Future<List<String>> scanDirectory(String directoryPath) {
    return Isolate.run(() => _scanDirectoryTask(directoryPath));
  }

  static Future<List<String>> _scanDirectoryTask(String directoryPath) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return [];

    final files = await dir
        .list(recursive: false, followLinks: false)
        .where((e) => e is File)
        .map((e) => e.path)
        .toList();

    return files;
  }

  // ─── Bulk Delete ──────────────────────────────────────────────

  /// Deletes all files at [filePaths].
  /// Returns a list of paths that FAILED to delete (empty = all success).
  static Future<List<String>> bulkDelete(List<String> filePaths) {
    return Isolate.run(() => _bulkDeleteTask(filePaths));
  }

  static Future<List<String>> _bulkDeleteTask(List<String> filePaths) async {
    final failed = <String>[];
    for (final path in filePaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        failed.add(path);
      }
    }
    return failed;
  }
}
