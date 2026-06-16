import 'package:equatable/equatable.dart';

class OnboardingState extends Equatable {
  final int currentPage;
  final bool isComplete;
  final bool navigateToSignUp;

  const OnboardingState({
    this.currentPage = 0,
    this.isComplete = false,
    this.navigateToSignUp = false,
  });

  OnboardingState copyWith({
    int? currentPage,
    bool? isComplete,
    bool? navigateToSignUp,
  }) => OnboardingState(
    currentPage: currentPage ?? this.currentPage,
    isComplete: isComplete ?? this.isComplete,
    navigateToSignUp: navigateToSignUp ?? this.navigateToSignUp,
  );

  @override
  List<Object> get props => [currentPage, isComplete, navigateToSignUp];
}
