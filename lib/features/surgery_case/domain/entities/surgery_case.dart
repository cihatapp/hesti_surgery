import 'package:equatable/equatable.dart';

class SurgeryCase extends Equatable {
  final String id;
  final String surgeonId;
  final String patientId;
  final String title;
  final String? description;
  final String surgeryType;
  final String status; // planning, scheduled, completed, archived
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final String? surgeonNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SurgeryCase({
    required this.id,
    required this.surgeonId,
    required this.patientId,
    required this.title,
    this.description,
    this.surgeryType = 'rhinoplasty',
    this.status = 'planning',
    this.scheduledDate,
    this.completedDate,
    this.surgeonNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPlanning => status == 'planning';
  bool get isScheduled => status == 'scheduled';
  bool get isCompleted => status == 'completed';
  bool get isArchived => status == 'archived';

  @override
  List<Object?> get props => [id, surgeonId, patientId, title, status];
}
