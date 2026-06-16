// lib/features/auth/domain/usecases/sign_out_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase implements UseCase<void, NoParams> {
  final AuthRepository _repository;
  const SignOutUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) => _repository.signOut();
}
