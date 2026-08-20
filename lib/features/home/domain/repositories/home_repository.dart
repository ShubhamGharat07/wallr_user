// lib/features/home/domain/repositories/home_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/home_feed_entity.dart';
import '../entities/wallpaper_entity.dart';

abstract interface class HomeRepository {
  /// Fetches everything the Home screen needs:
  /// active categories, Editor's Choice, Trending and the
  /// per-category wallpaper rows — in parallel.
  Future<Either<Failure, HomeFeedEntity>> getHomeFeed();

  /// Fetches a single wallpaper — used by deep links.
  Future<Either<Failure, WallpaperEntity>> getWallpaperById(String wallpaperId);
}
