import 'package:flutter_dotenv/flutter_dotenv.dart';

/// WALLR — Cloudinary Image URL Builder
///
/// Builds Cloudinary CDN URLs with transformation parameters.
/// Cloud name is read from .env at runtime via flutter_dotenv.
///
/// Usage:
///   ImageUtils.thumb(publicId)   // 400×600 optimised thumbnail
///   ImageUtils.full(publicId)    // Full resolution, auto format/quality
///   ImageUtils.avatar(publicId)  // 200×200 circle crop for profile

abstract final class ImageUtils {
  /// Cloud name from .env — `CLOUDINARY_CLOUD_NAME`
  static String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';

  static const String _base = 'https://res.cloudinary.com';
  static const String _upload = 'image/upload';

  // ─── Wallpaper Thumbnails ──────────────────────────────────────

  /// 400×600 thumbnail — used in masonry grid cards.
  /// f_auto: best format (WebP/AVIF), q_auto: optimal quality, c_fill: crop.
  static String thumb(String publicId) =>
      '$_base/$_cloudName/$_upload/w_400,h_600,c_fill,f_auto,q_auto/$publicId';

  /// 200×300 small thumbnail — used in search results & downloads grid.
  static String thumbSmall(String publicId) =>
      '$_base/$_cloudName/$_upload/w_200,h_300,c_fill,f_auto,q_auto:low/$publicId';

  // ─── Full Resolution ───────────────────────────────────────────

  /// Full resolution — used in detail view & wallpaper set flow.
  /// No width/height constraint — auto format + quality.
  static String full(String publicId) =>
      '$_base/$_cloudName/$_upload/f_auto,q_auto/$publicId';

  /// HD (1080p) — download quality: standard setting.
  static String hd(String publicId) =>
      '$_base/$_cloudName/$_upload/w_1080,f_auto,q_auto/$publicId';

  /// 4K (2160p) — download quality: high setting.
  static String uhd(String publicId) =>
      '$_base/$_cloudName/$_upload/w_2160,f_auto,q_auto/$publicId';

  // ─── Preview (apply screen) ────────────────────────────────────

  /// Device-width preview — for apply / set screen.
  /// Pass [deviceWidth] in logical pixels.
  static String preview(String publicId, {int deviceWidth = 390}) =>
      '$_base/$_cloudName/$_upload/w_${deviceWidth * 2},c_fill,f_auto,q_auto/$publicId';

  // ─── Avatar ────────────────────────────────────────────────────

  /// 200×200 face-crop circle — profile avatar.
  static String avatar(String publicId) =>
      '$_base/$_cloudName/$_upload/w_200,h_200,c_fill,g_face,r_max,f_auto,q_auto/$publicId';

  // ─── Category Covers ──────────────────────────────────────────

  /// 600×400 category grid cover image.
  static String categoryCover(String publicId) =>
      '$_base/$_cloudName/$_upload/w_600,h_400,c_fill,f_auto,q_auto/$publicId';

  // ─── Carousel / Featured ──────────────────────────────────────

  /// 480×720 featured carousel card image (taller aspect ratio).
  static String featured(String publicId) =>
      '$_base/$_cloudName/$_upload/w_480,h_720,c_fill,f_auto,q_auto/$publicId';

  // ─── Blurred Placeholder (LQIP) ───────────────────────────────

  /// 40×60 blurred placeholder — shown while full image loads.
  /// e_blur:1000 = heavy blur for LQIP effect.
  static String lqip(String publicId) =>
      '$_base/$_cloudName/$_upload/w_40,h_60,c_fill,e_blur:1000,f_auto,q_10/$publicId';
}
