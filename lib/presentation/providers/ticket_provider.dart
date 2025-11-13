import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/ticket_remote_datasource.dart';
import '../../data/repositories/ticket_repository_impl.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../../domain/usecases/ticket/get_my_tickets.dart';
import '../../domain/usecases/ticket/purchase_tickets.dart';
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
