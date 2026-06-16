// lib/core/widgets/app_chip.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../constants/dimensions.dart';
import '../constants/text_styles.dart';

/// WALLR — Reusable Chip
///
/// Variants:
///   AppChip.filter  → Category filter chips (Home/Search row)
///   AppChip.tag     → Metadata tag chips (Detail screen)
///   AppChip.badge   → Resolution/premium badge on wallpaper cards

enum _AppChipVariant { filter, tag, badge }

class AppChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final Widget? leadingIcon;
  final Color? activeColor;
  final _AppChipVariant _variant;

  // ── Filter chip (category row) ─────────────────────────────────
  const AppChip.filter({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.leadingIcon,
    this.activeColor,
  }) : _variant = _AppChipVariant.filter;

  // ── Tag chip (detail view metadata) ───────────────────────────
  const AppChip.tag({
    super.key,
    required this.label,
    this.onTap,
    this.leadingIcon,
    this.activeColor,
  }) : _variant = _AppChipVariant.tag,
       isActive = false;

  // ── Badge (resolution: 4K, HD etc.) ───────────────────────────
  const AppChip.badge({super.key, required this.label, this.activeColor})
    : _variant = _AppChipVariant.badge,
      isActive = true,
      onTap = null,
      leadingIcon = null;

  @override
  Widget build(BuildContext context) {
    switch (_variant) {
      case _AppChipVariant.filter:
        return _FilterChip(
          label: label,
          isActive: isActive,
          onTap: onTap,
          leadingIcon: leadingIcon,
          activeColor: activeColor,
        );
      case _AppChipVariant.tag:
        return _TagChip(label: label, onTap: onTap, leadingIcon: leadingIcon);
      case _AppChipVariant.badge:
        return _BadgeChip(label: label, color: activeColor);
    }
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final Widget? leadingIcon;
  final Color? activeColor;

  const _FilterChip({
    required this.label,
    required this.isActive,
    this.onTap,
    this.leadingIcon,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final goldColor = activeColor ?? AppColors.primaryContainer;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: AppDimensions.chipHeight,
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.sm,
          vertical: AppDimensions.xs,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? goldColor.withOpacity(0.12)
              : AppColors.inputSurface,
          borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
          border: Border.all(
            color: isActive ? goldColor : AppColors.cardBorder,
            width: AppDimensions.borderThin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              leadingIcon!,
              SizedBox(width: AppDimensions.xs),
            ],
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: isActive ? goldColor : AppColors.onSurface,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tag Chip ─────────────────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget? leadingIcon;

  const _TagChip({required this.label, this.onTap, this.leadingIcon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimensions.chipHeight,
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.sm,
          vertical: AppDimensions.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
          border: Border.all(
            color: AppColors.outlineVariant,
            width: AppDimensions.borderThin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              leadingIcon!,
              SizedBox(width: AppDimensions.xs),
            ],
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Badge Chip ───────────────────────────────────────────────────────────────

class _BadgeChip extends StatelessWidget {
  final String label;
  final Color? color;

  const _BadgeChip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.primaryContainer;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.xs + 2,
        vertical: 3.h,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
        border: Border.all(
          color: badgeColor.withOpacity(0.5),
          width: AppDimensions.borderThin,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
