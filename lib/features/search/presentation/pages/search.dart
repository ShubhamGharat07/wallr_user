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
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/wallpaper_card.dart';
import '../../../home/domain/entities/wallpaper_entity.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchBloc>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (value.isEmpty) {
      context.read<SearchBloc>().add(const SearchCleared());
    } else {
      context.read<SearchBloc>().add(SearchQueryChanged(query: value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            // ── Search Input ──────────────────────────────────────────
            RepaintBoundary(
              child: Container(
                color: AppColors.background,
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.md,
                  AppDimensions.md,
                  AppDimensions.md,
                  AppDimensions.md,
                ),
                child: _SearchInput(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                ),
              ),
            ),

            // ── Results ───────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                buildWhen: (previous, current) {
                  // Skip SearchQuerying state to prevent unnecessary rebuilds
                  return current is! SearchQuerying;
                },
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return const _EmptyStateView();
                  } else if (state is SearchLoading) {
                    return const _LoadingStateView();
                  } else if (state is SearchLoaded) {
                    return _ResultsView(state: state);
                  } else if (state is SearchError) {
                    return _ErrorStateView(state: state);
                  }
                  return const _EmptyStateView();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64.w,
              color: AppColors.navInactive,
            ),
            SizedBox(height: AppDimensions.lg),
            Text(
              'Search wallpapers & categories',
              style: AppTextStyles.headlineSm.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: AppDimensions.xs),
            Text('Type to start searching', style: AppTextStyles.bodyMdMuted),
          ],
        ),
      ),
    );
  }
}

// ─── Loading State ───────────────────────────────────────────────────────────

class _LoadingStateView extends StatelessWidget {
  const _LoadingStateView();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomScrollView(
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
              delegate: SliverChildBuilderDelegate(
                (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  child: const AppShimmer(),
                ),
                childCount: 8,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: AppDimensions.xl)),
        ],
      ),
    );
  }
}

// ─── Results View ────────────────────────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  final SearchLoaded state;

  const _ResultsView({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.results.isEmpty) {
      return RepaintBoundary(
        child: Center(
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
                'No results found',
                style: AppTextStyles.headlineSm.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(height: AppDimensions.xs),
              Text('Try different keywords', style: AppTextStyles.bodyMdMuted),
            ],
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: CustomScrollView(
        slivers: [
          // ── Categories ────────────────────────────────────────────
          if (state.results.categories.isNotEmpty)
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.md,
                      ),
                      child: Text(
                        'Categories',
                        style: AppTextStyles.headlineSm,
                      ),
                    ),
                    SizedBox(height: AppDimensions.md),
                    SizedBox(
                      height: 40.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                        ),
                        itemCount: state.results.categories.length,
                        itemBuilder: (context, index) {
                          final category = state.results.categories[index];
                          return Padding(
                            padding: EdgeInsets.only(right: AppDimensions.md),
                            child: _CategoryChip(
                              name: category.name,
                              onTap: () {
                                context.push(RouteNames.categories);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: AppDimensions.lg),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.md,
                      ),
                      child: Text(
                        'Wallpapers',
                        style: AppTextStyles.headlineSm,
                      ),
                    ),
                    SizedBox(height: AppDimensions.md),
                  ],
                ),
              ),
            ),

          // ── Wallpapers Grid ────────────────────────────────────────
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
                final wallpaper = state.results.wallpapers[index];
                return _SearchWallpaperCard(
                  wallpaper: wallpaper,
                  onTap: () {
                    context.push(
                      RouteNames.wallpaperDetail,
                      extra: WallpaperDetailExtras(wallpaper: wallpaper),
                    );
                  },
                );
              }, childCount: state.results.wallpapers.length),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: AppDimensions.xl)),
        ],
      ),
    );
  }
}

// ─── Error State ─────────────────────────────────────────────────────────────

class _ErrorStateView extends StatelessWidget {
  final SearchError state;

  const _ErrorStateView({required this.state});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64.w, color: AppColors.error),
              SizedBox(height: AppDimensions.lg),
              Text(
                'Search failed',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSm,
              ),
              SizedBox(height: AppDimensions.xs),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMdMuted,
              ),
              SizedBox(height: AppDimensions.lg),
              ElevatedButton(
                onPressed: () {
                  if (state.lastQuery != null && state.lastQuery!.isNotEmpty) {
                    context.read<SearchBloc>().add(
                      SearchQueryChanged(query: state.lastQuery!),
                    );
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Search Input ────────────────────────────────────────────────────────────

class _SearchInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchInput({required this.controller, required this.onChanged});

  @override
  State<_SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<_SearchInput> {
  late ValueNotifier<bool> _hasText;

  @override
  void initState() {
    super.initState();
    _hasText = ValueNotifier(false);
    widget.controller.addListener(_updateHasText);
  }

  void _updateHasText() {
    _hasText.value = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _hasText.dispose();
    widget.controller.removeListener(_updateHasText);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      autofocus:
          false, // Disabled to prevent keyboard jank on initial navigation
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search wallpapers...',
        hintStyle: AppTextStyles.bodyMd.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.md,
        ),
        prefixIcon: const Icon(Icons.search),
        prefixIconColor: AppColors.onSurfaceVariant,
        suffixIcon: ValueListenableBuilder<bool>(
          valueListenable: _hasText,
          builder: (context, hasText, _) {
            return hasText
                ? GestureDetector(
                    onTap: () {
                      widget.controller.clear();
                      widget.onChanged('');
                    },
                    child: const Icon(Icons.close),
                  )
                : const SizedBox.shrink();
          },
        ),
        suffixIconColor: AppColors.onSurfaceVariant,
      ),
      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
    );
  }
}

// ─── Category Chip ──────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _CategoryChip({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Center(
          child: Text(
            name,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Search Wallpaper Card ──────────────────────────────────────────────────

class _SearchWallpaperCard extends StatelessWidget {
  final WallpaperEntity wallpaper;
  final VoidCallback onTap;

  const _SearchWallpaperCard({required this.wallpaper, required this.onTap});

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
