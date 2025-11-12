import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/event.dart';
import '../../repositories/event_repository.dart';

/// Use case for creating a new event
class CreateEvent {
  final EventRepository repository;

  CreateEvent(this.repository);

  Future<Either<Failure, Event>> call(Event event) async {
    // Additional validation can be added here
    if (event.title.isEmpty) {
      return Left(ValidationFailure(message: 'Event title is required'));
    }

    if (event.startDatetime.isAfter(event.endDatetime)) {
      return Left(ValidationFailure(
        message: 'End date must be after start date',
      ));
    }

    return await repository.createEvent(event);
  }
}
