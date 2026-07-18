// lib/core/widgets/wallpaper_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../constants/dimensions.dart';
import '../constants/text_styles.dart';
import 'app_shimmer.dart';

// Pre-computed decorations to avoid recreating them every frame
const _textShadows = [
  Shadow(blurRadius: 8, color: Colors.black54),
];

final _premiumBorder = Border.all(
  color: AppColors.primaryContainer.withValues(alpha: 0.9),
  width: AppDimensions.borderThin,
);

final _normalBorder = Border.all(
  color: Colors.white.withValues(alpha: 0.4),
  width: AppDimensions.borderThin,
);

/// Reusable wallpaper card — used in:
/// Home feed masonry grid, Favourites, Collections, Search results
///
/// [onTap]          → navigate to wallpaper detail
/// [onFavouriteTap] → toggle favourite (optional, pass null to hide button)
/// [isPremium]      → shows 4K/Premium badge
/// [isFavourited]   → filled heart if true
class WallpaperCard extends StatelessWidget {
  final String imageUrl;
  final String? title;
  final String? resolution; // "4K", "HD", "2K"
  final bool isPremium;
  final bool isFavourited;
  final VoidCallback onTap;
  final VoidCallback? onFavouriteTap;

  const WallpaperCard({
    super.key,
    required this.imageUrl,
    required this.onTap,
    this.title,
    this.resolution,
    this.isPremium = false,
    this.isFavourited = false,
    this.onFavouriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Image ──────────────────────────────────────────
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 600,
                memCacheHeight: 900,
                maxHeightDiskCache: 1000,
                maxWidthDiskCache: 700,
                placeholder: (_, __) => const AppShimmer(),
                errorWidget: (_, _, _) => const _ErrorPlaceholder(),
                useOldImageOnUrlChange: true,
              ),

              // ── Bottom gradient overlay ─────────────────────
              if (title != null || isPremium)
                const Positioned.fill(
                  child: _GradientOverlay(),
                ),

              // ── Top-right: Resolution badge ─────────────────
              if (resolution != null)
                Positioned(
                  top: AppDimensions.xs,
                  right: AppDimensions.xs,
                  child: _ResolutionBadge(
                    label: resolution!,
                    isPremium: isPremium,
                  ),
                ),

              // ── Bottom: Title ───────────────────────────────
              if (title != null)
                Positioned(
                  bottom: AppDimensions.sm,
                  left: AppDimensions.sm,
                  right: AppDimensions.sm,
                  child: Text(
                    title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLg.copyWith(
                      color: Colors.white,
                      shadows: _textShadows,
                    ),
                  ),
                ),

              // ── Bottom-right: Favourite button ──────────────
              if (onFavouriteTap != null)
                Positioned(
                  bottom: AppDimensions.xs,
                  right: AppDimensions.xs,
                  child: _GlassFavButton(
                    isFavourited: isFavourited,
                    onTap: onFavouriteTap!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Gradient Overlay ─────────────────────────────────────────────────────────

class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Color.fromARGB(102, 0, 0, 0), // Colors.black.withValues(alpha: 0.4)
          ],
          stops: [0.4, 1.0],
        ),
      ),
    );
  }
}

// ─── Resolution Badge ─────────────────────────────────────────────────────────

class _ResolutionBadge extends StatelessWidget {
  final String label;
  final bool isPremium;

  const _ResolutionBadge({required this.label, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.xs + 2,
        vertical: 3.h,
      ),
      decoration: BoxDecoration(
        color: isPremium
            ? AppColors.primaryContainer.withValues(alpha: 0.25)
            : Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
        border: isPremium ? _premiumBorder : _normalBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPremium) ...[
            Icon(
              Icons.star_rounded,
              size: 12.sp,
              color: AppColors.primaryContainer,
            ),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: isPremium ? AppColors.primaryContainer : Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Glass Favourite Button ───────────────────────────────────────────────────

class _GlassFavButton extends StatelessWidget {
  final bool isFavourited;
  final VoidCallback onTap;

  const _GlassFavButton({required this.isFavourited, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: AppDimensions.borderThin,
          ),
        ),
        child: Icon(
          isFavourited ? Icons.favorite : Icons.favorite_border,
          size: AppDimensions.iconSm,
          color: isFavourited ? AppColors.error : Colors.white,
        ),
      ),
    );
  }
}

// ─── Error Placeholder ────────────────────────────────────────────────────────

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardSurface,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: AppColors.navInactive,
          size: AppDimensions.iconLg,
        ),
      ),
    );
  }
}
