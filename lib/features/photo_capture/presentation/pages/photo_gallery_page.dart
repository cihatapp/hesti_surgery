import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/photo.dart';
import '../bloc/photo_capture_bloc.dart';

@RoutePage()
class PhotoGalleryPage extends StatelessWidget {
  final String caseId;

  const PhotoGalleryPage({
    super.key,
    @PathParam('caseId') required this.caseId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PhotoCaptureBloc>()..add(LoadPhotos(caseId)),
      child: _PhotoGalleryView(caseId: caseId),
    );
  }
}

class _PhotoGalleryView extends StatelessWidget {
  final String caseId;

  const _PhotoGalleryView({required this.caseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              context.router.push(PhotoCaptureRoute(caseId: caseId));
            },
          ),
        ],
      ),
      body: BlocBuilder<PhotoCaptureBloc, PhotoCaptureState>(
        builder: (context, state) {
          if (state is PhotosLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PhotosLoaded) {
            if (state.photos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      size: 64,
                      color: context.colorScheme.onSurface
                          .withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text('No photos yet'),
                    const SizedBox(height: AppSpacing.sm),
                    const Text('Capture photos for this case'),
                  ],
                ),
              );
            }
            return _buildPhotoGrid(context, state.photos);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context, List<Photo> photos) {
    // Group photos by angle
    final grouped = <String, Photo>{};
    for (final photo in photos) {
      grouped[photo.angle] = photo;
    }

    final angles = [
      'front',
      'left_profile',
      'right_profile',
      'three_quarter_left',
      'three_quarter_right',
      'base',
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.8,
      ),
      itemCount: angles.length,
      itemBuilder: (context, index) {
        final angle = angles[index];
        final photo = grouped[angle];

        return _PhotoGridTile(
          angle: angle,
          photo: photo,
          onCapture: () {
            context.router.push(PhotoCaptureRoute(caseId: caseId));
          },
        );
      },
    );
  }
}

class _PhotoGridTile extends StatelessWidget {
  final String angle;
  final Photo? photo;
  final VoidCallback onCapture;

  const _PhotoGridTile({
    required this.angle,
    this.photo,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = switch (angle) {
      'front' => 'Front',
      'left_profile' => 'Left Profile',
      'right_profile' => 'Right Profile',
      'three_quarter_left' => '3/4 Left',
      'three_quarter_right' => '3/4 Right',
      'base' => 'Base',
      _ => angle,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: photo != null ? () {} : onCapture,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: photo != null
                  ? Container(
                      color: context.colorScheme.primary
                          .withValues(alpha: 0.1),
                      child: Icon(
                        Icons.photo,
                        size: 48,
                        color: context.colorScheme.primary,
                      ),
                    )
                  : Container(
                      color: context.colorScheme.surface,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 36,
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to capture',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      style: context.textTheme.labelMedium,
                    ),
                  ),
                  if (photo != null)
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
