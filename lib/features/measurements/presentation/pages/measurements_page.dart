import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/measurement.dart';
import '../bloc/measurement_bloc.dart';

@RoutePage()
class MeasurementsPage extends StatelessWidget {
  final String caseId;

  const MeasurementsPage({
    super.key,
    @PathParam('caseId') required this.caseId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MeasurementBloc>()..add(LoadMeasurements(caseId)),
      child: _MeasurementsView(caseId: caseId),
    );
  }
}

class _MeasurementsView extends StatelessWidget {
  final String caseId;

  const _MeasurementsView({required this.caseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurements'),
      ),
      body: BlocBuilder<MeasurementBloc, MeasurementState>(
        builder: (context, state) {
          if (state is MeasurementLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MeasurementsLoaded) {
            return _buildMeasurements(context, state);
          }
          if (state is MeasurementError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMeasurements(BuildContext context, MeasurementsLoaded state) {
    final grouped = state.grouped;

    if (state.measurements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.straighten,
              size: 64,
              color: context.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('No measurements yet'),
            const SizedBox(height: AppSpacing.sm),
            const Text('Measurements will be auto-calculated from landmarks'),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (grouped.containsKey('pre'))
          _buildPhaseSection(context, 'Pre-operative', grouped['pre']!),
        if (grouped.containsKey('planned'))
          _buildPhaseSection(context, 'Planned', grouped['planned']!),
        if (grouped.containsKey('post'))
          _buildPhaseSection(context, 'Post-operative', grouped['post']!),
      ],
    );
  }

  Widget _buildPhaseSection(
    BuildContext context,
    String title,
    List<Measurement> measurements,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Column(
            children: measurements.map((m) {
              final range = MeasurementTypes.normalRange(m.measurementType);
              final isInRange = range == null ||
                  (m.value >= range.$1 && m.value <= range.$2);

              return ListTile(
                title: Text(m.displayName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      m.formattedValue,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: isInRange ? null : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!isInRange) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: Colors.orange,
                      ),
                    ],
                  ],
                ),
                subtitle: range != null
                    ? Text(
                        'Normal: ${range.$1}° - ${range.$2}°',
                        style: context.textTheme.bodySmall,
                      )
                    : null,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
