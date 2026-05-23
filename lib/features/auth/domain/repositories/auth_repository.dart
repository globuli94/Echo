// lib/features/auth/domain/repositories/auth_repository.dart
//
// AuthRepository — abstract interface for authentication operations.
// Implementations live in the data layer; the domain layer never imports them.

import '../entities/auth_user.dart';

/// Abstract contract for all authentication operations.
///
/// The domain layer depends only on this interface. The data layer provides
/// [AuthRepositoryImpl] which fulfils it using Firebase Auth.
abstract class AuthRepository {
  /// Stream of the current authentication state.
  ///
  /// Emits an [AuthUser] when signed in, or `null` when signed out.
  Stream<AuthUser?> get authStateChanges;

  /// Signs in with [email] and [password].
  ///
  /// Returns the authenticated [AuthUser] on success.
  /// Throws on invalid credentials or network error.
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Creates a new account with [email] and [password].
  ///
  /// Returns the newly authenticated [AuthUser] on success and writes the
  /// initial Firestore user document via [createUserDocument].
  /// Throws if the email is already in use or on network error.
  Future<AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs in using Google Sign-In.
  ///
  /// Returns the authenticated [AuthUser] on success.
  /// Throws if the user cancels or on network error.
  Future<AuthUser> signInWithGoogle();

  /// Signs out the currently authenticated user.
  Future<void> signOut();

  /// Sends a password reset email to [email].
  Future<void> sendPasswordResetEmail({required String email});

  /// Writes the initial Firestore document for [user] at `users/{uid}`.
  ///
  /// Called on first sign-up to populate the user's public profile.
  Future<void> createUserDocument({required AuthUser user});

  /// Creates `users/{uid}` only when the document does not already exist.
  ///
  /// Called on Google Sign-In to ensure the document is created on first login
  /// without overwriting an existing profile on subsequent logins.
  Future<void> ensureUserDocument({required AuthUser user});
}
