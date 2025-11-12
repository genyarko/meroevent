import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/event.dart';
import '../../repositories/event_repository.dart';

/// Use case for getting a list of events with optional filters
class GetEvents {
  final EventRepository repository;

  GetEvents(this.repository);

  Future<Either<Failure, List<Event>>> call({
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
    return await repository.getEvents(
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
  }
}
