// lib/features/follow/data/repositories/follow_repository_impl.dart
//
// FollowRepositoryImpl — delegates all calls to [FollowRemoteDataSource] and
// maps raw bool values to [FollowStatus] domain entities.

import '../../domain/entities/follow_status.dart';
import '../../domain/repositories/follow_repository.dart';
import '../datasources/follow_remote_data_source.dart';

class FollowRepositoryImpl implements FollowRepository {
  FollowRepositoryImpl({required FollowRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final FollowRemoteDataSource _dataSource;

  @override
  Future<FollowStatus> getFollowStatus({
    required String currentUid,
    required String targetUid,
  }) async {
    final isFollowing = await _dataSource.isFollowing(
      currentUid: currentUid,
      targetUid: targetUid,
    );
    return FollowStatus(isFollowing: isFollowing, targetUid: targetUid);
  }

  @override
  Stream<FollowStatus> streamFollowStatus({
    required String currentUid,
    required String targetUid,
  }) {
    return _dataSource
        .streamIsFollowing(currentUid: currentUid, targetUid: targetUid)
        .map((isFollowing) =>
            FollowStatus(isFollowing: isFollowing, targetUid: targetUid));
  }

  @override
  Future<void> follow({
    required String currentUid,
    required String targetUid,
  }) =>
      _dataSource.follow(currentUid: currentUid, targetUid: targetUid);

  @override
  Future<void> unfollow({
    required String currentUid,
    required String targetUid,
  }) =>
      _dataSource.unfollow(currentUid: currentUid, targetUid: targetUid);

  @override
  Future<List<String>> getFollowingUids({required String uid}) =>
      _dataSource.getFollowingUids(uid: uid);
}
