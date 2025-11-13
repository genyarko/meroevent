import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/event_remote_datasource.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/usecases/event/create_event.dart';
import '../../domain/usecases/event/get_event_by_id.dart';
import '../../domain/usecases/event/get_events.dart';
import '../../domain/usecases/event/get_featured_events.dart';
import '../../domain/usecases/event/toggle_event_like.dart';
import '../../domain/usecases/event/toggle_event_favorite.dart';
import '../../domain/usecases/event/share_event.dart';
import '../../domain/usecases/event/check_event_like.dart';
import '../../domain/usecases/event/check_event_favorite.dart';
import '../../domain/usecases/event/get_favorite_events.dart';
import '../../domain/usecases/event/update_attendee_status.dart';
import '../providers/auth_provider.dart';

/// Provider for EventRemoteDataSource
final eventRemoteDataSourceProvider = Provider<EventRemoteDataSource>((ref) {
  return EventRemoteDataSourceImpl();
});

/// Provider for EventRepository
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl(
    remoteDataSource: ref.watch(eventRemoteDataSourceProvider),
  );
});

/// Provider for GetEvents use case
final getEventsUseCaseProvider = Provider<GetEvents>((ref) {
  return GetEvents(ref.watch(eventRepositoryProvider));
});

/// Provider for GetEventById use case
final getEventByIdUseCaseProvider = Provider<GetEventById>((ref) {
  return GetEventById(ref.watch(eventRepositoryProvider));
});

/// Provider for GetFeaturedEvents use case
final getFeaturedEventsUseCaseProvider = Provider<GetFeaturedEvents>((ref) {
  return GetFeaturedEvents(ref.watch(eventRepositoryProvider));
});

/// Provider for CreateEvent use case
final createEventUseCaseProvider = Provider<CreateEvent>((ref) {
  return CreateEvent(ref.watch(eventRepositoryProvider));
});

/// Provider for ToggleEventLike use case
final toggleEventLikeUseCaseProvider = Provider<ToggleEventLike>((ref) {
  return ToggleEventLike(repository: ref.watch(eventRepositoryProvider));
});

/// Provider for ToggleEventFavorite use case
final toggleEventFavoriteUseCaseProvider = Provider<ToggleEventFavorite>((ref) {
  return ToggleEventFavorite(repository: ref.watch(eventRepositoryProvider));
});

/// Provider for ShareEvent use case
final shareEventUseCaseProvider = Provider<ShareEvent>((ref) {
  return ShareEvent(repository: ref.watch(eventRepositoryProvider));
});

/// Provider for CheckEventLike use case
final checkEventLikeUseCaseProvider = Provider<CheckEventLike>((ref) {
  return CheckEventLike(repository: ref.watch(eventRepositoryProvider));
});

/// Provider for CheckEventFavorite use case
final checkEventFavoriteUseCaseProvider = Provider<CheckEventFavorite>((ref) {
  return CheckEventFavorite(repository: ref.watch(eventRepositoryProvider));
});

/// Provider for GetFavoriteEvents use case
final getFavoriteEventsUseCaseProvider = Provider<GetFavoriteEvents>((ref) {
  return GetFavoriteEvents(repository: ref.watch(eventRepositoryProvider));
});

/// Provider for UpdateAttendeeStatus use case
final updateAttendeeStatusUseCaseProvider = Provider<UpdateAttendeeStatus>((ref) {
  return UpdateAttendeeStatus(repository: ref.watch(eventRepositoryProvider));
});

/// Provider for featured events
final featuredEventsProvider = FutureProvider<List<Event>>((ref) async {
  final useCase = ref.watch(getFeaturedEventsUseCaseProvider);
  final result = await useCase(limit: 10);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (events) => events,
  );
});

/// Provider for events with filters
final eventsProvider = FutureProvider.autoDispose.family<List<Event>, EventFilters>(
  (ref, filters) async {
    final useCase = ref.watch(getEventsUseCaseProvider);
    final result = await useCase(
      category: filters.category,
      search: filters.search,
      status: filters.status,
      latitude: filters.latitude,
      longitude: filters.longitude,
      radiusKm: filters.radiusKm,
      startDate: filters.startDate,
      endDate: filters.endDate,
      limit: filters.limit,
      offset: filters.offset,
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (events) => events,
    );
  },
);

/// Provider for a single event by ID
final eventByIdProvider = FutureProvider.autoDispose.family<Event, String>(
  (ref, eventId) async {
    final useCase = ref.watch(getEventByIdUseCaseProvider);
    final result = await useCase(eventId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (event) => event,
    );
  },
);

/// Event state notifier provider
final eventStateProvider = StateNotifierProvider<EventStateNotifier, EventState>((ref) {
  return EventStateNotifier(ref.watch(eventRepositoryProvider));
});

/// Event filters class
class EventFilters {
  final String? category;
  final String? search;
  final String? status;
  final double? latitude;
  final double? longitude;
  final int? radiusKm;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;
  final int? offset;

  const EventFilters({
    this.category,
    this.search,
    this.status,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.startDate,
    this.endDate,
    this.limit = 20,
    this.offset = 0,
  });

  EventFilters copyWith({
    String? category,
    String? search,
    String? status,
    double? latitude,
    double? longitude,
    int? radiusKm,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) {
    return EventFilters(
      category: category ?? this.category,
      search: search ?? this.search,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}

/// Event state
class EventState {
  final List<Event> events;
  final bool isLoading;
  final String? errorMessage;
  final EventFilters filters;

  const EventState({
    this.events = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filters = const EventFilters(),
  });

  EventState copyWith({
    List<Event>? events,
    bool? isLoading,
    String? errorMessage,
    EventFilters? filters,
  }) {
    return EventState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      filters: filters ?? this.filters,
    );
  }
}

/// Event state notifier
class EventStateNotifier extends StateNotifier<EventState> {
  final EventRepository _repository;

  EventStateNotifier(this._repository) : super(const EventState());

  Future<void> loadEvents({EventFilters? filters}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final effectiveFilters = filters ?? state.filters;

    final result = await _repository.getEvents(
      category: effectiveFilters.category,
      search: effectiveFilters.search,
      status: effectiveFilters.status,
      latitude: effectiveFilters.latitude,
      longitude: effectiveFilters.longitude,
      radiusKm: effectiveFilters.radiusKm,
      startDate: effectiveFilters.startDate,
      endDate: effectiveFilters.endDate,
      limit: effectiveFilters.limit,
      offset: effectiveFilters.offset,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (events) => state = state.copyWith(
        events: events,
        isLoading: false,
        filters: effectiveFilters,
      ),
    );
  }

  Future<void> searchEvents(String query) async {
    final filters = state.filters.copyWith(search: query, offset: 0);
    await loadEvents(filters: filters);
  }

  Future<void> filterByCategory(String? category) async {
    final filters = state.filters.copyWith(category: category, offset: 0);
    await loadEvents(filters: filters);
  }

  Future<void> filterByLocation(double latitude, double longitude, int radiusKm) async {
    final filters = state.filters.copyWith(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      offset: 0,
    );
    await loadEvents(filters: filters);
  }

  Future<void> loadMore() async {
    if (state.isLoading) return;

    final filters = state.filters.copyWith(
      offset: state.filters.offset! + state.filters.limit!,
    );

    state = state.copyWith(isLoading: true);

    final result = await _repository.getEvents(
      category: filters.category,
      search: filters.search,
      status: filters.status,
      latitude: filters.latitude,
      longitude: filters.longitude,
      radiusKm: filters.radiusKm,
      startDate: filters.startDate,
      endDate: filters.endDate,
      limit: filters.limit,
      offset: filters.offset,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (newEvents) => state = state.copyWith(
        events: [...state.events, ...newEvents],
        isLoading: false,
        filters: filters,
      ),
    );
  }

  void clearFilters() {
    state = state.copyWith(filters: const EventFilters());
    loadEvents();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Event interaction state
class EventInteractionState {
  final bool isLiked;
  final bool isFavorited;
  final int likesCount;
  final bool isLoading;
  final String? errorMessage;

  const EventInteractionState({
    this.isLiked = false,
    this.isFavorited = false,
    this.likesCount = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  EventInteractionState copyWith({
    bool? isLiked,
    bool? isFavorited,
    int? likesCount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return EventInteractionState(
      isLiked: isLiked ?? this.isLiked,
      isFavorited: isFavorited ?? this.isFavorited,
      likesCount: likesCount ?? this.likesCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Event interaction notifier
class EventInteractionNotifier extends StateNotifier<EventInteractionState> {
  final EventRepository _repository;
  final String _eventId;
  final String _userId;

  EventInteractionNotifier({
    required EventRepository repository,
    required String eventId,
    required String userId,
  })  : _repository = repository,
        _eventId = eventId,
        _userId = userId,
        super(const EventInteractionState()) {
    _loadInteractionState();
  }

  Future<void> _loadInteractionState() async {
    state = state.copyWith(isLoading: true);

    final likeResult = await _repository.checkLike(_eventId, _userId);
    final favoriteResult = await _repository.checkFavorite(_eventId, _userId);

    final isLiked = likeResult.fold((l) => false, (r) => r);
    final isFavorited = favoriteResult.fold((l) => false, (r) => r);

    state = state.copyWith(
      isLiked: isLiked,
      isFavorited: isFavorited,
      isLoading: false,
    );
  }

  Future<void> toggleLike() async {
    final previousState = state;

    // Optimistic update
    state = state.copyWith(
      isLiked: !state.isLiked,
      likesCount: state.isLiked ? state.likesCount - 1 : state.likesCount + 1,
    );

    final result = await _repository.toggleLike(_eventId, _userId);

    result.fold(
      (failure) {
        // Revert on failure
        state = previousState.copyWith(errorMessage: failure.message);
      },
      (data) {
        state = state.copyWith(
          isLiked: data['is_liked'] as bool,
          likesCount: data['likes_count'] as int,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> toggleFavorite() async {
    final previousState = state;

    // Optimistic update
    state = state.copyWith(isFavorited: !state.isFavorited);

    final result = await _repository.toggleFavorite(_eventId, _userId);

    result.fold(
      (failure) {
        // Revert on failure
        state = previousState.copyWith(errorMessage: failure.message);
      },
      (data) {
        state = state.copyWith(
          isFavorited: data['is_favorited'] as bool,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> shareEvent({String platform = 'link'}) async {
    final result = await _repository.shareEvent(_eventId, _userId, platform: platform);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        // Share successful
        state = state.copyWith(errorMessage: null);
      },
    );
  }
}

/// Provider for event interaction state (per event)
final eventInteractionProvider = StateNotifierProvider.autoDispose
    .family<EventInteractionNotifier, EventInteractionState, String>(
  (ref, eventId) {
    final repository = ref.watch(eventRepositoryProvider);
    final user = ref.watch(currentUserProvider).value;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    return EventInteractionNotifier(
      repository: repository,
      eventId: eventId,
      userId: user.id,
    );
  },
);
