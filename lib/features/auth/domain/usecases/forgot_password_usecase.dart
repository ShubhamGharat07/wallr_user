// lib/features/auth/domain/usecases/forgot_password_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase implements UseCase<void, String> {
  final AuthRepository _repository;
  const ForgotPasswordUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String email) =>
      _repository.forgotPassword(email);
}
