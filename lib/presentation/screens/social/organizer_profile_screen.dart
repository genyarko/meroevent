import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/user.dart';
import '../../providers/social_provider.dart';
import '../../providers/auth_provider.dart';

/// Screen displaying organizer profile with reviews and stats
class OrganizerProfileScreen extends ConsumerWidget {
  final OrganizerProfile profile;
  final String? userId; // Optional user ID for the organizer

  const OrganizerProfileScreen({
    super.key,
    required this.profile,
    this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reviewsAsync = ref.watch(organizerReviewsProvider(profile.id));
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with profile header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(profile.displayName),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primaryContainer,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40), // Account for app bar
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.business,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (profile.isVerified) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verified Organizer',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              // Follow button (if user is logged in and not viewing own profile)
              if (currentUser != null && userId != null && currentUser.id != userId)
                Consumer(
                  builder: (context, ref, child) {
                    final followState = ref.watch(followProvider(userId!));
                    return IconButton(
                      icon: Icon(
                        followState.isFollowing ? Icons.favorite : Icons.favorite_border,
                      ),
                      onPressed: followState.isLoading
                          ? null
                          : () async {
                              await ref
                                  .read(followProvider(userId!).notifier)
                                  .toggleFollow(userId!, 'organizer');
                            },
                    );
                  },
                ),
            ],
          ),

          // Stats section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn(
                    context,
                    theme,
                    'Events',
                    profile.totalEventsHosted.toString(),
                  ),
                  _buildStatColumn(
                    context,
                    theme,
                    'Tickets Sold',
                    profile.totalTicketsSold.toString(),
                  ),
                  _buildStatColumn(
                    context,
                    theme,
                    'Rating',
                    profile.averageRating != null
                        ? profile.averageRating!.toStringAsFixed(1)
                        : 'N/A',
                  ),
                ],
              ),
            ),
          ),

          // About section
          if (profile.bio != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.bio!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

          // Organization type
          if (profile.organizationType != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                ),
                child: Chip(
                  label: Text(_formatOrganizationType(profile.organizationType!)),
                  avatar: const Icon(Icons.info_outline, size: 16),
                ),
              ),
            ),

          // Links section
          if (profile.websiteUrl != null || (profile.socialLinks?.isNotEmpty ?? false))
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Links',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (profile.websiteUrl != null)
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: const Text('Website'),
                        subtitle: Text(profile.websiteUrl!),
                        onTap: () => _launchUrl(profile.websiteUrl!),
                        contentPadding: EdgeInsets.zero,
                      ),
                    if (profile.socialLinks != null)
                      ...profile.socialLinks!.entries.map((entry) {
                        return ListTile(
                          leading: _getSocialIcon(entry.key),
                          title: Text(_formatSocialName(entry.key)),
                          subtitle: Text(entry.value),
                          onTap: () => _launchUrl(entry.value),
                          contentPadding: EdgeInsets.zero,
                        );
                      }),
                  ],
                ),
              ),
            ),

          // Reviews section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Text(
                'Reviews',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          reviewsAsync.when(
            data: (reviews) {
              if (reviews.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: Center(
                      child: Text(
                        'No reviews yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final review = reviews[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage: review.userAvatarUrl != null
                                        ? NetworkImage(review.userAvatarUrl!)
                                        : null,
                                    child: review.userAvatarUrl == null
                                        ? Text(review.displayName[0].toUpperCase())
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      review.displayName,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < review.rating ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              if (review.hasComment) ...[
                                const SizedBox(height: 8),
                                Text(
                                  review.comment!,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: reviews.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Center(child: Text('Error loading reviews: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
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

  Icon _getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return const Icon(Icons.facebook);
      case 'twitter':
      case 'x':
        return const Icon(Icons.alternate_email);
      case 'instagram':
        return const Icon(Icons.camera_alt);
      case 'linkedin':
        return const Icon(Icons.business_center);
      default:
        return const Icon(Icons.link);
    }
  }

  String _formatSocialName(String platform) {
    return platform[0].toUpperCase() + platform.substring(1);
  }

  String _formatOrganizationType(String type) {
    switch (type) {
      case 'individual':
        return 'Individual Organizer';
      case 'company':
        return 'Company';
      case 'nonprofit':
        return 'Non-Profit Organization';
      default:
        return type;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
