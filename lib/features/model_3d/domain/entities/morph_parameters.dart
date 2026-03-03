import 'package:equatable/equatable.dart';

class MorphParameters extends Equatable {
  /// Nose tip projection in mm (-5 to +5)
  final double tipProjection;

  /// Dorsal hump reduction as percentage (0 to 100)
  final double dorsalHumpReduction;

  /// Nose tip rotation in degrees (-15 to +15)
  final double tipRotation;

  /// Nostril width adjustment in mm (-3 to +3)
  final double nostrilWidth;

  /// Chin projection in mm (-5 to +5)
  final double chinProjection;

  /// Bridge width adjustment in mm (-3 to +3)
  final double bridgeWidth;

  /// Alar base adjustment in mm (-3 to +3)
  final double alarBase;

  const MorphParameters({
    this.tipProjection = 0,
    this.dorsalHumpReduction = 0,
    this.tipRotation = 0,
    this.nostrilWidth = 0,
    this.chinProjection = 0,
    this.bridgeWidth = 0,
    this.alarBase = 0,
  });

  Map<String, dynamic> toJson() => {
        'tip_projection': tipProjection,
        'dorsal_hump_reduction': dorsalHumpReduction,
        'tip_rotation': tipRotation,
        'nostril_width': nostrilWidth,
        'chin_projection': chinProjection,
        'bridge_width': bridgeWidth,
        'alar_base': alarBase,
      };

  factory MorphParameters.fromJson(Map<String, dynamic> json) {
    return MorphParameters(
      tipProjection: (json['tip_projection'] as num?)?.toDouble() ?? 0,
      dorsalHumpReduction:
          (json['dorsal_hump_reduction'] as num?)?.toDouble() ?? 0,
      tipRotation: (json['tip_rotation'] as num?)?.toDouble() ?? 0,
      nostrilWidth: (json['nostril_width'] as num?)?.toDouble() ?? 0,
      chinProjection: (json['chin_projection'] as num?)?.toDouble() ?? 0,
      bridgeWidth: (json['bridge_width'] as num?)?.toDouble() ?? 0,
      alarBase: (json['alar_base'] as num?)?.toDouble() ?? 0,
    );
  }

  MorphParameters copyWith({
    double? tipProjection,
    double? dorsalHumpReduction,
    double? tipRotation,
    double? nostrilWidth,
    double? chinProjection,
    double? bridgeWidth,
    double? alarBase,
  }) {
    return MorphParameters(
      tipProjection: tipProjection ?? this.tipProjection,
      dorsalHumpReduction: dorsalHumpReduction ?? this.dorsalHumpReduction,
      tipRotation: tipRotation ?? this.tipRotation,
      nostrilWidth: nostrilWidth ?? this.nostrilWidth,
      chinProjection: chinProjection ?? this.chinProjection,
      bridgeWidth: bridgeWidth ?? this.bridgeWidth,
      alarBase: alarBase ?? this.alarBase,
    );
  }

  @override
  List<Object?> get props => [
        tipProjection,
        dorsalHumpReduction,
        tipRotation,
        nostrilWidth,
        chinProjection,
        bridgeWidth,
        alarBase,
      ];
}
