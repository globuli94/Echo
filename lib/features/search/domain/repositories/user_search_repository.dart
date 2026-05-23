// lib/features/search/domain/repositories/user_search_repository.dart
//
// UserSearchRepository — domain-layer interface for user search operations.

import '../../../profile/domain/entities/user_profile.dart';

/// Abstract repository for searching users by display name.
abstract interface class UserSearchRepository {
  /// Returns up to 20 [UserProfile] results whose [displayName] starts with
  /// [query] (case-sensitive prefix match). Returns an empty list when [query]
  /// is empty or fewer than 2 characters.
  Future<List<UserProfile>> searchUsers({required String query});
}
