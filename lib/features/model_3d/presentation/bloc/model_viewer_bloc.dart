import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/fal_ai_datasource.dart';
import '../../data/datasources/model_3d_remote_datasource.dart';
import '../../domain/entities/model_3d.dart';

// Events
abstract class ModelViewerEvent extends Equatable {
  const ModelViewerEvent();

  @override
  List<Object?> get props => [];
}

class LoadModels extends ModelViewerEvent {
  final String caseId;
  const LoadModels(this.caseId);

  @override
  List<Object?> get props => [caseId];
}

class RequestReconstruction extends ModelViewerEvent {
  final String caseId;
  final String surgeonId;
  final String photoStoragePath;
  final String aiModel;

  const RequestReconstruction({
    required this.caseId,
    required this.surgeonId,
    required this.photoStoragePath,
    this.aiModel = 'fal-ai/sam-3d-body',
  });

  @override
  List<Object?> get props => [caseId, photoStoragePath, aiModel];
}

class LoadModelUrl extends ModelViewerEvent {
  final String storagePath;
  const LoadModelUrl(this.storagePath);

  @override
  List<Object?> get props => [storagePath];
}

// States
abstract class ModelViewerState extends Equatable {
  const ModelViewerState();

  @override
  List<Object?> get props => [];
}

class ModelViewerInitial extends ModelViewerState {}

class ModelsLoading extends ModelViewerState {}

class ModelsLoaded extends ModelViewerState {
  final List<Model3D> models;
  const ModelsLoaded(this.models);

  @override
  List<Object?> get props => [models];
}

class ReconstructionInProgress extends ModelViewerState {
  final String status;
  const ReconstructionInProgress(this.status);

  @override
  List<Object?> get props => [status];
}

class ReconstructionCompleted extends ModelViewerState {
  final Model3D model;
  const ReconstructionCompleted(this.model);

  @override
  List<Object?> get props => [model];
}

class ModelUrlLoaded extends ModelViewerState {
  final String url;
  const ModelUrlLoaded(this.url);

  @override
  List<Object?> get props => [url];
}

class ModelViewerError extends ModelViewerState {
  final String message;
  const ModelViewerError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ModelViewerBloc extends Bloc<ModelViewerEvent, ModelViewerState> {
  final Model3DRemoteDataSource remoteDataSource;
  final FalAiDataSource falAiDataSource;

  ModelViewerBloc({
    required this.remoteDataSource,
    required this.falAiDataSource,
  }) : super(ModelViewerInitial()) {
    on<LoadModels>(_onLoadModels);
    on<RequestReconstruction>(_onRequestReconstruction);
    on<LoadModelUrl>(_onLoadModelUrl);
  }

  Future<void> _onLoadModels(
    LoadModels event,
    Emitter<ModelViewerState> emit,
  ) async {
    emit(ModelsLoading());
    try {
      final models = await remoteDataSource.getModelsForCase(event.caseId);
      emit(ModelsLoaded(models));
    } catch (e) {
      emit(ModelViewerError(e.toString()));
    }
  }

  Future<void> _onRequestReconstruction(
    RequestReconstruction event,
    Emitter<ModelViewerState> emit,
  ) async {
    try {
      emit(const ReconstructionInProgress('Getting photo URL...'));

      // Get signed URL for the photo
      final photoUrl = await remoteDataSource.getSignedUrl(
        event.photoStoragePath,
      );

      emit(const ReconstructionInProgress('Submitting to AI...'));

      // Submit to fal.ai
      final result = await falAiDataSource.reconstruct3D(
        imageUrl: photoUrl,
        modelId: event.aiModel,
      );

      emit(const ReconstructionInProgress('Downloading 3D model...'));

      // Download the GLB file
      final tempPath = '/tmp/${event.caseId}_${DateTime.now().millisecondsSinceEpoch}.glb';
      final modelFile = await falAiDataSource.downloadModel(
        result.modelUrl,
        tempPath,
      );

      emit(const ReconstructionInProgress('Uploading to storage...'));

      // Upload to Supabase Storage
      final storagePath = await remoteDataSource.uploadModel(
        file: modelFile,
        surgeonId: event.surgeonId,
        caseId: event.caseId,
        modelType: 'original',
      );

      // Save metadata
      final model = await remoteDataSource.saveModelMetadata(
        caseId: event.caseId,
        surgeonId: event.surgeonId,
        storagePath: storagePath,
        modelType: 'original',
        fileSizeBytes: await modelFile.length(),
        aiModelUsed: event.aiModel,
        aiRequestId: result.requestId,
      );

      // Clean up temp file
      modelFile.deleteSync();

      emit(ReconstructionCompleted(model));
    } catch (e) {
      emit(ModelViewerError(e.toString()));
    }
  }

  Future<void> _onLoadModelUrl(
    LoadModelUrl event,
    Emitter<ModelViewerState> emit,
  ) async {
    try {
      final url = await remoteDataSource.getSignedUrl(event.storagePath);
      emit(ModelUrlLoaded(url));
    } catch (e) {
      emit(ModelViewerError(e.toString()));
    }
  }
}
