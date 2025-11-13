import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/event_repository.dart';

/// Use case for toggling favorite on an event
class ToggleEventFavorite {
  final EventRepository repository;

  ToggleEventFavorite({required this.repository});

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String eventId,
    required String userId,
  }) async {
    return await repository.toggleFavorite(eventId, userId);
  }
}
