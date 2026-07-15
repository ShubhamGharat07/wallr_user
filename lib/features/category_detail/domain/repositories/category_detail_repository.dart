// lib/features/category_detail/domain/repositories/category_detail_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/wallpaper_entity.dart';

abstract class CategoryDetailRepository {
  Future<Either<Failure, List<WallpaperEntity>>> getWallpapersByCategory(
    String categorySlug,
  );
}
