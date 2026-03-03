import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/patient.dart';

part 'patient_model.freezed.dart';
part 'patient_model.g.dart';

@freezed
abstract class PatientModel with _$PatientModel {
  const PatientModel._();

  const factory PatientModel({
    required String id,
    @JsonKey(name: 'surgeon_id') required String surgeonId,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? email,
    @JsonKey(name: 'medical_notes') String? medicalNotes,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _PatientModel;

  factory PatientModel.fromJson(Map<String, dynamic> json) =>
      _$PatientModelFromJson(json);

  Patient toEntity() => Patient(
        id: id,
        surgeonId: surgeonId,
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        phone: phone,
        email: email,
        medicalNotes: medicalNotes,
        avatarUrl: avatarUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory PatientModel.fromEntity(Patient entity) => PatientModel(
        id: entity.id,
        surgeonId: entity.surgeonId,
        firstName: entity.firstName,
        lastName: entity.lastName,
        dateOfBirth: entity.dateOfBirth,
        gender: entity.gender,
        phone: entity.phone,
        email: entity.email,
        medicalNotes: entity.medicalNotes,
        avatarUrl: entity.avatarUrl,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  /// Convert to Supabase insert map (excludes id, timestamps)
  Map<String, dynamic> toInsertMap() => {
        'surgeon_id': surgeonId,
        'first_name': firstName,
        'last_name': lastName,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth!.toIso8601String().split('T').first,
        if (gender != null) 'gender': gender,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (medicalNotes != null) 'medical_notes': medicalNotes,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

  /// Convert to Supabase update map
  Map<String, dynamic> toUpdateMap() => {
        'first_name': firstName,
        'last_name': lastName,
        'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
        'gender': gender,
        'phone': phone,
        'email': email,
        'medical_notes': medicalNotes,
        'avatar_url': avatarUrl,
      };
}
