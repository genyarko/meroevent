import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/ticket.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/event_provider.dart';

/// Screen to display user's purchased tickets
class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ticketsAsync = ref.watch(myTicketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(myTicketsProvider),
          ),
        ],
      ),
      body: ticketsAsync.when(
        data: (tickets) => _buildContent(context, theme, tickets, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, theme, error.toString(), ref),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, List<Ticket> tickets, WidgetRef ref) {
    if (tickets.isEmpty) {
      return _buildEmptyState(context, theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myTicketsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return _buildTicketCard(context, theme, ticket, ref);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 120,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Text(
              'No Tickets Yet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              'Your purchased tickets will appear here',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            FilledButton.icon(
              onPressed: () {
                context.go('/');
              },
              icon: const Icon(Icons.search),
              label: const Text('Browse Events'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, ThemeData theme, Ticket ticket, WidgetRef ref) {
    // Fetch event data for this ticket
    final eventAsync = ref.watch(eventByIdProvider(ticket.eventId));

    return eventAsync.when(
      data: (event) => Card(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
        child: InkWell(
          onTap: () {
            // TODO: Navigate to ticket detail screen with QR code
            context.push('/events/${ticket.eventId}');
          },
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Event image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      child: event.imageUrl != null
                          ? Image.network(
                              event.imageUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: theme.colorScheme.surfaceVariant,
                                  child: const Icon(Icons.event),
                                );
                              },
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: theme.colorScheme.surfaceVariant,
                              child: const Icon(Icons.event),
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
                            DateFormat('EEE, MMM d, y • h:mm a').format(event.startDatetime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.location ?? 'No location',
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                const Divider(),
                const SizedBox(height: AppDimensions.spacingSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ticket #',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ticket.ticketNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    _buildTicketStatus(theme, ticket),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () => Card(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(width: AppDimensions.spacingMedium),
              const Expanded(
                child: Text('Loading event details...'),
              ),
            ),
            error: (error, stack) => Text('Error loading event: $error'),
          ),
        ),
      ),
      error: (error, stack) => Card(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Text('Error loading ticket: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildTicketStatus(ThemeData theme, Ticket ticket) {
    Color statusColor;
    String statusText;

    if (ticket.isCheckedIn) {
      statusColor = Colors.blue;
      statusText = 'Used';
    } else if (ticket.isCancelled) {
      statusColor = Colors.red;
      statusText = 'Cancelled';
    } else if (ticket.isExpired) {
      statusColor = Colors.orange;
      statusText = 'Expired';
    } else if (ticket.isValid) {
      statusColor = Colors.green;
      statusText = 'Active';
    } else {
      statusColor = Colors.grey;
      statusText = ticket.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: Color.lerp(statusColor, Colors.black, 0.3)!,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme, String error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Text(
              'Error Loading Tickets',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            FilledButton.icon(
              onPressed: () => ref.refresh(myTicketsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'valid':
      case 'active':
        color = Colors.green;
        label = 'Valid';
        break;
      case 'used':
        color = Colors.orange;
        label = 'Used';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      case 'transferred':
        color = Colors.blue;
        label = 'Transferred';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
