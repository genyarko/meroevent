import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/event.dart';
import '../../repositories/event_repository.dart';

/// Use case for getting featured events
class GetFeaturedEvents {
  final EventRepository repository;

  GetFeaturedEvents(this.repository);

  Future<Either<Failure, List<Event>>> call({int? limit}) async {
    return await repository.getFeaturedEvents(limit: limit);
  }
}
