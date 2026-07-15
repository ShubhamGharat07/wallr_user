// lib/features/category_detail/presentation/bloc/category_detail_event.dart

import 'package:equatable/equatable.dart';

abstract class CategoryDetailEvent extends Equatable {
  const CategoryDetailEvent();

  @override
  List<Object?> get props => [];
}

class WallpapersByCategoryRequested extends CategoryDetailEvent {
  final String categorySlug;

  const WallpapersByCategoryRequested({required this.categorySlug});

  @override
  List<Object?> get props => [categorySlug];
}
