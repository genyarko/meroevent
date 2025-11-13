import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/event.dart';

/// Event repository interface
/// Defines all event-related operations
abstract class EventRepository {
  /// Get all events with optional filters
  Future<Either<Failure, List<Event>>> getEvents({
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
  });

  /// Get a single event by ID
  Future<Either<Failure, Event>> getEventById(String id);

  /// Get event by slug
  Future<Either<Failure, Event>> getEventBySlug(String slug);

  /// Get events by organizer
  Future<Either<Failure, List<Event>>> getEventsByOrganizer(
    String organizerId, {
    String? status,
    int? limit,
    int? offset,
  });

  /// Get nearby events based on location
  Future<Either<Failure, List<Event>>> getNearbyEvents({
    required double latitude,
    required double longitude,
    int radiusKm = 10,
    int? limit,
  });

  /// Get featured/trending events
  Future<Either<Failure, List<Event>>> getFeaturedEvents({
    int? limit,
  });

  /// Search events
  Future<Either<Failure, List<Event>>> searchEvents({
    required String query,
    String? category,
    String? city,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
    int? limit,
    int? offset,
  });

  /// Create a new event
  Future<Either<Failure, Event>> createEvent(Event event);

  /// Update an existing event
  Future<Either<Failure, Event>> updateEvent(Event event);

  /// Delete an event
  Future<Either<Failure, void>> deleteEvent(String id);

  /// Publish an event
  Future<Either<Failure, Event>> publishEvent(String id);

  /// Cancel an event
  Future<Either<Failure, Event>> cancelEvent(String id, String reason);

  /// Get events user is attending
  Future<Either<Failure, List<Event>>> getMyEvents(String userId);

  /// Get events user has liked/favorited
  Future<Either<Failure, List<Event>>> getFavoriteEvents(String userId);

  /// Like/unlike an event
  Future<Either<Failure, Map<String, dynamic>>> toggleLike(String eventId, String userId);

  /// Favorite/unfavorite an event
  Future<Either<Failure, Map<String, dynamic>>> toggleFavorite(String eventId, String userId);

  /// Share an event (increment share count and record share)
  Future<Either<Failure, void>> shareEvent(String eventId, String userId, {String platform});

  /// Check if user has liked an event
  Future<Either<Failure, bool>> checkLike(String eventId, String userId);

  /// Check if user has favorited an event
  Future<Either<Failure, bool>> checkFavorite(String eventId, String userId);

  /// Update attendee status (interested, going, etc.)
  Future<Either<Failure, void>> updateAttendeeStatus(String eventId, String userId, String status);

  /// Increment share count (legacy - use shareEvent instead)
  Future<Either<Failure, void>> incrementShareCount(String eventId);

  /// Increment view count
  Future<Either<Failure, void>> incrementViewCount(String eventId);
}
