import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/entities/review.dart';
import '../../providers/social_provider.dart';
import '../../providers/auth_provider.dart';
import 'write_review_screen.dart';

/// Screen displaying reviews for an event
class EventReviewsScreen extends ConsumerWidget {
  final Event event;

  const EventReviewsScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reviewsAsync = ref.watch(eventReviewsProvider(event.id));
    final ratingSummaryAsync = ref.watch(eventRatingSummaryProvider(event.id));
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews & Ratings'),
      ),
      body: reviewsAsync.when(
        data: (reviews) => CustomScrollView(
          slivers: [
            // Rating Summary Header
            SliverToBoxAdapter(
              child: ratingSummaryAsync.when(
                data: (summary) => _buildRatingSummaryCard(context, theme, summary),
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => const SizedBox.shrink(),
              ),
            ),

            // Write Review Button
            if (user != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WriteReviewScreen(event: event),
                        ),
                      );
                    },
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Write a Review'),
                  ),
                ),
              ),

            // Reviews List
            if (reviews.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(context, theme),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildReviewCard(context, theme, reviews[index]),
                    childCount: reviews.length,
                  ),
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading reviews: $error'),
        ),
      ),
    );
  }

  Widget _buildRatingSummaryCard(
    BuildContext context,
    ThemeData theme,
    EventRatingSummary summary,
  ) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        children: [
          // Average Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                summary.averageRating.toStringAsFixed(1),
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 40,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${summary.totalReviews} ${summary.totalReviews == 1 ? 'review' : 'reviews'}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          // Rating Distribution
          ...List.generate(5, (index) {
            final stars = 5 - index;
            return _buildRatingBar(
              context,
              theme,
              stars,
              summary.getRatingCount(stars),
              summary.getRatingPercentage(stars),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRatingBar(
    BuildContext context,
    ThemeData theme,
    int stars,
    int count,
    double percentage,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$stars'),
          const SizedBox(width: 4),
          Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surface,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '$count',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, ThemeData theme, EventReview review) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and rating
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundImage: review.userAvatarUrl != null
                      ? NetworkImage(review.userAvatarUrl!)
                      : null,
                  child: review.userAvatarUrl == null
                      ? Text(review.displayName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: AppDimensions.spacingSmall),

                // Name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.displayName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (review.isVerifiedAttendee) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        DateFormat('MMM d, yyyy').format(review.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Rating stars
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                ),
              ],
            ),

            // Review comment
            if (review.hasComment) ...[
              const SizedBox(height: AppDimensions.spacingMedium),
              Text(
                review.comment!,
                style: theme.textTheme.bodyMedium,
              ),
            ],

            // Review images
            if (review.hasImages) ...[
              const SizedBox(height: AppDimensions.spacingMedium),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.imageUrls!.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppDimensions.spacingSmall),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      child: Image.network(
                        review.imageUrls![index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],

            // Helpful button
            const SizedBox(height: AppDimensions.spacingSmall),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: Mark as helpful
                  },
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: Text('Helpful (${review.helpfulCount})'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
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
              Icons.rate_review_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Text(
              'No Reviews Yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              'Be the first to review this event!',
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
