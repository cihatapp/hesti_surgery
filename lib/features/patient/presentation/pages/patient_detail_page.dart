import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../injection_container.dart';
import '../../../surgery_case/presentation/bloc/surgery_case_bloc.dart';
import '../../domain/entities/patient.dart';
import '../bloc/patient_list_bloc.dart';

@RoutePage()
class PatientDetailPage extends StatelessWidget {
  final String patientId;

  const PatientDetailPage({
    super.key,
    @PathParam('id') required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<PatientListBloc>()..add(const LoadPatients()),
        ),
        BlocProvider(
          create: (_) => sl<SurgeryCaseBloc>()
            ..add(LoadSurgeryCases(patientId: patientId)),
        ),
      ],
      child: _PatientDetailView(patientId: patientId),
    );
  }
}

class _PatientDetailView extends StatelessWidget {
  final String patientId;

  const _PatientDetailView({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientListBloc, PatientListState>(
      builder: (context, state) {
        if (state is PatientListLoaded) {
          final patient = state.patients.where((p) => p.id == patientId).firstOrNull;
          if (patient == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Patient not found')),
            );
          }
          return _buildDetail(context, patient);
        }
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildDetail(BuildContext context, Patient patient) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patient.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await context.router.push(
                PatientFormRoute(patientId: patient.id),
              );
              if (context.mounted) {
                context.read<PatientListBloc>().add(const LoadPatients());
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient name + age — simple left-aligned
            Text(
              patient.fullName,
              style: context.textTheme.headlineSmall,
            ),
            if (patient.age != null)
              Text(
                '${patient.age} years old',
                style: context.textTheme.bodyMedium,
              ),
            const SizedBox(height: AppSpacing.lg),

            // Details — flat list with dividers
            Text(
              'DETAILS',
              style: context.textTheme.labelMedium?.copyWith(
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (patient.gender != null) ...[
              _infoRow(context, 'Gender', patient.gender!),
              const Divider(),
            ],
            if (patient.phone != null) ...[
              _infoRow(context, 'Phone', patient.phone!),
              const Divider(),
            ],
            if (patient.email != null) ...[
              _infoRow(context, 'Email', patient.email!),
              const Divider(),
            ],
            if (patient.medicalNotes != null &&
                patient.medicalNotes!.isNotEmpty) ...[
              _infoRow(context, 'Notes', patient.medicalNotes!),
              const Divider(),
            ],
            const SizedBox(height: AppSpacing.md),

            // Surgery cases
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SURGERY CASES',
                  style: context.textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.2,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await context.router.push(
                      SurgeryCaseFormRoute(patientId: patient.id),
                    );
                    if (context.mounted) {
                      context.read<SurgeryCaseBloc>().add(
                            LoadSurgeryCases(patientId: patientId),
                          );
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Case'),
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
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: Text(
                          'No surgery cases yet',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: state.cases.map((c) {
                      final Color statusColor = switch (c.status) {
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
                          title: Text(c.title),
                          subtitle: Text(c.status.toUpperCase()),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.router.push(
                            SurgeryCaseDetailRoute(caseId: c.id),
                          ),
                        ),
                      );
                    }).toList(),
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

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: context.textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
