import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/supabase/supabase_constants.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' as auth;
import '../bloc/photo_capture_bloc.dart';
import '../widgets/camera_angle_guide.dart';

@RoutePage()
class PhotoCapturePage extends StatelessWidget {
  final String caseId;

  const PhotoCapturePage({
    super.key,
    @PathParam('caseId') required this.caseId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PhotoCaptureBloc>(),
      child: _PhotoCaptureView(caseId: caseId),
    );
  }
}

class _PhotoCaptureView extends StatefulWidget {
  final String caseId;

  const _PhotoCaptureView({required this.caseId});

  @override
  State<_PhotoCaptureView> createState() => _PhotoCaptureViewState();
}

class _PhotoCaptureViewState extends State<_PhotoCaptureView> {
  CameraController? _controller;
  int _selectedAngleIndex = 0;
  bool _isCapturing = false;
  XFile? _capturedImage;

  final _angles = SupabaseConstants.photoAngles;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Use back camera
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhotoCaptureBloc, PhotoCaptureState>(
      listener: (context, state) {
        if (state is PhotoUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${state.photo.angleDisplayName} photo saved'
                '${state.landmarks != null ? " (${state.landmarks!.points.length} landmarks)" : ""}',
              ),
            ),
          );
          setState(() => _capturedImage = null);
          // Auto-advance to next angle
          if (_selectedAngleIndex < _angles.length - 1) {
            setState(() => _selectedAngleIndex++);
          }
        }
        if (state is PhotoCaptureError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          setState(() => _capturedImage = null);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            'Capture: ${_angleDisplayName(_angles[_selectedAngleIndex])}',
          ),
        ),
        body: _capturedImage != null
            ? _buildPreview()
            : _buildCamera(),
      ),
    );
  }

  Widget _buildCamera() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        CameraPreview(_controller!),

        // Angle guide overlay
        CameraAngleGuide(
          angle: _angles[_selectedAngleIndex],
          faceDetected: true, // TODO: Connect to real-time face detection
        ),

        // Angle selector (bottom)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black54,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Angle chips
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _angles.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedAngleIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            _angleDisplayName(_angles[index]),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          backgroundColor: Colors.grey[800],
                          onSelected: (_) =>
                              setState(() => _selectedAngleIndex = index),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Capture button
                GestureDetector(
                  onTap: _isCapturing ? null : _capturePhoto,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: _isCapturing ? Colors.grey : Colors.transparent,
                    ),
                    child: _isCapturing
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          File(_capturedImage!.path),
          fit: BoxFit.contain,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black54,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: BlocBuilder<PhotoCaptureBloc, PhotoCaptureState>(
              builder: (context, state) {
                if (state is PhotoProcessing) {
                  return Column(
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        state.status,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Retake
                    TextButton.icon(
                      onPressed: () => setState(() => _capturedImage = null),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Retake',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    // Use photo
                    ElevatedButton.icon(
                      onPressed: _uploadPhoto,
                      icon: const Icon(Icons.check),
                      label: const Text('Use Photo'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || _isCapturing) return;

    setState(() => _isCapturing = true);
    try {
      final image = await _controller!.takePicture();
      setState(() {
        _capturedImage = image;
        _isCapturing = false;
      });
    } catch (e) {
      setState(() => _isCapturing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture failed: $e')),
        );
      }
    }
  }

  void _uploadPhoto() {
    if (_capturedImage == null) return;

    final authState = context.read<AuthBloc>().state;
    final surgeonId = authState is auth.Authenticated ? authState.user.id : '';

    context.read<PhotoCaptureBloc>().add(ProcessAndUploadPhoto(
          rawFile: File(_capturedImage!.path),
          caseId: widget.caseId,
          surgeonId: surgeonId,
          angle: _angles[_selectedAngleIndex],
        ));
  }

  String _angleDisplayName(String angle) => switch (angle) {
        'front' => 'Front',
        'left_profile' => 'Left Profile',
        'right_profile' => 'Right Profile',
        'three_quarter_left' => '3/4 Left',
        'three_quarter_right' => '3/4 Right',
        'base' => 'Base',
        _ => angle,
      };
}
