import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/event_repository.dart';

/// Use case for sharing an event
class ShareEvent {
  final EventRepository repository;

  ShareEvent({required this.repository});

  Future<Either<Failure, void>> call({
    required String eventId,
    required String userId,
    String platform = 'link',
  }) async {
    return await repository.shareEvent(
      eventId,
      userId,
      platform: platform,
    );
  }
}
