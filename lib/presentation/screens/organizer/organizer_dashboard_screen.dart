import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../widgets/event_card.dart';

class OrganizerDashboardScreen extends ConsumerStatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  ConsumerState<OrganizerDashboardScreen> createState() =>
      _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState
    extends ConsumerState<OrganizerDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load organizer events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).user;
      if (user != null) {
        // Load events by organizer
        ref.read(eventStateProvider.notifier).loadEvents();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).user;
    final eventState = ref.watch(eventStateProvider);

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, size: 64),
              const SizedBox(height: AppDimensions.spacingMedium),
              const Text('Please sign in to access organizer dashboard'),
              const SizedBox(height: AppDimensions.spacingMedium),
              FilledButton(
                onPressed: () => context.push('/login'),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    // Filter events by organizer (for now showing all, but should filter by organizerId)
    final myEvents = eventState.events;
    final draftEvents = myEvents.where((e) => e.status == 'draft').toList();
    final publishedEvents = myEvents.where((e) => e.status == 'published').toList();
    final completedEvents = myEvents.where((e) => e.status == 'completed').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Organizer settings
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Published'),
            Tab(text: 'Drafts'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stats cards
          _buildStatsRow(theme, myEvents),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventList(myEvents, eventState.isLoading),
                _buildEventList(publishedEvents, eventState.isLoading),
                _buildEventList(draftEvents, eventState.isLoading),
                _buildEventList(completedEvents, eventState.isLoading),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-event'),
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme, List events) {
    final totalEvents = events.length;
    final totalTicketsSold = events.fold<int>(
      0,
      (sum, event) => sum + ((event.attendeesCount ?? 0) as int),
    );
    final totalRevenue = events.fold<double>(
      0,
      (sum, event) => sum + ((event.minPrice ?? 0) * (event.attendeesCount ?? 0)),
    );

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              theme,
              Icons.event,
              'Events',
              totalEvents.toString(),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSmall),
          Expanded(
            child: _buildStatCard(
              theme,
              Icons.confirmation_number,
              'Tickets Sold',
              totalTicketsSold.toString(),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSmall),
          Expanded(
            child: _buildStatCard(
              theme,
              Icons.attach_money,
              'Revenue',
              '\$${totalRevenue.toStringAsFixed(0)}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, IconData icon, String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(List events, bool isLoading) {
    if (isLoading && events.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 64),
            const SizedBox(height: AppDimensions.spacingMedium),
            const Text('No events found'),
            const SizedBox(height: AppDimensions.spacingSmall),
            FilledButton.icon(
              onPressed: () => context.push('/create-event'),
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Event'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(eventStateProvider.notifier).loadEvents();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
            child: _buildOrganizerEventCard(event),
          );
        },
      ),
    );
  }

  Widget _buildOrganizerEventCard(event) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Event card
          EventCard(event: event),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('/events/${event.id}/edit');
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSmall),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('/events/${event.id}/manage');
                    },
                    icon: const Icon(Icons.analytics, size: 18),
                    label: const Text('Manage'),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSmall),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    _showEventOptions(context, event);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEventOptions(BuildContext context, event) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Event'),
              onTap: () {
                Navigator.pop(context);
                context.push('/events/${event.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Event'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate Event'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement duplicate
              },
            ),
            if (event.status == 'draft')
              ListTile(
                leading: const Icon(Icons.publish),
                title: const Text('Publish Event'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement publish
                },
              ),
            if (event.status == 'published')
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel Event'),
                onTap: () {
                  Navigator.pop(context);
                  _showCancelDialog(context, event);
                },
              ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Delete Event',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context, event);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Event'),
        content: const Text(
          'Are you sure you want to cancel this event? All ticket holders will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancel event
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Event cancellation coming soon')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text(
          'Are you sure you want to permanently delete this event? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete event
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Event deletion coming soon')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
