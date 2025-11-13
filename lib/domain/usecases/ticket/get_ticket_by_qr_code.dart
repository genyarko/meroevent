import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/ticket.dart';
import '../../repositories/ticket_repository.dart';

/// Use case for getting a ticket by QR code
class GetTicketByQRCode {
  final TicketRepository repository;

  GetTicketByQRCode(this.repository);

  Future<Either<Failure, Ticket>> call(String qrCode) async {
    // Validation
    if (qrCode.isEmpty) {
      return Left(ValidationFailure(message: 'QR code is required'));
    }

    return await repository.getTicketByQRCode(qrCode);
  }
}
