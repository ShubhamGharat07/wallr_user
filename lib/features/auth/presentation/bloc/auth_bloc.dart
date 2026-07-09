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
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) async {
        // ✅ Session save kar
        await _saveSession(user.email);
        emit(AuthSuccess(user));
      },
    );
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
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) async {
        // ✅ Session save kar
        await _saveSession(user.email);
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInWithGoogle(const NoParams());
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) async {
        // ✅ Session save kar
        await _saveSession(user.email);
        emit(AuthSuccess(user));
      },
    );
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
    final result = await _signOut(const NoParams());
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (_) async {
        // ✅ Session clear kar
        await _clearSession();
        emit(const SignOutSuccess());
      },
    );
  }

  /// 💾 Session save kar - jab user successful login karega
  Future<void> _saveSession(String userEmail) async {
    try {
      // Generate unique session token (in production, Firebase auth token use kar)
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

  /// 🧹 Session clear kar - jab user logout karega
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

