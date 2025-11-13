import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/event.dart';
import '../../providers/event_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));

    return eventAsync.when(
      data: (event) => _EventDetailView(event: event),
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: AppDimensions.spacingMedium),
              Text('Error loading event'),
              const SizedBox(height: AppDimensions.spacingSmall),
              FilledButton(
                onPressed: () => ref.invalidate(eventByIdProvider(eventId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventDetailView extends ConsumerWidget {
  final Event event;

  const _EventDetailView({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: event.imageUrl != null
                  ? Image.network(
                      event.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) {
                        return Container(
                          color: theme.colorScheme.surfaceVariant,
                          child: const Center(
                            child: Icon(Icons.event, size: 64),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: const Center(
                        child: Icon(Icons.event, size: 64),
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  try {
                    await ref.read(eventInteractionProvider(event.id).notifier).shareEvent();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Event shared!')),
                      );
                    }
                  } catch (e) {
                    // User not authenticated, show message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please login to share events')),
                      );
                    }
                  }
                },
              ),
              Consumer(
                builder: (context, ref, child) {
                  try {
                    final interactionState = ref.watch(eventInteractionProvider(event.id));

                    return IconButton(
                      icon: Icon(
                        interactionState.isFavorited
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      onPressed: () {
                        ref.read(eventInteractionProvider(event.id).notifier).toggleFavorite();
                      },
                    );
                  } catch (e) {
                    // User not authenticated
                    return IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please login to favorite events')),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category and status badges
                      Row(
                        children: [
                          if (event.category != null)
                            _buildBadge(
                              theme,
                              event.category!,
                              theme.colorScheme.secondaryContainer,
                              theme.colorScheme.onSecondaryContainer,
                            ),
                          const SizedBox(width: AppDimensions.spacingSmall),
                          if (event.isFeatured)
                            _buildBadge(
                              theme,
                              'Featured',
                              theme.colorScheme.primary,
                              theme.colorScheme.onPrimary,
                              icon: Icons.star,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingMedium),

                      // Event title
                      Text(
                        event.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingMedium),

                      // Organizer
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            child: Text(event.organizerName?[0] ?? 'O'),
                          ),
                          const SizedBox(width: AppDimensions.spacingSmall),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Organized by',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                event.organizerName ?? 'Unknown',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingLarge),

                      // Date and time
                      _buildInfoRow(
                        theme,
                        Icons.calendar_today,
                        'Date & Time',
                        _formatDateTime(event.startDatetime, event.endDatetime),
                      ),
                      const SizedBox(height: AppDimensions.spacingMedium),

                      // Location
                      _buildInfoRow(
                        theme,
                        Icons.location_on,
                        'Location',
                        event.location ?? 'Location TBA',
                      ),
                      if (event.venue != null) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 40),
                          child: Text(
                            event.venue!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppDimensions.spacingMedium),

                      // Price
                      _buildInfoRow(
                        theme,
                        Icons.confirmation_number,
                        'Price',
                        event.isFree
                            ? 'FREE'
                            : event.minPrice != null
                                ? '${event.currency ?? '\$'}${event.minPrice}'
                                : 'Paid',
                      ),
                      const SizedBox(height: AppDimensions.spacingLarge),

                      // Stats
                      Consumer(
                        builder: (context, ref, child) {
                          try {
                            final interactionState = ref.watch(eventInteractionProvider(event.id));
                            final displayLikesCount = interactionState.likesCount > 0
                                ? interactionState.likesCount
                                : event.likesCount;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  theme,
                                  Icons.people,
                                  event.attendeesCount.toString(),
                                  'Going',
                                ),
                                InkWell(
                                  onTap: () {
                                    ref.read(eventInteractionProvider(event.id).notifier).toggleLike();
                                  },
                                  child: _buildStatItem(
                                    theme,
                                    interactionState.isLiked ? Icons.favorite : Icons.favorite_border,
                                    displayLikesCount.toString(),
                                    'Likes',
                                  ),
                                ),
                                _buildStatItem(
                                  theme,
                                  Icons.visibility,
                                  event.viewsCount.toString(),
                                  'Views',
                                ),
                              ],
                            );
                          } catch (e) {
                            // User not authenticated, show default view
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  theme,
                                  Icons.people,
                                  event.attendeesCount.toString(),
                                  'Going',
                                ),
                                _buildStatItem(
                                  theme,
                                  Icons.favorite_border,
                                  event.likesCount.toString(),
                                  'Likes',
                                ),
                                _buildStatItem(
                                  theme,
                                  Icons.visibility,
                                  event.viewsCount.toString(),
                                  'Views',
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingLarge),

                      // Description
                      if (event.description != null) ...[
                        Text(
                          'About Event',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingSmall),
                        Text(
                          event.description!,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: AppDimensions.spacingLarge),
                      ],

                      // Tags
                      if (event.tags != null && event.tags!.isNotEmpty) ...[
                        Text(
                          'Tags',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingSmall),
                        Wrap(
                          spacing: AppDimensions.spacingSmall,
                          runSpacing: AppDimensions.spacingSmall,
                          children: event.tags!.map((tag) {
                            return Chip(
                              label: Text(tag),
                              labelStyle: const TextStyle(fontSize: 12),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppDimensions.spacingLarge),
                      ],

                      // Additional info
                      if (event.capacity != null) ...[
                        Text(
                          'Event Information',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingSmall),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                            child: Column(
                              children: [
                                if (event.capacity != null)
                                  _buildInfoListTile(
                                    theme,
                                    Icons.people,
                                    'Capacity',
                                    '${event.capacity} people',
                                  ),
                                if (event.ageRestriction != null)
                                  _buildInfoListTile(
                                    theme,
                                    Icons.warning,
                                    'Age Restriction',
                                    '${event.ageRestriction}+',
                                  ),
                                if (event.dressCode != null)
                                  _buildInfoListTile(
                                    theme,
                                    Icons.checkroom,
                                    'Dress Code',
                                    event.dressCode!,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: FilledButton(
            onPressed: event.isSoldOut
                ? null
                : () {
                    context.push('/events/${event.id}/tickets');
                  },
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
            child: Text(
              event.isSoldOut
                  ? 'Sold Out'
                  : event.isFree
                      ? 'Register for Free'
                      : 'Buy Tickets',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    ThemeData theme,
    String label,
    Color backgroundColor,
    Color textColor, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: AppDimensions.spacingMedium),
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
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(ThemeData theme, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoListTile(ThemeData theme, IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(value),
      contentPadding: EdgeInsets.zero,
    );
  }

  String _formatDateTime(DateTime start, DateTime end) {
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final timeFormat = DateFormat('h:mm a');

    final dateStr = dateFormat.format(start);
    final startTimeStr = timeFormat.format(start);
    final endTimeStr = timeFormat.format(end);

    return '$dateStr\n$startTimeStr - $endTimeStr';
  }
}
