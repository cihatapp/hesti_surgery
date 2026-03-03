import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../surgery_case/domain/entities/surgery_case.dart';
import '../../../surgery_case/presentation/bloc/surgery_case_bloc.dart';

@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SurgeryCaseBloc>()..add(const LoadSurgeryCases()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesti Surgery'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome text
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, Dr. ${state.user.name ?? state.user.email}',
                        style: context.textTheme.headlineSmall,
                      ),
                      if (state.user.clinicName != null)
                        Text(
                          state.user.clinicName!,
                          style: context.textTheme.bodyMedium,
                        ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Quick actions
            Text(
              'QUICK ACTIONS',
              style: context.textTheme.labelMedium?.copyWith(
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.person_add_outlined,
                    title: 'New Patient',
                    onTap: () async {
                      await context.router.push(PatientFormRoute());
                      if (context.mounted) {
                        context
                            .read<SurgeryCaseBloc>()
                            .add(const LoadSurgeryCases());
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.view_in_ar_outlined,
                    title: '3D View',
                    onTap: () {
                      context.router.push(const PatientListRoute());
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Recent cases
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT CASES',
                  style: context.textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.2,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            BlocBuilder<SurgeryCaseBloc, SurgeryCaseState>(
              builder: (context, state) {
                if (state is SurgeryCaseLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SurgeryCaseListLoaded) {
                  if (state.cases.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.medical_services_outlined,
                                size: 48,
                                color: context.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              const Text('No surgery cases yet'),
                              const SizedBox(height: AppSpacing.sm),
                              const Text(
                                'Create a patient and start a new case',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: state.cases
                        .take(5)
                        .map((c) => _RecentCaseCard(
                              surgeryCase: c,
                              onTap: () async {
                                await context.router.push(
                                  SurgeryCaseDetailRoute(caseId: c.id),
                                );
                                if (context.mounted) {
                                  context
                                      .read<SurgeryCaseBloc>()
                                      .add(const LoadSurgeryCases());
                                }
                              },
                            ))
                        .toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: context.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                title,
                style: context.textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentCaseCard extends StatelessWidget {
  final SurgeryCase surgeryCase;
  final VoidCallback onTap;

  const _RecentCaseCard({required this.surgeryCase, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = switch (surgeryCase.status) {
      'planning' => context.colorScheme.primary,
      'scheduled' => const Color(0xFFD97706),
      'completed' => const Color(0xFF059669),
      'archived' => const Color(0xFF9CA3AF),
      _ => const Color(0xFF9CA3AF),
    };

    return Card(
      child: ListTile(
        leading: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(surgeryCase.title),
        subtitle: Text(
          '${surgeryCase.surgeryType} \u00B7 ${surgeryCase.status}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
