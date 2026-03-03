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
            onPressed: () => context.router.push(
              PatientFormRoute(patientId: patient.id),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          context.colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        patient.firstName[0].toUpperCase(),
                        style: context.textTheme.headlineMedium?.copyWith(
                          color: context.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      patient.fullName,
                      style: context.textTheme.titleLarge,
                    ),
                    if (patient.age != null)
                      Text(
                        '${patient.age} years old',
                        style: context.textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Details card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Details', style: context.textTheme.titleMedium),
                    const Divider(),
                    if (patient.gender != null)
                      _infoRow(context, 'Gender', patient.gender!),
                    if (patient.phone != null)
                      _infoRow(context, 'Phone', patient.phone!),
                    if (patient.email != null)
                      _infoRow(context, 'Email', patient.email!),
                    if (patient.medicalNotes != null &&
                        patient.medicalNotes!.isNotEmpty)
                      _infoRow(context, 'Notes', patient.medicalNotes!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Surgery cases
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Surgery Cases', style: context.textTheme.titleMedium),
                TextButton.icon(
                  onPressed: () => context.router.push(
                    SurgeryCaseFormRoute(patientId: patient.id),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Case'),
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
                      ),
                    );
                  }
                  return Column(
                    children: state.cases.map((c) {
                      return Card(
                        child: ListTile(
                          leading: _statusIcon(context, c.status),
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
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(child: Text(value, style: context.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _statusIcon(BuildContext context, String status) {
    final (IconData icon, Color color) = switch (status) {
      'planning' => (Icons.edit_note, Colors.blue),
      'scheduled' => (Icons.calendar_today, Colors.orange),
      'completed' => (Icons.check_circle, Colors.green),
      'archived' => (Icons.archive, Colors.grey),
      _ => (Icons.circle, Colors.grey),
    };
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
