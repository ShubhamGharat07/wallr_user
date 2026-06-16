import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'colors.dart';

/// WALLR — Aura Design System | Typography Tokens
///
/// All sizes use `.sp` (FlutterScreenUtil) for responsiveness.
/// Design reference: Inter font, designSize 390×844 (iPhone 14).
///
/// Usage: AppTextStyles.display(context)
///        AppTextStyles.bodyMd  // static getter variant
abstract final class AppTextStyles {
  // ─── Display ──────────────────────────────────────────────────
  /// 40sp · W700 · lh 48 · ls -0.02em  — hero headlines
  static TextStyle get display => TextStyle(
        fontFamily: 'Inter',
        fontSize: 40.sp,
        fontWeight: FontWeight.w700,
        height: 48 / 40,
        letterSpacing: -0.02 * 40,
        color: AppColors.onSurface,
      );

  // ─── Headline ─────────────────────────────────────────────────
  /// 32sp · W600 · lh 40 · ls -0.01em
  static TextStyle get headlineLg => TextStyle(
        fontFamily: 'Inter',
        fontSize: 32.sp,
        fontWeight: FontWeight.w600,
        height: 40 / 32,
        letterSpacing: -0.01 * 32,
        color: AppColors.onSurface,
      );

  /// 28sp · W600 · lh 34  — mobile headline variant
  static TextStyle get headlineLgMobile => TextStyle(
        fontFamily: 'Inter',
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        height: 34 / 28,
        color: AppColors.onSurface,
      );

  /// 24sp · W600 · lh 32
  static TextStyle get headlineMd => TextStyle(
        fontFamily: 'Inter',
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: AppColors.onSurface,
      );

  /// 20sp · W600 · lh 28
  static TextStyle get headlineSm => TextStyle(
        fontFamily: 'Inter',
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: AppColors.onSurface,
      );

  // ─── Body ─────────────────────────────────────────────────────
  /// 18sp · W400 · lh 28
  static TextStyle get bodyLg => TextStyle(
        fontFamily: 'Inter',
        fontSize: 18.sp,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: AppColors.onSurface,
      );

  /// 16sp · W400 · lh 24
  static TextStyle get bodyMd => TextStyle(
        fontFamily: 'Inter',
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurface,
      );

  /// 14sp · W400 · lh 20
  static TextStyle get bodySm => TextStyle(
        fontFamily: 'Inter',
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.onSurface,
      );

  // ─── Label ────────────────────────────────────────────────────
  /// 14sp · W600 · lh 20 · ls +0.02em  — strong labels / nav
  static TextStyle get labelLg => TextStyle(
        fontFamily: 'Inter',
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.02 * 14,
        color: AppColors.onSurface,
      );

  /// 12sp · W500 · lh 16 · ls +0.04em  — chips / badges
  static TextStyle get labelMd => TextStyle(
        fontFamily: 'Inter',
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.04 * 12,
        color: AppColors.onSurface,
      );

  /// 10sp · W500 · lh 14 · ls +0.05em  — micro labels
  static TextStyle get labelSm => TextStyle(
        fontFamily: 'Inter',
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        height: 14 / 10,
        letterSpacing: 0.05 * 10,
        color: AppColors.onSurface,
      );

  // ─── Convenience colour variants ──────────────────────────────
  /// [bodyMd] coloured with [AppColors.onSurfaceVariant] — secondary text
  static TextStyle get bodyMdMuted =>
      bodyMd.copyWith(color: AppColors.onSurfaceVariant);

  /// [bodySm] coloured with [AppColors.onSurfaceVariant]
  static TextStyle get bodySmMuted =>
      bodySm.copyWith(color: AppColors.onSurfaceVariant);

  /// [labelLg] coloured with [AppColors.primary] — gold accent labels
  static TextStyle get labelLgGold =>
      labelLg.copyWith(color: AppColors.primary);

  /// [headlineMd] coloured with [AppColors.primary] — gold accent titles
  static TextStyle get headlineMdGold =>
      headlineMd.copyWith(color: AppColors.primary);
}
