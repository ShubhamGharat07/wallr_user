import 'package:flutter/material.dart';

/// WALLR — Aura Design System
/// All colors directly from DESIGN.md
/// Dark mode only for now. Light mode values commented below each token.
abstract final class AppColors {
  // ─── Background ───────────────────────────────────────────────
  static const Color background = Color(0xFF171309);
  // light: Color(0xFFFFF8F0)

  // ─── Surface Scale ────────────────────────────────────────────
  static const Color surfaceLowest = Color(0xFF110E05);
  static const Color surfaceLow = Color(0xFF1F1B11);
  static const Color surface = Color(0xFF231F15);
  static const Color surfaceHigh = Color(0xFF2E2A1F);
  static const Color surfaceHighest = Color(0xFF393429);
  static const Color surfaceBright = Color(0xFF3E392D);

  // ─── On-Surface (text / icons on surfaces) ────────────────────
  static const Color onSurface = Color(0xFFEBE1D1);
  static const Color onSurfaceVariant = Color(0xFFD1C5AC);

  // ─── Inverse ──────────────────────────────────────────────────
  static const Color inverseSurface = Color(0xFFEBE1D1);
  static const Color inverseOnSurface = Color(0xFF353025);

  // ─── Outline ──────────────────────────────────────────────────
  static const Color outline = Color(0xFF9A9078);
  static const Color outlineVariant = Color(0xFF4E4633);

  // ─── Primary — Gold ───────────────────────────────────────────
  static const Color primary = Color(0xFFFFE5A0);
  static const Color onPrimary = Color(0xFF3D2F00);
  static const Color primaryContainer = Color(0xFFF5C518);
  static const Color onPrimaryContainer = Color(0xFF695200);
  static const Color inversePrimary = Color(0xFF745B00);
  static const Color surfaceTint = Color(0xFFF0C110);

  // Primary fixed
  static const Color primaryFixed = Color(0xFFFFE08B);
  static const Color primaryFixedDim = Color(0xFFF0C110);
  static const Color onPrimaryFixed = Color(0xFF241A00);
  static const Color onPrimaryFixedVariant = Color(0xFF584400);

  // ─── Secondary — Electric Blue ────────────────────────────────
  static const Color secondary = Color(0xFF75D1FF);
  static const Color onSecondary = Color(0xFF003548);
  static const Color secondaryContainer = Color(0xFF009CCE);
  static const Color onSecondaryContainer = Color(0xFF002E3F);

  // Secondary fixed
  static const Color secondaryFixed = Color(0xFFC2E8FF);
  static const Color secondaryFixedDim = Color(0xFF75D1FF);
  static const Color onSecondaryFixed = Color(0xFF001E2B);
  static const Color onSecondaryFixedVariant = Color(0xFF004D67);

  // ─── Tertiary ─────────────────────────────────────────────────
  static const Color tertiary = Color(0xFFBDEFFF);
  static const Color onTertiary = Color(0xFF003641);
  static const Color tertiaryContainer = Color(0xFF49DBFF);
  static const Color onTertiaryContainer = Color(0xFF005E70);

  // Tertiary fixed
  static const Color tertiaryFixed = Color(0xFFB0ECFF);
  static const Color tertiaryFixedDim = Color(0xFF42D7FB);
  static const Color onTertiaryFixed = Color(0xFF001F27);
  static const Color onTertiaryFixedVariant = Color(0xFF004E5E);

  // ─── Error ────────────────────────────────────────────────────
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // ─── Surface Variant ──────────────────────────────────────────
  static const Color surfaceVariant = Color(0xFF393429);

  // ─── Semantic Shortcuts (used across UI) ──────────────────────

  /// Pure black base — nav bar, overlays bg
  static const Color black = Color(0xFF0A0A0A);

  /// Card background level 1
  static const Color cardSurface = Color(0xFF141414);

  /// Subtle border on cards
  static const Color cardBorder = Color(0xFF2A2A2A);

  /// Search bar / chip background
  static const Color inputSurface = Color(0xFF1C1C1C);

  /// Inactive nav icon
  static const Color navInactive = Color(0xFF616161);

  /// Transparent — convenience
  static const Color transparent = Colors.transparent;
}
