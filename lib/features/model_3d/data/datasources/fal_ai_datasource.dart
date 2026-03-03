import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/fal_ai_client.dart';

class FalAiDataSource {
  final FalAiClient falAiClient;

  FalAiDataSource({required this.falAiClient});

  /// Request 3D reconstruction from a photo URL
  /// Returns the URL of the generated GLB model
  Future<FalAi3DResult> reconstruct3D({
    required String imageUrl,
    String modelId = FalAiModels.sam3dBody,
  }) async {
    try {
      final input = switch (modelId) {
        FalAiModels.sam3dBody => {
            'image_url': imageUrl,
          },
        FalAiModels.trellis2 => {
            'image_url': imageUrl,
            'output_format': 'glb',
          },
        FalAiModels.tripo3d => {
            'image_url': imageUrl,
            'output_format': 'glb',
          },
        _ => {
            'image_url': imageUrl,
          },
      };

      final result = await falAiClient.predict(
        modelId: modelId,
        input: input,
      );

      // Extract model URL from result
      final modelUrl = _extractModelUrl(result);
      if (modelUrl == null) {
        throw const ServerException(
          message: 'No 3D model URL in API response',
        );
      }

      return FalAi3DResult(
        modelUrl: modelUrl,
        requestId: result['request_id'] as String? ?? '',
        aiModel: modelId,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: '3D reconstruction failed: $e');
    }
  }

  /// Submit reconstruction to queue and return request ID
  Future<String> submitReconstruction({
    required String imageUrl,
    String modelId = FalAiModels.sam3dBody,
  }) async {
    try {
      return await falAiClient.submitPrediction(
        modelId: modelId,
        input: {'image_url': imageUrl},
      );
    } catch (e) {
      throw ServerException(message: 'Failed to submit reconstruction: $e');
    }
  }

  /// Check status of a queued reconstruction
  Future<FalPredictionStatus> checkReconstructionStatus({
    required String modelId,
    required String requestId,
  }) async {
    try {
      return await falAiClient.checkStatus(
        modelId: modelId,
        requestId: requestId,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to check status: $e');
    }
  }

  /// Download GLB file from URL to local path
  Future<File> downloadModel(String url, String savePath) async {
    try {
      final dio = Dio();
      await dio.download(url, savePath);
      return File(savePath);
    } catch (e) {
      throw ServerException(message: 'Failed to download model: $e');
    }
  }

  String? _extractModelUrl(Map<String, dynamic> result) {
    // Different models return URLs in different fields
    if (result.containsKey('model_mesh')) {
      final mesh = result['model_mesh'];
      if (mesh is Map && mesh.containsKey('url')) {
        return mesh['url'] as String?;
      }
    }
    if (result.containsKey('glb_url')) {
      return result['glb_url'] as String?;
    }
    if (result.containsKey('output')) {
      final output = result['output'];
      if (output is Map && output.containsKey('url')) {
        return output['url'] as String?;
      }
    }
    return null;
  }
}

class FalAi3DResult {
  final String modelUrl;
  final String requestId;
  final String aiModel;

  FalAi3DResult({
    required this.modelUrl,
    required this.requestId,
    required this.aiModel,
  });
}
