import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/ticket.dart';

/// Ticket repository interface
/// Defines all ticket-related operations
abstract class TicketRepository {
  /// Get ticket types for an event
  Future<Either<Failure, List<TicketType>>> getTicketTypes(String eventId);

  /// Get a single ticket type
  Future<Either<Failure, TicketType>> getTicketType(String id);

  /// Create ticket type
  Future<Either<Failure, TicketType>> createTicketType(TicketType ticketType);

  /// Update ticket type
  Future<Either<Failure, TicketType>> updateTicketType(TicketType ticketType);

  /// Delete ticket type
  Future<Either<Failure, void>> deleteTicketType(String id);

  /// Purchase tickets (create order)
  Future<Either<Failure, TicketOrder>> purchaseTickets({
    required String eventId,
    required String ticketTypeId,
    required int quantity,
    required String buyerId,
    required String buyerEmail,
    String? buyerPhone,
    String? promoCode,
    int karmaUsed = 0,
  });

  /// Get ticket order by ID
  Future<Either<Failure, TicketOrder>> getTicketOrder(String orderId);

  /// Get ticket orders by user
  Future<Either<Failure, List<TicketOrder>>> getMyOrders(String userId);

  /// Create a ticket
  Future<Either<Failure, Ticket>> createTicket(Ticket ticket);

  /// Get tickets for an order
  Future<Either<Failure, List<Ticket>>> getOrderTickets(String orderId);

  /// Get user's tickets
  Future<Either<Failure, List<Ticket>>> getMyTickets(String userId);

  /// Get a single ticket
  Future<Either<Failure, Ticket>> getTicket(String ticketId);

  /// Get ticket by QR code
  Future<Either<Failure, Ticket>> getTicketByQRCode(String qrCode);

  /// Validate and check-in ticket
  Future<Either<Failure, Ticket>> checkInTicket({
    required String qrCode,
    required String validatorId,
    String? location,
  });

  /// Transfer ticket to another user
  Future<Either<Failure, Ticket>> transferTicket({
    required String ticketId,
    required String fromUserId,
    required String toUserId,
    required String toEmail,
  });

  /// Cancel ticket order
  Future<Either<Failure, void>> cancelOrder(String orderId);

  /// Request ticket refund
  Future<Either<Failure, void>> requestRefund(String orderId, String reason);

  /// Get ticket sales for event (organizer)
  Future<Either<Failure, Map<String, dynamic>>> getTicketSales(String eventId);
}
