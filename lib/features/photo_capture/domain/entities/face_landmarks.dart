import 'package:equatable/equatable.dart';

class FaceLandmarks extends Equatable {
  final List<LandmarkPoint> points;
  final int imageWidth;
  final int imageHeight;

  const FaceLandmarks({
    required this.points,
    required this.imageWidth,
    required this.imageHeight,
  });

  Map<String, dynamic> toJson() => {
        'points': points.map((p) => p.toJson()).toList(),
        'image_width': imageWidth,
        'image_height': imageHeight,
      };

  factory FaceLandmarks.fromJson(Map<String, dynamic> json) {
    final pointsList = (json['points'] as List)
        .map((p) => LandmarkPoint.fromJson(p as Map<String, dynamic>))
        .toList();
    return FaceLandmarks(
      points: pointsList,
      imageWidth: json['image_width'] as int,
      imageHeight: json['image_height'] as int,
    );
  }

  @override
  List<Object?> get props => [points.length, imageWidth, imageHeight];
}

class LandmarkPoint extends Equatable {
  final int index;
  final double x;
  final double y;
  final double z;

  const LandmarkPoint({
    required this.index,
    required this.x,
    required this.y,
    required this.z,
  });

  Map<String, dynamic> toJson() => {
        'index': index,
        'x': x,
        'y': y,
        'z': z,
      };

  factory LandmarkPoint.fromJson(Map<String, dynamic> json) => LandmarkPoint(
        index: json['index'] as int,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        z: (json['z'] as num).toDouble(),
      );

  @override
  List<Object?> get props => [index, x, y, z];
}
