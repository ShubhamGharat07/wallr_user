import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/di/injection_container.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../home/domain/entities/wallpaper_entity.dart';
import '../cubit/wallpaper_actions_cubit.dart';
import '../cubit/wallpaper_actions_state.dart';
import '../widgets/author_stats_row.dart';
// import '../widgets/more_like_this_grid.dart';
import '../widgets/pro_upsell_banner.dart';
import '../widgets/set_wallpaper_sheet.dart';

/// WALLR — Wallpaper Detail Screen
///
/// Opened when a wallpaper card is tapped anywhere in the app. The hero
/// image is a fixed, full-bleed background; a [DraggableScrollableSheet]
/// floats on top holding title, meta chips, author + stats, the
/// Preview / Set wallpaper actions, the Pro upsell, and a "More like
/// this" grid. Dragging the sheet up reveals the grid without leaving
/// the wallpaper.
///
/// Provides its own [WallpaperActionsCubit] from DI.
class WallpaperDetailScreen extends StatelessWidget {
  final WallpaperEntity wallpaper;

  /// Wallpapers to surface under "More like this". Pass along whatever
  /// the caller already has in memory — e.g. the rest of the category
  /// section the tapped card came from — so this screen never needs its
  /// own fetch just to populate the grid. Defaults to empty, in which
  /// case the grid shows a quiet empty state instead of nothing at all.
  final List<WallpaperEntity> relatedWallpapers;

  const WallpaperDetailScreen({
    super.key,
    required this.wallpaper,
    this.relatedWallpapers = const [],
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WallpaperActionsCubit>(),
      child: _DetailView(
        wallpaper: wallpaper,
        relatedWallpapers: relatedWallpapers,
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  final WallpaperEntity wallpaper;
  final List<WallpaperEntity> relatedWallpapers;

  const _DetailView({required this.wallpaper, required this.relatedWallpapers});

  /// Resolves the public id from a Cloudinary URL, or returns the value
  /// as-is if it's already a public id. The detail/full image is built
  /// through [ImageUtils] for an optimised, device-appropriate fetch.
  String get _heroImageUrl => wallpaper.imageUrl.isNotEmpty
      ? wallpaper.imageUrl
      : wallpaper.cardImageUrl;

  Future<void> _onSetWallpaper(BuildContext context) async {
    final target = await SetWallpaperSheet.show(context);
    if (target == null || !context.mounted) return;

    await context.read<WallpaperActionsCubit>().setWallpaper(
      imageUrl: _heroImageUrl,
      wallpaperId: wallpaper.id,
      target: target,
    );
  }

  void _onPreview(BuildContext context) {
    context.push(RouteNames.wallpaperPreview, extra: wallpaper);
  }

  /// Opens another detail screen for a tapped "More like this" card,
  /// carrying the rest of the current pool along so the chain never
  /// dead-ends into an empty grid.
  ///
  /// NOTE: this pushes imperatively via [Navigator] rather than through
  /// go_router, since this screen's route may only know how to pass a
  /// single `wallpaper` extra today. If you've got a named route that
  /// already supports `relatedWallpapers`, swap this for
  /// `context.push(RouteNames.wallpaperDetail, extra: ...)` instead.
  void _onTapRelated(BuildContext context, WallpaperEntity target) {
    final siblings = [
      wallpaper,
      ...relatedWallpapers,
    ].where((w) => w.id != target.id).toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WallpaperDetailScreen(
          wallpaper: target,
          relatedWallpapers: siblings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<WallpaperActionsCubit, WallpaperActionsState>(
        listenWhen: (prev, curr) =>
            curr.message != null && prev.message != curr.message,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: state.status == WallpaperActionStatus.failure
                    ? AppColors.errorContainer
                    : AppColors.surfaceHigh,
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
        builder: (context, state) {
          return Stack(
            children: [
              // ── Fixed full-bleed hero — lives behind the sheet, not
              // inside its scroll, so it never moves while dragging ──
              Positioned.fill(child: _HeroImage(imageUrl: _heroImageUrl)),

              // ── Smooth, draggable info sheet ──────────────────────
              // Peeks at ~55% of the screen; can be pulled up to ~85%
              // to comfortably browse "More like this" without it
              // feeling cramped.
              DraggableScrollableSheet(
                initialChildSize: 0.55,
                minChildSize: 0.46,
                maxChildSize: 0.85,
                snap: true,
                snapSizes: const [0.55, 0.85],
                builder: (context, scrollController) {
                  return _InfoPanel(
                    wallpaper: wallpaper,
                    state: state,
                    relatedWallpapers: relatedWallpapers,
                    scrollController: scrollController,
                    onPreview: () => _onPreview(context),
                    onSetWallpaper: () => _onSetWallpaper(context),
                    onTapRelated: (w) => _onTapRelated(context, w),
                  );
                },
              ),

              // ── Floating top actions (back / share) ──────────────
              Positioned(
                top: MediaQuery.of(context).padding.top + AppDimensions.s,
                left: AppDimensions.md,
                right: AppDimensions.md,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppButton.glass(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onTap: () => context.pop(),
                    ),
                    AppButton.glass(
                      icon: const Icon(
                        Icons.share_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: const Text('Sharing coming soon.'),
                              backgroundColor: AppColors.surfaceHigh,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Hero Image ───────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  final String imageUrl;

  const _HeroImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => const AppShimmer(),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.cardSurface,
        child: Icon(
          Icons.broken_image_outlined,
          color: AppColors.navInactive,
          size: AppDimensions.iconLg,
        ),
      ),
    );
  }
}

// ─── Info Panel (the draggable sheet's content) ────────────────────────────────

class _InfoPanel extends StatelessWidget {
  final WallpaperEntity wallpaper;
  final WallpaperActionsState state;
  final List<WallpaperEntity> relatedWallpapers;
  final ScrollController scrollController;
  final VoidCallback onPreview;
  final VoidCallback onSetWallpaper;
  final ValueChanged<WallpaperEntity> onTapRelated;

  const _InfoPanel({
    required this.wallpaper,
    required this.state,
    required this.relatedWallpapers,
    required this.scrollController,
    required this.onPreview,
    required this.onSetWallpaper,
    required this.onTapRelated,
  });

  String _categoryLabel() {
    final slug = wallpaper.categorySlug;
    if (slug.isEmpty) return 'Wallpaper';
    return slug[0].toUpperCase() + slug.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final title = wallpaper.title.isEmpty ? 'Untitled' : wallpaper.title;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.pillRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 28,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.fromLTRB(
          AppDimensions.md,
          AppDimensions.s,
          AppDimensions.md,
          AppDimensions.xl,
        ),
        children: [
          // ── Drag handle ──────────────────────────────────────────
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
              ),
            ),
          ),
          SizedBox(height: AppDimensions.s),

          // ── Title + favourite ────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(title, style: AppTextStyles.headlineMd)),
              SizedBox(width: AppDimensions.s),
              _FavouriteButton(isFavourited: state.isFavourited),
            ],
          ),
          SizedBox(height: AppDimensions.md),

          // ── Meta chips ───────────────────────────────────────────
          Wrap(
            spacing: AppDimensions.s,
            runSpacing: AppDimensions.s,
            children: [
              _MetaChip(label: _categoryLabel()),
              _MetaChip(label: wallpaper.resolution),
              if (wallpaper.width > 0 && wallpaper.height > 0)
                _MetaChip(label: '${wallpaper.width}×${wallpaper.height}'),
            ],
          ),
          SizedBox(height: AppDimensions.lg),

          // ── Author + stats ───────────────────────────────────────
          AuthorStatsRow(
            authorName: wallpaper.authorName,
            authorHandle: wallpaper.authorHandle,
            authorAvatarUrl: wallpaper.authorAvatarUrl,
            downloadCount: wallpaper.downloadCount,
            viewCount: wallpaper.viewCount,
          ),
          SizedBox(height: AppDimensions.lg),

          // ── Actions: Preview / Set wallpaper ─────────────────────
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AppButton.secondary(label: 'Preview', onTap: onPreview),
              ),
              SizedBox(width: AppDimensions.md),
              Expanded(
                flex: 3,
                child: AppButton.primary(
                  label: 'Set wallpaper',
                  isLoading: state.isBusy,
                  onTap: onSetWallpaper,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.lg),

          // ── Pro upsell ───────────────────────────────────────────
          ProUpsellBanner(
            onUpgrade: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: const Text('Pro upgrade coming soon.'),
                    backgroundColor: AppColors.surfaceHigh,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
          ),
          SizedBox(height: AppDimensions.lg),

          // ── More like this ───────────────────────────────────────
          Text('More like this', style: AppTextStyles.headlineSm),
          SizedBox(height: AppDimensions.md),
          // MoreLikeThisGrid(wallpapers: relatedWallpapers, onTap: onTapRelated),
        ],
      ),
    );
  }
}

// ─── Small pieces ─────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final String label;

  const _MetaChip({required this.label});

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

class _FavouriteButton extends StatelessWidget {
  final bool isFavourited;

  const _FavouriteButton({required this.isFavourited});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<WallpaperActionsCubit>().toggleFavourite(),
      child: Container(
        width: AppDimensions.avatarSm,
        height: AppDimensions.avatarSm,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavourited ? Icons.favorite : Icons.favorite_border,
          color: isFavourited ? AppColors.error : AppColors.primary,
          size: AppDimensions.iconMd,
        ),
      ),
    );
  }
}
