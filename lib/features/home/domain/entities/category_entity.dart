// lib/features/home/domain/entities/category_entity.dart

import 'package:equatable/equatable.dart';

/// WALLR — Category Entity
///
/// Mirrors a document in the `categories` Firestore collection.
/// Field names match the admin panel exactly (see WALLR admin — categories
/// feature) so models can map straight from `DocumentSnapshot.data()`.
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String iconName;
  final String accentColor; // hex string e.g. "#F5C518"
  final String coverUrl;
  final int sortOrder;
  final int wallpaperCount;
  final bool isActive;
  final bool isPremium;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.iconName,
    required this.accentColor,
    required this.coverUrl,
    required this.sortOrder,
    required this.wallpaperCount,
    required this.isActive,
    this.isPremium = false,
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
