import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/social_repository.dart';
import '../datasources/remote/social_remote_datasource.dart';

/// Social repository implementation
class SocialRepositoryImpl implements SocialRepository {
  final SocialRemoteDataSource remoteDataSource;

  SocialRepositoryImpl({
    required this.remoteDataSource,
  });

  // ==================== EVENT REVIEWS ====================

  @override
  Future<Either<Failure, List<EventReview>>> getEventReviews(String eventId) async {
    try {
      final reviews = await remoteDataSource.getEventReviews(eventId);
      return Right(reviews.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventReview>> getEventReview(String reviewId) async {
    // TODO: Implement if needed
    return Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, EventReview>> createEventReview({
    required String eventId,
    required String userId,
    required int rating,
    String? comment,
    List<String>? imageUrls,
  }) async {
    try {
      final review = await remoteDataSource.createEventReview(
        eventId: eventId,
        userId: userId,
        rating: rating,
        comment: comment,
        imageUrls: imageUrls,
      );
      return Right(review.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventReview>> updateEventReview({
    required String reviewId,
    required int rating,
    String? comment,
    List<String>? imageUrls,
  }) async {
    try {
      final review = await remoteDataSource.updateEventReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
        imageUrls: imageUrls,
      );
      return Right(review.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEventReview(String reviewId) async {
    try {
      await remoteDataSource.deleteEventReview(reviewId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markReviewHelpful(String reviewId) async {
    try {
      await remoteDataSource.markReviewHelpful(reviewId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventRatingSummary>> getEventRatingSummary(String eventId) async {
    try {
      final reviews = await remoteDataSource.getEventReviews(eventId);

      if (reviews.isEmpty) {
        return Right(EventRatingSummary(
          eventId: eventId,
          averageRating: 0.0,
          totalReviews: 0,
          ratingDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        ));
      }

      // Calculate rating distribution
      final distribution = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      double totalRating = 0;

      for (var review in reviews) {
        distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
        totalRating += review.rating;
      }

      final averageRating = totalRating / reviews.length;

      return Right(EventRatingSummary(
        eventId: eventId,
        averageRating: averageRating,
        totalReviews: reviews.length,
        ratingDistribution: distribution,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ==================== ORGANIZER REVIEWS ====================

  @override
  Future<Either<Failure, List<OrganizerReview>>> getOrganizerReviews(String organizerId) async {
    try {
      final reviews = await remoteDataSource.getOrganizerReviews(organizerId);
      return Right(reviews.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganizerReview>> createOrganizerReview({
    required String organizerId,
    required String userId,
    required int rating,
    String? comment,
    int? communicationRating,
    int? professionalismRating,
    int? venueRating,
    int? valueRating,
  }) async {
    try {
      final review = await remoteDataSource.createOrganizerReview(
        organizerId: organizerId,
        userId: userId,
        rating: rating,
        comment: comment,
        communicationRating: communicationRating,
        professionalismRating: professionalismRating,
        venueRating: venueRating,
        valueRating: valueRating,
      );
      return Right(review.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getOrganizerAverageRating(String organizerId) async {
    try {
      final reviews = await remoteDataSource.getOrganizerReviews(organizerId);

      if (reviews.isEmpty) {
        return const Right(0.0);
      }

      final total = reviews.fold<double>(
        0.0,
        (sum, review) => sum + review.rating,
      );

      return Right(total / reviews.length);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ==================== FOLLOWS ====================

  @override
  Future<Either<Failure, UserFollow>> followUser({
    required String followerId,
    required String followingId,
    required String followType,
  }) async {
    try {
      final follow = await remoteDataSource.followUser(
        followerId: followerId,
        followingId: followingId,
        followType: followType,
      );
      return Right(follow.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unfollowUser({
    required String followerId,
    required String followingId,
  }) async {
    try {
      await remoteDataSource.unfollowUser(
        followerId: followerId,
        followingId: followingId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFollowing({
    required String followerId,
    required String followingId,
  }) async {
    try {
      final result = await remoteDataSource.isFollowing(
        followerId: followerId,
        followingId: followingId,
      );
      return Right(result);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, List<UserFollow>>> getFollowers(String userId) async {
    try {
      final follows = await remoteDataSource.getFollowers(userId);
      return Right(follows.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserFollow>>> getFollowing(String userId) async {
    try {
      final follows = await remoteDataSource.getFollowing(userId);
      return Right(follows.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getFollowerCount(String userId) async {
    try {
      final count = await remoteDataSource.getFollowerCount(userId);
      return Right(count);
    } catch (e) {
      return const Right(0);
    }
  }

  @override
  Future<Either<Failure, int>> getFollowingCount(String userId) async {
    try {
      final count = await remoteDataSource.getFollowingCount(userId);
      return Right(count);
    } catch (e) {
      return const Right(0);
    }
  }

  // ==================== EVENT ATTENDEES ====================

  @override
  Future<Either<Failure, List<EventAttendee>>> getEventAttendees(String eventId) async {
    try {
      final attendees = await remoteDataSource.getEventAttendees(eventId);
      return Right(attendees.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventAttendee>> updateAttendanceStatus({
    required String eventId,
    required String userId,
    required String status,
  }) async {
    try {
      final attendee = await remoteDataSource.updateAttendanceStatus(
        eventId: eventId,
        userId: userId,
        status: status,
      );
      return Right(attendee.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventAttendee?>> getAttendanceStatus({
    required String eventId,
    required String userId,
  }) async {
    try {
      final attendee = await remoteDataSource.getAttendanceStatus(
        eventId: eventId,
        userId: userId,
      );
      return Right(attendee?.toEntity());
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, int>> getGoingCount(String eventId) async {
    try {
      final count = await remoteDataSource.getGoingCount(eventId);
      return Right(count);
    } catch (e) {
      return const Right(0);
    }
  }

  @override
  Future<Either<Failure, int>> getInterestedCount(String eventId) async {
    try {
      final count = await remoteDataSource.getInterestedCount(eventId);
      return Right(count);
    } catch (e) {
      return const Right(0);
    }
  }
}
