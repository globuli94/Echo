// lib/features/auth/presentation/bloc/auth_event.dart
//
// AuthEvent — sealed hierarchy of events handled by [AuthBloc].

import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_user.dart';

/// Base class for all authentication events.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on app start to subscribe to the auth-state stream.
final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

/// Internal event emitted by the auth-state stream listener.
///
/// [user] is `null` when signed out and non-null when signed in.
final class AuthUserChanged extends AuthEvent {
  const AuthUserChanged({required this.user});

  /// The new auth user, or `null` if the user signed out.
  final AuthUser? user;

  @override
  List<Object?> get props => [user];
}

/// Requests sign-in with an email/password pair.
final class SignInWithEmailAndPasswordRequested extends AuthEvent {
  const SignInWithEmailAndPasswordRequested({
    required this.email,
    required this.password,
  });

  /// The user's email address.
  final String email;

  /// The user's plaintext password.
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Requests account creation with an email/password pair.
final class SignUpWithEmailAndPasswordRequested extends AuthEvent {
  const SignUpWithEmailAndPasswordRequested({
    required this.email,
    required this.password,
  });

  /// The desired email address.
  final String email;

  /// The desired plaintext password.
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Requests sign-in via Google OAuth.
final class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

/// Requests sign-out of the current session.
final class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Requests a password-reset email for [email].
final class ForgotPasswordRequested extends AuthEvent {
  const ForgotPasswordRequested({required this.email});

  /// The email address to send the reset link to.
  final String email;

  @override
  List<Object?> get props => [email];
}
