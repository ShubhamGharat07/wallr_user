import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/search_result_entity.dart';
import '../repositories/search_repository.dart';

class SearchUseCase implements UseCase<SearchResultEntity, SearchParams> {
  final SearchRepository _repository;

  SearchUseCase({required SearchRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, SearchResultEntity>> call(SearchParams params) {
    return _repository.searchWallpapersAndCategories(params.query);
  }
}

class SearchParams {
  final String query;

  const SearchParams({required this.query});
}
