import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/wallpaper_entity.dart';
import '../../data/models/downloaded_wallpaper_model.dart';
import '../../domain/repositories/download_repository.dart';
import 'downloads_event.dart';
import 'downloads_state.dart';

/// BLoC for managing downloaded wallpapers.
class DownloadsBloc extends Bloc<DownloadsEvent, DownloadsState> {
  final DownloadRepository _downloadRepository;

  DownloadsBloc({required DownloadRepository downloadRepository})
      : _downloadRepository = downloadRepository,
        super(const DownloadsInitial()) {
    on<DownloadsRequested>(_onDownloadsRequested);
  }

  Future<void> _onDownloadsRequested(
    DownloadsRequested event,
    Emitter<DownloadsState> emit,
  ) async {
    emit(const DownloadsLoading());

    final result = await _downloadRepository.getDownloadedWallpapers();

    result.fold(
      (failure) {
        emit(DownloadsError(message: failure.message));
      },
      (downloadedWallpapers) {
        // Convert downloaded wallpapers to WallpaperEntity
        final wallpapers = downloadedWallpapers.map((downloaded) {
          if (downloaded is DownloadedWallpaperModel) {
            return downloaded.toWallpaperEntity();
          }
          // Fallback: create basic WallpaperEntity from downloaded entity
          return WallpaperEntity(
            id: downloaded.wallpaperId,
            title: downloaded.title,
            imageUrl: downloaded.cloudinaryUrl,
            thumbnailUrl: downloaded.cloudinaryUrl,
            categorySlug: '',
            resolution: 'HD',
            width: 0,
            height: 0,
            viewCount: 0,
            isPremium: false,
            isEditorChoice: false,
            isTrendingPinned: false,
          );
        }).toList();

        emit(DownloadsLoaded(wallpapers: wallpapers));
      },
    );
  }
}

