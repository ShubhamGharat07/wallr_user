import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/colors.dart';

/// WALLR — Material TextTheme
///
/// Maps Wallr Aura typography tokens onto Flutter's [TextTheme] slots.
/// Used inside [AppTheme.dark] → `textTheme: AppTextTheme.textTheme`.
///
/// Note: FlutterScreenUtil (.sp) cannot be used here because TextTheme is
/// constructed before ScreenUtil is initialised (MaterialApp level).
/// Use AppTextStyles getters (which use .sp) inside widgets instead.
/// This TextTheme covers Material widget defaults (AppBar title, etc.).

abstract final class AppTextTheme {
  static TextTheme get textTheme => GoogleFonts.interTextTheme(
        const TextTheme(
          // ─── Display ─────────────────────────────────────────
          displayLarge: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.02 * 40,
            height: 48 / 40,
            color: AppColors.onSurface,
          ),
          displayMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.01 * 32,
            height: 40 / 32,
            color: AppColors.onSurface,
          ),
          displaySmall: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            height: 34 / 28,
            color: AppColors.onSurface,
          ),

          // ─── Headline ─────────────────────────────────────────
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            height: 36 / 28,
            color: AppColors.onSurface,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 32 / 24,
            color: AppColors.onSurface,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 28 / 20,
            color: AppColors.onSurface,
          ),

          // ─── Title ────────────────────────────────────────────
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 28 / 18,
            color: AppColors.onSurface,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.01 * 16,
            height: 24 / 16,
            color: AppColors.onSurface,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.01 * 14,
            height: 20 / 14,
            color: AppColors.onSurface,
          ),

          // ─── Body ─────────────────────────────────────────────
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 24 / 16,
            color: AppColors.onSurface,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
            color: AppColors.onSurface,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 16 / 12,
            color: AppColors.onSurfaceVariant,
          ),

          // ─── Label ────────────────────────────────────────────
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.02 * 14,
            height: 20 / 14,
            color: AppColors.onSurface,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.04 * 12,
            height: 16 / 12,
            color: AppColors.onSurface,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.05 * 10,
            height: 14 / 10,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
}
