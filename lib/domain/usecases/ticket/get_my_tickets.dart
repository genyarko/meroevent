import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/ticket.dart';
import '../../repositories/ticket_repository.dart';

/// Use case for getting user's tickets
class GetMyTickets {
  final TicketRepository repository;

  GetMyTickets(this.repository);

  Future<Either<Failure, List<Ticket>>> call(String userId) async {
    return await repository.getMyTickets(userId);
  }
}
