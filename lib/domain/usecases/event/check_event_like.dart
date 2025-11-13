import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/event_repository.dart';

/// Use case for checking if a user has liked an event
class CheckEventLike {
  final EventRepository repository;

  CheckEventLike({required this.repository});

  Future<Either<Failure, bool>> call({
    required String eventId,
    required String userId,
  }) async {
    return await repository.checkLike(eventId, userId);
  }
}
