import 'dart:async';

import 'package:app_links/app_links.dart';

/// WALLR — Deep Link Service
///
/// Resolves every supported link format down to a wallpaper id:
///   • Custom scheme  : wallr://wallpaper/{id}
///   • Web (prod)     : https://wallr.app/wallpaper/{id}
///   • Web, no scheme : wallr.app/wallpaper/{id}  (WhatsApp rewrites)
///   • Query fallback : https://wallr.app/wallpaper?id={id}
///
/// Cold start (app opened FROM the link) stores a pending id, consumed
/// by the UI once the router is attached. Warm start (app already
/// running) emits the id on [wallpaperLinks].
final class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  final StreamController<String> _wallpaperLinks =
      StreamController<String>.broadcast();

  String? _pendingWallpaperId;
  StreamSubscription<Uri>? _subscription;

  /// Wallpaper ids arriving while the app is already running.
  Stream<String> get wallpaperLinks => _wallpaperLinks.stream;

  /// Id from the cold-start link — null once consumed.
  String? consumePendingWallpaperId() {
    final id = _pendingWallpaperId;
    _pendingWallpaperId = null;
    return id;
  }

  Future<void> initialize() async {
    final pending = _subscription != null;
    if (pending) return;

    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        final id = _parseWallpaperId(initialLink);
        if (id != null) _pendingWallpaperId = id;
      }
    } catch (_) {
      // Deep link unavailable on this platform — sharing still works.
    }

    _subscription = _appLinks.uriLinkStream.listen((uri) {
      final id = _parseWallpaperId(uri);
      if (id != null && !_wallpaperLinks.isClosed) {
        _wallpaperLinks.add(id);
      }
    });
  }

  /// Normalises any supported wallpaper link into the shareable form.
  String buildWallpaperLink(String wallpaperId) =>
      'https://wallr.app/wallpaper/$wallpaperId';

  String? _parseWallpaperId(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();

    // wallr://wallpaper/{id}
    if (scheme == 'wallr' && host == 'wallpaper' && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }

    // https://wallr.app/wallpaper/{id}  — also allow bare "wallr.app" hosts
    // (some in-app browsers strip the scheme before opening the link).
    if ((scheme == 'https' || scheme == 'http' || (scheme.isEmpty && host.isNotEmpty)) &&
        host == 'wallr.app') {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty && segments.first == 'wallpaper') {
        if (segments.length >= 2 && segments[1].isNotEmpty) {
          return segments[1];
        }
        // ?id={id} fallback
        final queryId = uri.queryParameters['id'];
        if (queryId != null && queryId.isNotEmpty) return queryId;
      }
    }

    return null;
  }

  void dispose() {
    _subscription?.cancel();
    _wallpaperLinks.close();
  }
}