import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';

import '../../domain/entities/face_landmarks.dart';

class FaceMeshService {
  FaceMeshDetector? _detector;

  FaceMeshDetector get detector {
    _detector ??= FaceMeshDetector(option: FaceMeshDetectorOptions.faceMesh);
    return _detector!;
  }

  /// Detect face mesh landmarks from an image file path
  Future<FaceLandmarks?> detectFromImage(
    String imagePath, {
    required int imageWidth,
    required int imageHeight,
  }) async {
    final inputImage = InputImage.fromFilePath(imagePath);

    final meshes = await detector.processImage(inputImage);
    if (meshes.isEmpty) return null;

    final mesh = meshes.first;
    final points = <LandmarkPoint>[];

    for (int i = 0; i < mesh.points.length; i++) {
      final point = mesh.points[i];
      points.add(LandmarkPoint(
        index: i,
        x: point.x.toDouble(),
        y: point.y.toDouble(),
        z: 0.0,
      ));
    }

    return FaceLandmarks(
      points: points,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
  }

  void dispose() {
    _detector?.close();
    _detector = null;
  }
}
