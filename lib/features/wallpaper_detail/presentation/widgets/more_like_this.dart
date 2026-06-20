// lib/features/wallpaper_detail/presentation/widgets/more_like_this_grid.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../home/domain/entities/wallpaper_entity.dart';

/// Two-column grid of related wallpapers shown under "More like this" on
/// the detail screen.
///
/// Pure presentation — it's fed whatever list the caller already has on
/// hand (e.g. the rest of the category section the tapped card came
/// from), so opening this screen never costs an extra network round-trip
/// just to populate the grid.
class MoreLikeThisGrid extends StatelessWidget {
  final List<WallpaperEntity> wallpapers;
  final ValueChanged<WallpaperEntity> onTap;

  const MoreLikeThisGrid({
    super.key,
    required this.wallpapers,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (wallpapers.isEmpty) {
      return const _EmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: wallpapers.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.s,
        mainAxisSpacing: AppDimensions.s,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, i) {
        final w = wallpapers[i];
        return _GridTile(wallpaper: w, onTap: () => onTap(w));
      },
    );
  }
}

class _GridTile extends StatelessWidget {
  final WallpaperEntity wallpaper;
  final VoidCallback onTap;

  const _GridTile({required this.wallpaper, required this.onTap});

  String get _thumbUrl => wallpaper.thumbnailUrl.isNotEmpty
      ? wallpaper.thumbnailUrl
      : wallpaper.cardImageUrl;

  @override
  Widget build(BuildContext context) {
    final title = wallpaper.title.isEmpty ? 'Untitled' : wallpaper.title;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.containerRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: _thumbUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => const AppShimmer(),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.cardSurface,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.navInactive,
                ),
              ),
            ),

            // ── Bottom scrim + title ─────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.s,
                  AppDimensions.lg,
                  AppDimensions.s,
                  AppDimensions.s,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.78),
                    ],
                  ),
                ),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // ── Premium badge ─────────────────────────────────────
            if (wallpaper.isPremium)
              Positioned(
                top: AppDimensions.xs,
                right: AppDimensions.xs,
                child: Container(
                  padding: EdgeInsets.all(AppDimensions.xs),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    size: AppDimensions.iconSm,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: AppDimensions.lg),
      alignment: Alignment.center,
      child: Text(
        'No similar wallpapers yet — check back soon.',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmMuted,
      ),
    );
  }
}
