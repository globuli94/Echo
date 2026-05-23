// lib/features/search/presentation/bloc/user_search_bloc.dart
//
// UserSearchBloc — manages user-search state driven by [UserSearchEvent]s.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/user_search_repository.dart';
import 'user_search_event.dart';
import 'user_search_state.dart';

/// BLoC responsible for executing user-search queries and emitting
/// [UserSearchState] updates to the [SearchScreen].
///
/// Registered globally in `main.dart` because it is consumed by a shell tab.
class UserSearchBloc extends Bloc<UserSearchEvent, UserSearchState> {
  /// Creates a [UserSearchBloc] backed by [repository].
  UserSearchBloc({required UserSearchRepository repository})
      : _repository = repository,
        super(const UserSearchInitial()) {
    on<UserSearchQueryChanged>(_onQueryChanged);
    on<UserSearchCleared>(_onCleared);
  }

  final UserSearchRepository _repository;

  Future<void> _onQueryChanged(
    UserSearchQueryChanged event,
    Emitter<UserSearchState> emit,
  ) async {
    if (event.query.trim().length < 2) return;

    emit(const UserSearchLoading());
    try {
      final results = await _repository.searchUsers(query: event.query.trim());
      if (results.isEmpty) {
        emit(const UserSearchEmpty());
      } else {
        emit(UserSearchLoaded(results: results));
      }
    } catch (e) {
      emit(UserSearchFailure(error: e.toString()));
    }
  }

  void _onCleared(
    UserSearchCleared event,
    Emitter<UserSearchState> emit,
  ) {
    emit(const UserSearchInitial());
  }
}
