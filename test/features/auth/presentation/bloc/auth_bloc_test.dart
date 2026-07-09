import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallr/core/error/failures.dart';
import 'package:wallr/core/usecases/usecase.dart';
import 'package:wallr/features/auth/domain/entities/user_entity.dart';
import 'package:wallr/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:wallr/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:wallr/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:wallr/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:wallr/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:wallr/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wallr/features/auth/presentation/bloc/auth_event.dart';
import 'package:wallr/features/auth/presentation/bloc/auth_state.dart';

class MockSignInWithEmailUseCase extends Mock
    implements SignInWithEmailUseCase {}

class MockSignUpWithEmailUseCase extends Mock
    implements SignUpWithEmailUseCase {}

class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSignInWithEmailUseCase mockSignInWithEmail;
  late MockSignUpWithEmailUseCase mockSignUpWithEmail;
  late MockSignInWithGoogleUseCase mockSignInWithGoogle;
  late MockForgotPasswordUseCase mockForgotPassword;
  late MockSignOutUseCase mockSignOut;
  late MockSharedPreferences mockPrefs;
  late AuthBloc authBloc;

  final tUser = const UserEntity(
    uid: '123',
    email: 'test@example.com',
    name: 'Test User',
    photoUrl: '',
    isPremium: false,
  );

  setUp(() {
    mockSignInWithEmail = MockSignInWithEmailUseCase();
    mockSignUpWithEmail = MockSignUpWithEmailUseCase();
    mockSignInWithGoogle = MockSignInWithGoogleUseCase();
    mockForgotPassword = MockForgotPasswordUseCase();
    mockSignOut = MockSignOutUseCase();
    mockPrefs = MockSharedPreferences();

    // Setup default SharedPreferences mocks
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setInt(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);

    authBloc = AuthBloc(
      signInWithEmail: mockSignInWithEmail,
      signUpWithEmail: mockSignUpWithEmail,
      signInWithGoogle: mockSignInWithGoogle,
      forgotPassword: mockForgotPassword,
      signOut: mockSignOut,
      prefs: mockPrefs,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc - Sign In with Email', () {
    const email = 'test@example.com';
    const password = 'password123';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when sign in is successful',
      setUp: () {
        when(
          () => mockSignInWithEmail(
            SignInWithEmailParams(email: email, password: password),
          ),
        ).thenAnswer((_) async => Right(tUser));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const SignInWithEmailRequested(email: email, password: password),
      ),
      expect: () => [const AuthLoading(), AuthSuccess(tUser)],
      verify: (_) {
        verify(
          () => mockSignInWithEmail(
            SignInWithEmailParams(email: email, password: password),
          ),
        ).called(1);
        verify(() => mockPrefs.setString('user_email', email)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] when sign in fails with invalid credentials',
      setUp: () {
        when(() => mockSignInWithEmail(any())).thenAnswer(
          (_) async => const Left(AuthFailure('Invalid email or password')),
        );
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const SignInWithEmailRequested(email: email, password: password),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailureState('Invalid email or password'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] when network error occurs',
      setUp: () {
        when(() => mockSignInWithEmail(any())).thenAnswer(
          (_) async => const Left(NetworkFailure('No internet connection')),
        );
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const SignInWithEmailRequested(email: email, password: password),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailureState('No internet connection'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] for empty email',
      setUp: () {
        when(() => mockSignInWithEmail(any())).thenAnswer(
          (_) async => const Left(ValidationFailure('Email cannot be empty')),
        );
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const SignInWithEmailRequested(email: '', password: password),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailureState('Email cannot be empty'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] for empty password',
      setUp: () {
        when(() => mockSignInWithEmail(any())).thenAnswer(
          (_) async =>
              const Left(ValidationFailure('Password cannot be empty')),
        );
      },
      build: () => authBloc,
      act: (bloc) =>
          bloc.add(const SignInWithEmailRequested(email: email, password: '')),
      expect: () => [
        const AuthLoading(),
        const AuthFailureState('Password cannot be empty'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'saves session to SharedPreferences on successful sign in',
      setUp: () {
        when(
          () => mockSignInWithEmail(any()),
        ).thenAnswer((_) async => Right(tUser));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const SignInWithEmailRequested(email: email, password: password),
      ),
      verify: (_) {
        verify(() => mockPrefs.setString('session_token', any())).called(1);
        verify(() => mockPrefs.setString('user_email', email)).called(1);
        verify(() => mockPrefs.setInt('login_time', any())).called(1);
      },
    );
  });

  group('AuthBloc - Sign Up with Email', () {
    const name = 'Test User';
    const email = 'newuser@example.com';
    const password = 'password123';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when sign up is successful',
      setUp: () {
        when(
          () => mockSignUpWithEmail(any()),
        ).thenAnswer((_) async => Right(tUser));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const SignUpWithEmailRequested(
          name: name,
          email: email,
          password: password,
        ),
      ),
      expect: () => [const AuthLoading(), AuthSuccess(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] when email already exists',
      setUp: () {
        when(() => mockSignUpWithEmail(any())).thenAnswer(
          (_) async => const Left(AuthFailure('Email already registered')),
        );
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const SignUpWithEmailRequested(
          name: name,
          email: email,
          password: password,
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailureState('Email already registered'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] for invalid email format',
      setUp: () {
        when(() => mockSignUpWithEmail(any())).thenAnswer(
          (_) async => const Left(ValidationFailure('Invalid email format')),
        );
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const SignUpWithEmailRequested(
          name: name,
          email: 'invalid-email',
          password: password,
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailureState('Invalid email format'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] for weak password',
      setUp: () {
        when(() => mockSignUpWithEmail(any())).thenAnswer(
          (_) async => const Left(
            ValidationFailure('Password must be at least 6 characters'),
          ),
        );
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const SignUpWithEmailRequested(
          name: name,
          email: email,
          password: '123',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailureState('Password must be at least 6 characters'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] for empty name',
      setUp: () {
        when(() => mockSignUpWithEmail(any())).thenAnswer(
          (_) async => const Left(ValidationFailure('Name cannot be empty')),
        );
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const SignUpWithEmailRequested(
          name: '',
          email: email,
          password: password,
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailureState('Name cannot be empty'),
      ],
    );
  });

  group('AuthBloc - Sign Out', () {
    blocTest<AuthBloc, AuthState>(
      'emits [SignOutSuccess] when sign out is successful',
      setUp: () {
        when(
          () => mockSignOut(const NoParams()),
        ).thenAnswer((_) async => const Right(null));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(const SignOutRequested()),
      expect: () => [const SignOutSuccess()],
      verify: (_) {
        verify(() => mockPrefs.remove('session_token')).called(1);
        verify(() => mockPrefs.remove('user_email')).called(1);
        verify(() => mockPrefs.remove('login_time')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthFailureState] when sign out fails',
      setUp: () {
        when(() => mockSignOut(const NoParams())).thenAnswer(
          (_) async => const Left(AuthFailure('Failed to sign out')),
        );
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(const SignOutRequested()),
      expect: () => [const AuthFailureState('Failed to sign out')],
    );
  });

  group('AuthBloc - Forgot Password', () {
    const email = 'test@example.com';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, ForgotPasswordSuccess] when reset email is sent',
      setUp: () {
        when(
          () => mockForgotPassword(email),
        ).thenAnswer((_) async => const Right(null));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(const ForgotPasswordRequested(email)),
      expect: () => [const AuthLoading(), const ForgotPasswordSuccess()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] when email not found',
      setUp: () {
        when(
          () => mockForgotPassword(email),
        ).thenAnswer((_) async => const Left(AuthFailure('Email not found')));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(const ForgotPasswordRequested(email)),
      expect: () => [
        const AuthLoading(),
        const AuthFailureState('Email not found'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] for invalid email format',
      setUp: () {
        when(() => mockForgotPassword('invalid-email')).thenAnswer(
          (_) async => const Left(ValidationFailure('Invalid email format')),
        );
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(const ForgotPasswordRequested('invalid-email')),
      expect: () => [
        const AuthLoading(),
        const AuthFailureState('Invalid email format'),
      ],
    );
  });
}
