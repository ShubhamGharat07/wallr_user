// lib/features/categories/data/datasources/categories_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../models/category_with_wallpapers_model.dart';

abstract interface class CategoriesRemoteDataSource {
  /// Fetches all active categories ordered by sortOrder.
  Future<List<CategoryWithWallpapersModel>> getCategories();
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  final FirebaseFirestore _firestore;

  const CategoriesRemoteDataSourceImpl(this._firestore);

  static const _getOptions = GetOptions(source: Source.serverAndCache);

  CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _firestore.collection('categories');

  @override
  Future<List<CategoryWithWallpapersModel>> getCategories() async {
    try {
      final snap = await _categoriesRef
          .where('isActive', isEqualTo: true)
          .get(_getOptions);

      final categories =
          snap.docs.map(CategoryWithWallpapersModel.fromSnapshot).toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return categories;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load categories.',
      );
    }
  }
}
