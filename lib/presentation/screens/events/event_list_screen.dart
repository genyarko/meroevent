import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../providers/event_provider.dart';
import '../../widgets/event_card.dart';

class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key});

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load events on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventStateProvider.notifier).loadEvents();
    });

    // Setup infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(eventStateProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventState = ref.watch(eventStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(eventStateProvider.notifier).loadEvents();
        },
        child: eventState.events.isEmpty && eventState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : eventState.events.isEmpty && eventState.errorMessage != null
                ? _buildErrorState(eventState.errorMessage!)
                : eventState.events.isEmpty
                    ? _buildEmptyState()
                    : _buildEventList(eventState),
      ),
    );
  }

  Widget _buildEventList(EventState eventState) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: eventState.events.length + (eventState.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == eventState.events.length) {
          return const Padding(
            padding: EdgeInsets.all(AppDimensions.paddingLarge),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
          child: EventCard(event: eventState.events[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 64),
          const SizedBox(height: AppDimensions.spacingMedium),
          const Text('No events found'),
          const SizedBox(height: AppDimensions.spacingSmall),
          TextButton(
            onPressed: () {
              ref.read(eventStateProvider.notifier).clearFilters();
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(message),
          const SizedBox(height: AppDimensions.spacingSmall),
          FilledButton(
            onPressed: () {
              ref.read(eventStateProvider.notifier).loadEvents();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _FilterSheet(),
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  String? selectedCategory;
  String? selectedStatus;
  DateTimeRange? selectedDateRange;

  final List<String> categories = [
    'Music',
    'Sports',
    'Arts',
    'Food',
    'Technology',
    'Business',
    'Education',
  ];

  final List<String> statuses = [
    'upcoming',
    'ongoing',
    'past',
  ];

  @override
  void initState() {
    super.initState();
    final filters = ref.read(eventStateProvider).filters;
    selectedCategory = filters.category;
    selectedStatus = filters.status;
    if (filters.startDate != null && filters.endDate != null) {
      selectedDateRange = DateTimeRange(
        start: filters.startDate!,
        end: filters.endDate!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: theme.textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Category filter
                    Text(
                      'Category',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSmall),
                    Wrap(
                      spacing: AppDimensions.spacingSmall,
                      children: categories.map((category) {
                        return FilterChip(
                          label: Text(category),
                          selected: selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = selected ? category : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppDimensions.spacingLarge),

                    // Status filter
                    Text(
                      'Status',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSmall),
                    Wrap(
                      spacing: AppDimensions.spacingSmall,
                      children: statuses.map((status) {
                        return FilterChip(
                          label: Text(status.toUpperCase()),
                          selected: selectedStatus == status,
                          onSelected: (selected) {
                            setState(() {
                              selectedStatus = selected ? status : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppDimensions.spacingLarge),

                    // Date range filter
                    Text(
                      'Date Range',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSmall),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          initialDateRange: selectedDateRange,
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDateRange = picked;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        selectedDateRange != null
                            ? '${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}'
                            : 'Select Date Range',
                      ),
                    ),
                    if (selectedDateRange != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedDateRange = null;
                          });
                        },
                        child: const Text('Clear Date Range'),
                      ),
                  ],
                ),
              ),

              // Action buttons
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = null;
                          selectedStatus = null;
                          selectedDateRange = null;
                        });
                        ref.read(eventStateProvider.notifier).clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final filters = EventFilters(
                          category: selectedCategory,
                          status: selectedStatus,
                          startDate: selectedDateRange?.start,
                          endDate: selectedDateRange?.end,
                        );
                        ref.read(eventStateProvider.notifier).loadEvents(filters: filters);
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
