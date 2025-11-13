import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/event.dart';
import '../../providers/event_provider.dart';

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

                // Quantity selector
                if (!event.isFree) ...[
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
                                onPressed: _ticketQuantity < 10
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
                  const SizedBox(height: AppDimensions.spacingLarge),
                ],

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
              onPressed: event.isSoldOut
                  ? null
                  : () {
                      _proceedToCheckout(context, event);
                    },
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Text(
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

  void _proceedToCheckout(BuildContext context, Event event) {
    // TODO: Implement actual payment processing
    // For now, show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          event.isFree
              ? 'Registration successful!'
              : 'Payment integration coming soon',
        ),
        action: SnackBarAction(
          label: 'View Tickets',
          onPressed: () {
            context.go('/tickets');
          },
        ),
      ),
    );

    if (event.isFree) {
      // Navigate to tickets screen after a delay
      Future.delayed(const Duration(seconds: 1), () {
        if (context.mounted) {
          context.go('/tickets');
        }
      });
    }
  }
}
