import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/ticket.dart';
import '../../repositories/ticket_repository.dart';

/// Use case for transferring a ticket to another user
class TransferTicket {
  final TicketRepository repository;

  TransferTicket(this.repository);

  Future<Either<Failure, Ticket>> call({
    required String ticketId,
    required String fromUserId,
    required String toUserId,
    required String toEmail,
  }) async {
    // Validation
    if (ticketId.isEmpty) {
      return Left(ValidationFailure(message: 'Ticket ID is required'));
    }

    if (fromUserId.isEmpty || toUserId.isEmpty) {
      return Left(ValidationFailure(message: 'User IDs are required'));
    }

    if (fromUserId == toUserId) {
      return Left(ValidationFailure(
        message: 'Cannot transfer ticket to yourself',
      ));
    }

    if (toEmail.isEmpty) {
      return Left(ValidationFailure(
        message: 'Recipient email is required',
      ));
    }

    return await repository.transferTicket(
      ticketId: ticketId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      toEmail: toEmail,
    );
  }
}
