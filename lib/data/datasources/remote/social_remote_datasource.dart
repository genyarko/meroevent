import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/review_model.dart';

/// Social remote data source interface
abstract class SocialRemoteDataSource {
  // Event Reviews
  Future<List<EventReviewModel>> getEventReviews(String eventId);
  Future<EventReviewModel> createEventReview({
    required String eventId,
    required String userId,
    required int rating,
    String? comment,
    List<String>? imageUrls,
  });
  Future<EventReviewModel> updateEventReview({
    required String reviewId,
    required int rating,
    String? comment,
    List<String>? imageUrls,
  });
  Future<void> deleteEventReview(String reviewId);
  Future<void> markReviewHelpful(String reviewId);

  // Organizer Reviews
  Future<List<OrganizerReviewModel>> getOrganizerReviews(String organizerId);
  Future<OrganizerReviewModel> createOrganizerReview({
    required String organizerId,
    required String userId,
    required int rating,
    String? comment,
    int? communicationRating,
    int? professionalismRating,
    int? venueRating,
    int? valueRating,
  });

  // Follows
  Future<UserFollowModel> followUser({
    required String followerId,
    required String followingId,
    required String followType,
  });
  Future<void> unfollowUser({
    required String followerId,
    required String followingId,
  });
  Future<bool> isFollowing({
    required String followerId,
    required String followingId,
  });
  Future<List<UserFollowModel>> getFollowers(String userId);
  Future<List<UserFollowModel>> getFollowing(String userId);
  Future<int> getFollowerCount(String userId);
  Future<int> getFollowingCount(String userId);

  // Event Attendees
  Future<List<EventAttendeeModel>> getEventAttendees(String eventId);
  Future<EventAttendeeModel> updateAttendanceStatus({
    required String eventId,
    required String userId,
    required String status,
  });
  Future<EventAttendeeModel?> getAttendanceStatus({
    required String eventId,
    required String userId,
  });
  Future<int> getGoingCount(String eventId);
  Future<int> getInterestedCount(String eventId);
}

/// Social remote data source implementation
class SocialRemoteDataSourceImpl implements SocialRemoteDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== EVENT REVIEWS ====================

  @override
  Future<List<EventReviewModel>> getEventReviews(String eventId) async {
    try {
      final response = await _supabase
          .from('event_reviews')
          .select('''
            *,
            profiles:user_id (
              full_name,
              avatar_url
            )
          ''')
          .eq('event_id', eventId)
          .eq('is_visible', true)
          .order('created_at', ascending: false);

      final reviews = (response as List).map((json) {
        // Merge profile data
        if (json['profiles'] != null) {
          json['user_name'] = json['profiles']['full_name'];
          json['user_avatar_url'] = json['profiles']['avatar_url'];
        }
        return EventReviewModel.fromJson(json);
      }).toList();

      return reviews;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch event reviews: ${e.toString()}');
    }
  }

  @override
  Future<EventReviewModel> createEventReview({
    required String eventId,
    required String userId,
    required int rating,
    String? comment,
    List<String>? imageUrls,
  }) async {
    try {
      final response = await _supabase
          .from('event_reviews')
          .insert({
            'event_id': eventId,
            'user_id': userId,
            'rating': rating,
            'comment': comment,
            'image_urls': imageUrls,
            'is_verified_attendee': true, // TODO: Check from tickets
          })
          .select()
          .single();

      return EventReviewModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to create review: ${e.toString()}');
    }
  }

  @override
  Future<EventReviewModel> updateEventReview({
    required String reviewId,
    required int rating,
    String? comment,
    List<String>? imageUrls,
  }) async {
    try {
      final response = await _supabase
          .from('event_reviews')
          .update({
            'rating': rating,
            'comment': comment,
            'image_urls': imageUrls,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reviewId)
          .select()
          .single();

      return EventReviewModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to update review: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteEventReview(String reviewId) async {
    try {
      await _supabase.from('event_reviews').delete().eq('id', reviewId);
    } catch (e) {
      throw ServerException(message: 'Failed to delete review: ${e.toString()}');
    }
  }

  @override
  Future<void> markReviewHelpful(String reviewId) async {
    try {
      await _supabase.rpc('increment_review_helpful', params: {'review_id': reviewId});
    } catch (e) {
      throw ServerException(message: 'Failed to mark review helpful: ${e.toString()}');
    }
  }

  // ==================== ORGANIZER REVIEWS ====================

  @override
  Future<List<OrganizerReviewModel>> getOrganizerReviews(String organizerId) async {
    try {
      final response = await _supabase
          .from('organizer_reviews')
          .select('''
            *,
            profiles:user_id (
              full_name,
              avatar_url
            )
          ''')
          .eq('organizer_id', organizerId)
          .eq('is_visible', true)
          .order('created_at', ascending: false);

      final reviews = (response as List).map((json) {
        if (json['profiles'] != null) {
          json['user_name'] = json['profiles']['full_name'];
          json['user_avatar_url'] = json['profiles']['avatar_url'];
        }
        return OrganizerReviewModel.fromJson(json);
      }).toList();

      return reviews;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch organizer reviews: ${e.toString()}');
    }
  }

  @override
  Future<OrganizerReviewModel> createOrganizerReview({
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
      final response = await _supabase
          .from('organizer_reviews')
          .insert({
            'organizer_id': organizerId,
            'user_id': userId,
            'rating': rating,
            'comment': comment,
            'communication_rating': communicationRating,
            'professionalism_rating': professionalismRating,
            'venue_rating': venueRating,
            'value_rating': valueRating,
          })
          .select()
          .single();

      return OrganizerReviewModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to create organizer review: ${e.toString()}');
    }
  }

  // ==================== FOLLOWS ====================

  @override
  Future<UserFollowModel> followUser({
    required String followerId,
    required String followingId,
    required String followType,
  }) async {
    try {
      final response = await _supabase
          .from('user_follows')
          .insert({
            'follower_id': followerId,
            'following_id': followingId,
            'follow_type': followType,
          })
          .select()
          .single();

      return UserFollowModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to follow user: ${e.toString()}');
    }
  }

  @override
  Future<void> unfollowUser({
    required String followerId,
    required String followingId,
  }) async {
    try {
      await _supabase
          .from('user_follows')
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', followingId);
    } catch (e) {
      throw ServerException(message: 'Failed to unfollow user: ${e.toString()}');
    }
  }

  @override
  Future<bool> isFollowing({
    required String followerId,
    required String followingId,
  }) async {
    try {
      final response = await _supabase
          .from('user_follows')
          .select('id')
          .eq('follower_id', followerId)
          .eq('following_id', followingId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<UserFollowModel>> getFollowers(String userId) async {
    try {
      final response = await _supabase
          .from('user_follows')
          .select()
          .eq('following_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => UserFollowModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch followers: ${e.toString()}');
    }
  }

  @override
  Future<List<UserFollowModel>> getFollowing(String userId) async {
    try {
      final response = await _supabase
          .from('user_follows')
          .select()
          .eq('follower_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => UserFollowModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch following: ${e.toString()}');
    }
  }

  @override
  Future<int> getFollowerCount(String userId) async {
    try {
      final response = await _supabase
          .from('user_follows')
          .select('id')
          .eq('following_id', userId)
          .count();

      return response.count;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> getFollowingCount(String userId) async {
    try {
      final response = await _supabase
          .from('user_follows')
          .select('id')
          .eq('follower_id', userId)
          .count();

      return response.count;
    } catch (e) {
      return 0;
    }
  }

  // ==================== EVENT ATTENDEES ====================

  @override
  Future<List<EventAttendeeModel>> getEventAttendees(String eventId) async {
    try {
      final response = await _supabase
          .from('event_attendees')
          .select('''
            *,
            profiles:user_id (
              full_name,
              avatar_url
            )
          ''')
          .eq('event_id', eventId)
          .eq('status', 'going')
          .order('created_at', ascending: false);

      final attendees = (response as List).map((json) {
        if (json['profiles'] != null) {
          json['user_name'] = json['profiles']['full_name'];
          json['user_avatar_url'] = json['profiles']['avatar_url'];
        }
        return EventAttendeeModel.fromJson(json);
      }).toList();

      return attendees;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch attendees: ${e.toString()}');
    }
  }

  @override
  Future<EventAttendeeModel> updateAttendanceStatus({
    required String eventId,
    required String userId,
    required String status,
  }) async {
    try {
      // Check if record exists
      final existing = await _supabase
          .from('event_attendees')
          .select('id')
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .maybeSingle();

      final response = existing != null
          ? await _supabase
              .from('event_attendees')
              .update({
                'status': status,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('event_id', eventId)
              .eq('user_id', userId)
              .select()
              .single()
          : await _supabase
              .from('event_attendees')
              .insert({
                'event_id': eventId,
                'user_id': userId,
                'status': status,
              })
              .select()
              .single();

      return EventAttendeeModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to update attendance: ${e.toString()}');
    }
  }

  @override
  Future<EventAttendeeModel?> getAttendanceStatus({
    required String eventId,
    required String userId,
  }) async {
    try {
      final response = await _supabase
          .from('event_attendees')
          .select()
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null ? EventAttendeeModel.fromJson(response) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> getGoingCount(String eventId) async {
    try {
      final response = await _supabase
          .from('event_attendees')
          .select('id')
          .eq('event_id', eventId)
          .eq('status', 'going')
          .count();

      return response.count;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> getInterestedCount(String eventId) async {
    try {
      final response = await _supabase
          .from('event_attendees')
          .select('id')
          .eq('event_id', eventId)
          .eq('status', 'interested')
          .count();

      return response.count;
    } catch (e) {
      return 0;
    }
  }
}
