import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/wallpaper_entity.dart';
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
      (wallpapers) {
        // Convert downloaded wallpapers to WallpaperEntity
        // For now, we'll just pass them through
        // In a real scenario, we might need to map them
        emit(DownloadsLoaded(wallpapers: wallpapers.cast<WallpaperEntity>()));
      },
    );
  }
}
