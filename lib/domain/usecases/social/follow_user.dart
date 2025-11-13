import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/review.dart';
import '../../repositories/social_repository.dart';

/// Use case for following a user or organizer
class FollowUser {
  final SocialRepository repository;

  FollowUser(this.repository);

  Future<Either<Failure, UserFollow>> call({
    required String followerId,
    required String followingId,
    required String followType,
  }) async {
    // Validation
    if (followerId.isEmpty) {
      return Left(ValidationFailure(message: 'Follower ID is required'));
    }

    if (followingId.isEmpty) {
      return Left(ValidationFailure(message: 'Following ID is required'));
    }

    if (followerId == followingId) {
      return Left(ValidationFailure(message: 'Cannot follow yourself'));
    }

    if (followType != 'user' && followType != 'organizer') {
      return Left(ValidationFailure(message: 'Follow type must be user or organizer'));
    }

    return await repository.followUser(
      followerId: followerId,
      followingId: followingId,
      followType: followType,
    );
  }
}
