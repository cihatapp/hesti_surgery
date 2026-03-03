import 'package:equatable/equatable.dart';

class Measurement extends Equatable {
  final String id;
  final String caseId;
  final String surgeonId;
  final String measurementType;
  final double value;
  final String unit; // degrees, mm, ratio
  final String phase; // pre, post, planned
  final Map<String, dynamic>? landmarksUsed;
  final String? notes;
  final DateTime createdAt;

  const Measurement({
    required this.id,
    required this.caseId,
    required this.surgeonId,
    required this.measurementType,
    required this.value,
    this.unit = 'degrees',
    this.phase = 'pre',
    this.landmarksUsed,
    this.notes,
    required this.createdAt,
  });

  String get displayName => MeasurementTypes.displayName(measurementType);

  String get formattedValue {
    switch (unit) {
      case 'degrees':
        return '${value.toStringAsFixed(1)}°';
      case 'mm':
        return '${value.toStringAsFixed(1)} mm';
      case 'ratio':
        return value.toStringAsFixed(2);
      default:
        return value.toStringAsFixed(1);
    }
  }

  @override
  List<Object?> get props => [id, caseId, measurementType, phase];
}

abstract class MeasurementTypes {
  static const String nasofrontalAngle = 'nasofrontal_angle';
  static const String nasolabialAngle = 'nasolabial_angle';
  static const String nasofacialAngle = 'nasofacial_angle';
  static const String nasomentalAngle = 'nasomental_angle';
  static const String rickettsELine = 'ricketts_e_line';
  static const String horizontalThirds = 'horizontal_thirds';
  static const String verticalFifths = 'vertical_fifths';
  static const String faceAsymmetry = 'face_asymmetry';
  static const String customDistance = 'custom_distance';
  static const String customAngle = 'custom_angle';
  static const String tipProjection = 'tip_projection';
  static const String tipRotation = 'tip_rotation';
  static const String dorsalHeight = 'dorsal_height';
  static const String alarWidth = 'alar_width';
  static const String columellarShow = 'columellar_show';

  static String displayName(String type) => switch (type) {
        nasofrontalAngle => 'Nasofrontal Angle',
        nasolabialAngle => 'Nasolabial Angle',
        nasofacialAngle => 'Nasofacial Angle',
        nasomentalAngle => 'Nasomental Angle',
        rickettsELine => 'Ricketts E-Line',
        horizontalThirds => 'Horizontal Thirds',
        verticalFifths => 'Vertical Fifths',
        faceAsymmetry => 'Face Asymmetry',
        customDistance => 'Custom Distance',
        customAngle => 'Custom Angle',
        tipProjection => 'Tip Projection',
        tipRotation => 'Tip Rotation',
        dorsalHeight => 'Dorsal Height',
        alarWidth => 'Alar Width',
        columellarShow => 'Columellar Show',
        _ => type.replaceAll('_', ' '),
      };

  /// Normal ranges for validation
  static (double min, double max)? normalRange(String type) => switch (type) {
        nasofrontalAngle => (115, 135),
        nasolabialAngle => (90, 120),
        nasofacialAngle => (30, 40),
        nasomentalAngle => (120, 132),
        _ => null,
      };
}
