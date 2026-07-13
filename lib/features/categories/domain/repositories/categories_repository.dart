// lib/features/categories/domain/repositories/categories_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_with_wallpapers_entity.dart';

abstract interface class CategoriesRepository {
  /// Fetches all active categories with their wallpapers count.
  Future<Either<Failure, List<CategoryWithWallpapersEntity>>> getCategories();
}
