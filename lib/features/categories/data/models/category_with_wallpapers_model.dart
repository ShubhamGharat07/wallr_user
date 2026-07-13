// lib/features/categories/data/models/category_with_wallpapers_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/category_with_wallpapers_entity.dart';

/// Maps a `categories/{id}` Firestore document → [CategoryWithWallpapersEntity].
class CategoryWithWallpapersModel extends CategoryWithWallpapersEntity {
  const CategoryWithWallpapersModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.iconName,
    required super.accentColor,
    required super.coverUrl,
    required super.sortOrder,
    required super.wallpaperCount,
    required super.isActive,
    required super.isPremium,
  });

  factory CategoryWithWallpapersModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return CategoryWithWallpapersModel(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      slug: (data['slug'] as String?) ?? '',
      iconName: (data['iconName'] as String?) ?? 'category',
      accentColor: (data['accentColor'] as String?) ?? '#F5C518',
      coverUrl: (data['coverUrl'] as String?) ?? '',
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      wallpaperCount: (data['wallpaperCount'] as num?)?.toInt() ?? 0,
      isActive: (data['isActive'] as bool?) ?? true,
      isPremium: (data['isPremium'] as bool?) ?? false,
    );
  }
}
