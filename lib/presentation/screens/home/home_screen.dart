import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../providers/event_provider.dart';
import '../../widgets/event_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<String> categories = [
    'All',
    'Music',
    'Sports',
    'Arts',
    'Food',
    'Technology',
    'Business',
    'Education',
  ];

  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // Load events on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventStateProvider.notifier).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final featuredEventsAsync = ref.watch(featuredEventsProvider);
    final eventState = ref.watch(eventStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MeroEvent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(featuredEventsProvider);
          await ref.read(eventStateProvider.notifier).loadEvents();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero section
              _buildHeroSection(theme),

              // Categories
              _buildCategories(theme),

              // Featured events
              _buildFeaturedEvents(theme, featuredEventsAsync),

              // Upcoming events
              _buildUpcomingEvents(theme, eventState),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-event'),
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover Events',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            'Find amazing events happening near you',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          FilledButton.icon(
            onPressed: () => context.push('/events'),
            icon: const Icon(Icons.explore),
            label: const Text('Explore All Events'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.onPrimary,
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Text(
            'Categories',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == selectedCategory;

              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.spacingSmall),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedCategory = category;
                    });
                    if (category == 'All') {
                      ref.read(eventStateProvider.notifier).filterByCategory(null);
                    } else {
                      ref.read(eventStateProvider.notifier).filterByCategory(category);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedEvents(
    ThemeData theme,
    AsyncValue<List> featuredEventsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Events',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/events?featured=true'),
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        featuredEventsAsync.when(
          data: (events) {
            if (events.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppDimensions.paddingLarge),
                child: Center(
                  child: Text('No featured events available'),
                ),
              );
            }

            return SizedBox(
              height: 320,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                ),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: AppDimensions.spacingMedium,
                      ),
                      child: EventCard(event: events[index]),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 320,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text('Error loading featured events'),
                  TextButton(
                    onPressed: () => ref.invalidate(featuredEventsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingEvents(ThemeData theme, eventState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  selectedCategory == 'All'
                      ? 'Upcoming Events'
                      : '$selectedCategory Events',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/events'),
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        if (eventState.isLoading && eventState.events.isEmpty)
          const Padding(
            padding: EdgeInsets.all(AppDimensions.paddingLarge),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (eventState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text(eventState.errorMessage!),
                  TextButton(
                    onPressed: () {
                      ref.read(eventStateProvider.notifier).loadEvents();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (eventState.events.isEmpty)
          const Padding(
            padding: EdgeInsets.all(AppDimensions.paddingLarge),
            child: Center(child: Text('No events found')),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
            ),
            itemCount: eventState.events.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.spacingMedium,
                ),
                child: EventCard(event: eventState.events[index]),
              );
            },
          ),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }
}
