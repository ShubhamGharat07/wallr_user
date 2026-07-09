abstract final class RouteNames {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String search = '/home/search';
  static const String categories = '/home/categories';
  static const String favourites = '/home/favourites';
  static const String profile = '/home/profile';

  /// Wallpaper detail — pushed with a [WallpaperEntity] via `extra`.
  static const String wallpaperDetail = '/wallpaper';

  /// Fullscreen preview — pushed with a [WallpaperEntity] via `extra`.
  static const String wallpaperPreview = '/wallpaper/preview';
  // More added as screens are built
}
