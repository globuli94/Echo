// lib/features/search/data/repositories/user_search_repository_impl.dart
//
// UserSearchRepositoryImpl — data-layer implementation of [UserSearchRepository].

import '../../../profile/domain/entities/user_profile.dart';
import '../../domain/repositories/user_search_repository.dart';
import '../datasources/user_search_remote_data_source.dart';

/// Concrete implementation of [UserSearchRepository].
///
/// Short-circuits Firestore calls when the trimmed [query] is fewer than
/// 2 characters.
class UserSearchRepositoryImpl implements UserSearchRepository {
  /// Creates a [UserSearchRepositoryImpl] backed by [dataSource].
  const UserSearchRepositoryImpl({
    required UserSearchRemoteDataSource dataSource,
  }) : _dataSource = dataSource;

  final UserSearchRemoteDataSource _dataSource;

  @override
  Future<List<UserProfile>> searchUsers({required String query}) async {
    if (query.trim().length < 2) return [];
    return _dataSource.searchUsers(query: query.trim());
  }
}
