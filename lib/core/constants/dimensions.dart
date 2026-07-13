import 'package:flutter_screenutil/flutter_screenutil.dart';

/// WALLR — Aura Design System | Spacing & Shape Tokens
///
/// All spacing values use `.w` (horizontal-relative) and heights use `.h`.
/// Border-radius values use `.r` — all via FlutterScreenUtil.
///
/// Usage:
///   Padding(padding: EdgeInsets.all(AppDimensions.md))
///   BorderRadius.circular(AppDimensions.cardRadius)
abstract final class AppDimensions {
  // ─── Spacing Scale ────────────────────────────────────────────
  /// 4dp — micro gap / icon padding
  static double get xs => 4.w;

  /// 8dp — tight inner padding
  static double get s => 8.w;

  /// 12dp — default gutter between grid columns
  static double get sm => 12.w;

  /// 16dp — standard inner padding / margin
  static double get md => 16.w;

  /// 24dp — section spacing / large gaps
  static double get lg => 24.w;

  /// 32dp — xl section spacing
  static double get xl => 32.w;

  /// 48dp — xxl / hero spacer
  static double get xxl => 48.w;

  // ─── Layout ───────────────────────────────────────────────────
  /// 12dp — grid gutter (horizontal gap between masonry columns)
  static double get gutter => 12.w;

  /// 16dp — screen horizontal margin on mobile
  static double get marginMobile => 16.w;

  // ─── Component Heights ────────────────────────────────────────
  /// 64dp — bottom nav bar height
  static double get navBarHeight => 64.h;

  /// 56dp — top app bar height
  static double get appBarHeight => 56.h;

  /// 48dp — primary button height
  static double get buttonHeight => 48.h;

  /// 52dp — text field / input height
  static double get inputHeight => 52.h;

  /// 44dp — chip height
  static double get chipHeight => 44.h;

  // ─── Icon Sizes ───────────────────────────────────────────────
  /// 24dp — standard icon
  static double get iconMd => 24.w;

  /// 20dp — small icon (nav inactive)
  static double get iconSm => 20.w;

  /// 32dp — large icon / action icon
  static double get iconLg => 32.w;

  // ─── Avatar / Image ───────────────────────────────────────────
  /// 80dp — profile avatar diameter
  static double get avatarLg => 80.w;

  /// 40dp — small avatar / comment avatar
  static double get avatarSm => 40.w;

  // ─── Card Dimensions ─────────────────────────────────────────
  /// Featured carousel card width
  static double get carouselCardWidth => 240.w;

  /// Featured carousel card height
  static double get carouselCardHeight => 340.h;

  // ─── Border Radius ────────────────────────────────────────────
  /// 12dp — wallpaper preview cards
  static double get cardRadius => 12.r;

  /// 16dp — container / panel cards
  static double get containerRadius => 16.r;

  /// 24dp — pill buttons & action sheets (top corners)
  static double get pillRadius => 24.r;

  /// 8dp — metadata chips
  static double get chipRadius => 8.r;

  /// 100dp — fully circular (glass buttons, avatars)
  static double get circleRadius => 100.r;

  // ─── Elevation / Blur ─────────────────────────────────────────
  /// 20.0 — glassmorphism backdrop blur sigma
  static const double blurSigma = 20.0;

  /// 10.0 — subtle blur (app bars)
  static const double blurSigmaLight = 10.0;

  // ─── Border Width ─────────────────────────────────────────────
  /// 1dp — card border / divider
  static const double borderThin = 1.0;

  /// 1.5dp — input field border
  static const double borderMedium = 1.5;

  // ─── Grid ─────────────────────────────────────────────────────
  /// Number of columns in the main masonry grid (home / collections)
  static const int gridColumnCount = 2;

  /// Number of columns in the downloads grid (compact)
  static const int downloadsGridColumnCount = 3;
}
