// lib/features/home/data/models/wallpaper_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/wallpaper_entity.dart';

/// Maps a `wallpapers/{id}` Firestore document → [WallpaperEntity].
class WallpaperModel extends WallpaperEntity {
  const WallpaperModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    required super.thumbnailUrl,
    required super.categorySlug,
    required super.resolution,
    required super.width,
    required super.height,
    required super.viewCount,
    required super.isPremium,
    required super.isEditorChoice,
    required super.isTrendingPinned,
    super.downloadCount,
    super.tags,
    super.authorName,
    super.authorHandle,
    super.authorAvatarUrl,
  });

  factory WallpaperModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return WallpaperModel(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      imageUrl: (data['imageUrl'] as String?) ?? '',
      thumbnailUrl: (data['thumbnailUrl'] as String?) ?? '',
      // Firestore stores this field as `category` (not `categorySlug`).
      categorySlug: (data['category'] as String?) ?? '',
      resolution: (data['resolution'] as String?) ?? 'HD',
      width: (data['width'] as num?)?.toInt() ?? 0,
      height: (data['height'] as num?)?.toInt() ?? 0,
      viewCount: (data['viewCount'] as num?)?.toInt() ?? 0,
      downloadCount: (data['downloadCount'] as num?)?.toInt() ?? 0,
      isPremium: (data['isPremium'] as bool?) ?? false,
      isEditorChoice: (data['isEditorChoice'] as bool?) ?? false,
      isTrendingPinned: (data['isTrendingPinned'] as bool?) ?? false,
      tags: (data['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      // Author info is optional — older docs simply omit these fields.
      authorName: (data['authorName'] as String?) ?? '',
      authorHandle: (data['authorHandle'] as String?) ?? '',
      authorAvatarUrl: (data['authorAvatarUrl'] as String?) ?? '',
    );
  }
}
