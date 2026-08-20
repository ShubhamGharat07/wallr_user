// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmailUseCase _signInWithEmail;
  final SignUpWithEmailUseCase _signUpWithEmail;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final ForgotPasswordUseCase _forgotPassword;
  final SignOutUseCase _signOut;
  final SharedPreferences _prefs;

  AuthBloc({
    required SignInWithEmailUseCase signInWithEmail,
    required SignUpWithEmailUseCase signUpWithEmail,
    required SignInWithGoogleUseCase signInWithGoogle,
    required ForgotPasswordUseCase forgotPassword,
    required SignOutUseCase signOut,
    required SharedPreferences prefs,
  }) : _signInWithEmail = signInWithEmail,
       _signUpWithEmail = signUpWithEmail,
       _signInWithGoogle = signInWithGoogle,
       _forgotPassword = forgotPassword,
       _signOut = signOut,
       _prefs = prefs,
       super(const AuthInitial()) {
    on<SignInWithEmailRequested>(_onSignInWithEmail);
    on<SignUpWithEmailRequested>(_onSignUpWithEmail);
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<ForgotPasswordRequested>(_onForgotPassword);
    on<SignOutRequested>(_onSignOut);
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInWithEmail(
      SignInWithEmailParams(email: event.email, password: event.password),
    );
    // IMPORTANT: always emit() before the handler completes. Emitting from
    // inside the async fold callback after `await _saveSession` meant the
    // handler had already finished, which tripped the debug
    // 'emit was called after an event handler completed' assertion: the
    // spinner stuck forever and navigation never fired.
    final failureMessage = result.fold<String?>(
      (failure) => failure.message,
      (_) => null,
    );
    if (failureMessage != null) {
      emit(AuthFailureState(failureMessage));
      return;
    }
    final user = result.getOrElse(() => throw StateError('Unreachable'));
    await _saveSession(user.email);
    emit(AuthSuccess(user));
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signUpWithEmail(
      SignUpWithEmailParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );
    final failureMessage = result.fold<String?>(
      (failure) => failure.message,
      (_) => null,
    );
    if (failureMessage != null) {
      emit(AuthFailureState(failureMessage));
      return;
    }
    final user = result.getOrElse(() => throw StateError('Unreachable'));
    await _saveSession(user.email);
    emit(AuthSuccess(user));
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInWithGoogle(const NoParams());
    final failureMessage = result.fold<String?>(
      (failure) => failure.message,
      (_) => null,
    );
    if (failureMessage != null) {
      emit(AuthFailureState(failureMessage));
      return;
    }
    final user = result.getOrElse(() => throw StateError('Unreachable'));
    await _saveSession(user.email);
    emit(AuthSuccess(user));
  }

  Future<void> _onForgotPassword(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _forgotPassword(event.email);
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (_) => emit(const ForgotPasswordSuccess()),
    );
  }

  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Try the Firebase/Google remote sign-out. Even if it fails for any
    // reason (network, GoogleSignIn config, etc.), the local session is
    // ALWAYS cleared — the user must always be able to log out.
    await _signOut(const NoParams());
    await _clearSession();
    emit(const SignOutSuccess());
  }

  /// Save the session when the user successfully logs in.
  Future<void> _saveSession(String userEmail) async {
    try {
      // Generate a unique session token (use the Firebase auth token in production)
      final sessionToken = 'session_${DateTime.now().millisecondsSinceEpoch}';

      await Future.wait([
        _prefs.setString('session_token', sessionToken),
        _prefs.setString('user_email', userEmail),
        _prefs.setInt('login_time', DateTime.now().millisecondsSinceEpoch),
      ]);
    } catch (e) {
      // Log error but don't break auth flow
      print('Error saving session: $e');
    }
  }

  /// Clear the session when the user logs out.
  Future<void> _clearSession() async {
    try {
      await Future.wait([
        _prefs.remove('session_token'),
        _prefs.remove('user_email'),
        _prefs.remove('login_time'),
      ]);
    } catch (e) {
      print('Error clearing session: $e');
    }
  }
}

