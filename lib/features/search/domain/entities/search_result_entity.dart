import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/category_entity.dart';
import '../../../home/domain/entities/wallpaper_entity.dart';

class SearchResultEntity extends Equatable {
  final List<WallpaperEntity> wallpapers;
  final List<CategoryEntity> categories;

  const SearchResultEntity({
    required this.wallpapers,
    required this.categories,
  });

  bool get isEmpty => wallpapers.isEmpty && categories.isEmpty;

  @override
  List<Object?> get props => [wallpapers, categories];
}
