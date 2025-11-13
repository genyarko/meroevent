import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/social_remote_datasource.dart';
import '../../data/repositories/social_repository_impl.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/social_repository.dart';
import '../../domain/usecases/social/create_event_review.dart';
import '../../domain/usecases/social/get_event_reviews.dart';
import '../../domain/usecases/social/follow_user.dart';
import '../../domain/usecases/social/unfollow_user.dart';
import '../../domain/usecases/social/update_attendance_status.dart';
import '../../domain/usecases/social/get_event_attendees.dart';
import 'auth_provider.dart';

/// Provider for SocialRemoteDataSource
final socialRemoteDataSourceProvider = Provider<SocialRemoteDataSource>((ref) {
  return SocialRemoteDataSourceImpl();
});

/// Provider for SocialRepository
final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepositoryImpl(
    remoteDataSource: ref.watch(socialRemoteDataSourceProvider),
  );
});

// ==================== USE CASE PROVIDERS ====================

/// Provider for CreateEventReview use case
final createEventReviewUseCaseProvider = Provider<CreateEventReview>((ref) {
  return CreateEventReview(ref.watch(socialRepositoryProvider));
});

/// Provider for GetEventReviews use case
final getEventReviewsUseCaseProvider = Provider<GetEventReviews>((ref) {
  return GetEventReviews(ref.watch(socialRepositoryProvider));
});

/// Provider for FollowUser use case
final followUserUseCaseProvider = Provider<FollowUser>((ref) {
  return FollowUser(ref.watch(socialRepositoryProvider));
});

/// Provider for UnfollowUser use case
final unfollowUserUseCaseProvider = Provider<UnfollowUser>((ref) {
  return UnfollowUser(ref.watch(socialRepositoryProvider));
});

/// Provider for UpdateAttendanceStatus use case
final updateAttendanceStatusUseCaseProvider = Provider<UpdateAttendanceStatus>((ref) {
  return UpdateAttendanceStatus(ref.watch(socialRepositoryProvider));
});

/// Provider for GetEventAttendees use case
final getEventAttendeesUseCaseProvider = Provider<GetEventAttendees>((ref) {
  return GetEventAttendees(ref.watch(socialRepositoryProvider));
});

// ==================== DATA PROVIDERS ====================

/// Provider for event reviews
final eventReviewsProvider = FutureProvider.autoDispose.family<List<EventReview>, String>(
  (ref, eventId) async {
    final repository = ref.watch(socialRepositoryProvider);
    final result = await repository.getEventReviews(eventId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (reviews) => reviews,
    );
  },
);

/// Provider for event rating summary
final eventRatingSummaryProvider = FutureProvider.autoDispose.family<EventRatingSummary, String>(
  (ref, eventId) async {
    final repository = ref.watch(socialRepositoryProvider);
    final result = await repository.getEventRatingSummary(eventId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (summary) => summary,
    );
  },
);

/// Provider for event attendees
final eventAttendeesProvider = FutureProvider.autoDispose.family<List<EventAttendee>, String>(
  (ref, eventId) async {
    final repository = ref.watch(socialRepositoryProvider);
    final result = await repository.getEventAttendees(eventId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (attendees) => attendees,
    );
  },
);

/// Provider for event going count
final eventGoingCountProvider = FutureProvider.autoDispose.family<int, String>(
  (ref, eventId) async {
    final repository = ref.watch(socialRepositoryProvider);
    final result = await repository.getGoingCount(eventId);

    return result.fold(
      (failure) => 0,
      (count) => count,
    );
  },
);

/// Provider for event interested count
final eventInterestedCountProvider = FutureProvider.autoDispose.family<int, String>(
  (ref, eventId) async {
    final repository = ref.watch(socialRepositoryProvider);
    final result = await repository.getInterestedCount(eventId);

    return result.fold(
      (failure) => 0,
      (count) => count,
    );
  },
);

/// Provider for user's attendance status for an event
final userAttendanceStatusProvider =
    FutureProvider.autoDispose.family<EventAttendee?, String>(
  (ref, eventId) async {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return null;

    final repository = ref.watch(socialRepositoryProvider);
    final result = await repository.getAttendanceStatus(
      eventId: eventId,
      userId: user.id,
    );

    return result.fold(
      (failure) => null,
      (attendee) => attendee,
    );
  },
);

/// Provider for checking if user is following someone
final isFollowingProvider =
    FutureProvider.autoDispose.family<bool, String>(
  (ref, followingId) async {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return false;

    final repository = ref.watch(socialRepositoryProvider);
    final result = await repository.isFollowing(
      followerId: user.id,
      followingId: followingId,
    );

    return result.fold(
      (failure) => false,
      (isFollowing) => isFollowing,
    );
  },
);

/// Provider for organizer reviews
final organizerReviewsProvider = FutureProvider.autoDispose.family<List<OrganizerReview>, String>(
  (ref, organizerId) async {
    final repository = ref.watch(socialRepositoryProvider);
    final result = await repository.getOrganizerReviews(organizerId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (reviews) => reviews,
    );
  },
);

// ==================== STATE NOTIFIERS ====================

/// Review submission state
class ReviewSubmissionState {
  final bool isLoading;
  final String? error;
  final EventReview? submittedReview;

  const ReviewSubmissionState({
    this.isLoading = false,
    this.error,
    this.submittedReview,
  });

  ReviewSubmissionState copyWith({
    bool? isLoading,
    String? error,
    EventReview? submittedReview,
  }) {
    return ReviewSubmissionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      submittedReview: submittedReview ?? this.submittedReview,
    );
  }
}

/// Review submission notifier
class ReviewSubmissionNotifier extends StateNotifier<ReviewSubmissionState> {
  final SocialRepository _repository;

  ReviewSubmissionNotifier(this._repository) : super(const ReviewSubmissionState());

  Future<bool> submitReview({
    required String eventId,
    required String userId,
    required int rating,
    String? comment,
    List<String>? imageUrls,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.createEventReview(
        eventId: eventId,
        userId: userId,
        rating: rating,
        comment: comment,
        imageUrls: imageUrls,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
          return false;
        },
        (review) {
          state = state.copyWith(
            isLoading: false,
            submittedReview: review,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = const ReviewSubmissionState();
  }
}

/// Provider for review submission
final reviewSubmissionProvider = StateNotifierProvider.autoDispose<ReviewSubmissionNotifier, ReviewSubmissionState>(
  (ref) {
    final repository = ref.watch(socialRepositoryProvider);
    return ReviewSubmissionNotifier(repository);
  },
);

/// Attendance state
class AttendanceState {
  final bool isLoading;
  final String? error;
  final EventAttendee? currentStatus;

  const AttendanceState({
    this.isLoading = false,
    this.error,
    this.currentStatus,
  });

  AttendanceState copyWith({
    bool? isLoading,
    String? error,
    EventAttendee? currentStatus,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentStatus: currentStatus ?? this.currentStatus,
    );
  }
}

/// Attendance notifier
class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final SocialRepository _repository;
  final String _userId;

  AttendanceNotifier({
    required SocialRepository repository,
    required String userId,
  })  : _repository = repository,
        _userId = userId,
        super(const AttendanceState());

  Future<bool> updateStatus(String eventId, String status) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.updateAttendanceStatus(
        eventId: eventId,
        userId: _userId,
        status: status,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
          return false;
        },
        (attendee) {
          state = state.copyWith(
            isLoading: false,
            currentStatus: attendee,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = const AttendanceState();
  }
}

/// Provider for attendance management
final attendanceProvider = StateNotifierProvider.autoDispose<AttendanceNotifier, AttendanceState>(
  (ref) {
    final repository = ref.watch(socialRepositoryProvider);
    final user = ref.watch(currentUserProvider).value;

    if (user == null) {
      throw Exception('User must be authenticated');
    }

    return AttendanceNotifier(
      repository: repository,
      userId: user.id,
    );
  },
);

/// Follow state
class FollowState {
  final bool isLoading;
  final String? error;
  final bool isFollowing;

  const FollowState({
    this.isLoading = false,
    this.error,
    this.isFollowing = false,
  });

  FollowState copyWith({
    bool? isLoading,
    String? error,
    bool? isFollowing,
  }) {
    return FollowState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

/// Follow notifier
class FollowNotifier extends StateNotifier<FollowState> {
  final SocialRepository _repository;
  final String _userId;

  FollowNotifier({
    required SocialRepository repository,
    required String userId,
  })  : _repository = repository,
        _userId = userId,
        super(const FollowState());

  Future<void> checkFollowStatus(String followingId) async {
    final result = await _repository.isFollowing(
      followerId: _userId,
      followingId: followingId,
    );

    result.fold(
      (failure) => state = state.copyWith(isFollowing: false),
      (isFollowing) => state = state.copyWith(isFollowing: isFollowing),
    );
  }

  Future<bool> toggleFollow(String followingId, String followType) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      if (state.isFollowing) {
        // Unfollow
        final result = await _repository.unfollowUser(
          followerId: _userId,
          followingId: followingId,
        );

        return result.fold(
          (failure) {
            state = state.copyWith(
              isLoading: false,
              error: failure.message,
            );
            return false;
          },
          (_) {
            state = state.copyWith(
              isLoading: false,
              isFollowing: false,
            );
            return true;
          },
        );
      } else {
        // Follow
        final result = await _repository.followUser(
          followerId: _userId,
          followingId: followingId,
          followType: followType,
        );

        return result.fold(
          (failure) {
            state = state.copyWith(
              isLoading: false,
              error: failure.message,
            );
            return false;
          },
          (_) {
            state = state.copyWith(
              isLoading: false,
              isFollowing: true,
            );
            return true;
          },
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
}

/// Provider for follow management
final followProvider = StateNotifierProvider.autoDispose.family<FollowNotifier, FollowState, String>(
  (ref, followingId) {
    final repository = ref.watch(socialRepositoryProvider);
    final user = ref.watch(currentUserProvider).value;

    if (user == null) {
      throw Exception('User must be authenticated');
    }

    final notifier = FollowNotifier(
      repository: repository,
      userId: user.id,
    );

    // Check initial follow status
    notifier.checkFollowStatus(followingId);

    return notifier;
  },
);
