// lib/features/auth/presentation/bloc/auth_event.dart

import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

final class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInWithEmailRequested({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

final class SignUpWithEmailRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const SignUpWithEmailRequested({
    required this.name,
    required this.email,
    required this.password,
  });
  @override
  List<Object> get props => [name, email, password];
}

final class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

final class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested(this.email);
  @override
  List<Object> get props => [email];
}

final class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}
