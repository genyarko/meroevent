import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/review.dart';
import '../../repositories/social_repository.dart';

/// Use case for updating event attendance status
class UpdateAttendanceStatus {
  final SocialRepository repository;

  UpdateAttendanceStatus(this.repository);

  Future<Either<Failure, EventAttendee>> call({
    required String eventId,
    required String userId,
    required String status,
  }) async {
    // Validation
    if (eventId.isEmpty) {
      return Left(ValidationFailure(message: 'Event ID is required'));
    }

    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID is required'));
    }

    final validStatuses = ['going', 'interested', 'not_going'];
    if (!validStatuses.contains(status)) {
      return Left(ValidationFailure(message: 'Invalid status. Must be: going, interested, or not_going'));
    }

    return await repository.updateAttendanceStatus(
      eventId: eventId,
      userId: userId,
      status: status,
    );
  }
}
