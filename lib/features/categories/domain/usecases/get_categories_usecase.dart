// lib/features/categories/domain/usecases/get_categories_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_with_wallpapers_entity.dart';
import '../repositories/categories_repository.dart';

class GetCategoriesUseCase {
  final CategoriesRepository _repository;

  const GetCategoriesUseCase(this._repository);

  Future<Either<Failure, List<CategoryWithWallpapersEntity>>> call() =>
      _repository.getCategories();
}
