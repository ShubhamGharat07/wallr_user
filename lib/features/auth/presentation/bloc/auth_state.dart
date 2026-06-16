// lib/features/auth/presentation/bloc/auth_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthSuccess extends AuthState {
  final UserEntity user;
  const AuthSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

final class AuthFailureState extends AuthState {
  final String message;
  const AuthFailureState(this.message);
  @override
  List<Object?> get props => [message];
}

final class ForgotPasswordSuccess extends AuthState {
  const ForgotPasswordSuccess();
}

final class SignOutSuccess extends AuthState {
  const SignOutSuccess();
}
