// lib/features/search/presentation/bloc/user_search_state.dart
//
// UserSearchState — sealed hierarchy of states emitted by [UserSearchBloc].

import 'package:equatable/equatable.dart';

import '../../../profile/domain/entities/user_profile.dart';

/// Base class for all user-search states.
sealed class UserSearchState extends Equatable {
  const UserSearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state before the user has typed any query.
final class UserSearchInitial extends UserSearchState {
  /// Creates a [UserSearchInitial] state.
  const UserSearchInitial();
}

/// Debounce has fired and the Firestore request is in-flight.
final class UserSearchLoading extends UserSearchState {
  /// Creates a [UserSearchLoading] state.
  const UserSearchLoading();
}

/// Search returned one or more results.
final class UserSearchLoaded extends UserSearchState {
  /// Creates a [UserSearchLoaded] state with the given [results].
  const UserSearchLoaded({required this.results});

  /// The list of matching [UserProfile] objects.
  final List<UserProfile> results;

  @override
  List<Object?> get props => [results];
}

/// Search completed but returned no results.
final class UserSearchEmpty extends UserSearchState {
  /// Creates a [UserSearchEmpty] state.
  const UserSearchEmpty();
}

/// Search failed with an error.
final class UserSearchFailure extends UserSearchState {
  /// Creates a [UserSearchFailure] state with the given [error] message.
  const UserSearchFailure({required this.error});

  /// Human-readable error message.
  final String error;

  @override
  List<Object?> get props => [error];
}
