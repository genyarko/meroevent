import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/event.dart';
import '../../repositories/event_repository.dart';

/// Use case for getting a single event by ID
class GetEventById {
  final EventRepository repository;

  GetEventById(this.repository);

  Future<Either<Failure, Event>> call(String id) async {
    return await repository.getEventById(id);
  }
}
