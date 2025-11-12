import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/ticket.dart';
import '../../repositories/ticket_repository.dart';

/// Use case for checking in a ticket
class CheckInTicket {
  final TicketRepository repository;

  CheckInTicket(this.repository);

  Future<Either<Failure, Ticket>> call({
    required String qrCode,
    required String validatorId,
    String? location,
  }) async {
    // Validation
    if (qrCode.isEmpty) {
      return Left(ValidationFailure(message: 'QR code is required'));
    }

    if (validatorId.isEmpty) {
      return Left(ValidationFailure(message: 'Validator ID is required'));
    }

    return await repository.checkInTicket(
      qrCode: qrCode,
      validatorId: validatorId,
      location: location,
    );
  }
}
