import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/wallpaper_entity.dart';
import '../../../home/data/models/wallpaper_model.dart';
import '../../domain/repositories/favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FavoriteRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  String get _userId => _auth.currentUser?.uid ?? '';

  @override
  Future<Either<Failure, void>> addFavorite(String wallpaperId) async {
    try {
      if (_userId.isEmpty) {
        return Left(UnauthenticatedFailure('User not authenticated'));
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favourites')
          .doc(wallpaperId)
          .set({
        'wallpaperId': wallpaperId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to add favorite'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String wallpaperId) async {
    try {
      if (_userId.isEmpty) {
        return Left(UnauthenticatedFailure('User not authenticated'));
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favourites')
          .doc(wallpaperId)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to remove favorite'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorited(String wallpaperId) async {
    try {
      if (_userId.isEmpty) return const Right(false);

      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favourites')
          .doc(wallpaperId)
          .get();

      return Right(doc.exists);
    } catch (e) {
      return Left(ServerFailure('Failed to check favorite'));
    }
  }

  @override
  Future<Either<Failure, List<WallpaperEntity>>> getFavoriteWallpapers() async {
    try {
      if (_userId.isEmpty) {
        return const Right([]);
      }

      final favoriteDocs = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favourites')
          .get();

      final wallpaperIds =
          favoriteDocs.docs.map((doc) => doc['wallpaperId'] as String).toList();

      if (wallpaperIds.isEmpty) {
        return const Right([]);
      }

      final wallpapers = <WallpaperEntity>[];
      for (final id in wallpaperIds) {
        final wallpaperDoc = await _firestore.collection('wallpapers').doc(id).get();
        if (wallpaperDoc.exists) {
          final model = WallpaperModel.fromSnapshot(wallpaperDoc);
          wallpapers.add(model);
        }
      }

      return Right(wallpapers);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch favorites'));
    }
  }

  @override
  Future<Either<Failure, int>> getFavoritesCount() async {
    try {
      if (_userId.isEmpty) return const Right(0);

      final query = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favourites')
          .get();

      return Right(query.docs.length);
    } catch (e) {
      return Left(ServerFailure('Failed to get favorites count'));
    }
  }
}
