import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/supabase/supabase_constants.dart';
import '../models/patient_model.dart';

abstract class PatientRemoteDataSource {
  Future<List<PatientModel>> getPatients();
  Future<PatientModel> getPatientById(String id);
  Future<PatientModel> createPatient(PatientModel patient);
  Future<PatientModel> updatePatient(PatientModel patient);
  Future<void> deletePatient(String id);
  Future<List<PatientModel>> searchPatients(String query);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final SupabaseClient client;

  PatientRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PatientModel>> getPatients() async {
    try {
      final data = await client
          .from(SupabaseConstants.patientsTable)
          .select()
          .order('updated_at', ascending: false);

      return data.map((json) => PatientModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch patients: $e');
    }
  }

  @override
  Future<PatientModel> getPatientById(String id) async {
    try {
      final data = await client
          .from(SupabaseConstants.patientsTable)
          .select()
          .eq('id', id)
          .single();

      return PatientModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch patient: $e');
    }
  }

  @override
  Future<PatientModel> createPatient(PatientModel patient) async {
    try {
      final data = await client
          .from(SupabaseConstants.patientsTable)
          .insert(patient.toInsertMap())
          .select()
          .single();

      return PatientModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Failed to create patient: $e');
    }
  }

  @override
  Future<PatientModel> updatePatient(PatientModel patient) async {
    try {
      final data = await client
          .from(SupabaseConstants.patientsTable)
          .update(patient.toUpdateMap())
          .eq('id', patient.id)
          .select()
          .single();

      return PatientModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Failed to update patient: $e');
    }
  }

  @override
  Future<void> deletePatient(String id) async {
    try {
      await client
          .from(SupabaseConstants.patientsTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw ServerException(message: 'Failed to delete patient: $e');
    }
  }

  @override
  Future<List<PatientModel>> searchPatients(String query) async {
    try {
      final data = await client
          .from(SupabaseConstants.patientsTable)
          .select()
          .or('first_name.ilike.%$query%,last_name.ilike.%$query%,email.ilike.%$query%')
          .order('updated_at', ascending: false);

      return data.map((json) => PatientModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to search patients: $e');
    }
  }
}
