// lib/features/home/presentation/bloc/home_event.dart

import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

/// First load — shows shimmer while fetching.
final class HomeFeedRequested extends HomeEvent {
  const HomeFeedRequested();
}

/// Pull-to-refresh — re-fetches without resetting to a full-screen loader.
final class HomeFeedRefreshed extends HomeEvent {
  const HomeFeedRefreshed();
}
