import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/surgery_case.dart';
import '../bloc/surgery_case_bloc.dart';

@RoutePage()
class SurgeryCaseDetailPage extends StatelessWidget {
  final String caseId;

  const SurgeryCaseDetailPage({
    super.key,
    @PathParam('id') required this.caseId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SurgeryCaseBloc>()..add(const LoadSurgeryCases()),
      child: _SurgeryCaseDetailView(caseId: caseId),
    );
  }
}

class _SurgeryCaseDetailView extends StatelessWidget {
  final String caseId;

  const _SurgeryCaseDetailView({required this.caseId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SurgeryCaseBloc, SurgeryCaseState>(
      builder: (context, state) {
        if (state is SurgeryCaseListLoaded) {
          final surgeryCase =
              state.cases.where((c) => c.id == caseId).firstOrNull;
          if (surgeryCase == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Case not found')),
            );
          }
          return _buildDetail(context, surgeryCase);
        }
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildDetail(BuildContext context, SurgeryCase surgeryCase) {
    return Scaffold(
      appBar: AppBar(
        title: Text(surgeryCase.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status chip
            _StatusChip(status: surgeryCase.status),
            const SizedBox(height: AppSpacing.md),

            // Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Case Details',
                        style: context.textTheme.titleMedium),
                    const Divider(),
                    _infoRow(context, 'Type', surgeryCase.surgeryType),
                    if (surgeryCase.description != null)
                      _infoRow(context, 'Description', surgeryCase.description!),
                    if (surgeryCase.scheduledDate != null)
                      _infoRow(
                        context,
                        'Scheduled',
                        '${surgeryCase.scheduledDate!.day}/${surgeryCase.scheduledDate!.month}/${surgeryCase.scheduledDate!.year}',
                      ),
                    if (surgeryCase.surgeonNotes != null)
                      _infoRow(context, 'Notes', surgeryCase.surgeonNotes!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Action buttons
            Text(
              'ACTIONS',
              style: context.textTheme.labelMedium?.copyWith(
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionCard(
              icon: Icons.camera_alt_outlined,
              title: 'Capture Photos',
              subtitle: 'Take multi-angle photos',
              onTap: () {
                context.router.push(PhotoCaptureRoute(caseId: caseId));
              },
            ),
            _ActionCard(
              icon: Icons.view_in_ar_outlined,
              title: '3D Reconstruction',
              subtitle: 'Generate 3D model from photos',
              onTap: () {
                context.router.push(ModelViewerRoute(caseId: caseId));
              },
            ),
            _ActionCard(
              icon: Icons.straighten_outlined,
              title: 'Measurements',
              subtitle: 'Anatomical measurements',
              onTap: () {
                context.router.push(MeasurementsRoute(caseId: caseId));
              },
            ),
            _ActionCard(
              icon: Icons.picture_as_pdf_outlined,
              title: 'Generate Report',
              subtitle: 'PDF report with all data',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Report generation requires completed measurements. '
                      'Complete the workflow first.',
                    ),
                  ),
                );
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
            width: 100,
            child: Text(
              label,
              style: context.textTheme.bodySmall,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status) {
      'planning' => (context.colorScheme.primary, 'Planning'),
      'scheduled' => (const Color(0xFFD97706), 'Scheduled'),
      'completed' => (const Color(0xFF059669), 'Completed'),
      'archived' => (const Color(0xFF9CA3AF), 'Archived'),
      _ => (const Color(0xFF9CA3AF), status),
    };

    return Chip(
      label: Text(label, style: TextStyle(color: color)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: context.colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
