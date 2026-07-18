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
// import '../widgets/author_stats_row.dart';
// import '../widgets/more_like_this_grid.dart';
// import '../widgets/pro_upsell_banner.dart';
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

  Future<void> _onDownload(BuildContext context) async {
    await context.read<WallpaperActionsCubit>().downloadWallpaper(
      imageUrl: _heroImageUrl,
      wallpaperId: wallpaper.id,
      fileName: wallpaper.title.isEmpty ? 'wallpaper' : wallpaper.title,
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
                    onDownload: () => _onDownload(context),
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
    return RepaintBoundary(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        memCacheWidth: 800,
        memCacheHeight: 1400,
        maxHeightDiskCache: 1600,
        maxWidthDiskCache: 1000,
        placeholder: (_, __) => const AppShimmer(),
        errorWidget: (_, _, _) => Container(
          color: AppColors.cardSurface,
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.navInactive,
            size: AppDimensions.iconLg,
          ),
        ),
        useOldImageOnUrlChange: true,
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
  final VoidCallback onDownload;
  final ValueChanged<WallpaperEntity> onTapRelated;

  const _InfoPanel({
    required this.wallpaper,
    required this.state,
    required this.relatedWallpapers,
    required this.scrollController,
    required this.onPreview,
    required this.onSetWallpaper,
    required this.onDownload,
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
            color: Colors.black.withValues(alpha: 0.4),
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
          const Center(child: _DragHandle()),
          SizedBox(height: AppDimensions.s),

          // ── Title + Favourite Button ────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.headlineMd,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppDimensions.s),
              // Favourite button
              GestureDetector(
                onTap: () =>
                    context.read<WallpaperActionsCubit>().toggleFavourite(),
                child: Container(
                  width: AppDimensions.avatarSm,
                  height: AppDimensions.avatarSm,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    state.isFavourited ? Icons.favorite : Icons.favorite_border,
                    color: state.isFavourited
                        ? AppColors.error
                        : AppColors.primary,
                    size: AppDimensions.iconMd,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.md),

          // ── Wallpaper Info (Category, Quality, Size) ──────────────
          Row(
            children: [
              // Category
              Expanded(
                child: _InfoItem(
                  icon: Icons.category_rounded,
                  label: 'Category',
                  value: _categoryLabel(),
                ),
              ),
              SizedBox(width: AppDimensions.md),
              // Resolution
              Expanded(
                child: _InfoItem(
                  icon: Icons.hd_rounded,
                  label: 'Quality',
                  value: wallpaper.resolution,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.md),

          // Size (if available)
          if (wallpaper.width > 0 && wallpaper.height > 0)
            _InfoItem(
              icon: Icons.aspect_ratio_rounded,
              label: 'Size',
              value: '${wallpaper.width} × ${wallpaper.height}',
            ),
          SizedBox(height: AppDimensions.lg),

          // ── Primary Action: Set wallpaper (FAST) ────────────────
          AppButton.primary(
            label: 'Set wallpaper',
            isLoading: state.isBusy,
            onTap: onSetWallpaper,
          ),
          SizedBox(height: AppDimensions.md),

          // ── Secondary Actions: Preview / Download ──────────────────
          Row(
            children: [
              Expanded(
                child: AppButton.secondary(label: 'Preview', onTap: onPreview),
              ),
              SizedBox(width: AppDimensions.md),
              Expanded(
                child: _DownloadButton(
                  state: state,
                  onTap: onDownload,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.lg),

          // ── Divider ────────────────────────────────────────────
          Divider(
            height: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: AppDimensions.lg),

          // ── Lazy-loaded heavy content ────────────────────────────
          _LazyContent(
            wallpaper: wallpaper,
            relatedWallpapers: relatedWallpapers,
            onTapRelated: onTapRelated,
          ),
        ],
      ),
    );
  }
}

// ─── Download Button with Progress ────────────────────────────────────────

class _DownloadButton extends StatelessWidget {
  final WallpaperActionsState state;
  final VoidCallback onTap;

  const _DownloadButton({
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDownloading = state.status == WallpaperActionStatus.downloading;
    final downloadProgress = state.downloadProgress;

    // Show progress % when downloading
    if (isDownloading) {
      return Stack(
        children: [
          // Background bar with progress
          Container(
            height: AppDimensions.buttonHeight,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.containerRadius),
              border: Border.all(
                color: AppColors.primaryContainer,
                width: 1.5,
              ),
            ),
            // Progress fill
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.containerRadius),
              child: LinearProgressIndicator(
                value: downloadProgress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryContainer.withValues(alpha: 0.3),
                ),
                minHeight: AppDimensions.buttonHeight,
              ),
            ),
          ),
          // Progress text
          Center(
            child: Text(
              '${(downloadProgress * 100).toStringAsFixed(0)}%',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.primaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    // Download button
    return GestureDetector(
      onTap: state.isBusy ? null : onTap,
      child: Container(
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(AppDimensions.containerRadius),
          border: Border.all(
            color: AppColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_rounded,
              size: AppDimensions.iconMd,
              color: AppColors.primary,
            ),
            SizedBox(width: AppDimensions.xs),
            Text(
              'Download',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small pieces ─────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.outlineVariant,
        borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
      ),
    );
  }
}

// ─── Lazy Content (deferred rendering) ─────────────────────────────────────

class _LazyContent extends StatefulWidget {
  final WallpaperEntity wallpaper;
  final List<WallpaperEntity> relatedWallpapers;
  final ValueChanged<WallpaperEntity> onTapRelated;

  const _LazyContent({
    required this.wallpaper,
    required this.relatedWallpapers,
    required this.onTapRelated,
  });

  @override
  State<_LazyContent> createState() => _LazyContentState();
}

class _LazyContentState extends State<_LazyContent> {
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showContent) {
      return SizedBox(height: AppDimensions.lg);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // // ── Author + stats (LAZY) ────────────────────────────────
        // AuthorStatsRow(
        //   authorName: widget.wallpaper.authorName,
        //   authorHandle: widget.wallpaper.authorHandle,
        //   authorAvatarUrl: widget.wallpaper.authorAvatarUrl,
        //   downloadCount: widget.wallpaper.downloadCount,
        //   viewCount: widget.wallpaper.viewCount,
        // ),
        // SizedBox(height: AppDimensions.lg),

        // // ── Pro upsell (LAZY) ────────────────────────────────────
        // ProUpsellBanner(
        //   onUpgrade: () {
        //     ScaffoldMessenger.of(context)
        //       ..hideCurrentSnackBar()
        //       ..showSnackBar(
        //         SnackBar(
        //           content: const Text('Pro upgrade coming soon.'),
        //           backgroundColor: AppColors.surfaceHigh,
        //           behavior: SnackBarBehavior.floating,
        //         ),
        //       );
        //   },
        // ),
        // SizedBox(height: AppDimensions.lg),

        // ── More like this (LAZY) ────────────────────────────────
        if (widget.relatedWallpapers.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('More like this', style: AppTextStyles.headlineSm),
              SizedBox(height: AppDimensions.md),
              _MoreLikeThisGrid(
                wallpapers: widget.relatedWallpapers.take(5).toList(),
                onTap: widget.onTapRelated,
              ),
            ],
          ),
      ],
    );
  }
}

// ─── More Like This Grid ─────────────────────────────────────────────────────

class _MoreLikeThisGrid extends StatelessWidget {
  final List<WallpaperEntity> wallpapers;
  final ValueChanged<WallpaperEntity> onTap;

  const _MoreLikeThisGrid({
    required this.wallpapers,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 160.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: wallpapers.length,
          itemBuilder: (context, index) {
            final wallpaper = wallpapers[index];
            return Padding(
              padding: EdgeInsets.only(right: AppDimensions.md),
              child: GestureDetector(
                onTap: () => onTap(wallpaper),
                child: RepaintBoundary(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                    child: CachedNetworkImage(
                      imageUrl: wallpaper.cardImageUrl,
                      fit: BoxFit.cover,
                      width: 100.w,
                      height: 160.h,
                      memCacheWidth: 150,
                      memCacheHeight: 240,
                      maxWidthDiskCache: 200,
                      maxHeightDiskCache: 300,
                      placeholder: (_, _) => Container(
                        color: AppColors.surface,
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: AppColors.cardSurface,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.navInactive,
                          size: AppDimensions.iconMd,
                        ),
                      ),
                      useOldImageOnUrlChange: true,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Small pieces ─────────────────────────────────────────────────────────────

/// Simple info item with icon, label, and value
/// Example: [category icon] Category: Space
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with icon
          Row(
            children: [
              Icon(icon, size: AppDimensions.iconSm, color: AppColors.primary),
              SizedBox(width: AppDimensions.s),
              Text(
                label,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.xs),
          // Value
          Text(
            value,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

