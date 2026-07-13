import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/di/injection_container.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../domain/entities/category_with_wallpapers_entity.dart';
import '../bloc/categories_bloc.dart';
import '../bloc/categories_event.dart';
import '../bloc/categories_state.dart';

// Placeholder color generator for fallback backgrounds
Color _generatePlaceholderColor(String id) {
  final colors = [
    const Color(0xFF1a1a2e),
    const Color(0xFF2d5016),
    const Color(0xFF1a0033),
    const Color(0xFF0a0a0a),
    const Color(0xFF1a1410),
    const Color(0xFF0d0820),
    const Color(0xFF1a2a3a),
    const Color(0xFF3a1a1a),
  ];
  return colors[id.hashCode % colors.length];
}

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoriesBloc>()..add(const CategoriesRequested()),
      child: Container(
        color: AppColors.background,
        child: BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesLoading || state is CategoriesInitial) {
              return const _LoadingView();
            } else if (state is CategoriesError) {
              return _ErrorView(message: state.message);
            } else if (state is CategoriesLoaded) {
              return _ContentView(categories: state.categories);
            } else {
              return const _LoadingView();
            }
          },
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
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.primaryContainer,
        ),
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: AppColors.error,
            ),
            SizedBox(height: AppDimensions.lg),
            Text(
              'Couldn\'t load categories',
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
              onPressed: () {
                context.read<CategoriesBloc>().add(
                  const CategoriesRequested(),
                );
              },
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
  final List<CategoryWithWallpapersEntity> categories;

  const _ContentView({required this.categories});

  @override
  Widget build(BuildContext context) {
    final featured = categories.isNotEmpty ? categories.first : null;
    final others = categories.length > 1 ? categories.skip(1).toList() : [];

    return CustomScrollView(
      slivers: [
        // ── Header Section ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppDimensions.md),
                Text(
                  'Categories',
                  style: AppTextStyles.headlineLgMobile.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 32.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${categories.length} curated collections',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppDimensions.lg),
              ],
            ),
          ),
        ),

        // ── Featured Collection Card ──────────────────────────────
        if (featured != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
              child: _FeaturedCollectionCard(category: featured),
            ),
          ),

        if (featured != null)
          SliverToBoxAdapter(child: SizedBox(height: AppDimensions.lg)),

        // ── Category Cards Grid ────────────────────────────────────
        if (others.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
              child: Text(
                'Explore',
                style: AppTextStyles.headlineMd.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: AppDimensions.md)),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.md,
              mainAxisSpacing: AppDimensions.md,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _CategoryCard(category: others[index]),
              childCount: others.length,
            ),
          ),
        ],

        SliverToBoxAdapter(child: SizedBox(height: AppDimensions.xl)),
      ],
    );
  }
}

// ─── Featured Collection Card ─────────────────────────────────────────────

class _FeaturedCollectionCard extends StatelessWidget {
  final CategoryWithWallpapersEntity category;

  const _FeaturedCollectionCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final bgColor = _generatePlaceholderColor(category.id);
    final hasImage = category.coverUrl.isNotEmpty;

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.containerRadius),
        child: Container(
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.containerRadius),
            border: Border.all(
              color: AppColors.surface,
              width: 0.5,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
            // Background / Image
            if (hasImage)
              CachedNetworkImage(
                imageUrl: category.coverUrl,
                fit: BoxFit.cover,
                memCacheWidth: 500,
                memCacheHeight: 300,
                maxHeightDiskCache: 500,
                maxWidthDiskCache: 700,
                placeholder: (_, _) => const AppShimmer(),
                errorWidget: (_, _, _) => _ErrorImagePlaceholder(
                  bgColor: bgColor,
                ),
                useOldImageOnUrlChange: true,
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2a1a1a),
                      Color(0xFF1a0a0a),
                    ],
                  ),
                ),
              ),

            // Gradient overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),

            // Premium badge
            if (category.isPremium)
              Positioned(
                top: 10.h,
                right: 20.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 14.w,
                        color: AppColors.onPrimaryContainer,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'PREMIUM',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onPrimaryContainer,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Content
            Positioned(
              bottom: 16.h,
              left: 16.w,
              right: 16.w - 40.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'FEATURED COLLECTION',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineMd.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ─── Category Card ────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final CategoryWithWallpapersEntity category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final bgColor = _generatePlaceholderColor(category.id);
    final hasImage = category.coverUrl.isNotEmpty;

    return GestureDetector(
      onTap: () {},
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.surface,
                width: 0.5,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image with caching & shimmer loading
                if (hasImage)
                  CachedNetworkImage(
                    imageUrl: category.coverUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 400,
                    memCacheHeight: 600,
                    maxHeightDiskCache: 800,
                    maxWidthDiskCache: 500,
                    placeholder: (_, _) => const AppShimmer(),
                    errorWidget: (_, _, _) => _ErrorImagePlaceholder(
                      bgColor: bgColor,
                    ),
                    useOldImageOnUrlChange: true,
                  )
                else
                  Container(color: bgColor),

                // Gradient overlay for text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.5, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        AppColors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(AppDimensions.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headlineSm.copyWith(
                          color: AppColors.onSurface,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '${category.wallpaperCount} Wallpapers',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Error Image Placeholder ──────────────────────────────────────────────

class _ErrorImagePlaceholder extends StatelessWidget {
  final Color bgColor;

  const _ErrorImagePlaceholder({required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.navInactive,
          size: AppDimensions.iconLg,
        ),
      ),
    );
  }
}
