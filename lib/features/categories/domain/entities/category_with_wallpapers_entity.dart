// lib/features/categories/domain/entities/category_with_wallpapers_entity.dart

import 'package:equatable/equatable.dart';

/// Category with wallpaper count and metadata for the Categories page.
class CategoryWithWallpapersEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String iconName;
  final String accentColor;
  final String coverUrl;
  final int sortOrder;
  final int wallpaperCount;
  final bool isActive;
  final bool isPremium;

  const CategoryWithWallpapersEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.iconName,
    required this.accentColor,
    required this.coverUrl,
    required this.sortOrder,
    required this.wallpaperCount,
    required this.isActive,
    required this.isPremium,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        iconName,
        accentColor,
        coverUrl,
        sortOrder,
        wallpaperCount,
        isActive,
        isPremium,
      ];
}
