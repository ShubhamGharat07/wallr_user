// lib/features/home/presentation/bloc/home_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/home_feed_entity.dart';

sealed class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

/// Before the very first fetch.
final class HomeInitial extends HomeState {
  const HomeInitial();
}

/// First fetch in progress — UI shows shimmer placeholders.
final class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Feed fetched successfully.
final class HomeLoaded extends HomeState {
  final HomeFeedEntity feed;

  /// True while a pull-to-refresh re-fetch is in flight — keeps the old
  /// feed on screen with a small refresh indicator instead of shimmer.
  final bool isRefreshing;

  const HomeLoaded(this.feed, {this.isRefreshing = false});

  HomeLoaded copyWith({HomeFeedEntity? feed, bool? isRefreshing}) =>
      HomeLoaded(feed ?? this.feed, isRefreshing: isRefreshing ?? this.isRefreshing);

  @override
  List<Object?> get props => [feed, isRefreshing];
}

/// First fetch failed — UI shows a retry button.
final class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
