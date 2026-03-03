import 'package:flutter/material.dart';

class CameraAngleGuide extends StatelessWidget {
  final String angle;
  final bool faceDetected;

  const CameraAngleGuide({
    super.key,
    required this.angle,
    this.faceDetected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Guide overlay
        Center(
          child: Container(
            width: 280,
            height: 380,
            decoration: BoxDecoration(
              border: Border.all(
                color: faceDetected ? Colors.green : Colors.white54,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(140),
            ),
          ),
        ),

        // Angle instruction
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getAngleInstruction(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Rotation indicator for profile shots
              if (_showRotationGuide())
                Icon(
                  _getRotationIcon(),
                  color: Colors.white70,
                  size: 32,
                ),
            ],
          ),
        ),

        // Face detection indicator
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: faceDetected ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    faceDetected ? Icons.check_circle : Icons.warning,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    faceDetected ? 'Face Detected' : 'Position Face',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getAngleInstruction() => switch (angle) {
        'front' => 'Look straight ahead',
        'left_profile' => 'Turn head to the right',
        'right_profile' => 'Turn head to the left',
        'three_quarter_left' => 'Turn slightly to the right',
        'three_quarter_right' => 'Turn slightly to the left',
        'base' => 'Tilt head back',
        _ => 'Position face',
      };

  bool _showRotationGuide() =>
      angle != 'front' && angle != 'base';

  IconData _getRotationIcon() => switch (angle) {
        'left_profile' || 'three_quarter_left' => Icons.rotate_left,
        'right_profile' || 'three_quarter_right' => Icons.rotate_right,
        _ => Icons.rotate_right,
      };
}
