import 'package:equatable/equatable.dart';

import '../../domain/entities/search_result_entity.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchQuerying extends SearchState {
  final String lastQuery;

  const SearchQuerying({this.lastQuery = ''});

  @override
  List<Object?> get props => [lastQuery];
}

class SearchLoading extends SearchState {
  final String query;

  const SearchLoading({required this.query});

  @override
  List<Object?> get props => [query];
}

class SearchLoaded extends SearchState {
  final SearchResultEntity results;
  final String query;

  const SearchLoaded({
    required this.results,
    required this.query,
  });

  @override
  List<Object?> get props => [results, query];
}

class SearchError extends SearchState {
  final String message;
  final String? lastQuery;

  const SearchError({
    required this.message,
    this.lastQuery,
  });

  @override
  List<Object?> get props => [message, lastQuery];
}
