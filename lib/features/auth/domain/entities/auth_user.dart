// lib/features/auth/domain/entities/auth_user.dart
//
// AuthUser — pure Dart domain entity representing an authenticated user.
// Zero Firebase imports; outer layers map Firebase types to this entity.

import 'package:equatable/equatable.dart';

/// Represents an authenticated user in the domain layer.
///
/// All fields map 1:1 to Firebase Auth properties but carry no Firebase
/// dependencies so the domain layer stays portable and testable.
class AuthUser extends Equatable {
  /// Creates an [AuthUser].
  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
  });

  /// The unique identifier assigned by Firebase Auth.
  final String uid;

  /// The user's email address, or `null` if not available.
  final String? email;

  /// The user's display name, or `null` if not set.
  final String? displayName;

  @override
  List<Object?> get props => [uid, email, displayName];
}
