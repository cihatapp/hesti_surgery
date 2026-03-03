import 'dart:convert';

import '../../../../core/database/hive_manager.dart';
import '../models/patient_model.dart';

abstract class PatientLocalDataSource {
  Future<List<PatientModel>> getCachedPatients();
  Future<void> cachePatients(List<PatientModel> patients);
  Future<void> clearCache();
}

class PatientLocalDataSourceImpl implements PatientLocalDataSource {
  final HiveManager hiveManager;
  static const String _boxName = 'patients_cache';

  PatientLocalDataSourceImpl({required this.hiveManager});

  @override
  Future<List<PatientModel>> getCachedPatients() async {
    try {
      final box = await hiveManager.openBox<String>(_boxName);
      final jsonList = box.get('patients');
      if (jsonList == null) return [];

      final list = jsonDecode(jsonList) as List;
      return list
          .map((e) => PatientModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> cachePatients(List<PatientModel> patients) async {
    try {
      final box = await hiveManager.openBox<String>(_boxName);
      final jsonList = jsonEncode(patients.map((p) => p.toJson()).toList());
      await box.put('patients', jsonList);
    } catch (_) {
      // Cache failure is non-critical
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await hiveManager.clearBox(_boxName);
    } catch (_) {}
  }
}
