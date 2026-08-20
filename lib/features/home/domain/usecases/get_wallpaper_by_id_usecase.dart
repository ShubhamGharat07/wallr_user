// lib/features/home/domain/usecases/get_wallpaper_by_id_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallpaper_entity.dart';
import '../repositories/home_repository.dart';

class GetWallpaperByIdUseCase implements UseCase<WallpaperEntity, String> {
  final HomeRepository _repository;
  const GetWallpaperByIdUseCase(this._repository);

  @override
  Future<Either<Failure, WallpaperEntity>> call(String wallpaperId) =>
      _repository.getWallpaperById(wallpaperId);
}