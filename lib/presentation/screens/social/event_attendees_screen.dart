import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/entities/review.dart';
import '../../providers/social_provider.dart';

/// Screen displaying attendees for an event
class EventAttendeesScreen extends ConsumerWidget {
  final Event event;

  const EventAttendeesScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final attendeesAsync = ref.watch(eventAttendeesProvider(event.id));
    final goingCountAsync = ref.watch(eventGoingCountProvider(event.id));
    final interestedCountAsync = ref.watch(eventInterestedCountProvider(event.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendees'),
      ),
      body: Column(
        children: [
          // Stats header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            color: theme.colorScheme.surfaceVariant,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                goingCountAsync.when(
                  data: (count) => _buildStatColumn(context, theme, 'Going', count),
                  loading: () => _buildStatColumn(context, theme, 'Going', 0),
                  error: (error, stack) => _buildStatColumn(context, theme, 'Going', 0),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline,
                ),
                interestedCountAsync.when(
                  data: (count) => _buildStatColumn(context, theme, 'Interested', count),
                  loading: () => _buildStatColumn(context, theme, 'Interested', 0),
                  error: (error, stack) => _buildStatColumn(context, theme, 'Interested', 0),
                ),
              ],
            ),
          ),

          // Attendees list
          Expanded(
            child: attendeesAsync.when(
              data: (attendees) {
                if (attendees.isEmpty) {
                  return _buildEmptyState(context, theme);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  itemCount: attendees.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppDimensions.spacingSmall),
                  itemBuilder: (context, index) {
                    return _buildAttendeeCard(context, theme, attendees[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading attendees: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, ThemeData theme, String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendeeCard(BuildContext context, ThemeData theme, EventAttendee attendee) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: attendee.userAvatarUrl != null
              ? NetworkImage(attendee.userAvatarUrl!)
              : null,
          child: attendee.userAvatarUrl == null
              ? Text(attendee.displayName[0].toUpperCase())
              : null,
        ),
        title: Text(
          attendee.displayName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Row(
          children: [
            if (attendee.hasTicket) ...[
              Icon(
                Icons.confirmation_number,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Has ticket',
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (attendee.isCheckedIn) ...[
              if (attendee.hasTicket) const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                'Checked in',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
        trailing: _buildStatusChip(theme, attendee.status),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, String status) {
    Color color;
    String label;

    switch (status) {
      case 'going':
        color = Colors.green;
        label = 'Going';
        break;
      case 'interested':
        color = Colors.orange;
        label = 'Interested';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
              Icons.people_outline,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Text(
              'No Attendees Yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              'Be the first to join this event!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
