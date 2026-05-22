// lib/features/auth/presentation/bloc/auth_bloc.dart
//
// AuthBloc — manages authentication state for the entire application.
// Registered globally in main.dart.

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC that orchestrates all authentication flows.
///
/// - [AuthStarted] → subscribes to [AuthRepository.authStateChanges] and
///   re-emits state via internal [AuthUserChanged] events.
/// - Sign-in / sign-up / Google events → emit [AuthLoading] then
///   [AuthAuthenticated] or [AuthFailure].
/// - [ForgotPasswordRequested] → emit [AuthLoading] then
///   [ForgotPasswordEmailSent] or [AuthFailure].
/// - [SignOutRequested] → calls [AuthRepository.signOut]; the stream handles
///   the resulting state change.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Creates an [AuthBloc] backed by [repository].
  AuthBloc({required AuthRepository repository})
      : _repository = repository,
        super(const AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<SignInWithEmailAndPasswordRequested>(_onSignInWithEmailAndPassword);
    on<SignUpWithEmailAndPasswordRequested>(_onSignUpWithEmailAndPassword);
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<SignOutRequested>(_onSignOutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  final AuthRepository _repository;
  StreamSubscription<dynamic>? _authStateSubscription;

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    await _authStateSubscription?.cancel();
    _authStateSubscription = _repository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user: user)),
    );
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthAuthenticated(user: event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignInWithEmailAndPassword(
    SignInWithEmailAndPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onSignUpWithEmailAndPassword(
    SignUpWithEmailAndPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.signInWithGoogle();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  void _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) {
    _repository.signOut();
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.sendPasswordResetEmail(email: event.email);
      emit(const ForgotPasswordEmailSent());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
