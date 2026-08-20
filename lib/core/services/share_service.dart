import 'package:share_plus/share_plus.dart';

import '../../features/home/domain/entities/wallpaper_entity.dart';
import 'deep_link_service.dart';

/// WALLR — Share Service
///
/// Shares a wallpaper as a deep link (`https://wallr.app/wallpaper/{id}`)
/// via the native share sheet — WhatsApp, Telegram, email, SMS, anything
/// that accepts text. The receiving side re-opens the exact wallpaper
/// through [DeepLinkService].
final class ShareService {
  final DeepLinkService _deepLinkService;

  ShareService({required DeepLinkService deepLinkService})
      : _deepLinkService = deepLinkService;

  Future<void> shareWallpaper(WallpaperEntity wallpaper) async {
    final title = wallpaper.title.isEmpty ? 'wallpaper' : wallpaper.title;
    final link = _deepLinkService.buildWallpaperLink(wallpaper.id);

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: 'Check out "$title" on WALLR\n$link',
          subject: '"$title" on WALLR',
        ),
      );
    } catch (_) {
      // Share sheet dismissed / unavailable — nothing to recover.
    }
  }
}