import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/event_remote_datasource.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/usecases/event/create_event.dart';
import '../../domain/usecases/event/get_event_by_id.dart';
import '../../domain/usecases/event/get_events.dart';
import '../../domain/usecases/event/get_featured_events.dart';

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
