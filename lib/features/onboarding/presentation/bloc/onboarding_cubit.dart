import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final CompleteOnboardingUseCase _completeOnboarding;

  OnboardingCubit(this._completeOnboarding) : super(const OnboardingState());

  /// Called by PageView.onPageChanged
  void changePage(int page) => emit(state.copyWith(currentPage: page));

  /// "GET STARTED" — saves flag + navigates to auth
  Future<void> complete({bool signUp = false}) async {
    // If already completed, do nothing
    if (state.isComplete) return;

    // Emit navigation state immediately so UI can navigate without waiting
    emit(state.copyWith(isComplete: true, navigateToSignUp: signUp));

    // Persist onboarding completion in background. Do not await to avoid UI jank.
    Future(() async {
      await _completeOnboarding(const NoParams());
    }).catchError((_) {
      // ignore failures for now; app should still navigate
    });
  }

  /// "SKIP" or "SIGN IN" — same flow, skip saving (still marks done)
  Future<void> skip() => complete(signUp: false);
}
