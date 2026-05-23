// lib/features/search/presentation/bloc/user_search_event.dart
//
// UserSearchEvent — sealed hierarchy of events for [UserSearchBloc].

import 'package:equatable/equatable.dart';

/// Base class for all user-search events.
sealed class UserSearchEvent extends Equatable {
  const UserSearchEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the search query text changes.
final class UserSearchQueryChanged extends UserSearchEvent {
  /// Creates a [UserSearchQueryChanged] with the updated [query] string.
  const UserSearchQueryChanged({required this.query});

  /// The current text in the search field.
  final String query;

  @override
  List<Object?> get props => [query];
}

/// Dispatched when the screen resets (e.g. user clears the field).
final class UserSearchCleared extends UserSearchEvent {
  /// Creates a [UserSearchCleared] event.
  const UserSearchCleared();
}
