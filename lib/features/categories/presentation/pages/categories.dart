import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/di/injection_container.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../category_detail/presentation/pages/category_detail_page.dart';
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
    return CustomScrollView(
      slivers: [
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
                  'Loading curated collections',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppDimensions.lg),
              ],
            ),
          ),
        ),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.md,
            mainAxisSpacing: AppDimensions.md,
            childAspectRatio: 0.75,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                child: const AppShimmer(),
              ),
            ),
            childCount: 6,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: AppDimensions.xl)),
      ],
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

        // ── Category Cards Grid ────────────────────────────────────
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.md,
            mainAxisSpacing: AppDimensions.md,
            childAspectRatio: 0.75,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _CategoryCard(category: categories[index]),
            childCount: categories.length,
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: AppDimensions.xl)),
      ],
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryDetailPage(category: category),
          ),
        );
      },
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
