import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';
import '../models/search_result_model.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remote;
  final NetworkInfo _networkInfo;

  const SearchRepositoryImpl({
    required SearchRemoteDataSource remote,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, SearchResultEntity>> searchWallpapersAndCategories(
    String query,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final wallpapers = await _remote.searchWallpapers(query);
      final categories = await _remote.searchCategories(query);

      return Right(
        SearchResultModel.fromWallpapersAndCategories(
          wallpapers,
          categories,
        ),
      );
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}
