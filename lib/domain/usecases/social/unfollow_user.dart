import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/social_repository.dart';

/// Use case for unfollowing a user or organizer
class UnfollowUser {
  final SocialRepository repository;

  UnfollowUser(this.repository);

  Future<Either<Failure, void>> call({
    required String followerId,
    required String followingId,
  }) async {
    // Validation
    if (followerId.isEmpty) {
      return Left(ValidationFailure(message: 'Follower ID is required'));
    }

    if (followingId.isEmpty) {
      return Left(ValidationFailure(message: 'Following ID is required'));
    }

    return await repository.unfollowUser(
      followerId: followerId,
      followingId: followingId,
    );
  }
}
