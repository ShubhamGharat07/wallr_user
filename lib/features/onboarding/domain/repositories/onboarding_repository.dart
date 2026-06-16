abstract interface class OnboardingRepository {
  Future<bool> isOnboardingComplete();
  Future<void> markOnboardingComplete();
}
