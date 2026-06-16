// lib/features/home/domain/usecases/get_home_feed_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/home_feed_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeFeedUseCase implements UseCase<HomeFeedEntity, NoParams> {
  final HomeRepository _repository;
  const GetHomeFeedUseCase(this._repository);

  @override
  Future<Either<Failure, HomeFeedEntity>> call(NoParams params) =>
      _repository.getHomeFeed();
}
