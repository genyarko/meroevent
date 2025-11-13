import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/review.dart';

/// Social repository interface
/// Defines all social-related operations (reviews, follows, attendees)
abstract class SocialRepository {
  // ==================== EVENT REVIEWS ====================

  /// Get reviews for an event
  Future<Either<Failure, List<EventReview>>> getEventReviews(String eventId);

  /// Get a single event review
  Future<Either<Failure, EventReview>> getEventReview(String reviewId);

  /// Create event review (must be verified attendee)
  Future<Either<Failure, EventReview>> createEventReview({
    required String eventId,
    required String userId,
    required int rating,
    String? comment,
    List<String>? imageUrls,
  });

  /// Update event review
  Future<Either<Failure, EventReview>> updateEventReview({
    required String reviewId,
    required int rating,
    String? comment,
    List<String>? imageUrls,
  });

  /// Delete event review
  Future<Either<Failure, void>> deleteEventReview(String reviewId);

  /// Mark review as helpful
  Future<Either<Failure, void>> markReviewHelpful(String reviewId);

  /// Get event rating summary
  Future<Either<Failure, EventRatingSummary>> getEventRatingSummary(String eventId);

  // ==================== ORGANIZER REVIEWS ====================

  /// Get reviews for an organizer
  Future<Either<Failure, List<OrganizerReview>>> getOrganizerReviews(String organizerId);

  /// Create organizer review
  Future<Either<Failure, OrganizerReview>> createOrganizerReview({
    required String organizerId,
    required String userId,
    required int rating,
    String? comment,
    int? communicationRating,
    int? professionalismRating,
    int? venueRating,
    int? valueRating,
  });

  /// Get organizer average rating
  Future<Either<Failure, double>> getOrganizerAverageRating(String organizerId);

  // ==================== FOLLOWS ====================

  /// Follow a user or organizer
  Future<Either<Failure, UserFollow>> followUser({
    required String followerId,
    required String followingId,
    required String followType, // 'user' or 'organizer'
  });

  /// Unfollow a user or organizer
  Future<Either<Failure, void>> unfollowUser({
    required String followerId,
    required String followingId,
  });

  /// Check if user is following
  Future<Either<Failure, bool>> isFollowing({
    required String followerId,
    required String followingId,
  });

  /// Get followers for a user/organizer
  Future<Either<Failure, List<UserFollow>>> getFollowers(String userId);

  /// Get users/organizers that a user is following
  Future<Either<Failure, List<UserFollow>>> getFollowing(String userId);

  /// Get follower count
  Future<Either<Failure, int>> getFollowerCount(String userId);

  /// Get following count
  Future<Either<Failure, int>> getFollowingCount(String userId);

  // ==================== EVENT ATTENDEES ====================

  /// Get attendees for an event
  Future<Either<Failure, List<EventAttendee>>> getEventAttendees(String eventId);

  /// Update attendance status (going, interested, not_going)
  Future<Either<Failure, EventAttendee>> updateAttendanceStatus({
    required String eventId,
    required String userId,
    required String status,
  });

  /// Get user's attendance status for an event
  Future<Either<Failure, EventAttendee?>> getAttendanceStatus({
    required String eventId,
    required String userId,
  });

  /// Get going count for an event
  Future<Either<Failure, int>> getGoingCount(String eventId);

  /// Get interested count for an event
  Future<Either<Failure, int>> getInterestedCount(String eventId);
}
