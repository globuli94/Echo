// Copyright (c) 2024. All rights reserved.
// Test suite for UserSearchRepositoryImpl.

import 'package:echo/features/profile/domain/entities/user_profile.dart';
import 'package:echo/features/search/data/datasources/user_search_remote_data_source.dart';
import 'package:echo/features/search/data/repositories/user_search_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserSearchRemoteDataSource extends Mock
    implements UserSearchRemoteDataSource {}

void main() {
  late UserSearchRepositoryImpl repository;
  late MockUserSearchRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockUserSearchRemoteDataSource();
    repository = UserSearchRepositoryImpl(dataSource: mockDataSource);
  });

  group('UserSearchRepositoryImpl', () {
    test('returns empty list for query shorter than 2 chars without calling data source', () async {
      final result = await repository.searchUsers(query: 'a');

      expect(result, isEmpty);
      verifyNever(() => mockDataSource.searchUsers(query: 'a'));
    });

    test('returns empty list for empty query without calling data source', () async {
      final result = await repository.searchUsers(query: '');

      expect(result, isEmpty);
      verifyNever(() => mockDataSource.searchUsers(query: ''));
    });

    test('delegates to data source and returns users for valid query', () async {
      final mockUser = UserProfile(
        uid: 'uid1',
        displayName: 'Alice',
        bio: 'Test bio',
        avatarUrl: null,
        postCount: 0,
      );
      when(() => mockDataSource.searchUsers(query: 'ali')).thenAnswer((_) async => [mockUser]);

      final result = await repository.searchUsers(query: 'ali');

      expect(result, [mockUser]);
      verify(() => mockDataSource.searchUsers(query: 'ali')).called(1);
    });
  });
}
