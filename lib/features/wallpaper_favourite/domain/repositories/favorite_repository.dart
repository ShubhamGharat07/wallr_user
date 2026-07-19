import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/wallpaper_entity.dart';
import '../entities/favorite_entity.dart';

abstract class FavoriteRepository {
  Future<Either<Failure, void>> addFavorite(String wallpaperId);
  Future<Either<Failure, void>> removeFavorite(String wallpaperId);
  Future<Either<Failure, bool>> isFavorited(String wallpaperId);
  Future<Either<Failure, List<WallpaperEntity>>> getFavoriteWallpapers();
  Future<Either<Failure, int>> getFavoritesCount();
}
