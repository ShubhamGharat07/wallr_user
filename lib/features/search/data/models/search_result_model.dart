import '../../domain/entities/search_result_entity.dart';
import '../../../home/data/models/category_model.dart';
import '../../../home/data/models/wallpaper_model.dart';

class SearchResultModel extends SearchResultEntity {
  const SearchResultModel({
    required super.wallpapers,
    required super.categories,
  });

  factory SearchResultModel.fromWallpapersAndCategories(
    List<WallpaperModel> wallpapers,
    List<CategoryModel> categories,
  ) {
    return SearchResultModel(
      wallpapers: wallpapers,
      categories: categories,
    );
  }
}
