// lib/features/category_detail/data/datasources/category_detail_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../home/data/models/wallpaper_model.dart';
import '../../../home/domain/entities/wallpaper_entity.dart';

abstract class CategoryDetailRemoteDataSource {
  Future<List<WallpaperEntity>> getWallpapersByCategory(String categorySlug);
}

class CategoryDetailRemoteDataSourceImpl implements CategoryDetailRemoteDataSource {
  final FirebaseFirestore firestore;

  CategoryDetailRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<WallpaperEntity>> getWallpapersByCategory(String categorySlug) async {
    final snapshot = await firestore
        .collection('wallpapers')
        .where('category', isEqualTo: categorySlug)
        .where('isActive', isEqualTo: true)
        .get(
          GetOptions(source: Source.serverAndCache),
        );

    final wallpapers = snapshot.docs
        .map((doc) => WallpaperModel.fromSnapshot(doc))
        .toList();

    wallpapers.sort((a, b) {
      final aTime = a.id.hashCode;
      final bTime = b.id.hashCode;
      return bTime.compareTo(aTime);
    });

    return wallpapers;
  }
}
