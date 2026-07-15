// lib/features/category_detail/data/repositories/category_detail_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../home/domain/entities/wallpaper_entity.dart';
import '../../domain/repositories/category_detail_repository.dart';
import '../datasources/category_detail_remote_datasource.dart';

class CategoryDetailRepositoryImpl implements CategoryDetailRepository {
  final CategoryDetailRemoteDataSource remote;
  final NetworkInfo networkInfo;

  CategoryDetailRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<WallpaperEntity>>> getWallpapersByCategory(
    String categorySlug,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final wallpapers = await remote.getWallpapersByCategory(categorySlug);
      return Right(wallpapers);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
