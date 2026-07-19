import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/favorite_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoriteRepository _favoriteRepository;

  FavoritesBloc({required FavoriteRepository favoriteRepository})
      : _favoriteRepository = favoriteRepository,
        super(const FavoritesInitial()) {
    on<FavoritesRequested>(_onFavoritesRequested);
    on<FavoriteRemoved>(_onFavoriteRemoved);
  }

  Future<void> _onFavoritesRequested(
    FavoritesRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());

    final result = await _favoriteRepository.getFavoriteWallpapers();

    result.fold(
      (failure) {
        emit(FavoritesError(message: failure.message));
      },
      (wallpapers) {
        emit(FavoritesLoaded(wallpapers: wallpapers));
      },
    );
  }

  Future<void> _onFavoriteRemoved(
    FavoriteRemoved event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      final result = await _favoriteRepository.removeFavorite(event.wallpaperId);
      result.fold(
        (failure) {
          emit(FavoritesError(message: failure.message));
        },
        (_) {
          final updatedWallpapers = currentState.wallpapers
              .where((w) => w.id != event.wallpaperId)
              .toList();
          emit(FavoritesLoaded(wallpapers: updatedWallpapers));
        },
      );
    }
  }
}
