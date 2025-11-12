import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/ticket.dart';
import '../../repositories/ticket_repository.dart';

/// Use case for purchasing tickets
class PurchaseTickets {
  final TicketRepository repository;

  PurchaseTickets(this.repository);

  Future<Either<Failure, TicketOrder>> call({
    required String eventId,
    required String ticketTypeId,
    required int quantity,
    required String buyerId,
    required String buyerEmail,
    String? buyerPhone,
    String? promoCode,
    int karmaUsed = 0,
  }) async {
    // Validation
    if (quantity <= 0) {
      return Left(ValidationFailure(message: 'Quantity must be greater than 0'));
    }

    if (quantity > 10) {
      return Left(ValidationFailure(
        message: 'Maximum 10 tickets per purchase',
      ));
    }

    return await repository.purchaseTickets(
      eventId: eventId,
      ticketTypeId: ticketTypeId,
      quantity: quantity,
      buyerId: buyerId,
      buyerEmail: buyerEmail,
      buyerPhone: buyerPhone,
      promoCode: promoCode,
      karmaUsed: karmaUsed,
    );
  }
}
