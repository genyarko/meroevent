import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/review.dart';

part 'review_model.g.dart';

/// Event review data model
@JsonSerializable()
class EventReviewModel {
  final String id;
  @JsonKey(name: 'event_id')
  final String eventId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'user_name')
  final String? userName;
  @JsonKey(name: 'user_avatar_url')
  final String? userAvatarUrl;
  final int rating;
  final String? comment;
  @JsonKey(name: 'image_urls')
  final List<String>? imageUrls;
  @JsonKey(name: 'helpful_count')
  final int helpfulCount;
  @JsonKey(name: 'is_verified_attendee')
  final bool isVerifiedAttendee;
  @JsonKey(name: 'is_visible')
  final bool isVisible;
  @JsonKey(name: 'moderation_status')
  final String? moderationStatus;
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const EventReviewModel({
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

  /// Convert to domain entity
  EventReview toEntity() {
    return EventReview(
      id: id,
      eventId: eventId,
      userId: userId,
      userName: userName,
      userAvatarUrl: userAvatarUrl,
      rating: rating,
      comment: comment,
      imageUrls: imageUrls,
      helpfulCount: helpfulCount,
      isVerifiedAttendee: isVerifiedAttendee,
      isVisible: isVisible,
      moderationStatus: moderationStatus,
      rejectionReason: rejectionReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory EventReviewModel.fromEntity(EventReview entity) {
    return EventReviewModel(
      id: entity.id,
      eventId: entity.eventId,
      userId: entity.userId,
      userName: entity.userName,
      userAvatarUrl: entity.userAvatarUrl,
      rating: entity.rating,
      comment: entity.comment,
      imageUrls: entity.imageUrls,
      helpfulCount: entity.helpfulCount,
      isVerifiedAttendee: entity.isVerifiedAttendee,
      isVisible: entity.isVisible,
      moderationStatus: entity.moderationStatus,
      rejectionReason: entity.rejectionReason,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory EventReviewModel.fromJson(Map<String, dynamic> json) =>
      _$EventReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewModelToJson(this);
}

/// Organizer review data model
@JsonSerializable()
class OrganizerReviewModel {
  final String id;
  @JsonKey(name: 'organizer_id')
  final String organizerId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'user_name')
  final String? userName;
  @JsonKey(name: 'user_avatar_url')
  final String? userAvatarUrl;
  final int rating;
  final String? comment;
  @JsonKey(name: 'communication_rating')
  final int? communicationRating;
  @JsonKey(name: 'professionalism_rating')
  final int? professionalismRating;
  @JsonKey(name: 'venue_rating')
  final int? venueRating;
  @JsonKey(name: 'value_rating')
  final int? valueRating;
  @JsonKey(name: 'helpful_count')
  final int helpfulCount;
  @JsonKey(name: 'is_visible')
  final bool isVisible;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const OrganizerReviewModel({
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

  /// Convert to domain entity
  OrganizerReview toEntity() {
    return OrganizerReview(
      id: id,
      organizerId: organizerId,
      userId: userId,
      userName: userName,
      userAvatarUrl: userAvatarUrl,
      rating: rating,
      comment: comment,
      communicationRating: communicationRating,
      professionalismRating: professionalismRating,
      venueRating: venueRating,
      valueRating: valueRating,
      helpfulCount: helpfulCount,
      isVisible: isVisible,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory OrganizerReviewModel.fromJson(Map<String, dynamic> json) =>
      _$OrganizerReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizerReviewModelToJson(this);
}

/// Event attendee data model
@JsonSerializable()
class EventAttendeeModel {
  final String id;
  @JsonKey(name: 'event_id')
  final String eventId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'user_name')
  final String? userName;
  @JsonKey(name: 'user_avatar_url')
  final String? userAvatarUrl;
  final String status;
  @JsonKey(name: 'has_ticket')
  final bool hasTicket;
  @JsonKey(name: 'is_checked_in')
  final bool isCheckedIn;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const EventAttendeeModel({
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

  /// Convert to domain entity
  EventAttendee toEntity() {
    return EventAttendee(
      id: id,
      eventId: eventId,
      userId: userId,
      userName: userName,
      userAvatarUrl: userAvatarUrl,
      status: status,
      hasTicket: hasTicket,
      isCheckedIn: isCheckedIn,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory EventAttendeeModel.fromJson(Map<String, dynamic> json) =>
      _$EventAttendeeModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventAttendeeModelToJson(this);
}

/// User follow data model
@JsonSerializable()
class UserFollowModel {
  final String id;
  @JsonKey(name: 'follower_id')
  final String followerId;
  @JsonKey(name: 'following_id')
  final String followingId;
  @JsonKey(name: 'follow_type')
  final String followType;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const UserFollowModel({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.followType,
    required this.createdAt,
  });

  /// Convert to domain entity
  UserFollow toEntity() {
    return UserFollow(
      id: id,
      followerId: followerId,
      followingId: followingId,
      followType: followType,
      createdAt: createdAt,
    );
  }

  factory UserFollowModel.fromJson(Map<String, dynamic> json) =>
      _$UserFollowModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserFollowModelToJson(this);
}
