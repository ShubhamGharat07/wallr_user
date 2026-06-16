// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmail(
    String email,
    String password,
  );
  Future<Either<Failure, UserEntity>> signUpWithEmail(
    String name,
    String email,
    String password,
  );
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> forgotPassword(String email);
  Either<Failure, UserEntity?> getCurrentUser();
}
