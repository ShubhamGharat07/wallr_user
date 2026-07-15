// lib/features/category_detail/domain/usecases/get_wallpapers_by_category_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/wallpaper_entity.dart';
import '../repositories/category_detail_repository.dart';

class GetWallpapersByCategoryUseCase {
  final CategoryDetailRepository repository;

  GetWallpapersByCategoryUseCase(this.repository);

  Future<Either<Failure, List<WallpaperEntity>>> call(String categorySlug) {
    return repository.getWallpapersByCategory(categorySlug);
  }
}
