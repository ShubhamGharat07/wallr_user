// lib/features/home/presentation/bloc/home_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_home_feed_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeFeedUseCase _getHomeFeed;

  HomeBloc({required GetHomeFeedUseCase getHomeFeed})
    : _getHomeFeed = getHomeFeed,
      super(const HomeInitial()) {
    on<HomeFeedRequested>(_onHomeFeedRequested);
    on<HomeFeedRefreshed>(_onHomeFeedRefreshed);
  }

  Future<void> _onHomeFeedRequested(
    HomeFeedRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    final result = await _getHomeFeed(const NoParams());
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (feed) => emit(HomeLoaded(feed)),
    );
  }

  Future<void> _onHomeFeedRefreshed(
    HomeFeedRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is HomeLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(const HomeLoading());
    }

    final result = await _getHomeFeed(const NoParams());
    result.fold((failure) {
      // Refresh failed silently if we already had data on screen.
      if (current is HomeLoaded) {
        emit(current.copyWith(isRefreshing: false));
      } else {
        emit(HomeError(failure.message));
      }
    }, (feed) => emit(HomeLoaded(feed)));
  }
}
