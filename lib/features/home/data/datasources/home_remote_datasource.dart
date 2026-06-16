// // lib/features/home/data/datasources/home_remote_datasource.dart

// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../../../../core/error/exceptions.dart';
// import '../models/category_model.dart';
// import '../models/wallpaper_model.dart';

// /// WALLR — Home Remote DataSource
// ///
// /// All queries are kept as **lean as possible** for low-latency:
// ///  • `.limit(...)` on every query — never fetch more than the UI shows.
// ///  • Parallel fan-out (`Future.wait`) from the repository — categories,
// ///    Editor's Choice, Trending and every per-category wallpaper row are
// ///    requested in the SAME network round-trip window.
// ///  • `GetOptions(source: Source.serverAndCache)` — Firestore serves from
// ///    local cache instantly if available while syncing in background.
// ///
// /// ⚠️ Required Firestore composite indexes (Firestore console will also
// /// give you a direct "create index" link the first time each query runs):
// ///   1. categories      → isActive (ASC) + sortOrder (ASC)
// ///   2. wallpapers      → categorySlug (ASC) + isActive (ASC) + createdAt (DESC)
// ///   3. wallpapers      → isActive (ASC) + isTrendingPinned (ASC) + viewCount (DESC)
// ///   (Editor's Choice uses pure equality filters only — no index needed.)
// abstract interface class HomeRemoteDataSource {
//   /// Active categories ordered by their admin-defined `sortOrder`.
//   Future<List<CategoryModel>> getActiveCategories({int limit});

//   /// Latest active wallpapers belonging to a single category.
//   Future<List<WallpaperModel>> getWallpapersByCategory(
//     String categorySlug, {
//     int limit,
//   });

//   /// Manually curated "Editor's Choice" wallpapers.
//   Future<List<WallpaperModel>> getEditorsChoice({int limit});

//   /// Trending wallpapers — pinned first, then highest view count.
//   Future<List<WallpaperModel>> getTrending({int limit});
// }

// class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
//   final FirebaseFirestore _firestore;

//   const HomeRemoteDataSourceImpl(this._firestore);

//   static const _getOptions = GetOptions(source: Source.serverAndCache);

//   CollectionReference<Map<String, dynamic>> get _categoriesRef =>
//       _firestore.collection('categories');

//   CollectionReference<Map<String, dynamic>> get _wallpapersRef =>
//       _firestore.collection('wallpapers');

//   @override
//   Future<List<CategoryModel>> getActiveCategories({int limit = 8}) async {
//     try {
//       final snap = await _categoriesRef
//           .where('isActive', isEqualTo: true)
//           .orderBy('sortOrder')
//           .limit(limit)
//           .get(_getOptions);

//       return snap.docs.map(CategoryModel.fromSnapshot).toList();
//     } on FirebaseException catch (e) {
//       throw ServerException(
//         message: e.message ?? 'Failed to load categories.',
//       );
//     }
//   }

//   @override
//   Future<List<WallpaperModel>> getWallpapersByCategory(
//     String categorySlug, {
//     int limit = 10,
//   }) async {
//     if (categorySlug.isEmpty) return const [];
//     try {
//       final snap = await _wallpapersRef
//           .where('categorySlug', isEqualTo: categorySlug)
//           .where('isActive', isEqualTo: true)
//           .orderBy('createdAt', descending: true)
//           .limit(limit)
//           .get(_getOptions);

//       return snap.docs.map(WallpaperModel.fromSnapshot).toList();
//     } on FirebaseException catch (e) {
//       throw ServerException(
//         message: e.message ?? 'Failed to load wallpapers for $categorySlug.',
//       );
//     }
//   }

//   @override
//   Future<List<WallpaperModel>> getEditorsChoice({int limit = 6}) async {
//     try {
//       // Pure equality filters — Firestore needs no composite index for this.
//       final snap = await _wallpapersRef
//           .where('isActive', isEqualTo: true)
//           .where('isEditorChoice', isEqualTo: true)
//           .limit(limit)
//           .get(_getOptions);

//       return snap.docs.map(WallpaperModel.fromSnapshot).toList();
//     } on FirebaseException catch (e) {
//       throw ServerException(
//         message: e.message ?? 'Failed to load Editor\'s Choice.',
//       );
//     }
//   }

//   @override
//   Future<List<WallpaperModel>> getTrending({int limit = 6}) async {
//     try {
//       final snap = await _wallpapersRef
//           .where('isActive', isEqualTo: true)
//           .orderBy('viewCount', descending: true)
//           .limit(limit)
//           .get(_getOptions);

//       return snap.docs.map(WallpaperModel.fromSnapshot).toList();
//     } on FirebaseException catch (e) {
//       throw ServerException(
//         message: e.message ?? 'Failed to load trending wallpapers.',
//       );
//     }
//   }
// }

// lib/features/home/data/datasources/home_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../models/category_model.dart';
import '../models/wallpaper_model.dart';

/// WALLR — Home Remote DataSource
///
/// Latency strategy — and why NO Firestore composite indexes are needed:
///  • Every query below uses ONLY equality (`==`) filters with NO
///    `orderBy` on a different field. Firestore serves equality-only
///    queries (zigzag merge join) using its automatic single-field
///    indexes — zero manual index setup, zero "requires an index" error.
///  • Sorting (by `sortOrder` / `viewCount`) is done client-side, AFTER
///    Firestore returns the (already small, `.limit()`-bounded) result
///    set — negligible cost for <50 documents.
///  • `.limit(...)` on every query — never fetch more than the UI shows.
///  • Parallel fan-out (`Future.wait`) from the repository — categories,
///    Editor's Choice, Trending and every per-category wallpaper row are
///    requested in the SAME network round-trip window.
///  • `GetOptions(source: Source.serverAndCache)` — Firestore serves from
///    local cache instantly if available while syncing in background.
abstract interface class HomeRemoteDataSource {
  /// Active categories ordered by their admin-defined `sortOrder`.
  Future<List<CategoryModel>> getActiveCategories({int limit});

  /// Latest active wallpapers belonging to a single category.
  Future<List<WallpaperModel>> getWallpapersByCategory(
    String categorySlug, {
    int limit,
  });

  /// Manually curated "Editor's Choice" wallpapers.
  Future<List<WallpaperModel>> getEditorsChoice({int limit});

  /// Trending wallpapers — highest view count first.
  Future<List<WallpaperModel>> getTrending({int limit});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore _firestore;

  const HomeRemoteDataSourceImpl(this._firestore);

  static const _getOptions = GetOptions(source: Source.serverAndCache);

  CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _firestore.collection('categories');

  CollectionReference<Map<String, dynamic>> get _wallpapersRef =>
      _firestore.collection('wallpapers');

  @override
  Future<List<CategoryModel>> getActiveCategories({int limit = 8}) async {
    try {
      // Equality-only filter — no composite index required.
      // Categories collection is small, so we fetch all active ones
      // and sort/trim client-side by `sortOrder`.
      final snap = await _categoriesRef
          .where('isActive', isEqualTo: true)
          .get(_getOptions);

      final categories = snap.docs.map(CategoryModel.fromSnapshot).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return categories.take(limit).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to load categories.');
    }
  }

  @override
  Future<List<WallpaperModel>> getWallpapersByCategory(
    String categorySlug, {
    int limit = 10,
  }) async {
    if (categorySlug.isEmpty) return const [];
    try {
      // Two equality filters — Firestore handles this without any
      // composite index (zigzag merge join on auto single-field indexes).
      final snap = await _wallpapersRef
          // Firestore field is `category`, value matches a category's slug.
          .where('category', isEqualTo: categorySlug)
          .where('isActive', isEqualTo: true)
          .limit(limit)
          .get(_getOptions);

      return snap.docs.map(WallpaperModel.fromSnapshot).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load wallpapers for $categorySlug.',
      );
    }
  }

  @override
  Future<List<WallpaperModel>> getEditorsChoice({int limit = 6}) async {
    try {
      // Pure equality filters — no composite index needed.
      final snap = await _wallpapersRef
          .where('isActive', isEqualTo: true)
          .where('isEditorChoice', isEqualTo: true)
          .limit(limit)
          .get(_getOptions);

      return snap.docs.map(WallpaperModel.fromSnapshot).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load Editor\'s Choice.',
      );
    }
  }

  @override
  Future<List<WallpaperModel>> getTrending({int limit = 6}) async {
    try {
      // Single equality filter — no composite index needed.
      // Over-fetch a bit, then sort by viewCount client-side and trim.
      final snap = await _wallpapersRef
          .where('isActive', isEqualTo: true)
          .limit(limit * 3)
          .get(_getOptions);

      final wallpapers = snap.docs.map(WallpaperModel.fromSnapshot).toList()
        ..sort((a, b) => b.viewCount.compareTo(a.viewCount));

      return wallpapers.take(limit).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load trending wallpapers.',
      );
    }
  }
}
