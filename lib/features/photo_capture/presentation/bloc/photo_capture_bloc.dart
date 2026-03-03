import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/photo_remote_datasource.dart';
import '../../data/services/face_mesh_service.dart';
import '../../data/services/image_processing_service.dart';
import '../../domain/entities/face_landmarks.dart';
import '../../domain/entities/photo.dart';

// Events
abstract class PhotoCaptureEvent extends Equatable {
  const PhotoCaptureEvent();

  @override
  List<Object?> get props => [];
}

class LoadPhotos extends PhotoCaptureEvent {
  final String caseId;
  const LoadPhotos(this.caseId);

  @override
  List<Object?> get props => [caseId];
}

class ProcessAndUploadPhoto extends PhotoCaptureEvent {
  final File rawFile;
  final String caseId;
  final String surgeonId;
  final String angle;

  const ProcessAndUploadPhoto({
    required this.rawFile,
    required this.caseId,
    required this.surgeonId,
    required this.angle,
  });

  @override
  List<Object?> get props => [rawFile.path, caseId, angle];
}

class DeletePhotoEvent extends PhotoCaptureEvent {
  final String photoId;
  const DeletePhotoEvent(this.photoId);

  @override
  List<Object?> get props => [photoId];
}

// States
abstract class PhotoCaptureState extends Equatable {
  const PhotoCaptureState();

  @override
  List<Object?> get props => [];
}

class PhotoCaptureInitial extends PhotoCaptureState {}

class PhotosLoading extends PhotoCaptureState {}

class PhotosLoaded extends PhotoCaptureState {
  final List<Photo> photos;
  const PhotosLoaded(this.photos);

  @override
  List<Object?> get props => [photos];
}

class PhotoProcessing extends PhotoCaptureState {
  final String angle;
  final String status; // processing, uploading, detecting
  const PhotoProcessing({required this.angle, required this.status});

  @override
  List<Object?> get props => [angle, status];
}

class PhotoUploaded extends PhotoCaptureState {
  final Photo photo;
  final FaceLandmarks? landmarks;
  const PhotoUploaded({required this.photo, this.landmarks});

  @override
  List<Object?> get props => [photo];
}

class PhotoCaptureError extends PhotoCaptureState {
  final String message;
  const PhotoCaptureError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class PhotoCaptureBloc extends Bloc<PhotoCaptureEvent, PhotoCaptureState> {
  final PhotoRemoteDataSource remoteDataSource;
  final ImageProcessingService imageProcessingService;
  final FaceMeshService faceMeshService;

  PhotoCaptureBloc({
    required this.remoteDataSource,
    required this.imageProcessingService,
    required this.faceMeshService,
  }) : super(PhotoCaptureInitial()) {
    on<LoadPhotos>(_onLoadPhotos);
    on<ProcessAndUploadPhoto>(_onProcessAndUpload);
    on<DeletePhotoEvent>(_onDeletePhoto);
  }

  Future<void> _onLoadPhotos(
    LoadPhotos event,
    Emitter<PhotoCaptureState> emit,
  ) async {
    emit(PhotosLoading());
    try {
      final photos = await remoteDataSource.getPhotosForCase(event.caseId);
      emit(PhotosLoaded(photos));
    } catch (e) {
      emit(PhotoCaptureError(e.toString()));
    }
  }

  Future<void> _onProcessAndUpload(
    ProcessAndUploadPhoto event,
    Emitter<PhotoCaptureState> emit,
  ) async {
    try {
      // Step 1: Process image
      emit(PhotoProcessing(angle: event.angle, status: 'Processing image...'));
      final processed = await imageProcessingService.processPhoto(event.rawFile);

      if (!imageProcessingService.validateResolution(
        processed.width,
        processed.height,
      )) {
        emit(const PhotoCaptureError(
          'Image resolution too low. Minimum 1080px required.',
        ));
        return;
      }

      // Step 2: Upload photo
      emit(PhotoProcessing(angle: event.angle, status: 'Uploading...'));
      final storagePath = await remoteDataSource.uploadPhoto(
        file: processed.processedFile,
        surgeonId: event.surgeonId,
        caseId: event.caseId,
        angle: event.angle,
      );

      // Step 3: Upload thumbnail
      final thumbnailPath = await remoteDataSource.uploadThumbnail(
        file: processed.thumbnailFile,
        surgeonId: event.surgeonId,
        caseId: event.caseId,
        angle: event.angle,
      );

      // Step 4: Face mesh detection
      emit(PhotoProcessing(
        angle: event.angle,
        status: 'Detecting face landmarks...',
      ));
      FaceLandmarks? landmarks;
      try {
        landmarks = await faceMeshService.detectFromImage(
          processed.processedFile.path,
          imageWidth: processed.width,
          imageHeight: processed.height,
        );
      } catch (_) {
        // Non-critical: landmarks detection failure shouldn't block upload
      }

      // Step 5: Save metadata
      final photo = await remoteDataSource.savePhotoMetadata(
        caseId: event.caseId,
        surgeonId: event.surgeonId,
        angle: event.angle,
        storagePath: storagePath,
        thumbnailPath: thumbnailPath,
        width: processed.width,
        height: processed.height,
        landmarks: landmarks,
      );

      emit(PhotoUploaded(photo: photo, landmarks: landmarks));

      // Clean up temp files
      processed.processedFile.deleteSync();
      processed.thumbnailFile.deleteSync();
    } catch (e) {
      emit(PhotoCaptureError(e.toString()));
    }
  }

  Future<void> _onDeletePhoto(
    DeletePhotoEvent event,
    Emitter<PhotoCaptureState> emit,
  ) async {
    try {
      await remoteDataSource.deletePhoto(event.photoId);
    } catch (e) {
      emit(PhotoCaptureError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    faceMeshService.dispose();
    return super.close();
  }
}
