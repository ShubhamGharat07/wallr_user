// lib/features/categories/presentation/bloc/categories_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_categories_usecase.dart';
import 'categories_event.dart';
import 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final GetCategoriesUseCase _getCategories;

  CategoriesBloc({required GetCategoriesUseCase getCategories})
      : _getCategories = getCategories,
        super(const CategoriesInitial()) {
    on<CategoriesRequested>(_onCategoriesRequested);
  }

  Future<void> _onCategoriesRequested(
    CategoriesRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesLoading());

    final result = await _getCategories();

    result.fold(
      (failure) => emit(
        CategoriesError(message: failure.message),
      ),
      (categories) => emit(
        CategoriesLoaded(categories: categories),
      ),
    );
  }
}
