import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/patient.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                alignment: Alignment.center,
                child: Text(
                  patient.firstName[0].toUpperCase(),
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: context.textTheme.titleSmall,
                    ),
                    if (patient.age != null || patient.gender != null)
                      Text(
                        [
                          if (patient.age != null) '${patient.age} yrs',
                          if (patient.gender != null) patient.gender,
                        ].join(' \u00B7 '),
                        style: context.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
