import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/event.dart';
import '../../repositories/event_repository.dart';

/// Use case for getting user's favorite events
class GetFavoriteEvents {
  final EventRepository repository;

  GetFavoriteEvents({required this.repository});

  Future<Either<Failure, List<Event>>> call({
    required String userId,
  }) async {
    return await repository.getFavoriteEvents(userId);
  }
}
