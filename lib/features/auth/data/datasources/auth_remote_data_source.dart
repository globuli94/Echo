// lib/features/auth/data/datasources/auth_remote_data_source.dart
//
// AuthRemoteDataSource — wraps Firebase Auth, Google Sign-In, and Firestore.
// Handles raw Firebase types; the repository implementation converts them to
// domain entities.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Abstract contract for remote authentication operations.
///
/// Exists to allow mocking in tests without a live Firebase connection.
abstract class AuthRemoteDataSource {
  /// Raw Firebase auth-state stream emitting [User] or `null`.
  Stream<User?> get authStateChanges;

  /// Signs in with email and password, returning the [UserCredential].
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Creates a new Firebase account, returning the [UserCredential].
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Completes the Google OAuth flow and returns the [UserCredential].
  Future<UserCredential> signInWithGoogle();

  /// Signs out from both Firebase Auth and Google Sign-In.
  Future<void> signOut();

  /// Sends a password-reset email to [email].
  Future<void> sendPasswordResetEmail({required String email});

  /// Writes [data] to `users/{uid}` in Firestore.
  Future<void> createUserDocument({
    required String uid,
    required Map<String, dynamic> data,
  });
}

/// Firebase-backed implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// Creates an [AuthRemoteDataSourceImpl].
  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _firestore = firestore;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  @override
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

  @override
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled by the user.');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() => Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _firebaseAuth.sendPasswordResetEmail(email: email);

  @override
  Future<void> createUserDocument({
    required String uid,
    required Map<String, dynamic> data,
  }) =>
      _firestore.collection('users').doc(uid).set(data);
}
