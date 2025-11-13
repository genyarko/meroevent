import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/event_repository.dart';

/// Use case for toggling like on an event
class ToggleEventLike {
  final EventRepository repository;

  ToggleEventLike({required this.repository});

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String eventId,
    required String userId,
  }) async {
    return await repository.toggleLike(eventId, userId);
  }
}
