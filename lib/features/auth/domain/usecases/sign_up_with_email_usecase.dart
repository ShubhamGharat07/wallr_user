// lib/features/auth/domain/usecases/sign_up_with_email_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailParams {
  final String name;
  final String email;
  final String password;
  const SignUpWithEmailParams({
    required this.name,
    required this.email,
    required this.password,
  });
}

class SignUpWithEmailUseCase
    implements UseCase<UserEntity, SignUpWithEmailParams> {
  final AuthRepository _repository;
  const SignUpWithEmailUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpWithEmailParams params) =>
      _repository.signUpWithEmail(params.name, params.email, params.password);
}
