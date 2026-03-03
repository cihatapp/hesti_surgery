import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/supabase/supabase_constants.dart';
import '../../domain/entities/model_3d.dart';

abstract class Model3DRemoteDataSource {
  Future<String> uploadModel({
    required File file,
    required String surgeonId,
    required String caseId,
    required String modelType,
  });

  Future<Model3D> saveModelMetadata({
    required String caseId,
    required String surgeonId,
    required String storagePath,
    required String modelType,
    String fileFormat,
    int? fileSizeBytes,
    String? aiModelUsed,
    String? aiRequestId,
    Map<String, dynamic>? morphParameters,
    String? parentModelId,
  });

  Future<List<Model3D>> getModelsForCase(String caseId);

  Future<Model3D> updateMorphParameters(
    String modelId,
    Map<String, dynamic> parameters,
  );

  Future<String> getSignedUrl(String path);

  Future<void> deleteModel(String modelId);
}

class Model3DRemoteDataSourceImpl implements Model3DRemoteDataSource {
  final SupabaseClient client;

  Model3DRemoteDataSourceImpl({required this.client});

  @override
  Future<String> uploadModel({
    required File file,
    required String surgeonId,
    required String caseId,
    required String modelType,
  }) async {
    try {
      final ext = file.path.split('.').last;
      final path = '$surgeonId/$caseId/${modelType}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await client.storage
          .from(SupabaseConstants.modelsThreeDBucket)
          .upload(path, file);

      return path;
    } catch (e) {
      throw ServerException(message: 'Failed to upload 3D model: $e');
    }
  }

  @override
  Future<Model3D> saveModelMetadata({
    required String caseId,
    required String surgeonId,
    required String storagePath,
    required String modelType,
    String fileFormat = 'glb',
    int? fileSizeBytes,
    String? aiModelUsed,
    String? aiRequestId,
    Map<String, dynamic>? morphParameters,
    String? parentModelId,
  }) async {
    try {
      final data = await client
          .from(SupabaseConstants.modelsThreeDTable)
          .insert({
            'case_id': caseId,
            'surgeon_id': surgeonId,
            'storage_path': storagePath,
            'model_type': modelType,
            'file_format': fileFormat,
            'file_size_bytes': ?fileSizeBytes,
            'ai_model_used': ?aiModelUsed,
            'ai_request_id': ?aiRequestId,
            'morph_parameters': ?morphParameters,
            'parent_model_id': ?parentModelId,
          })
          .select()
          .single();

      return _mapToModel(data);
    } catch (e) {
      throw ServerException(message: 'Failed to save model metadata: $e');
    }
  }

  @override
  Future<List<Model3D>> getModelsForCase(String caseId) async {
    try {
      final data = await client
          .from(SupabaseConstants.modelsThreeDTable)
          .select()
          .eq('case_id', caseId)
          .order('created_at');

      return data.map((json) => _mapToModel(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch 3D models: $e');
    }
  }

  @override
  Future<Model3D> updateMorphParameters(
    String modelId,
    Map<String, dynamic> parameters,
  ) async {
    try {
      final data = await client
          .from(SupabaseConstants.modelsThreeDTable)
          .update({'morph_parameters': parameters})
          .eq('id', modelId)
          .select()
          .single();

      return _mapToModel(data);
    } catch (e) {
      throw ServerException(message: 'Failed to update morph parameters: $e');
    }
  }

  @override
  Future<String> getSignedUrl(String path) async {
    try {
      return await client.storage
          .from(SupabaseConstants.modelsThreeDBucket)
          .createSignedUrl(path, 3600);
    } catch (e) {
      throw ServerException(message: 'Failed to get signed URL: $e');
    }
  }

  @override
  Future<void> deleteModel(String modelId) async {
    try {
      await client
          .from(SupabaseConstants.modelsThreeDTable)
          .delete()
          .eq('id', modelId);
    } catch (e) {
      throw ServerException(message: 'Failed to delete model: $e');
    }
  }

  Model3D _mapToModel(Map<String, dynamic> json) => Model3D(
        id: json['id'] as String,
        caseId: json['case_id'] as String,
        surgeonId: json['surgeon_id'] as String,
        modelType: json['model_type'] as String? ?? 'original',
        storagePath: json['storage_path'] as String,
        fileFormat: json['file_format'] as String? ?? 'glb',
        fileSizeBytes: json['file_size_bytes'] as int?,
        aiModelUsed: json['ai_model_used'] as String?,
        aiRequestId: json['ai_request_id'] as String?,
        morphParameters: json['morph_parameters'] as Map<String, dynamic>?,
        parentModelId: json['parent_model_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
