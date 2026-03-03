import 'package:flutter/material.dart';

import '../../domain/entities/face_landmarks.dart';

class LandmarksOverlay extends StatelessWidget {
  final FaceLandmarks landmarks;
  final Size displaySize;

  const LandmarksOverlay({
    super.key,
    required this.landmarks,
    required this.displaySize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: displaySize,
      painter: _LandmarksPainter(
        landmarks: landmarks,
        displaySize: displaySize,
      ),
    );
  }
}

class _LandmarksPainter extends CustomPainter {
  final FaceLandmarks landmarks;
  final Size displaySize;

  _LandmarksPainter({
    required this.landmarks,
    required this.displaySize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = displaySize.width / landmarks.imageWidth;
    final scaleY = displaySize.height / landmarks.imageHeight;

    final pointPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Key landmark indices for face mesh (nose, eyes, lips contour)
    final keyIndices = <int>{
      // Nose bridge and tip
      1, 2, 4, 5, 6, 168, 197, 195,
      // Nose tip
      19, 94, 370,
      // Left eye
      33, 133, 160, 159, 158, 144, 145, 153,
      // Right eye
      362, 263, 387, 386, 385, 373, 374, 380,
      // Lips outer
      61, 185, 40, 39, 37, 0, 267, 269, 270, 409, 291,
      375, 321, 405, 314, 17, 84, 181, 91, 146,
      // Jaw line
      10, 338, 297, 332, 284, 251, 389, 356, 454,
      323, 361, 288, 397, 365, 379, 378, 400, 377,
      152, 148, 176, 149, 150, 136, 172, 58, 132,
      93, 234, 127, 162, 21, 54, 103, 67, 109,
    };

    for (final point in landmarks.points) {
      if (keyIndices.contains(point.index)) {
        canvas.drawCircle(
          Offset(point.x * scaleX, point.y * scaleY),
          1.5,
          pointPaint,
        );
      }
    }

    // Draw nose contour lines
    _drawContour(canvas, scaleX, scaleY, [1, 2, 168, 6, 197, 195, 5, 4, 19]);
  }

  void _drawContour(
    Canvas canvas,
    double scaleX,
    double scaleY,
    List<int> indices,
  ) {
    final linePaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    bool first = true;

    for (final idx in indices) {
      final point = landmarks.points
          .where((p) => p.index == idx)
          .firstOrNull;
      if (point == null) continue;

      if (first) {
        path.moveTo(point.x * scaleX, point.y * scaleY);
        first = false;
      } else {
        path.lineTo(point.x * scaleX, point.y * scaleY);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LandmarksPainter oldDelegate) {
    return oldDelegate.landmarks != landmarks;
  }
}
