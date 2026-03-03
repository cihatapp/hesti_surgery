import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/supabase/supabase_constants.dart';
import '../models/surgery_case_model.dart';

abstract class SurgeryCaseRemoteDataSource {
  Future<List<SurgeryCaseModel>> getSurgeryCases({String? patientId});
  Future<SurgeryCaseModel> getSurgeryCaseById(String id);
  Future<SurgeryCaseModel> createSurgeryCase(SurgeryCaseModel surgeryCase);
  Future<SurgeryCaseModel> updateSurgeryCase(SurgeryCaseModel surgeryCase);
  Future<void> deleteSurgeryCase(String id);
  Future<List<SurgeryCaseModel>> getRecentCases({int limit = 5});
}

class SurgeryCaseRemoteDataSourceImpl implements SurgeryCaseRemoteDataSource {
  final SupabaseClient client;

  SurgeryCaseRemoteDataSourceImpl({required this.client});

  @override
  Future<List<SurgeryCaseModel>> getSurgeryCases({String? patientId}) async {
    try {
      var query = client
          .from(SupabaseConstants.surgeryCasesTable)
          .select();

      if (patientId != null) {
        query = query.eq('patient_id', patientId);
      }

      final data = await query.order('updated_at', ascending: false);
      return data.map((json) => SurgeryCaseModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch surgery cases: $e');
    }
  }

  @override
  Future<SurgeryCaseModel> getSurgeryCaseById(String id) async {
    try {
      final data = await client
          .from(SupabaseConstants.surgeryCasesTable)
          .select()
          .eq('id', id)
          .single();

      return SurgeryCaseModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch surgery case: $e');
    }
  }

  @override
  Future<SurgeryCaseModel> createSurgeryCase(SurgeryCaseModel surgeryCase) async {
    try {
      final data = await client
          .from(SupabaseConstants.surgeryCasesTable)
          .insert(surgeryCase.toInsertMap())
          .select()
          .single();

      return SurgeryCaseModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Failed to create surgery case: $e');
    }
  }

  @override
  Future<SurgeryCaseModel> updateSurgeryCase(SurgeryCaseModel surgeryCase) async {
    try {
      final data = await client
          .from(SupabaseConstants.surgeryCasesTable)
          .update(surgeryCase.toUpdateMap())
          .eq('id', surgeryCase.id)
          .select()
          .single();

      return SurgeryCaseModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Failed to update surgery case: $e');
    }
  }

  @override
  Future<void> deleteSurgeryCase(String id) async {
    try {
      await client
          .from(SupabaseConstants.surgeryCasesTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw ServerException(message: 'Failed to delete surgery case: $e');
    }
  }

  @override
  Future<List<SurgeryCaseModel>> getRecentCases({int limit = 5}) async {
    try {
      final data = await client
          .from(SupabaseConstants.surgeryCasesTable)
          .select()
          .order('updated_at', ascending: false)
          .limit(limit);

      return data.map((json) => SurgeryCaseModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch recent cases: $e');
    }
  }
}
