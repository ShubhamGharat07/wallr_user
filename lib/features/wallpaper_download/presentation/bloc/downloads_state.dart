import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/wallpaper_entity.dart';

sealed class DownloadsState extends Equatable {
  const DownloadsState();

  @override
  List<Object?> get props => [];
}

class DownloadsInitial extends DownloadsState {
  const DownloadsInitial();
}

class DownloadsLoading extends DownloadsState {
  const DownloadsLoading();
}

class DownloadsLoaded extends DownloadsState {
  final List<WallpaperEntity> wallpapers;

  const DownloadsLoaded({required this.wallpapers});

  @override
  List<Object?> get props => [wallpapers];
}

class DownloadsError extends DownloadsState {
  final String message;

  const DownloadsError({required this.message});

  @override
  List<Object?> get props => [message];
}
