import 'package:equatable/equatable.dart';

sealed class DownloadsEvent extends Equatable {
  const DownloadsEvent();

  @override
  List<Object?> get props => [];
}

class DownloadsRequested extends DownloadsEvent {
  const DownloadsRequested();
}

class DownloadDeleted extends DownloadsEvent {
  final String wallpaperId;

  const DownloadDeleted({required this.wallpaperId});

  @override
  List<Object?> get props => [wallpaperId];
}
