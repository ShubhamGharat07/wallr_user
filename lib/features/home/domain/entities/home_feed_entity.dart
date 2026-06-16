// lib/features/home/domain/entities/home_feed_entity.dart

import 'package:equatable/equatable.dart';

import 'category_entity.dart';
import 'wallpaper_entity.dart';

/// One "Category" section on the Home screen — a category row +
/// its wallpapers (empty list ⇒ UI shows "Coming soon").
class CategorySectionEntity extends Equatable {
  final CategoryEntity category;
  final List<WallpaperEntity> wallpapers;

  const CategorySectionEntity({
    required this.category,
    required this.wallpapers,
  });

  bool get isEmpty => wallpapers.isEmpty;

  @override
  List<Object?> get props => [category, wallpapers];
}

/// The full aggregated payload for the Home screen — fetched in a single
/// (parallelised) round of Firestore queries.
class HomeFeedEntity extends Equatable {
  final List<WallpaperEntity> editorsChoice;
  final List<WallpaperEntity> trending;
  final List<CategorySectionEntity> categorySections;

  const HomeFeedEntity({
    required this.editorsChoice,
    required this.trending,
    required this.categorySections,
  });

  @override
  List<Object?> get props => [editorsChoice, trending, categorySections];
}
