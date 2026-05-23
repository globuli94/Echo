// Copyright (c) 2024. All rights reserved.
// Test suite for UserSearchBloc.

import 'package:bloc_test/bloc_test.dart';
import 'package:echo/features/profile/domain/entities/user_profile.dart';
import 'package:echo/features/search/domain/repositories/user_search_repository.dart';
import 'package:echo/features/search/presentation/bloc/user_search_bloc.dart';
import 'package:echo/features/search/presentation/bloc/user_search_event.dart';
import 'package:echo/features/search/presentation/bloc/user_search_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserSearchRepository extends Mock implements UserSearchRepository {}

void main() {
  late UserSearchBloc userSearchBloc;
  late MockUserSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockUserSearchRepository();
    userSearchBloc = UserSearchBloc(repository: mockRepository);
  });

  tearDown(() {
    userSearchBloc.close();
  });

  group('UserSearchBloc', () {
    test('initial state is UserSearchInitial', () {
      expect(userSearchBloc.state, isA<UserSearchInitial>());
    });

    blocTest<UserSearchBloc, UserSearchState>(
      'emits no states when query is shorter than 2 chars',
      build: () => userSearchBloc,
      act: (bloc) => bloc.add(const UserSearchQueryChanged(query: 'a')),
      expect: () => [],
    );

    blocTest<UserSearchBloc, UserSearchState>(
      'emits [UserSearchLoading, UserSearchLoaded] when valid query returns results',
      build: () {
        final mockUsers = [
          UserProfile(
            uid: 'uid1',
            displayName: 'Alice',
            bio: 'Test bio',
            avatarUrl: null,
            postCount: 0,
          ),
          UserProfile(
            uid: 'uid2',
            displayName: 'Albert',
            bio: 'Test bio',
            avatarUrl: null,
            postCount: 0,
          ),
        ];
        when(() => mockRepository.searchUsers(query: 'al')).thenAnswer((_) async => mockUsers);
        return userSearchBloc;
      },
      act: (bloc) => bloc.add(const UserSearchQueryChanged(query: 'al')),
      expect: () => [
        isA<UserSearchLoading>(),
        isA<UserSearchLoaded>()
            .having((state) => state.results, 'results', hasLength(2))
            .having((state) => state.results[0].displayName, 'first user name', 'Alice'),
      ],
    );

    blocTest<UserSearchBloc, UserSearchState>(
      'emits [UserSearchLoading, UserSearchEmpty] when valid query returns no results',
      build: () {
        when(() => mockRepository.searchUsers(query: 'zzz')).thenAnswer((_) async => []);
        return userSearchBloc;
      },
      act: (bloc) => bloc.add(const UserSearchQueryChanged(query: 'zzz')),
      expect: () => [
        isA<UserSearchLoading>(),
        isA<UserSearchEmpty>(),
      ],
    );

    blocTest<UserSearchBloc, UserSearchState>(
      'emits [UserSearchInitial] when query is cleared',
      build: () => userSearchBloc,
      seed: () => UserSearchLoaded(
        results: [
          UserProfile(
            uid: 'uid1',
            displayName: 'Test',
            bio: 'Test bio',
            avatarUrl: null,
            postCount: 0,
          ),
        ],
      ),
      act: (bloc) => bloc.add(const UserSearchCleared()),
      expect: () => [isA<UserSearchInitial>()],
    );

    blocTest<UserSearchBloc, UserSearchState>(
      'emits [UserSearchLoading, UserSearchFailure] when repository throws',
      build: () {
        when(() => mockRepository.searchUsers(query: 'er')).thenThrow(Exception('Network error'));
        return userSearchBloc;
      },
      act: (bloc) => bloc.add(const UserSearchQueryChanged(query: 'er')),
      expect: () => [
        isA<UserSearchLoading>(),
        isA<UserSearchFailure>(),
      ],
    );
  });
}
