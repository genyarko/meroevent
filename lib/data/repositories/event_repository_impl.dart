import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/remote/event_remote_datasource.dart';
import '../models/event_model.dart';

/// Event repository implementation
class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl({required this.remoteDataSource});

  @override
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
  }) async {
    try {
      final models = await remoteDataSource.getEvents(
        category: category,
        search: search,
        status: status,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> getEventById(String id) async {
    try {
      final model = await remoteDataSource.getEventById(id);
      return Right(model.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> getEventBySlug(String slug) async {
    try {
      final model = await remoteDataSource.getEventBySlug(slug);
      return Right(model.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getEventsByOrganizer(
    String organizerId, {
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final models = await remoteDataSource.getEventsByOrganizer(
        organizerId,
        status: status,
        limit: limit,
        offset: offset,
      );
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getNearbyEvents({
    required double latitude,
    required double longitude,
    int radiusKm = 10,
    int? limit,
  }) async {
    try {
      final models = await remoteDataSource.getNearbyEvents(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        limit: limit,
      );
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getFeaturedEvents({int? limit}) async {
    try {
      final models = await remoteDataSource.getFeaturedEvents(limit: limit);
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final models = await remoteDataSource.getEvents(
        search: query,
        category: category,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> createEvent(Event event) async {
    try {
      final model = EventModel.fromEntity(event);
      final createdModel = await remoteDataSource.createEvent(model);
      return Right(createdModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> updateEvent(Event event) async {
    try {
      final model = EventModel.fromEntity(event);
      final updatedModel = await remoteDataSource.updateEvent(model);
      return Right(updatedModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String id) async {
    try {
      await remoteDataSource.deleteEvent(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> publishEvent(String id) async {
    try {
      final model = await remoteDataSource.getEventById(id);
      final updatedModel = EventModel.fromJson({
        ...model.toJson(),
        'status': 'published',
        'published_at': DateTime.now().toIso8601String(),
      });
      final result = await remoteDataSource.updateEvent(updatedModel);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> cancelEvent(String id, String reason) async {
    try {
      final model = await remoteDataSource.getEventById(id);
      final updatedModel = EventModel.fromJson({
        ...model.toJson(),
        'status': 'cancelled',
      });
      final result = await remoteDataSource.updateEvent(updatedModel);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getMyEvents(String userId) async {
    try {
      final models = await remoteDataSource.getEventsByOrganizer(userId);
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getFavoriteEvents(String userId) async {
    try {
      final models = await remoteDataSource.getFavoriteEvents(userId);
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> toggleLike(
    String eventId,
    String userId,
  ) async {
    try {
      final result = await remoteDataSource.toggleLike(eventId, userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> toggleFavorite(
    String eventId,
    String userId,
  ) async {
    try {
      final result = await remoteDataSource.toggleFavorite(eventId, userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> shareEvent(
    String eventId,
    String userId, {
    String platform = 'link',
  }) async {
    try {
      await remoteDataSource.recordShare(eventId, userId, platform: platform);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkLike(String eventId, String userId) async {
    try {
      final result = await remoteDataSource.checkLike(eventId, userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkFavorite(String eventId, String userId) async {
    try {
      final result = await remoteDataSource.checkFavorite(eventId, userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAttendeeStatus(
    String eventId,
    String userId,
    String status,
  ) async {
    try {
      await remoteDataSource.updateAttendeeStatus(eventId, userId, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementShareCount(String eventId) async {
    try {
      await remoteDataSource.incrementShareCount(eventId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementViewCount(String eventId) async {
    try {
      await remoteDataSource.incrementViewCount(eventId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
