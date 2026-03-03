import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class SupabaseConstants {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get falAiApiKey => dotenv.env['FAL_AI_API_KEY'] ?? '';

  // Storage bucket names
  static const String patientPhotosBucket = 'patient-photos';
  static const String modelsThreeDBucket = '3d-models';
  static const String reportsBucket = 'reports';

  // Table names
  static const String surgeonProfilesTable = 'surgeon_profiles';
  static const String patientsTable = 'patients';
  static const String surgeryCasesTable = 'surgery_cases';
  static const String photosTable = 'photos';
  static const String modelsThreeDTable = 'models_3d';
  static const String measurementsTable = 'measurements';

  // Photo angles
  static const List<String> photoAngles = [
    'front',
    'left_profile',
    'right_profile',
    'three_quarter_left',
    'three_quarter_right',
    'base',
  ];

  // Surgery case statuses
  static const String statusPlanning = 'planning';
  static const String statusScheduled = 'scheduled';
  static const String statusCompleted = 'completed';
  static const String statusArchived = 'archived';
}
