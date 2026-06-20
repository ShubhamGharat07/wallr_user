// lib/features/home/data/models/category_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/category_entity.dart';

/// Maps a `categories/{id}` Firestore document → [CategoryEntity].
///
/// All reads are defensive (`??` fallbacks) so a missing/renamed field
/// on one document can never crash the whole Home feed.
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.iconName,
    required super.accentColor,
    required super.coverUrl,
    required super.sortOrder,
    required super.wallpaperCount,
    required super.isActive,
    super.isPremium,
  });

  factory CategoryModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return CategoryModel(
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
