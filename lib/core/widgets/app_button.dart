// lib/core/widgets/app_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../constants/dimensions.dart';
import '../constants/text_styles.dart';

/// WALLR — Reusable Button
///
/// Variants:
///   AppButton.primary   → Gold pill (main CTAs)
///   AppButton.secondary → Outlined pill (secondary actions)
///   AppButton.glass     → Frosted glass circle (on-image actions)
///   AppButton.text      → Text only (links)
///
/// All variants respect [isLoading] and [isDisabled]

enum _AppButtonVariant { primary, secondary, glass, text }

class AppButton extends StatelessWidget {
  final String? label;
  final Widget? icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final _AppButtonVariant _variant;
  final double? width;
  final double? height;

  // ── Primary constructor ─────────────────────────────────────────
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = true,
    this.width,
    this.height,
  }) : _variant = _AppButtonVariant.primary;

  // ── Secondary constructor ───────────────────────────────────────
  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = true,
    this.width,
    this.height,
  }) : _variant = _AppButtonVariant.secondary;

  // ── Glass circle constructor (on-image actions) ─────────────────
  const AppButton.glass({
    super.key,
    required this.icon,
    required this.onTap,
    this.label,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
  }) : _variant = _AppButtonVariant.glass,
       isFullWidth = false;

  // ── Text / link constructor ─────────────────────────────────────
  const AppButton.text({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
  }) : _variant = _AppButtonVariant.text,
       isFullWidth = false;

  @override
  Widget build(BuildContext context) {
    switch (_variant) {
      case _AppButtonVariant.primary:
        return _PrimaryButton(
          label: label!,
          icon: icon,
          onTap: isDisabled || isLoading ? null : onTap,
          isLoading: isLoading,
          isFullWidth: isFullWidth,
          width: width,
          height: height,
        );
      case _AppButtonVariant.secondary:
        return _SecondaryButton(
          label: label!,
          icon: icon,
          onTap: isDisabled || isLoading ? null : onTap,
          isLoading: isLoading,
          isFullWidth: isFullWidth,
          width: width,
          height: height,
        );
      case _AppButtonVariant.glass:
        return _GlassButton(
          icon: icon!,
          onTap: isDisabled ? null : onTap,
          size: width ?? 40.w,
        );
      case _AppButtonVariant.text:
        return _TextButton(
          label: label!,
          icon: icon,
          onTap: isDisabled ? null : onTap,
        );
    }
  }
}

// ─── Primary Button (Gold pill) ───────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    required this.isLoading,
    required this.isFullWidth,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final btn = SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height ?? AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: onTap == null
              ? AppColors.primaryContainer.withOpacity(0.4)
              : AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.lg),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onPrimary,
                ),
              )
            : Row(
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    SizedBox(width: AppDimensions.xs),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.onPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
    return btn;
  }
}

// ─── Secondary Button (Outlined pill) ────────────────────────────────────────

class _SecondaryButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;

  const _SecondaryButton({
    required this.label,
    required this.onTap,
    required this.isLoading,
    required this.isFullWidth,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height ?? AppDimensions.buttonHeight,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: onTap == null
              ? AppColors.onSurfaceVariant
              : AppColors.onSurface,
          side: BorderSide(
            color: onTap == null
                ? AppColors.cardBorder.withOpacity(0.4)
                : AppColors.cardBorder,
            width: AppDimensions.borderThin,
          ),
          elevation: 0,
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.lg),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onSurface,
                ),
              )
            : Row(
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    SizedBox(width: AppDimensions.xs),
                  ],
                  Text(label, style: AppTextStyles.labelLg),
                ],
              ),
      ),
    );
  }
}

// ─── Glass Circle Button (on-image actions: fav, share, back) ────────────────

class _GlassButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final double size;

  const _GlassButton({
    required this.icon,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: AppDimensions.borderThin,
          ),
        ),
        child: Center(child: icon),
      ),
    );
  }
}

// ─── Text Button ──────────────────────────────────────────────────────────────

class _TextButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback? onTap;

  const _TextButton({required this.label, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, SizedBox(width: AppDimensions.xs)],
          Text(
            label,
            style: AppTextStyles.labelLg.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
