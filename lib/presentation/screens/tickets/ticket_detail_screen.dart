import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/ticket.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/event_provider.dart';

/// Screen to display ticket details with QR code
class TicketDetailScreen extends ConsumerWidget {
  final String ticketId;

  const TicketDetailScreen({
    super.key,
    required this.ticketId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ticketAsync = ref.watch(ticketProvider(ticketId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement ticket sharing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share ticket feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: ticketAsync.when(
        data: (ticket) => _buildTicketContent(context, theme, ticket, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: AppDimensions.spacingMedium),
              const Text('Error loading ticket'),
              const SizedBox(height: AppDimensions.spacingSmall),
              FilledButton(
                onPressed: () => ref.invalidate(ticketProvider(ticketId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketContent(
    BuildContext context,
    ThemeData theme,
    Ticket ticket,
    WidgetRef ref,
  ) {
    final eventAsync = ref.watch(eventByIdProvider(ticket.eventId));

    return eventAsync.when(
      data: (event) => SingleChildScrollView(
        child: Column(
          children: [
            // QR Code Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppDimensions.radiusLarge),
                  bottomRight: Radius.circular(AppDimensions.radiusLarge),
                ),
              ),
              child: Column(
                children: [
                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                    child: QrImageView(
                      data: ticket.qrCode,
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  Text(
                    'Ticket #${ticket.ticketNumber}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusChip(theme, ticket.status),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Info
                  Text(
                    'Event Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (event.imageUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
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
                                      DateFormat('EEEE, MMMM d, y').format(event.startDatetime),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    Text(
                                      '${DateFormat('h:mm a').format(event.startDatetime)} - ${DateFormat('h:mm a').format(event.endDatetime)}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            theme,
                            Icons.location_on,
                            'Location',
                            event.location ?? 'TBA',
                          ),
                          if (event.venue != null) ...[
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              theme,
                              Icons.business,
                              'Venue',
                              event.venue!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLarge),

                  // Ticket Details
                  Text(
                    'Ticket Details',
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
                          _buildDetailRow(theme, 'Ticket Type', 'General Admission'),
                          const Divider(height: 20),
                          if (ticket.assignedName != null)
                            _buildDetailRow(theme, 'Assigned To', ticket.assignedName!),
                          if (ticket.seatNumber != null) ...[
                            const Divider(height: 20),
                            _buildDetailRow(theme, 'Seat', ticket.seatNumber!),
                          ],
                          const Divider(height: 20),
                          _buildDetailRow(
                            theme,
                            'Validation Code',
                            ticket.validationCode ?? 'N/A',
                          ),
                          if (ticket.isCheckedIn) ...[
                            const Divider(height: 20),
                            _buildDetailRow(
                              theme,
                              'Checked In',
                              DateFormat('MMM d, y h:mm a').format(ticket.checkedInAt!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Important Information
                  const SizedBox(height: AppDimensions.spacingLarge),
                  Card(
                    color: theme.colorScheme.surfaceVariant,
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Important Information',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• Please present this QR code at the entrance\n'
                            '• Arrive 30 minutes before the event\n'
                            '• This ticket is non-transferable\n'
                            '• Take a screenshot for offline access',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error loading event: $error')),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Color.lerp(color, Colors.black, 0.3)!,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
