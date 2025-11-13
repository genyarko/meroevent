import 'package:equatable/equatable.dart';

/// Event review entity
class EventReview extends Equatable {
  final String id;
  final String eventId;
  final String userId;
  final String? userName;
  final String? userAvatarUrl;
  final int rating; // 1-5 stars
  final String? comment;
  final List<String>? imageUrls;

  // Engagement
  final int helpfulCount;
  final bool isVerifiedAttendee; // Only attendees can review

  // Moderation
  final bool isVisible;
  final String? moderationStatus; // approved, pending, rejected
  final String? rejectionReason;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventReview({
    required this.id,
    required this.eventId,
    required this.userId,
    this.userName,
    this.userAvatarUrl,
    required this.rating,
    this.comment,
    this.imageUrls,
    this.helpfulCount = 0,
    this.isVerifiedAttendee = false,
    this.isVisible = true,
    this.moderationStatus,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper methods
  bool get hasComment => comment != null && comment!.isNotEmpty;
  bool get hasImages => imageUrls != null && imageUrls!.isNotEmpty;
  String get displayName => userName ?? 'Anonymous User';

  @override
  List<Object?> get props => [
        id,
        eventId,
        userId,
        userName,
        userAvatarUrl,
        rating,
        comment,
        imageUrls,
        helpfulCount,
        isVerifiedAttendee,
        isVisible,
        moderationStatus,
        rejectionReason,
        createdAt,
        updatedAt,
      ];
}

/// Organizer review entity
class OrganizerReview extends Equatable {
  final String id;
  final String organizerId;
  final String userId;
  final String? userName;
  final String? userAvatarUrl;
  final int rating; // 1-5 stars
  final String? comment;

  // Categories (granular feedback)
  final int? communicationRating;
  final int? professionalismRating;
  final int? venueRating;
  final int? valueRating;

  // Engagement
  final int helpfulCount;

  // Moderation
  final bool isVisible;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrganizerReview({
    required this.id,
    required this.organizerId,
    required this.userId,
    this.userName,
    this.userAvatarUrl,
    required this.rating,
    this.comment,
    this.communicationRating,
    this.professionalismRating,
    this.venueRating,
    this.valueRating,
    this.helpfulCount = 0,
    this.isVisible = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper methods
  bool get hasComment => comment != null && comment!.isNotEmpty;
  String get displayName => userName ?? 'Anonymous User';

  @override
  List<Object?> get props => [
        id,
        organizerId,
        userId,
        userName,
        userAvatarUrl,
        rating,
        comment,
        communicationRating,
        professionalismRating,
        venueRating,
        valueRating,
        helpfulCount,
        isVisible,
        createdAt,
        updatedAt,
      ];
}

/// Event rating summary
class EventRatingSummary extends Equatable {
  final String eventId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // {5: 10, 4: 5, 3: 2, 2: 1, 1: 0}

  const EventRatingSummary({
    required this.eventId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  // Helper methods
  bool get hasReviews => totalReviews > 0;

  int getRatingCount(int stars) => ratingDistribution[stars] ?? 0;

  double getRatingPercentage(int stars) {
    if (totalReviews == 0) return 0.0;
    return (getRatingCount(stars) / totalReviews) * 100;
  }

  @override
  List<Object?> get props => [
        eventId,
        averageRating,
        totalReviews,
        ratingDistribution,
      ];
}

/// User follow entity
class UserFollow extends Equatable {
  final String id;
  final String followerId; // User who is following
  final String followingId; // User/organizer being followed
  final String followType; // 'user' or 'organizer'
  final DateTime createdAt;

  const UserFollow({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.followType,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        followerId,
        followingId,
        followType,
        createdAt,
      ];
}

/// Event attendee entity
class EventAttendee extends Equatable {
  final String id;
  final String eventId;
  final String userId;
  final String? userName;
  final String? userAvatarUrl;
  final String status; // 'going', 'interested', 'not_going'
  final bool hasTicket;
  final bool isCheckedIn;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventAttendee({
    required this.id,
    required this.eventId,
    required this.userId,
    this.userName,
    this.userAvatarUrl,
    required this.status,
    this.hasTicket = false,
    this.isCheckedIn = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper methods
  bool get isGoing => status == 'going';
  bool get isInterested => status == 'interested';
  String get displayName => userName ?? 'Anonymous User';

  @override
  List<Object?> get props => [
        id,
        eventId,
        userId,
        userName,
        userAvatarUrl,
        status,
        hasTicket,
        isCheckedIn,
        createdAt,
        updatedAt,
      ];
}
