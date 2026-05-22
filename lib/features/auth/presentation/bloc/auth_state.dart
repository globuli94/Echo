// lib/features/auth/presentation/bloc/auth_state.dart
//
// AuthState — sealed hierarchy of states emitted by [AuthBloc].

import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_user.dart';

/// Base class for all authentication states.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before the auth-state stream has emitted.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Emitted while an async auth operation is in flight.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Emitted when a user is signed in.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  /// The currently signed-in user.
  final AuthUser user;

  @override
  List<Object?> get props => [user];
}

/// Emitted when no user is signed in.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Emitted when an auth operation fails.
final class AuthFailure extends AuthState {
  const AuthFailure({required this.error});

  /// Human-readable error message.
  final String error;

  @override
  List<Object?> get props => [error];
}

/// Emitted when the password-reset email was sent successfully.
final class ForgotPasswordEmailSent extends AuthState {
  const ForgotPasswordEmailSent();
}
