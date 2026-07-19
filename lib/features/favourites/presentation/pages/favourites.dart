import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/di/injection_container.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/wallpaper_card.dart';
import '../../../home/domain/entities/wallpaper_entity.dart';
import '../../../wallpaper_favourite/presentation/bloc/favorites_bloc.dart';
import '../../../wallpaper_favourite/presentation/bloc/favorites_event.dart';
import '../../../wallpaper_favourite/presentation/bloc/favorites_state.dart';

class Favourites extends StatelessWidget {
  const Favourites({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FavoritesBloc>()..add(const FavoritesRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RepaintBoundary(
          child: BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              if (state is FavoritesLoading || state is FavoritesInitial) {
                return const _LoadingView();
              } else if (state is FavoritesError) {
                return _ErrorView(
                  message: state.message,
                  onRetry: () {
                    context.read<FavoritesBloc>().add(const FavoritesRequested());
                  },
                );
              } else if (state is FavoritesLoaded) {
                if (state.wallpapers.isEmpty) {
                  return const _EmptyView();
                }
                return _ContentView(wallpapers: state.wallpapers);
              } else {
                return const _LoadingView();
              }
            },
          ),
        ),
      ),
    );
  }
}

// ─── Loading View ─────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppDimensions.md),
                SizedBox(
                  height: 20.h,
                  width: 200.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.lg),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppDimensions.gridColumnCount,
              crossAxisSpacing: AppDimensions.md,
              mainAxisSpacing: AppDimensions.md,
              childAspectRatio: 0.65,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _ShimmerCard(),
              childCount: 8,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: AppDimensions.xl)),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          ),
        ),
      ),
    );
  }
}

// ─── Empty View ───────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 64.w,
            color: AppColors.navInactive,
          ),
          SizedBox(height: AppDimensions.lg),
          Text(
            'No favorites yet',
            style: AppTextStyles.headlineSm.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: AppDimensions.xs),
          Text(
            'Add wallpapers to your favorites',
            style: AppTextStyles.bodyMdMuted,
          ),
        ],
      ),
    );
  }
}

// ─── Error View ────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64.w,
              color: AppColors.navInactive,
            ),
            SizedBox(height: AppDimensions.lg),
            Text(
              'Couldn\'t load favorites',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSm,
            ),
            SizedBox(height: AppDimensions.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMdMuted,
            ),
            SizedBox(height: AppDimensions.lg),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Content View ──────────────────────────────────────────────────────────

class _ContentView extends StatelessWidget {
  final List<WallpaperEntity> wallpapers;

  const _ContentView({required this.wallpapers});

  void _showOptionsDialog(BuildContext context, WallpaperEntity wallpaper) {
    final bloc = context.read<FavoritesBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.containerRadius),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Wallpaper Options',
                style: AppTextStyles.headlineSm.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(height: AppDimensions.lg),
              _DialogOptionItem(
                icon: Icons.visibility_rounded,
                label: 'View',
                onTap: () {
                  Navigator.pop(dialogContext);
                  context.push(
                    RouteNames.wallpaperDetail,
                    extra: WallpaperDetailExtras(
                      wallpaper: wallpaper,
                    ),
                  );
                },
              ),
              SizedBox(height: AppDimensions.md),
              _DialogOptionItem(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Share: ${wallpaper.title}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              SizedBox(height: AppDimensions.md),
              _DialogOptionItem(
                icon: Icons.delete_rounded,
                label: 'Remove',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(dialogContext);
                  bloc.add(FavoriteRemoved(wallpaperId: wallpaper.id));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppDimensions.gridColumnCount,
              crossAxisSpacing: AppDimensions.md,
              mainAxisSpacing: AppDimensions.md,
              childAspectRatio: 0.65,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final wallpaper = wallpapers[index];
                return _FavoriteWallpaperCard(
                  wallpaper: wallpaper,
                  onTap: () {
                    _showOptionsDialog(context, wallpaper);
                  },
                );
              },
              childCount: wallpapers.length,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: AppDimensions.xl)),
      ],
    );
  }
}

// ─── Dialog Option Item ────────────────────────────────────────────────────

class _DialogOptionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DialogOptionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.md,
        ),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.w,
              color: isDestructive ? AppColors.error : AppColors.primaryContainer,
            ),
            SizedBox(width: AppDimensions.md),
            Text(
              label,
              style: AppTextStyles.bodyMd.copyWith(
                color: isDestructive ? AppColors.error : AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Favorite Wallpaper Card ──────────────────────────────────────────────

class _FavoriteWallpaperCard extends StatelessWidget {
  final WallpaperEntity wallpaper;
  final VoidCallback onTap;

  const _FavoriteWallpaperCard({
    required this.wallpaper,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: WallpaperCard(
          imageUrl: wallpaper.cardImageUrl,
          title: wallpaper.title.isEmpty ? null : wallpaper.title,
          resolution: wallpaper.resolution,
          isPremium: wallpaper.isPremium,
          onTap: onTap,
        ),
      ),
    );
  }
}
