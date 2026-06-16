// lib/features/auth/domain/usecases/sign_in_with_email_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailParams {
  final String email;
  final String password;
  const SignInWithEmailParams({required this.email, required this.password});
}

class SignInWithEmailUseCase
    implements UseCase<UserEntity, SignInWithEmailParams> {
  final AuthRepository _repository;
  const SignInWithEmailUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithEmailParams params) =>
      _repository.signInWithEmail(params.email, params.password);
}
