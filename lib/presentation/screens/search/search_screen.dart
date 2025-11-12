import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../providers/event_provider.dart';
import '../../widgets/event_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventState = ref.watch(eventStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          decoration: const InputDecoration(
            hintText: 'Search events...',
            border: InputBorder.none,
          ),
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              ref.read(eventStateProvider.notifier).searchEvents(query);
            }
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(eventStateProvider.notifier).clearFilters();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Recent searches or suggestions
          if (_searchController.text.isEmpty)
            Expanded(child: _buildSearchSuggestions(theme))
          else if (eventState.isLoading && eventState.events.isEmpty)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (eventState.errorMessage != null)
            Expanded(
              child: _buildErrorState(theme, eventState.errorMessage!),
            )
          else if (eventState.events.isEmpty)
            Expanded(child: _buildEmptyState(theme))
          else
            Expanded(child: _buildSearchResults(eventState)),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions(ThemeData theme) {
    final popularSearches = [
      'Music concerts',
      'Tech meetups',
      'Food festivals',
      'Sports events',
      'Art exhibitions',
      'Business conferences',
    ];

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      children: [
        Text(
          'Popular Searches',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Wrap(
          spacing: AppDimensions.spacingSmall,
          runSpacing: AppDimensions.spacingSmall,
          children: popularSearches.map((search) {
            return ActionChip(
              avatar: const Icon(Icons.search, size: 18),
              label: Text(search),
              onPressed: () {
                _searchController.text = search;
                ref.read(eventStateProvider.notifier).searchEvents(search);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        Text(
          'Search by Category',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        _buildCategoryGrid(theme),
      ],
    );
  }

  Widget _buildCategoryGrid(ThemeData theme) {
    final categories = [
      {'name': 'Music', 'icon': Icons.music_note},
      {'name': 'Sports', 'icon': Icons.sports_soccer},
      {'name': 'Arts', 'icon': Icons.palette},
      {'name': 'Food', 'icon': Icons.restaurant},
      {'name': 'Technology', 'icon': Icons.computer},
      {'name': 'Business', 'icon': Icons.business},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppDimensions.spacingMedium,
        mainAxisSpacing: AppDimensions.spacingMedium,
        childAspectRatio: 1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          child: InkWell(
            onTap: () {
              _searchController.text = category['name'] as String;
              ref.read(eventStateProvider.notifier).filterByCategory(
                    category['name'] as String,
                  );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(EventState eventState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Text(
            '${eventState.events.length} results found',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
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
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            'No events found',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            'Try searching with different keywords',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String message) {
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
              if (_searchController.text.isNotEmpty) {
                ref
                    .read(eventStateProvider.notifier)
                    .searchEvents(_searchController.text);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
