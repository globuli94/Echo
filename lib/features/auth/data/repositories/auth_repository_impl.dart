// lib/features/auth/data/repositories/auth_repository_impl.dart
//
// AuthRepositoryImpl — implements AuthRepository using Firebase Auth via
// AuthRemoteDataSource. Converts raw Firebase types to domain entities and
// writes the initial Firestore user document on sign-up.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Firebase-backed implementation of [AuthRepository].
///
/// Converts [firebase_auth.User] instances to [AuthUser] domain entities so
/// the presentation layer remains free of Firebase dependencies.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates an [AuthRepositoryImpl] backed by [dataSource].
  AuthRepositoryImpl({required AuthRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final AuthRemoteDataSource _dataSource;

  @override
  Stream<AuthUser?> get authStateChanges =>
      _dataSource.authStateChanges.map(_toAuthUser);

  @override
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _dataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _fromCredential(credential);
  }

  @override
  Future<AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _dataSource.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = _fromCredential(credential);
    await createUserDocument(user: user);
    return user;
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    final credential = await _dataSource.signInWithGoogle();
    final user = _fromCredential(credential);
    await ensureUserDocument(user: user);
    return user;
  }

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _dataSource.sendPasswordResetEmail(email: email);

  @override
  Future<void> createUserDocument({required AuthUser user}) {
    final emailPrefix = user.email?.split('@').first ?? '';
    return _dataSource.createUserDocument(
      uid: user.uid,
      data: {
        'uid': user.uid,
        'displayName': user.displayName ?? emailPrefix,
        'username': emailPrefix,
        'bio': '',
        'avatarUrl': null,
        'followerCount': 0,
        'followingCount': 0,
        'postCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );
  }

  @override
  Future<void> ensureUserDocument({required AuthUser user}) {
    final emailPrefix = user.email?.split('@').first ?? '';
    return _dataSource.ensureUserDocument(
      uid: user.uid,
      defaultData: {
        'uid': user.uid,
        'displayName': user.displayName ?? emailPrefix,
        'username': emailPrefix,
        'bio': '',
        'avatarUrl': null,
        'followerCount': 0,
        'followingCount': 0,
        'postCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );
  }

  /// Maps a nullable [firebase_auth.User] to a nullable [AuthUser].
  AuthUser? _toAuthUser(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) return null;
    return AuthUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
    );
  }

  /// Extracts the [firebase_auth.User] from [credential] and converts it.
  ///
  /// Throws if [credential.user] is unexpectedly null.
  AuthUser _fromCredential(firebase_auth.UserCredential credential) {
    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw Exception('No user returned in Firebase credential.');
    }
    return AuthUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
    );
  }
}
