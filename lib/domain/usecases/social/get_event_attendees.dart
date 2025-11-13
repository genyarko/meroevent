import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/review.dart';
import '../../repositories/social_repository.dart';

/// Use case for getting event attendees
class GetEventAttendees {
  final SocialRepository repository;

  GetEventAttendees(this.repository);

  Future<Either<Failure, List<EventAttendee>>> call(String eventId) async {
    if (eventId.isEmpty) {
      return Left(ValidationFailure(message: 'Event ID is required'));
    }

    return await repository.getEventAttendees(eventId);
  }
}
