import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_outlined, size: 64),
              const SizedBox(height: AppDimensions.spacingMedium),
              const Text('Not logged in'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
              ),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.colorScheme.primary,
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? Text(
                                user.displayName[0].toUpperCase(),
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              color: theme.colorScheme.onPrimary,
                              size: 20,
                            ),
                            onPressed: () {
                              // TODO: Implement image picker
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Image picker coming soon'),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  Text(
                    user.displayName,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text(
                    user.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingSmall),
                    Text(
                      user.bio!,
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppDimensions.spacingMedium),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        context,
                        'Events Attended',
                        user.totalEventsAttended.toString(),
                      ),
                      _buildStatItem(
                        context,
                        'Karma Points',
                        user.karmaPoints.toString(),
                      ),
                      _buildStatItem(
                        context,
                        'Events Created',
                        user.totalEventsCreated.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Profile sections
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information
                  Text(
                    'Personal Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Card(
                    child: Column(
                      children: [
                        if (user.phoneNumber != null)
                          _buildInfoTile(
                            context,
                            Icons.phone_outlined,
                            'Phone',
                            user.phoneNumber!,
                          ),
                        if (user.dateOfBirth != null)
                          _buildInfoTile(
                            context,
                            Icons.cake_outlined,
                            'Birthday',
                            _formatDate(user.dateOfBirth!),
                          ),
                        if (user.gender != null)
                          _buildInfoTile(
                            context,
                            Icons.person_outline,
                            'Gender',
                            user.gender!,
                          ),
                        if (user.location != null || user.city != null)
                          _buildInfoTile(
                            context,
                            Icons.location_on_outlined,
                            'Location',
                            user.location ?? '${user.city}, ${user.country}',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLarge),

                  // Verification Status
                  Text(
                    'Account Status',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Card(
                    child: Column(
                      children: [
                        _buildStatusTile(
                          context,
                          Icons.email_outlined,
                          'Email Verification',
                          user.isEmailVerified,
                        ),
                        _buildStatusTile(
                          context,
                          Icons.phone_outlined,
                          'Phone Verification',
                          user.isPhoneVerified,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLarge),

                  // Actions
                  FilledButton.icon(
                    onPressed: () => context.push('/edit-profile'),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        await ref.read(authStateProvider.notifier).signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  Widget _buildStatusTile(
    BuildContext context,
    IconData icon,
    String label,
    bool verified,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label),
      trailing: verified
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Verified',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ],
            )
          : TextButton(
              onPressed: () {
                // TODO: Implement verification
              },
              child: const Text('Verify'),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
