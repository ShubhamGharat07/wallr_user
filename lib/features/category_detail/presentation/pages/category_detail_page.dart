// lib/features/category_detail/presentation/pages/category_detail_page.dart

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
import '../../../categories/domain/entities/category_with_wallpapers_entity.dart';
import '../../../home/domain/entities/wallpaper_entity.dart';
import '../bloc/category_detail_bloc.dart';
import '../bloc/category_detail_event.dart';
import '../bloc/category_detail_state.dart';

class CategoryDetailPage extends StatelessWidget {
  final CategoryWithWallpapersEntity category;

  const CategoryDetailPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<CategoryDetailBloc>()
            ..add(WallpapersByCategoryRequested(categorySlug: category.slug)),
      child: RepaintBoundary(
        child: Container(
          color: AppColors.background,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(context),
            body: RepaintBoundary(
              child: BlocBuilder<CategoryDetailBloc, CategoryDetailState>(
                builder: (context, state) {
                  if (state is CategoryDetailLoading ||
                      state is CategoryDetailInitial) {
                    return const _LoadingView();
                  } else if (state is CategoryDetailError) {
                    return _ErrorView(
                      message: state.message,
                      onRetry: () {
                        context.read<CategoryDetailBloc>().add(
                          WallpapersByCategoryRequested(
                            categorySlug: category.slug,
                          ),
                        );
                      },
                    );
                  } else if (state is CategoryDetailLoaded) {
                    return _ContentView(wallpapers: state.wallpapers);
                  } else {
                    return const _LoadingView();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(0),
      child: Container(
        color: AppColors.background,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
            child: Row(children: [
                
              ],
            ),
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
              crossAxisCount: 2,
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

// ─── Error View ───────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64.w, color: AppColors.error),
            SizedBox(height: AppDimensions.lg),
            Text(
              'Couldn\'t load wallpapers',
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
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
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

  @override
  Widget build(BuildContext context) {
    if (wallpapers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 64.w,
              color: AppColors.navInactive,
            ),
            SizedBox(height: AppDimensions.lg),
            Text(
              'No wallpapers found',
              style: AppTextStyles.headlineSm.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.md,
              mainAxisSpacing: AppDimensions.md,
              childAspectRatio: 0.65,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final wallpaper = wallpapers[index];
              return WallpaperCard(
                imageUrl: wallpaper.cardImageUrl,
                title: wallpaper.title.isEmpty ? null : wallpaper.title,
                resolution: wallpaper.resolution,
                isPremium: wallpaper.isPremium,
                onTap: () {
                  final related = wallpapers
                      .where((w) => w.id != wallpaper.id)
                      .toList();
                  context.push(
                    RouteNames.wallpaperDetail,
                    extra: WallpaperDetailExtras(
                      wallpaper: wallpaper,
                      relatedWallpapers: related,
                    ),
                  );
                },
              );
            }, childCount: wallpapers.length),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: AppDimensions.xl)),
      ],
    );
  }
}
