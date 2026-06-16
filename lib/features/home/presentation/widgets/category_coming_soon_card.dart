// lib/features/home/presentation/widgets/category_coming_soon_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import 'category_icon_map.dart';

/// Shown inside a category row when that category has zero active
/// wallpapers yet — keeps the section visible (so users discover the
/// category exists) without showing a broken/empty grid.
class CategoryComingSoonCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;

  const CategoryComingSoonCard({
    super.key,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220.w,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.cardBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: AppDimensions.iconMd),
            ),
            SizedBox(height: AppDimensions.sm),
            Text(
              'Coming soon',
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: AppDimensions.xs / 2),
            Text(
              'New wallpapers on the way',
              textAlign: TextAlign.center,
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
