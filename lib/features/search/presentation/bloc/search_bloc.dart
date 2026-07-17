import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/search_usecase.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUseCase _searchUseCase;
  Timer? _debounce;

  static const int _debounceMs = 300;

  SearchBloc({required SearchUseCase searchUseCase})
      : _searchUseCase = searchUseCase,
        super(const SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchCleared>(_onCleared);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      _debounce?.cancel();
      emit(const SearchInitial());
      return;
    }

    _debounce?.cancel();

    await Future<void>.delayed(
      const Duration(milliseconds: _debounceMs),
    );

    if (!emit.isDone) {
      emit(SearchLoading(query: query));

      final result = await _searchUseCase(SearchParams(query: query));

      if (!emit.isDone) {
        result.fold(
          (failure) => emit(SearchError(
            message: failure.message,
            lastQuery: query,
          )),
          (searchResult) => emit(SearchLoaded(
            results: searchResult,
            query: query,
          )),
        );
      }
    }
  }

  Future<void> _onCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) async {
    _debounce?.cancel();
    emit(const SearchInitial());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
