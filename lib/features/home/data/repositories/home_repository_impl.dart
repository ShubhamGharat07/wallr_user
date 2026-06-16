// lib/features/home/data/repositories/home_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/home_feed_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/category_model.dart';
import '../models/wallpaper_model.dart';

/// WALLR — Home Repository Implementation
///
/// Latency strategy:
///  1. Fire categories + Editor's Choice + Trending TOGETHER
///     (`Future.wait`) — 3 queries run concurrently, not sequentially.
///  2. Once categories are known, fire ALL per-category wallpaper
///     queries TOGETHER as well — N categories = N parallel queries,
///     not N sequential round-trips.
///
/// Total wall-clock time ≈ time of the single slowest query, not the
/// sum of every query.
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remote;
  final NetworkInfo _networkInfo;

  const HomeRepositoryImpl({
    required HomeRemoteDataSource remote,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _networkInfo = networkInfo;

  /// How many categories show up as sections on Home.
  static const int _categoryLimit = 8;

  /// How many wallpapers to preview per category row.
  static const int _wallpapersPerCategory = 10;

  static const int _editorsChoiceLimit = 6;
  static const int _trendingLimit = 6;

  @override
  Future<Either<Failure, HomeFeedEntity>> getHomeFeed() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      // ── Round 1: categories + Editor's Choice + Trending in parallel ──
      final results = await Future.wait([
        _remote.getActiveCategories(limit: _categoryLimit),
        _remote.getEditorsChoice(limit: _editorsChoiceLimit),
        _remote.getTrending(limit: _trendingLimit),
      ]);

      final categories = results[0] as List<CategoryModel>;
      final editorsChoice = results[1] as List<WallpaperModel>;
      final trending = results[2] as List<WallpaperModel>;

      // ── Round 2: every category's wallpapers — also in parallel ──
      final perCategoryWallpapers = await Future.wait(
        categories.map(
          (category) => _remote.getWallpapersByCategory(
            category.slug,
            limit: _wallpapersPerCategory,
          ),
        ),
      );

      final sections = <CategorySectionEntity>[
        for (var i = 0; i < categories.length; i++)
          CategorySectionEntity(
            category: categories[i],
            wallpapers: perCategoryWallpapers[i],
          ),
      ];

      return Right(
        HomeFeedEntity(
          editorsChoice: editorsChoice,
          trending: trending,
          categorySections: sections,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
