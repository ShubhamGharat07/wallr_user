// lib/features/category_detail/presentation/bloc/category_detail_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_wallpapers_by_category_usecase.dart';
import 'category_detail_event.dart';
import 'category_detail_state.dart';

class CategoryDetailBloc extends Bloc<CategoryDetailEvent, CategoryDetailState> {
  final GetWallpapersByCategoryUseCase _getWallpapers;

  CategoryDetailBloc({required GetWallpapersByCategoryUseCase getWallpapers})
      : _getWallpapers = getWallpapers,
        super(const CategoryDetailInitial()) {
    on<WallpapersByCategoryRequested>(_onWallpapersByCategoryRequested);
  }

  Future<void> _onWallpapersByCategoryRequested(
    WallpapersByCategoryRequested event,
    Emitter<CategoryDetailState> emit,
  ) async {
    emit(const CategoryDetailLoading());

    final result = await _getWallpapers(event.categorySlug);

    result.fold(
      (failure) => emit(CategoryDetailError(message: failure.message)),
      (wallpapers) => emit(CategoryDetailLoaded(wallpapers: wallpapers)),
    );
  }
}
