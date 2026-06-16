// lib/features/wallpaper_detail/presentation/widgets/wallpaper_meta_chips.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';

/// Small rounded metadata chip — category / resolution / file size.
class WallpaperMetaChip extends StatelessWidget {
  final String label;

  const WallpaperMetaChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.s,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurface),
      ),
    );
  }
}

/// Wraps a row of meta chips with consistent spacing.
class WallpaperMetaChipRow extends StatelessWidget {
  final List<String> labels;

  const WallpaperMetaChipRow({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.s,
      runSpacing: AppDimensions.s,
      children: [
        for (final label in labels) WallpaperMetaChip(label: label),
      ],
    );
  }
}
