import 'package:equatable/equatable.dart';

class Model3D extends Equatable {
  final String id;
  final String caseId;
  final String surgeonId;
  final String modelType; // original, morphed, comparison
  final String storagePath;
  final String fileFormat; // glb, obj
  final int? fileSizeBytes;
  final String? aiModelUsed;
  final String? aiRequestId;
  final Map<String, dynamic>? morphParameters;
  final String? parentModelId;
  final DateTime createdAt;

  const Model3D({
    required this.id,
    required this.caseId,
    required this.surgeonId,
    this.modelType = 'original',
    required this.storagePath,
    this.fileFormat = 'glb',
    this.fileSizeBytes,
    this.aiModelUsed,
    this.aiRequestId,
    this.morphParameters,
    this.parentModelId,
    required this.createdAt,
  });

  bool get isOriginal => modelType == 'original';
  bool get isMorphed => modelType == 'morphed';

  @override
  List<Object?> get props => [id, caseId, modelType];
}
