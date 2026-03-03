import 'package:equatable/equatable.dart';

class Photo extends Equatable {
  final String id;
  final String caseId;
  final String surgeonId;
  final String angle; // front, left_profile, right_profile, etc.
  final String storagePath;
  final String? thumbnailPath;
  final int? originalWidth;
  final int? originalHeight;
  final Map<String, dynamic>? landmarksJson;
  final DateTime createdAt;

  const Photo({
    required this.id,
    required this.caseId,
    required this.surgeonId,
    required this.angle,
    required this.storagePath,
    this.thumbnailPath,
    this.originalWidth,
    this.originalHeight,
    this.landmarksJson,
    required this.createdAt,
  });

  String get angleDisplayName => switch (angle) {
        'front' => 'Front',
        'left_profile' => 'Left Profile',
        'right_profile' => 'Right Profile',
        'three_quarter_left' => '3/4 Left',
        'three_quarter_right' => '3/4 Right',
        'base' => 'Base',
        _ => angle,
      };

  @override
  List<Object?> get props => [id, caseId, angle];
}
