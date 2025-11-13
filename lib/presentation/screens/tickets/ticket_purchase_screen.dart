import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/entities/ticket.dart';
import '../../providers/event_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/auth_provider.dart';

/// Screen for purchasing tickets to an event
class TicketPurchaseScreen extends ConsumerStatefulWidget {
  final String eventId;

  const TicketPurchaseScreen({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<TicketPurchaseScreen> createState() => _TicketPurchaseScreenState();
}

class _TicketPurchaseScreenState extends ConsumerState<TicketPurchaseScreen> {
  int _ticketQuantity = 1;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventAsync = ref.watch(eventByIdProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Tickets'),
      ),
      body: eventAsync.when(
        data: (event) => _buildContent(context, theme, event),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: AppDimensions.spacingMedium),
              const Text('Error loading event'),
              const SizedBox(height: AppDimensions.spacingSmall),
              FilledButton(
                onPressed: () => ref.invalidate(eventByIdProvider(widget.eventId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, Event event) {
    final ticketPrice = event.minPrice ?? 0;
    final totalPrice = ticketPrice * _ticketQuantity;
    final maxTickets = event.maxTicketsPerPurchase;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Row(
                      children: [
                        if (event.imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            child: Image.network(
                              event.imageUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: theme.colorScheme.surfaceVariant,
                                  child: const Icon(Icons.event),
                                );
                              },
                            ),
                          ),
                        const SizedBox(width: AppDimensions.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.location ?? 'Location TBA',
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLarge),

                // Ticket type (simplified - using event price)
                Text(
                  'Ticket Type',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                Card(
                  child: ListTile(
                    title: Text(event.isFree ? 'Free Admission' : 'General Admission'),
                    subtitle: Text(event.isFree ? 'Free' : '${event.currency ?? '\$'}${ticketPrice.toStringAsFixed(2)}'),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLarge),

                // Quantity selector (for both free and paid events)
                Text(
                  'Quantity',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Number of tickets'),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _ticketQuantity > 1
                                  ? () {
                                      setState(() {
                                        _ticketQuantity--;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(
                              '$_ticketQuantity',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _ticketQuantity < maxTickets
                                  ? () {
                                      setState(() {
                                        _ticketQuantity++;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (maxTickets < 20)
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.spacingSmall),
                    child: Text(
                      'Maximum $maxTickets tickets per purchase',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                const SizedBox(height: AppDimensions.spacingLarge),

                // Order summary
                Text(
                  'Order Summary',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          theme,
                          'Tickets × $_ticketQuantity',
                          event.isFree ? 'Free' : '${event.currency ?? '\$'}${totalPrice.toStringAsFixed(2)}',
                        ),
                        if (!event.isFree) ...[
                          const Divider(height: 24),
                          _buildSummaryRow(
                            theme,
                            'Service Fee',
                            '${event.currency ?? '\$'}0.00',
                          ),
                          const Divider(height: 24),
                          _buildSummaryRow(
                            theme,
                            'Total',
                            '${event.currency ?? '\$'}${totalPrice.toStringAsFixed(2)}',
                            isBold: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: FilledButton(
              onPressed: event.isSoldOut || _isProcessing
                  ? null
                  : () {
                      _proceedToCheckout(context, event);
                    },
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      event.isSoldOut
                          ? 'Sold Out'
                          : event.isFree
                              ? 'Register Now'
                              : 'Proceed to Payment',
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    ThemeData theme,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Future<void> _proceedToCheckout(BuildContext context, Event event) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final ticketRepository = ref.read(ticketRepositoryProvider);

      // Get or create ticket type for this event
      final ticketTypesResult = await ticketRepository.getTicketTypes(event.id);

      TicketType? ticketType;

      // Check if ticket types exist
      final needsCreation = ticketTypesResult.fold(
        (failure) => true, // Failed to get, needs creation
        (types) => types.isEmpty, // Empty list, needs creation
      );

      if (needsCreation) {
        // No ticket types exist - this means the event organizer hasn't set up ticketing yet
        throw Exception(
          'Tickets are not available for this event yet. '
          'Please contact the event organizer.'
        );
      } else {
        // Use existing ticket type
        ticketType = ticketTypesResult.fold(
          (failure) => throw Exception('Failed to get ticket types: ${failure.message}'),
          (types) => types.first,
        );
      }

      // Create the ticket order
      final purchaseResult = await ticketRepository.purchaseTickets(
        eventId: event.id,
        ticketTypeId: ticketType!.id,
        quantity: _ticketQuantity,
        buyerId: user.id,
        buyerEmail: user.email,
        buyerPhone: user.phone,
      );

      await purchaseResult.fold(
        (failure) async {
          throw Exception('Purchase failed: ${failure.message}');
        },
        (order) async {
          // Order created successfully, now create individual tickets
          await _createTicketsForOrder(order, ticketType!, user.id, user.email, _ticketQuantity);

          if (!mounted) return;

          // Invalidate tickets provider to refresh the list
          ref.invalidate(myTicketsProvider);

          // Capture the router before showing snackbar
          final router = GoRouter.of(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                event.isFree
                    ? 'Registration successful! ${_ticketQuantity} ticket(s) registered.'
                    : 'Order created! Payment integration coming soon.',
              ),
              action: SnackBarAction(
                label: 'View Tickets',
                onPressed: () {
                  router.go('/tickets');
                },
              ),
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate to tickets screen
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.go('/tickets');
            }
          });
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _createTicketsForOrder(
    TicketOrder order,
    TicketType ticketType,
    String userId,
    String userEmail,
    int quantity,
  ) async {
    // Create individual tickets for the order
    final ticketRepository = ref.read(ticketRepositoryProvider);

    try {
      int successCount = 0;
      int errorCount = 0;
      String? lastError;

      // Generate tickets based on quantity ordered
      for (int i = 0; i < quantity; i++) {
        final ticketNumber = 'TKT-${order.orderNumber}-${i + 1}';
        final qrCode = '${order.id}-${ticketNumber}-${DateTime.now().millisecondsSinceEpoch}';

        final ticket = Ticket(
          id: '', // Will be generated by database
          ticketNumber: ticketNumber,
          orderId: order.id,
          ticketTypeId: ticketType.id,
          eventId: order.eventId,
          assignedToId: userId,
          assignedEmail: userEmail,
          qrCode: qrCode,
          createdAt: DateTime.now(),
        );

        final result = await ticketRepository.createTicket(ticket);
        result.fold(
          (failure) {
            errorCount++;
            lastError = failure.message;
            print('❌ Error creating ticket $ticketNumber: ${failure.message}');
          },
          (createdTicket) {
            successCount++;
            print('✅ Successfully created ticket: ${createdTicket.ticketNumber}');
          },
        );
      }

      // Show summary to user
      if (errorCount > 0) {
        print('⚠️ Ticket creation summary: $successCount/$quantity succeeded, $errorCount failed');
        print('⚠️ Last error: $lastError');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Warning: Only $successCount of $quantity tickets were created. '
                'Error: $lastError',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        print('✅ All $successCount tickets created successfully');
      }
    } catch (e) {
      print('❌ Critical error creating tickets: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating tickets: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      // Don't throw - order was created successfully
    }
  }
}
