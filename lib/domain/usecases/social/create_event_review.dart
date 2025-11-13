import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/review.dart';
import '../../repositories/social_repository.dart';

/// Use case for creating an event review
class CreateEventReview {
  final SocialRepository repository;

  CreateEventReview(this.repository);

  Future<Either<Failure, EventReview>> call({
    required String eventId,
    required String userId,
    required int rating,
    String? comment,
    List<String>? imageUrls,
  }) async {
    // Validation
    if (eventId.isEmpty) {
      return Left(ValidationFailure(message: 'Event ID is required'));
    }

    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID is required'));
    }

    if (rating < 1 || rating > 5) {
      return Left(ValidationFailure(message: 'Rating must be between 1 and 5'));
    }

    if (comment != null && comment.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Comment cannot be empty if provided'));
    }

    return await repository.createEventReview(
      eventId: eventId,
      userId: userId,
      rating: rating,
      comment: comment?.trim(),
      imageUrls: imageUrls,
    );
  }
}
