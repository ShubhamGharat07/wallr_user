// lib/features/home/presentation/widgets/category_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/wallpaper_card.dart';
import '../../domain/entities/home_feed_entity.dart';
import '../../domain/entities/wallpaper_entity.dart';
import 'category_coming_soon_card.dart';
import 'category_icon_map.dart';

/// One horizontal "category row" on Home — section header (icon + name)
/// followed by either:
///  • a horizontal list of [WallpaperCard]s, or
///  • a single [CategoryComingSoonCard] when the category has no
///    active wallpapers yet.
class CategorySection extends StatelessWidget {
  final CategorySectionEntity section;
  final void Function(WallpaperEntity wallpaper) onWallpaperTap;
  final VoidCallback? onSeeAllTap;

  const CategorySection({
    super.key,
    required this.section,
    required this.onWallpaperTap,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = section.category;
    final accentColor = hexToColor(
      category.accentColor,
      fallback: AppColors.primaryContainer,
    );
    final icon = categoryIconFromName(category.iconName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ───────────────────────────────────────────
        Row(
          children: [
            Icon(icon, color: accentColor, size: AppDimensions.iconMd),
            SizedBox(width: AppDimensions.xs),
            Expanded(
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineMd.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            if (onSeeAllTap != null && section.wallpapers.isNotEmpty)
              GestureDetector(
                onTap: onSeeAllTap,
                child: Text(
                  'See all',
                  style: AppTextStyles.labelLg.copyWith(color: accentColor),
                ),
              ),
          ],
        ),
        SizedBox(height: AppDimensions.md),

        // ── Content ──────────────────────────────────────────
        SizedBox(
          height: 220.h,
          child: section.isEmpty
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: CategoryComingSoonCard(
                    icon: icon,
                    accentColor: accentColor,
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: section.wallpapers.length,
                  itemBuilder: (context, index) {
                    final wallpaper = section.wallpapers[index];
                    return Padding(
                      padding: EdgeInsets.only(right: AppDimensions.md),
                      child: SizedBox(
                        width: 160.w,
                        child: WallpaperCard(
                          imageUrl: wallpaper.cardImageUrl,
                          title: wallpaper.title.isEmpty ? null : wallpaper.title,
                          resolution: wallpaper.resolution,
                          isPremium: wallpaper.isPremium,
                          onTap: () => onWallpaperTap(wallpaper),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
