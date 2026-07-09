import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wallr/core/error/failures.dart';
import 'package:wallr/features/auth/domain/entities/user_entity.dart';
import 'package:wallr/features/auth/domain/repositories/auth_repository.dart';
import 'package:wallr/features/auth/domain/usecases/sign_in_with_email_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInWithEmailUseCase signInWithEmailUseCase;
  late MockAuthRepository mockAuthRepository;

  final tUser = const UserEntity(
    uid: '123',
    email: 'test@example.com',
    name: 'Test User',
    photoUrl: '',
    isPremium: false,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signInWithEmailUseCase = SignInWithEmailUseCase(mockAuthRepository);
  });

  group('SignInWithEmailUseCase', () {
    const email = 'test@example.com';
    const password = 'password123';
    const params = SignInWithEmailParams(email: email, password: password);

    test(
      'should return UserEntity when sign in is successful',
      () async {
        // Arrange
        when(() => mockAuthRepository.signInWithEmail(email, password))
            .thenAnswer((_) async => Right(tUser));

        // Act
        final result = await signInWithEmailUseCase(params);

        // Assert
        expect(result, Right(tUser));
        verify(() => mockAuthRepository.signInWithEmail(email, password))
            .called(1);
      },
    );

    test(
      'should return AuthFailure when credentials are invalid',
      () async {
        // Arrange
        const failure = AuthFailure('Invalid email or password');
        when(() => mockAuthRepository.signInWithEmail(email, password))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await signInWithEmailUseCase(params);

        // Assert
        expect(result, const Left(failure));
        verify(() => mockAuthRepository.signInWithEmail(email, password))
            .called(1);
      },
    );

    test(
      'should return NetworkFailure when network error occurs',
      () async {
        // Arrange
        const failure = NetworkFailure('No internet connection');
        when(() => mockAuthRepository.signInWithEmail(email, password))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await signInWithEmailUseCase(params);

        // Assert
        expect(result, const Left(failure));
      },
    );

    test(
      'should return ValidationFailure for empty email',
      () async {
        // Arrange
        const failure = ValidationFailure('Email cannot be empty');
        when(() => mockAuthRepository.signInWithEmail('', password))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await signInWithEmailUseCase(
          const SignInWithEmailParams(email: '', password: password),
        );

        // Assert
        expect(result, const Left(failure));
      },
    );

    test(
      'should return ValidationFailure for empty password',
      () async {
        // Arrange
        const failure = ValidationFailure('Password cannot be empty');
        when(() => mockAuthRepository.signInWithEmail(email, ''))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await signInWithEmailUseCase(
          const SignInWithEmailParams(email: email, password: ''),
        );

        // Assert
        expect(result, const Left(failure));
      },
    );

    test(
      'should return correct UserEntity with all fields populated',
      () async {
        // Arrange
        when(() => mockAuthRepository.signInWithEmail(email, password))
            .thenAnswer((_) async => Right(tUser));

        // Act
        final result = await signInWithEmailUseCase(params);

        // Assert
        result.fold(
          (failure) => fail('Should return Right'),
          (user) {
            expect(user.uid, '123');
            expect(user.email, 'test@example.com');
            expect(user.name, 'Test User');
            expect(user.isPremium, false);
          },
        );
      },
    );

    test(
      'should pass correct parameters to repository',
      () async {
        // Arrange
        when(() => mockAuthRepository.signInWithEmail(email, password))
            .thenAnswer((_) async => Right(tUser));

        // Act
        await signInWithEmailUseCase(params);

        // Assert
        verify(() => mockAuthRepository.signInWithEmail(email, password))
            .called(1);
      },
    );

    test(
      'should return ServerFailure when server error occurs',
      () async {
        // Arrange
        const failure = ServerFailure('Internal server error');
        when(() => mockAuthRepository.signInWithEmail(email, password))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await signInWithEmailUseCase(params);

        // Assert
        expect(result, const Left(failure));
      },
    );
  });
}
