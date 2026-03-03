import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/morph_parameters.dart';

class MorphControlPanel extends StatelessWidget {
  final MorphParameters parameters;
  final void Function(String name, double value) onParameterChanged;
  final VoidCallback onReset;
  final VoidCallback onSave;
  final bool hasUnsavedChanges;

  const MorphControlPanel({
    super.key,
    required this.parameters,
    required this.onParameterChanged,
    required this.onReset,
    required this.onSave,
    this.hasUnsavedChanges = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Morph Controls', style: context.textTheme.titleMedium),
                Row(
                  children: [
                    TextButton(onPressed: onReset, child: const Text('Reset')),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: hasUnsavedChanges ? onSave : null,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sliders
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                _MorphSlider(
                  label: 'Tip Projection',
                  value: parameters.tipProjection,
                  min: -5,
                  max: 5,
                  unit: 'mm',
                  onChanged: (v) =>
                      onParameterChanged('tipProjection', v),
                ),
                _MorphSlider(
                  label: 'Dorsal Hump',
                  value: parameters.dorsalHumpReduction,
                  min: 0,
                  max: 100,
                  unit: '%',
                  onChanged: (v) =>
                      onParameterChanged('dorsalHumpReduction', v),
                ),
                _MorphSlider(
                  label: 'Tip Rotation',
                  value: parameters.tipRotation,
                  min: -15,
                  max: 15,
                  unit: '°',
                  onChanged: (v) =>
                      onParameterChanged('tipRotation', v),
                ),
                _MorphSlider(
                  label: 'Nostril Width',
                  value: parameters.nostrilWidth,
                  min: -3,
                  max: 3,
                  unit: 'mm',
                  onChanged: (v) =>
                      onParameterChanged('nostrilWidth', v),
                ),
                _MorphSlider(
                  label: 'Chin Projection',
                  value: parameters.chinProjection,
                  min: -5,
                  max: 5,
                  unit: 'mm',
                  onChanged: (v) =>
                      onParameterChanged('chinProjection', v),
                ),
                _MorphSlider(
                  label: 'Bridge Width',
                  value: parameters.bridgeWidth,
                  min: -3,
                  max: 3,
                  unit: 'mm',
                  onChanged: (v) =>
                      onParameterChanged('bridgeWidth', v),
                ),
                _MorphSlider(
                  label: 'Alar Base',
                  value: parameters.alarBase,
                  min: -3,
                  max: 3,
                  unit: 'mm',
                  onChanged: (v) =>
                      onParameterChanged('alarBase', v),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MorphSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  const _MorphSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: context.textTheme.bodyMedium),
              Text(
                '${value.toStringAsFixed(1)} $unit',
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 10).toInt(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
