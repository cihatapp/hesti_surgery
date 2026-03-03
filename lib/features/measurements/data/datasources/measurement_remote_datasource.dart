import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/supabase/supabase_constants.dart';
import '../../domain/entities/measurement.dart';

abstract class MeasurementRemoteDataSource {
  Future<List<Measurement>> getMeasurements(String caseId);
  Future<Measurement> saveMeasurement(Measurement measurement);
  Future<void> deleteMeasurement(String measurementId);
}

class MeasurementRemoteDataSourceImpl implements MeasurementRemoteDataSource {
  final SupabaseClient client;

  MeasurementRemoteDataSourceImpl({required this.client});

  @override
  Future<List<Measurement>> getMeasurements(String caseId) async {
    try {
      final data = await client
          .from(SupabaseConstants.measurementsTable)
          .select()
          .eq('case_id', caseId)
          .order('created_at');

      return data.map((json) => _mapToMeasurement(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch measurements: $e');
    }
  }

  @override
  Future<Measurement> saveMeasurement(Measurement measurement) async {
    try {
      final data = await client
          .from(SupabaseConstants.measurementsTable)
          .insert({
            'case_id': measurement.caseId,
            'surgeon_id': measurement.surgeonId,
            'measurement_type': measurement.measurementType,
            'value': measurement.value,
            'unit': measurement.unit,
            'phase': measurement.phase,
            if (measurement.landmarksUsed != null)
              'landmarks_used': measurement.landmarksUsed,
            if (measurement.notes != null) 'notes': measurement.notes,
          })
          .select()
          .single();

      return _mapToMeasurement(data);
    } catch (e) {
      throw ServerException(message: 'Failed to save measurement: $e');
    }
  }

  @override
  Future<void> deleteMeasurement(String measurementId) async {
    try {
      await client
          .from(SupabaseConstants.measurementsTable)
          .delete()
          .eq('id', measurementId);
    } catch (e) {
      throw ServerException(message: 'Failed to delete measurement: $e');
    }
  }

  Measurement _mapToMeasurement(Map<String, dynamic> json) => Measurement(
        id: json['id'] as String,
        caseId: json['case_id'] as String,
        surgeonId: json['surgeon_id'] as String,
        measurementType: json['measurement_type'] as String,
        value: (json['value'] as num).toDouble(),
        unit: json['unit'] as String? ?? 'degrees',
        phase: json['phase'] as String? ?? 'pre',
        landmarksUsed: json['landmarks_used'] as Map<String, dynamic>?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
