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
            // Welcome header
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return _WelcomeCard(
                    name: state.user.name ?? state.user.email,
                    clinicName: state.user.clinicName,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Quick actions
            Text('Quick Actions', style: context.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.person_add,
                    title: 'New Patient',
                    color: Colors.blue,
                    onTap: () => context.router.push(PatientFormRoute()),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.camera_alt,
                    title: 'Capture',
                    color: Colors.green,
                    onTap: () {
                      context.router.push(PatientListRoute());
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.view_in_ar,
                    title: '3D View',
                    color: Colors.purple,
                    onTap: () {
                      context.router.push(PatientListRoute());
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
                Text('Recent Cases', style: context.textTheme.titleMedium),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
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
                              onTap: () => context.router.push(
                                SurgeryCaseDetailRoute(caseId: c.id),
                              ),
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

class _WelcomeCard extends StatelessWidget {
  final String name;
  final String? clinicName;

  const _WelcomeCard({required this.name, this.clinicName});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Icon(
                Icons.medical_services,
                color: context.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Dr. $name',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.onPrimary,
                    ),
                  ),
                  if (clinicName != null)
                    Text(
                      clinicName!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color:
                            context.colorScheme.onPrimary.withValues(alpha: 0.8),
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
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                title,
                style: context.textTheme.labelSmall,
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
    final (Color color, IconData icon) = switch (surgeryCase.status) {
      'planning' => (Colors.blue, Icons.edit_note),
      'scheduled' => (Colors.orange, Icons.calendar_today),
      'completed' => (Colors.green, Icons.check_circle),
      'archived' => (Colors.grey, Icons.archive),
      _ => (Colors.grey, Icons.circle),
    };

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(surgeryCase.title),
        subtitle: Text(
          '${surgeryCase.surgeryType} - ${surgeryCase.status}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
