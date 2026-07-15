// lib/features/category_detail/presentation/bloc/category_detail_state.dart

import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/wallpaper_entity.dart';

abstract class CategoryDetailState extends Equatable {
  const CategoryDetailState();

  @override
  List<Object?> get props => [];
}

class CategoryDetailInitial extends CategoryDetailState {
  const CategoryDetailInitial();
}

class CategoryDetailLoading extends CategoryDetailState {
  const CategoryDetailLoading();
}

class CategoryDetailLoaded extends CategoryDetailState {
  final List<WallpaperEntity> wallpapers;

  const CategoryDetailLoaded({required this.wallpapers});

  @override
  List<Object?> get props => [wallpapers];
}

class CategoryDetailError extends CategoryDetailState {
  final String message;

  const CategoryDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
