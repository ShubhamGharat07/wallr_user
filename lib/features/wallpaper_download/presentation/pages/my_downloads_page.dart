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
import '../bloc/downloads_bloc.dart';
import '../bloc/downloads_event.dart';
import '../bloc/downloads_state.dart';

class MyDownloadsPage extends StatelessWidget {
  const MyDownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DownloadsBloc>()..add(const DownloadsRequested()),
      child: RepaintBoundary(
        child: Container(
          color: AppColors.background,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(context),
            body: RepaintBoundary(
              child: BlocBuilder<DownloadsBloc, DownloadsState>(
                builder: (context, state) {
                  if (state is DownloadsLoading || state is DownloadsInitial) {
                    return const _LoadingView();
                  } else if (state is DownloadsError) {
                    return _ErrorView(
                      message: state.message,
                      onRetry: () {
                        context.read<DownloadsBloc>().add(const DownloadsRequested());
                      },
                    );
                  } else if (state is DownloadsLoaded) {
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
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(AppDimensions.appBarHeight),
      child: Container(
        color: AppColors.background,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.sm,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.onSurface,
                    size: AppDimensions.iconMd,
                  ),
                ),
                SizedBox(width: AppDimensions.md),
                Text(
                  'My Downloads',
                  style: AppTextStyles.headlineMd.copyWith(
                    color: AppColors.onSurface,
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
            Icons.download_outlined,
            size: 64.w,
            color: AppColors.navInactive,
          ),
          SizedBox(height: AppDimensions.lg),
          Text(
            'No downloaded wallpapers',
            style: AppTextStyles.headlineSm.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: AppDimensions.xs),
          Text(
            'Download wallpapers to access them offline',
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
              'Couldn\'t load downloads',
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
    final bloc = context.read<DownloadsBloc>();
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
                label: 'Delete',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(dialogContext);
                  bloc.add(DownloadDeleted(wallpaperId: wallpaper.id));
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
                return _DownloadedWallpaperCard(
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

// ─── Downloaded Wallpaper Card ─────────────────────────────────────────────

class _DownloadedWallpaperCard extends StatelessWidget {
  final WallpaperEntity wallpaper;
  final VoidCallback onTap;

  const _DownloadedWallpaperCard({
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
