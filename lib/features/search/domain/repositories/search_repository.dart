import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/search_result_entity.dart';

abstract interface class SearchRepository {
  Future<Either<Failure, SearchResultEntity>> searchWallpapersAndCategories(
    String query,
  );
}
