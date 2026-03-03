import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/surgery_case.dart';

part 'surgery_case_model.freezed.dart';
part 'surgery_case_model.g.dart';

@freezed
abstract class SurgeryCaseModel with _$SurgeryCaseModel {
  const SurgeryCaseModel._();

  const factory SurgeryCaseModel({
    required String id,
    @JsonKey(name: 'surgeon_id') required String surgeonId,
    @JsonKey(name: 'patient_id') required String patientId,
    required String title,
    String? description,
    @JsonKey(name: 'surgery_type') @Default('rhinoplasty') String surgeryType,
    @Default('planning') String status,
    @JsonKey(name: 'scheduled_date') DateTime? scheduledDate,
    @JsonKey(name: 'completed_date') DateTime? completedDate,
    @JsonKey(name: 'surgeon_notes') String? surgeonNotes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _SurgeryCaseModel;

  factory SurgeryCaseModel.fromJson(Map<String, dynamic> json) =>
      _$SurgeryCaseModelFromJson(json);

  SurgeryCase toEntity() => SurgeryCase(
        id: id,
        surgeonId: surgeonId,
        patientId: patientId,
        title: title,
        description: description,
        surgeryType: surgeryType,
        status: status,
        scheduledDate: scheduledDate,
        completedDate: completedDate,
        surgeonNotes: surgeonNotes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory SurgeryCaseModel.fromEntity(SurgeryCase entity) => SurgeryCaseModel(
        id: entity.id,
        surgeonId: entity.surgeonId,
        patientId: entity.patientId,
        title: entity.title,
        description: entity.description,
        surgeryType: entity.surgeryType,
        status: entity.status,
        scheduledDate: entity.scheduledDate,
        completedDate: entity.completedDate,
        surgeonNotes: entity.surgeonNotes,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  Map<String, dynamic> toInsertMap() => {
        'surgeon_id': surgeonId,
        'patient_id': patientId,
        'title': title,
        if (description != null) 'description': description,
        'surgery_type': surgeryType,
        'status': status,
        if (scheduledDate != null)
          'scheduled_date': scheduledDate!.toIso8601String(),
        if (surgeonNotes != null) 'surgeon_notes': surgeonNotes,
      };

  Map<String, dynamic> toUpdateMap() => {
        'title': title,
        'description': description,
        'surgery_type': surgeryType,
        'status': status,
        'scheduled_date': scheduledDate?.toIso8601String(),
        'completed_date': completedDate?.toIso8601String(),
        'surgeon_notes': surgeonNotes,
      };
}
