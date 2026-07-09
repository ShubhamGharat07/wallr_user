import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wallr/core/error/failures.dart';
import 'package:wallr/features/auth/domain/entities/user_entity.dart';
import 'package:wallr/features/auth/domain/repositories/auth_repository.dart';
import 'package:wallr/features/auth/domain/usecases/sign_up_with_email_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignUpWithEmailUseCase signUpWithEmailUseCase;
  late MockAuthRepository mockAuthRepository;

  final tUser = const UserEntity(
    uid: '123',
    email: 'newuser@example.com',
    name: 'New User',
    photoUrl: '',
    isPremium: false,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signUpWithEmailUseCase = SignUpWithEmailUseCase(mockAuthRepository);
  });

  group('SignUpWithEmailUseCase', () {
    const name = 'New User';
    const email = 'newuser@example.com';
    const password = 'password123';
    const params = SignUpWithEmailParams(
      name: name,
      email: email,
      password: password,
    );

    test(
      'should return UserEntity when sign up is successful',
      () async {
        // Arrange
        when(() => mockAuthRepository.signUpWithEmail(name, email, password))
            .thenAnswer((_) async => Right(tUser));

        // Act
        final result = await signUpWithEmailUseCase(params);

        // Assert
        expect(result, Right(tUser));
        verify(() =>
                mockAuthRepository.signUpWithEmail(name, email, password))
            .called(1);
      },
    );

    test(
      'should return AuthFailure when email already exists',
      () async {
        // Arrange
        const failure = AuthFailure('Email already registered');
        when(() => mockAuthRepository.signUpWithEmail(name, email, password))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await signUpWithEmailUseCase(params);

        // Assert
        expect(result, const Left(failure));
      },
    );

    test(
      'should return ValidationFailure for invalid email format',
      () async {
        // Arrange
        const invalidEmail = 'invalid-email';
        const failure = ValidationFailure('Invalid email format');
        when(() =>
                mockAuthRepository.signUpWithEmail(name, invalidEmail, password))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await signUpWithEmailUseCase(
          const SignUpWithEmailParams(
            name: name,
            email: invalidEmail,
            password: password,
          ),
        );

        // Assert
        expect(result, const Left(failure));
      },
    );

    test(
      'should return ValidationFailure for weak password',
      () async {
        // Arrange
        const weakPassword = '123';
        const failure = ValidationFailure('Password must be at least 6 characters');
        when(() => mockAuthRepository.signUpWithEmail(name, email, weakPassword))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await signUpWithEmailUseCase(
          const SignUpWithEmailParams(
            name: name,
            email: email,
            password: weakPassword,
          ),
        );

        // Assert
        expect(result, const Left(failure));
      },
    );

    test(
      'should return ValidationFailure for empty name',
      () async {
        // Arrange
        const emptyName = '';
        const failure = ValidationFailure('Name cannot be empty');
        when(() => mockAuthRepository.signUpWithEmail(emptyName, email, password))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await signUpWithEmailUseCase(
          const SignUpWithEmailParams(
            name: emptyName,
            email: email,
            password: password,
          ),
        );

        // Assert
        expect(result, const Left(failure));
      },
    );

    test(
      'should return ValidationFailure for empty email',
      () async {
        // Arrange
        const emptyEmail = '';
        const failure = ValidationFailure('Email cannot be empty');
        when(() => mockAuthRepository.signUpWithEmail(name, emptyEmail, password))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await signUpWithEmailUseCase(
          const SignUpWithEmailParams(
            name: name,
            email: emptyEmail,
            password: password,
          ),
        );

        // Assert
        expect(result, const Left(failure));
      },
    );

    test(
      'should return ValidationFailure for empty password',
      () async {
        // Arrange
        const emptyPassword = '';
        const failure = ValidationFailure('Password cannot be empty');
        when(() => mockAuthRepository.signUpWithEmail(name, email, emptyPassword))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await signUpWithEmailUseCase(
          const SignUpWithEmailParams(
            name: name,
            email: email,
            password: emptyPassword,
          ),
        );

        // Assert
        expect(result, const Left(failure));
      },
    );

    test(
      'should return NetworkFailure when network error occurs',
      () async {
        // Arrange
        const failure = NetworkFailure('No internet connection');
        when(() => mockAuthRepository.signUpWithEmail(name, email, password))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await signUpWithEmailUseCase(params);

        // Assert
        expect(result, const Left(failure));
      },
    );

    test(
      'should return correct UserEntity with all fields populated',
      () async {
        // Arrange
        when(() => mockAuthRepository.signUpWithEmail(name, email, password))
            .thenAnswer((_) async => Right(tUser));

        // Act
        final result = await signUpWithEmailUseCase(params);

        // Assert
        result.fold(
          (failure) => fail('Should return Right'),
          (user) {
            expect(user.uid, '123');
            expect(user.email, 'newuser@example.com');
            expect(user.name, 'New User');
            expect(user.isPremium, false);
          },
        );
      },
    );

    test(
      'should pass correct parameters to repository',
      () async {
        // Arrange
        when(() => mockAuthRepository.signUpWithEmail(name, email, password))
            .thenAnswer((_) async => Right(tUser));

        // Act
        await signUpWithEmailUseCase(params);

        // Assert
        verify(() =>
                mockAuthRepository.signUpWithEmail(name, email, password))
            .called(1);
      },
    );

    test(
      'should return ServerFailure when server error occurs',
      () async {
        // Arrange
        const failure = ServerFailure('Internal server error');
        when(() => mockAuthRepository.signUpWithEmail(name, email, password))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await signUpWithEmailUseCase(params);

        // Assert
        expect(result, const Left(failure));
      },
    );
  });
}
