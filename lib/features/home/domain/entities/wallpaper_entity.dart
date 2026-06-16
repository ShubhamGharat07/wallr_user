// lib/features/home/domain/entities/wallpaper_entity.dart

import 'package:equatable/equatable.dart';

/// WALLR — Wallpaper Entity
///
/// Mirrors a document in the `wallpapers` Firestore collection.
class WallpaperEntity extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final String thumbnailUrl;
  final String categorySlug;
  final String resolution; // "HD", "4K", "8K" etc.
  final int width;
  final int height;
  final int viewCount;
  final int downloadCount;
  final bool isPremium;
  final bool isEditorChoice;
  final bool isTrendingPinned;
  final List<String> tags;

  // ── Optional author metadata (may be absent on older docs) ──
  final String authorName;
  final String authorHandle;
  final String authorAvatarUrl;

  const WallpaperEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.categorySlug,
    required this.resolution,
    required this.width,
    required this.height,
    required this.viewCount,
    required this.isPremium,
    required this.isEditorChoice,
    required this.isTrendingPinned,
    this.downloadCount = 0,
    this.tags = const [],
    this.authorName = '',
    this.authorHandle = '',
    this.authorAvatarUrl = '',
  });

  /// Best image to render on a card — falls back to full image
  /// if a thumbnail hasn't been generated yet.
  String get cardImageUrl => thumbnailUrl.isNotEmpty ? thumbnailUrl : imageUrl;

  /// True when this wallpaper carries any displayable author info.
  bool get hasAuthor => authorName.isNotEmpty || authorHandle.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        title,
        imageUrl,
        thumbnailUrl,
        categorySlug,
        resolution,
        width,
        height,
        viewCount,
        downloadCount,
        isPremium,
        isEditorChoice,
        isTrendingPinned,
        tags,
        authorName,
        authorHandle,
        authorAvatarUrl,
      ];
}
