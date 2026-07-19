import 'package:equatable/equatable.dart';

sealed class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class FavoritesRequested extends FavoritesEvent {
  const FavoritesRequested();
}

class FavoriteRemoved extends FavoritesEvent {
  final String wallpaperId;

  const FavoriteRemoved({required this.wallpaperId});

  @override
  List<Object?> get props => [wallpaperId];
}
