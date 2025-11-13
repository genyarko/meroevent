import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/review.dart';
import '../../repositories/social_repository.dart';

/// Use case for getting event reviews
class GetEventReviews {
  final SocialRepository repository;

  GetEventReviews(this.repository);

  Future<Either<Failure, List<EventReview>>> call(String eventId) async {
    if (eventId.isEmpty) {
      return Left(ValidationFailure(message: 'Event ID is required'));
    }

    return await repository.getEventReviews(eventId);
  }
}
