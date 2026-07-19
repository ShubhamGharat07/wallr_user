import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/wallpaper_entity.dart';

sealed class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<WallpaperEntity> wallpapers;

  const FavoritesLoaded({required this.wallpapers});

  @override
  List<Object?> get props => [wallpapers];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError({required this.message});

  @override
  List<Object?> get props => [message];
}
