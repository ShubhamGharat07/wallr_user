import 'package:equatable/equatable.dart';

sealed class DownloadsEvent extends Equatable {
  const DownloadsEvent();

  @override
  List<Object?> get props => [];
}

class DownloadsRequested extends DownloadsEvent {
  const DownloadsRequested();
}
