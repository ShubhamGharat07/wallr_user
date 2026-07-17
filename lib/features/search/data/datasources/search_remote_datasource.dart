import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../home/data/models/category_model.dart';
import '../../../home/data/models/wallpaper_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<WallpaperModel>> searchWallpapers(String query);
  Future<List<CategoryModel>> searchCategories(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final FirebaseFirestore firestore;
  static const int _fetchLimit = 100;
  static const int _displayLimit = 20;

  SearchRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<WallpaperModel>> searchWallpapers(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final searchQuery = query.toLowerCase().trim();

      final snapshot = await firestore
          .collection('wallpapers')
          .where('isActive', isEqualTo: true)
          .limit(_fetchLimit)
          .get(GetOptions(source: Source.serverAndCache));

      if (snapshot.docs.isEmpty) return [];

      final results = <WallpaperModel>[];

      for (final doc in snapshot.docs) {
        final wallpaper = WallpaperModel.fromSnapshot(doc);
        if (wallpaper.title.toLowerCase().contains(searchQuery)) {
          results.add(wallpaper);
        }
        if (results.length >= _displayLimit) break;
      }

      results.sort((a, b) {
        final aIdx = a.title.toLowerCase().indexOf(searchQuery);
        final bIdx = b.title.toLowerCase().indexOf(searchQuery);
        return aIdx.compareTo(bIdx);
      });

      return results;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<CategoryModel>> searchCategories(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final searchQuery = query.toLowerCase().trim();

      final snapshot = await firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .limit(_fetchLimit)
          .get(GetOptions(source: Source.serverAndCache));

      if (snapshot.docs.isEmpty) return [];

      final results = <CategoryModel>[];

      for (final doc in snapshot.docs) {
        final category = CategoryModel.fromSnapshot(doc);
        if (category.name.toLowerCase().contains(searchQuery)) {
          results.add(category);
        }
        if (results.length >= 5) break;
      }

      results.sort((a, b) {
        final aIdx = a.name.toLowerCase().indexOf(searchQuery);
        final bIdx = b.name.toLowerCase().indexOf(searchQuery);
        return aIdx.compareTo(bIdx);
      });

      return results;
    } catch (e) {
      return [];
    }
  }
}
