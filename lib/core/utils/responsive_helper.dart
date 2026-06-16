import 'package:flutter/material.dart';

/// WALLR — Responsive Layout Helper
///
/// FlutterScreenUtil (.sp / .w / .h) handles proportional scaling.
/// THIS class handles breakpoint-based layout decisions:
///   - How many grid columns to show
///   - Phone bottom nav vs Tablet side rail
///   - Widget layout changes per device class
///
/// Breakpoints (Material 3 standard):
///   Compact  (phone)   : width < 600
///   Medium   (tablet)  : 600 ≤ width < 840
///   Expanded (desktop) : width ≥ 840
///
/// Usage:
///   ResponsiveHelper.isTablet(context)   // true/false
///   ResponsiveHelper.gridColumns(context) // 2 or 3
///   ResponsiveHelper.when(context, phone: ..., tablet: ...) // widget switch

abstract final class ResponsiveHelper {
  // ─── Breakpoints ──────────────────────────────────────────────

  /// Compact — phone portrait (width < 600dp)
  static const double _compactBreakpoint = 600;

  /// Medium — tablet portrait / phone landscape (600 ≤ width < 840)
  static const double _mediumBreakpoint = 840;

  // ─── Device Class Checks ──────────────────────────────────────

  /// Returns current screen width from [BuildContext].
  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// Returns current screen height from [BuildContext].
  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// `true` if the device is in compact (phone) range — width < 600.
  static bool isPhone(BuildContext context) =>
      screenWidth(context) < _compactBreakpoint;

  /// `true` if the device is in medium (tablet portrait) range.
  /// 600 ≤ width < 840
  static bool isMedium(BuildContext context) {
    final w = screenWidth(context);
    return w >= _compactBreakpoint && w < _mediumBreakpoint;
  }

  /// `true` if the device is in expanded (tablet landscape / desktop) range.
  /// width ≥ 840
  static bool isExpanded(BuildContext context) =>
      screenWidth(context) >= _mediumBreakpoint;

  /// `true` if the device is a tablet (medium OR expanded).
  static bool isTablet(BuildContext context) =>
      screenWidth(context) >= _compactBreakpoint;

  // ─── Grid Column Counts ───────────────────────────────────────

  /// Home feed / Collections — main masonry grid columns.
  ///   Phone    → 2 columns
  ///   Tablet   → 3 columns
  ///   Expanded → 4 columns
  static int wallpaperGridColumns(BuildContext context) {
    if (isExpanded(context)) return 4;
    if (isMedium(context)) return 3;
    return 2; // compact / phone
  }

  /// Downloads grid (compact thumbnails).
  ///   Phone    → 3 columns
  ///   Tablet   → 5 columns
  ///   Expanded → 6 columns
  static int downloadsGridColumns(BuildContext context) {
    if (isExpanded(context)) return 6;
    if (isMedium(context)) return 5;
    return 3;
  }

  /// Categories grid columns.
  ///   Phone    → 2 columns
  ///   Tablet   → 3 columns
  ///   Expanded → 4 columns
  static int categoriesGridColumns(BuildContext context) {
    if (isExpanded(context)) return 4;
    if (isMedium(context)) return 3;
    return 2;
  }

  // ─── Navigation Type ──────────────────────────────────────────

  /// Returns the appropriate [NavigationType] for the current screen size.
  ///   Phone    → bottom navigation bar
  ///   Tablet   → side navigation rail
  ///   Expanded → side navigation drawer (full labels)
  static NavigationType navigationTypeOf(BuildContext context) {
    if (isExpanded(context)) return NavigationType.drawer;
    if (isMedium(context)) return NavigationType.rail;
    return NavigationType.bottomBar;
  }

  // ─── Responsive Value Helpers ─────────────────────────────────

  /// Returns one of three values based on the current breakpoint.
  ///
  /// ```dart
  /// double padding = ResponsiveHelper.value(context,
  ///   phone: 16.0,
  ///   tablet: 24.0,
  ///   expanded: 32.0,
  /// );
  /// ```
  static T value<T>(
    BuildContext context, {
    required T phone,
    required T tablet,
    T? expanded,
  }) {
    if (isExpanded(context)) return expanded ?? tablet;
    if (isMedium(context)) return tablet;
    return phone;
  }

  // ─── Conditional Widget Builder ───────────────────────────────

  /// Renders a different widget based on the current breakpoint.
  ///
  /// ```dart
  /// ResponsiveHelper.when(
  ///   context,
  ///   phone:  BottomNavBar(),
  ///   tablet: SideNavRail(),
  /// )
  /// ```
  static Widget when(
    BuildContext context, {
    required Widget phone,
    Widget? tablet,
    Widget? expanded,
  }) {
    if (isExpanded(context)) return expanded ?? tablet ?? phone;
    if (isMedium(context)) return tablet ?? phone;
    return phone;
  }

  // ─── Adaptive Padding ─────────────────────────────────────────

  /// Returns horizontal screen padding.
  ///   Phone    → 16dp
  ///   Tablet   → 32dp
  ///   Expanded → 64dp
  static double horizontalPadding(BuildContext context) =>
      value(context, phone: 16.0, tablet: 32.0, expanded: 64.0);

  /// Returns adaptive EdgeInsets with horizontal padding.
  static EdgeInsets screenPadding(BuildContext context) => EdgeInsets.symmetric(
        horizontal: horizontalPadding(context),
      );
}

// ─── Navigation Type Enum ──────────────────────────────────────────────────

/// Describes which navigation component to render.
enum NavigationType {
  /// Bottom Navigation Bar — phone portrait
  bottomBar,

  /// Navigation Rail — tablet portrait
  rail,

  /// Navigation Drawer — tablet landscape / desktop
  drawer,
}
