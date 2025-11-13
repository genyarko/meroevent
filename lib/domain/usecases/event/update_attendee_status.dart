import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/event_repository.dart';

/// Use case for updating attendee status (interested, going, etc.)
class UpdateAttendeeStatus {
  final EventRepository repository;

  UpdateAttendeeStatus({required this.repository});

  Future<Either<Failure, void>> call({
    required String eventId,
    required String userId,
    required String status,
  }) async {
    return await repository.updateAttendeeStatus(eventId, userId, status);
  }
}
