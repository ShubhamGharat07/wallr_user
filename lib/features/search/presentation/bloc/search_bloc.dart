import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/search_usecase.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUseCase _searchUseCase;
  Timer? _debounceTimer;

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
      _debounceTimer?.cancel();
      emit(const SearchInitial());
      return;
    }

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Emit intermediate state to show user is typing
    emit(SearchQuerying(lastQuery: query));

    // Wait for debounce period
    await Future<void>.delayed(const Duration(milliseconds: _debounceMs));

    // Check if bloc is still active and not closed
    if (isClosed) return;

    // Emit loading state
    emit(SearchLoading(query: query));

    // Perform the search
    final result = await _searchUseCase(SearchParams(query: query));

    // Only emit if bloc is still active
    if (!isClosed) {
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

  Future<void> _onCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) async {
    _debounceTimer?.cancel();
    emit(const SearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}

