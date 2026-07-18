import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/wallpaper_card.dart';
import '../../domain/entities/home_feed_entity.dart';
import '../../domain/entities/wallpaper_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/category_coming_soon_card.dart';
import '../widgets/category_icon_map.dart';
import '../widgets/home_loading_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ValueNotifier<String> _selectedCategoryNotifier;

  @override
  void initState() {
    super.initState();
    _selectedCategoryNotifier = ValueNotifier('all');
    context.read<HomeBloc>().add(const HomeFeedRequested());
  }

  @override
  void dispose() {
    _selectedCategoryNotifier.dispose();
    super.dispose();
  }

  void _onWallpaperTap(WallpaperEntity wallpaper) {
    context.push(RouteNames.wallpaperDetail, extra: wallpaper);
  }

  Future<void> _onRefresh() async {
    context.read<HomeBloc>().add(const HomeFeedRefreshed());
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            switch (state) {
              case HomeInitial():
              case HomeLoading():
                return const HomeLoadingView();

              case HomeError(message: final message):
                return _HomeErrorView(
                  message: message,
                  onRetry: () =>
                      context.read<HomeBloc>().add(const HomeFeedRequested()),
                );

              case HomeLoaded(feed: final feed):
                return RefreshIndicator(
                  color: AppColors.primaryContainer,
                  backgroundColor: AppColors.surface,
                  onRefresh: _onRefresh,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Category Filters ───────────────────
                              if (feed.categorySections.isNotEmpty) ...[
                                Text(
                                  'Categories',
                                  style: AppTextStyles.headlineMd.copyWith(
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                SizedBox(height: AppDimensions.md),
                                SizedBox(
                                  height: AppDimensions.chipHeight + 8.h,
                                  child: ValueListenableBuilder<String>(
                                    valueListenable: _selectedCategoryNotifier,
                                    builder: (context, selectedCategorySlug, _) {
                                      return ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            feed.categorySections.length + 1,
                                        itemBuilder: (context, index) {
                                          // First chip is always "All"
                                          if (index == 0) {
                                            final isActive =
                                                selectedCategorySlug == 'all';
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                right: AppDimensions.s,
                                              ),
                                              child: AppChip.filter(
                                                label: 'All',
                                                isActive: isActive,
                                                activeColor: AppColors
                                                    .primaryContainer,
                                                onTap: () {
                                                  _selectedCategoryNotifier
                                                      .value = 'all';
                                                },
                                              ),
                                            );
                                          }

                                          final category = feed
                                              .categorySections[index - 1]
                                              .category;
                                          final isActive =
                                              selectedCategorySlug ==
                                                  category.slug;
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              right: AppDimensions.s,
                                            ),
                                            child: AppChip.filter(
                                              label: category.name,
                                              isActive: isActive,
                                              activeColor: AppColors
                                                  .primaryContainer,
                                              onTap: () {
                                                _selectedCategoryNotifier
                                                    .value = category.slug;
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: AppDimensions.lg),
                              ],

                              // ── Editor's Choice ────────────────────
                              if (feed.editorsChoice.isNotEmpty) ...[
                                Text(
                                  'Editor\'s Choice',
                                  style: AppTextStyles.headlineMd.copyWith(
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                SizedBox(height: AppDimensions.md),
                                SizedBox(
                                  height: 300.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: feed.editorsChoice.length,
                                    itemBuilder: (context, index) {
                                      final wallpaper =
                                          feed.editorsChoice[index];
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          right: AppDimensions.md,
                                        ),
                                        child: SizedBox(
                                          width: 220.w,
                                          child: WallpaperCard(
                                            imageUrl: wallpaper.cardImageUrl,
                                            title: wallpaper.title.isEmpty
                                                ? null
                                                : wallpaper.title,
                                            resolution: wallpaper.resolution,
                                            isPremium: wallpaper.isPremium,
                                            onTap: () =>
                                                _onWallpaperTap(wallpaper),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: AppDimensions.lg),
                              ],

                              // ── Selected Category / All Grid ───────
                              ValueListenableBuilder<String>(
                                valueListenable: _selectedCategoryNotifier,
                                builder: (context, selectedCategorySlug, _) {
                                  return _SelectedSectionView(
                                    feed: feed,
                                    selectedCategorySlug: selectedCategorySlug,
                                    onWallpaperTap: _onWallpaperTap,
                                  );
                                },
                              ),

                              SizedBox(height: AppDimensions.xl),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}

// ─── Selected Section (All wallpapers OR a single category's) ──────────────

class _SelectedSectionView extends StatelessWidget {
  final HomeFeedEntity feed;
  final String selectedCategorySlug;
  final void Function(WallpaperEntity wallpaper) onWallpaperTap;

  const _SelectedSectionView({
    required this.feed,
    required this.selectedCategorySlug,
    required this.onWallpaperTap,
  });

  /// "All" = every category's wallpapers + trending, de-duplicated by id.
  /// So a wallpaper that belongs to "Anime" shows up under BOTH
  /// "All" and "Anime" — same underlying data, just merged for "All".
  List<WallpaperEntity> _allWallpapers() {
    final byId = <String, WallpaperEntity>{};

    for (final w in feed.trending) {
      byId[w.id] = w;
    }
    for (final section in feed.categorySections) {
      for (final w in section.wallpapers) {
        byId.putIfAbsent(w.id, () => w);
      }
    }

    return byId.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAll = selectedCategorySlug == 'all';

    final String title;
    final List<WallpaperEntity> wallpapers;
    CategorySectionEntity? section;

    if (isAll) {
      title = 'All Wallpapers';
      wallpapers = _allWallpapers();
    } else {
      section = feed.categorySections.firstWhere(
        (s) => s.category.slug == selectedCategorySlug,
        orElse: () => feed.categorySections.first,
      );
      title = section.category.name;
      wallpapers = section.wallpapers;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineMd.copyWith(color: AppColors.onSurface),
        ),
        SizedBox(height: AppDimensions.md),
        if (wallpapers.isEmpty)
          _ComingSoonSection(section: section)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppDimensions.gridColumnCount,
              crossAxisSpacing: AppDimensions.md,
              mainAxisSpacing: AppDimensions.md,
              childAspectRatio: 0.65,
            ),
            itemCount: wallpapers.length,
            itemBuilder: (context, index) {
              final wallpaper = wallpapers[index];
              return WallpaperCard(
                imageUrl: wallpaper.cardImageUrl,
                title: wallpaper.title.isEmpty ? null : wallpaper.title,
                resolution: wallpaper.resolution,
                isPremium: wallpaper.isPremium,
                onTap: () => onWallpaperTap(wallpaper),
              );
            },
          ),
      ],
    );
  }
}

// ─── Coming Soon (selected category has zero wallpapers) ───────────────────

class _ComingSoonSection extends StatelessWidget {
  final CategorySectionEntity? section;

  const _ComingSoonSection({required this.section});

  @override
  Widget build(BuildContext context) {
    final category = section?.category;
    final accentColor = category == null
        ? AppColors.primaryContainer
        : hexToColor(
            category.accentColor,
            fallback: AppColors.primaryContainer,
          );
    final icon = category == null
        ? Icons.image_search_rounded
        : categoryIconFromName(category.iconName);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.xxl),
      child: Center(
        child: CategoryComingSoonCard(icon: icon, accentColor: accentColor),
      ),
    );
  }
}

// ─── Error View ─────────────────────────────────────────────────────────────

class _HomeErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HomeErrorView({required this.message, required this.onRetry});

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
            AppButton.secondary(
              label: 'Retry',
              onTap: onRetry,
              isFullWidth: false,
              width: 160.w,
            ),
          ],
        ),
      ),
    );
  }
}
