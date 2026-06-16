import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/onboarding_repository.dart';

class CompleteOnboardingUseCase implements UseCase<void, NoParams> {
  final OnboardingRepository _repository;
  const CompleteOnboardingUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await _repository.markOnboardingComplete();
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
