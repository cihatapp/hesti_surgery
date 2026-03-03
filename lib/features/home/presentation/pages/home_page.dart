import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Legacy home page - replaced by DashboardPage.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return _buildContent(context, state);
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Authenticated state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: context.colorScheme.primary,
                    child: Text(
                      state.user.name?.isNotEmpty == true
                          ? state.user.name![0].toUpperCase()
                          : state.user.email[0].toUpperCase(),
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: context.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: context.textTheme.bodyMedium,
                        ),
                        Text(
                          state.user.name ?? state.user.email,
                          style: context.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Quick actions
          Text(
            'Quick Actions',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.5,
            children: [
              _buildQuickAction(
                context,
                icon: Icons.person,
                title: 'Profile',
                onTap: () {},
              ),
              _buildQuickAction(
                context,
                icon: Icons.notifications,
                title: 'Notifications',
                onTap: () {},
              ),
              _buildQuickAction(
                context,
                icon: Icons.favorite,
                title: 'Favorites',
                onTap: () {},
              ),
              _buildQuickAction(
                context,
                icon: Icons.history,
                title: 'History',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Recent activity
          Text(
            'Recent Activity',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: context.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.access_time,
                      color: context.colorScheme.primary,
                    ),
                  ),
                  title: Text('Activity ${index + 1}'),
                  subtitle: Text('${index + 1} hour${index > 0 ? 's' : ''} ago'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: context.textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
