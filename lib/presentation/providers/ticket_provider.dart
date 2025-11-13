import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/ticket_remote_datasource.dart';
import '../../data/repositories/ticket_repository_impl.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../../domain/usecases/ticket/get_my_tickets.dart';
import '../../domain/usecases/ticket/purchase_tickets.dart';
import '../../domain/usecases/ticket/check_in_ticket.dart';
import '../../domain/usecases/ticket/get_ticket_by_qr_code.dart';
import '../providers/auth_provider.dart';

/// Provider for TicketRemoteDataSource
final ticketRemoteDataSourceProvider = Provider<TicketRemoteDataSource>((ref) {
  return TicketRemoteDataSourceImpl();
});

/// Provider for TicketRepository
final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepositoryImpl(
    remoteDataSource: ref.watch(ticketRemoteDataSourceProvider),
  );
});

/// Provider for PurchaseTickets use case
final purchaseTicketsUseCaseProvider = Provider<PurchaseTickets>((ref) {
  return PurchaseTickets(ref.watch(ticketRepositoryProvider));
});

/// Provider for GetMyTickets use case
final getMyTicketsUseCaseProvider = Provider<GetMyTickets>((ref) {
  return GetMyTickets(ref.watch(ticketRepositoryProvider));
});

/// Provider for CheckInTicket use case
final checkInTicketUseCaseProvider = Provider<CheckInTicket>((ref) {
  return CheckInTicket(ref.watch(ticketRepositoryProvider));
});

/// Provider for GetTicketByQRCode use case
final getTicketByQRCodeUseCaseProvider = Provider<GetTicketByQRCode>((ref) {
  return GetTicketByQRCode(ref.watch(ticketRepositoryProvider));
});

/// Provider for user's tickets
final myTicketsProvider = FutureProvider.autoDispose<List<Ticket>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) {
    return [];
  }

  final repository = ref.watch(ticketRepositoryProvider);
  final result = await repository.getMyTickets(user.id);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (tickets) => tickets,
  );
});

/// Provider for ticket types for an event
final eventTicketTypesProvider = FutureProvider.autoDispose.family<List<TicketType>, String>(
  (ref, eventId) async {
    final repository = ref.watch(ticketRepositoryProvider);
    final result = await repository.getTicketTypes(eventId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (ticketTypes) => ticketTypes,
    );
  },
);

/// Provider for a single ticket
final ticketProvider = FutureProvider.autoDispose.family<Ticket, String>(
  (ref, ticketId) async {
    final repository = ref.watch(ticketRepositoryProvider);
    final result = await repository.getTicket(ticketId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (ticket) => ticket,
    );
  },
);

/// Ticket purchase state
class TicketPurchaseState {
  final bool isLoading;
  final String? error;
  final TicketOrder? completedOrder;
  final List<Ticket>? generatedTickets;

  const TicketPurchaseState({
    this.isLoading = false,
    this.error,
    this.completedOrder,
    this.generatedTickets,
  });

  TicketPurchaseState copyWith({
    bool? isLoading,
    String? error,
    TicketOrder? completedOrder,
    List<Ticket>? generatedTickets,
  }) {
    return TicketPurchaseState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      completedOrder: completedOrder ?? this.completedOrder,
      generatedTickets: generatedTickets ?? this.generatedTickets,
    );
  }
}

/// Ticket purchase notifier
class TicketPurchaseNotifier extends StateNotifier<TicketPurchaseState> {
  final TicketRepository _repository;

  TicketPurchaseNotifier(this._repository) : super(const TicketPurchaseState());

  /// Purchase tickets (creates order and generates tickets)
  Future<bool> purchaseTickets({
    required String eventId,
    required String ticketTypeId,
    required int quantity,
    required String buyerId,
    required String buyerEmail,
    String? buyerPhone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Create the order
      final orderResult = await _repository.purchaseTickets(
        eventId: eventId,
        ticketTypeId: ticketTypeId,
        quantity: quantity,
        buyerId: buyerId,
        buyerEmail: buyerEmail,
        buyerPhone: buyerPhone,
      );

      return orderResult.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
          return false;
        },
        (order) async {
          // Get the generated tickets for this order
          final ticketsResult = await _repository.getOrderTickets(order.id);

          return ticketsResult.fold(
            (failure) {
              state = state.copyWith(
                isLoading: false,
                error: 'Order created but failed to load tickets: ${failure.message}',
                completedOrder: order,
              );
              return false;
            },
            (tickets) {
              state = state.copyWith(
                isLoading: false,
                completedOrder: order,
                generatedTickets: tickets,
              );
              return true;
            },
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = const TicketPurchaseState();
  }
}

/// Provider for ticket purchase state
final ticketPurchaseProvider = StateNotifierProvider.autoDispose<TicketPurchaseNotifier, TicketPurchaseState>(
  (ref) {
    final repository = ref.watch(ticketRepositoryProvider);
    return TicketPurchaseNotifier(repository);
  },
);

/// Ticket validation state
class TicketValidationState {
  final bool isLoading;
  final String? error;
  final Ticket? scannedTicket;
  final Ticket? checkedInTicket;
  final String? successMessage;

  const TicketValidationState({
    this.isLoading = false,
    this.error,
    this.scannedTicket,
    this.checkedInTicket,
    this.successMessage,
  });

  TicketValidationState copyWith({
    bool? isLoading,
    String? error,
    Ticket? scannedTicket,
    Ticket? checkedInTicket,
    String? successMessage,
  }) {
    return TicketValidationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      scannedTicket: scannedTicket ?? this.scannedTicket,
      checkedInTicket: checkedInTicket ?? this.checkedInTicket,
      successMessage: successMessage,
    );
  }
}

/// Ticket validation notifier
class TicketValidationNotifier extends StateNotifier<TicketValidationState> {
  final TicketRepository _repository;
  final String _validatorId;

  TicketValidationNotifier({
    required TicketRepository repository,
    required String validatorId,
  })  : _repository = repository,
        _validatorId = validatorId,
        super(const TicketValidationState());

  /// Scan and validate a ticket by QR code
  Future<void> scanTicket(String qrCode) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      successMessage: null,
    );

    try {
      // Get ticket by QR code
      final result = await _repository.getTicketByQRCode(qrCode);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (ticket) {
          // Check if ticket is already checked in
          if (ticket.isCheckedIn) {
            state = state.copyWith(
              isLoading: false,
              scannedTicket: ticket,
              error: 'Ticket already checked in on ${ticket.checkedInAt}',
            );
          } else if (ticket.status.toLowerCase() == 'cancelled') {
            state = state.copyWith(
              isLoading: false,
              scannedTicket: ticket,
              error: 'Ticket has been cancelled',
            );
          } else if (ticket.status.toLowerCase() == 'transferred') {
            state = state.copyWith(
              isLoading: false,
              scannedTicket: ticket,
              error: 'Ticket has been transferred',
            );
          } else {
            // Ticket is valid
            state = state.copyWith(
              isLoading: false,
              scannedTicket: ticket,
              error: null,
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Check in a ticket
  Future<bool> checkInTicket(String qrCode, {String? location}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      successMessage: null,
    );

    try {
      final result = await _repository.checkInTicket(
        qrCode: qrCode,
        validatorId: _validatorId,
        location: location,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
          return false;
        },
        (ticket) {
          state = state.copyWith(
            isLoading: false,
            checkedInTicket: ticket,
            successMessage: 'Ticket checked in successfully!',
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Reset state
  void reset() {
    state = const TicketValidationState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for ticket validation state
final ticketValidationProvider = StateNotifierProvider.autoDispose<TicketValidationNotifier, TicketValidationState>(
  (ref) {
    final repository = ref.watch(ticketRepositoryProvider);
    final user = ref.watch(currentUserProvider).value;

    if (user == null) {
      throw Exception('User must be authenticated to validate tickets');
    }

    return TicketValidationNotifier(
      repository: repository,
      validatorId: user.id,
    );
  },
);
