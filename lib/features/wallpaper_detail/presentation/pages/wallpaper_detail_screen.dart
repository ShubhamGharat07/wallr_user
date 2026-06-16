// lib/features/wallpaper_detail/presentation/pages/wallpaper_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../widgets/pro_upsell_banner.dart';
import '../widgets/set_wallpaper_sheet.dart';

/// WALLR — Wallpaper Detail Screen
///
/// Opened when a wallpaper card is tapped anywhere in the app. Shows the
/// hero image with a scrollable info panel: title, meta chips, author +
/// stats, Preview / Set wallpaper actions, and the Pro upsell.
///
/// Provides its own [WallpaperActionsCubit] from DI.
class WallpaperDetailScreen extends StatelessWidget {
  final WallpaperEntity wallpaper;

  const WallpaperDetailScreen({super.key, required this.wallpaper});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WallpaperActionsCubit>(),
      child: _DetailView(wallpaper: wallpaper),
    );
  }
}

class _DetailView extends StatelessWidget {
  final WallpaperEntity wallpaper;

  const _DetailView({required this.wallpaper});

  /// Resolves the public id from a Cloudinary URL, or returns the value
  /// as-is if it's already a public id. The detail/full image is built
  /// through [ImageUtils] for an optimised, device-appropriate fetch.
  String get _heroImageUrl =>
      wallpaper.imageUrl.isNotEmpty ? wallpaper.imageUrl : wallpaper.cardImageUrl;

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
              // ── Scrollable content ───────────────────────────────
              CustomScrollView(
                slivers: [
                  // Hero image
                  SliverToBoxAdapter(
                    child: _HeroImage(imageUrl: _heroImageUrl),
                  ),

                  // Info panel
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: Offset(0, -AppDimensions.lg),
                      child: _InfoPanel(
                        wallpaper: wallpaper,
                        state: state,
                        onPreview: () => _onPreview(context),
                        onSetWallpaper: () => _onSetWallpaper(context),
                      ),
                    ),
                  ),
                ],
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
    // Image occupies ~62% of screen height — leaves room for the info panel.
    final height = MediaQuery.of(context).size.height * 0.62;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppDimensions.pillRadius),
        ),
        child: CachedNetworkImage(
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
        ),
      ),
    );
  }
}

// ─── Info Panel ───────────────────────────────────────────────────────────────

class _InfoPanel extends StatelessWidget {
  final WallpaperEntity wallpaper;
  final WallpaperActionsState state;
  final VoidCallback onPreview;
  final VoidCallback onSetWallpaper;

  const _InfoPanel({
    required this.wallpaper,
    required this.state,
    required this.onPreview,
    required this.onSetWallpaper,
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
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.pillRadius),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.md,
        AppDimensions.lg,
        AppDimensions.md,
        AppDimensions.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title + favourite ────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(title, style: AppTextStyles.headlineMd),
              ),
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
                child: AppButton.secondary(
                  label: 'Preview',
                  onTap: onPreview,
                ),
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

          // ── More like this (placeholder header) ──────────────────
          Text('More like this', style: AppTextStyles.headlineSm),
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
