import 'package:dio/dio.dart';

import '../supabase/supabase_constants.dart';

class FalAiClient {
  late final Dio _dio;

  FalAiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://queue.fal.run',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      headers: {
        'Authorization': 'Key ${SupabaseConstants.falAiApiKey}',
        'Content-Type': 'application/json',
      },
    ));
  }

  /// Submit a prediction to the queue
  /// Returns a request_id for polling status
  Future<String> submitPrediction({
    required String modelId,
    required Map<String, dynamic> input,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/$modelId',
      data: {'input': input},
    );

    return response.data!['request_id'] as String;
  }

  /// Check the status of a queued prediction
  Future<FalPredictionStatus> checkStatus({
    required String modelId,
    required String requestId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/$modelId/requests/$requestId/status',
    );

    final data = response.data as Map<String, dynamic>;
    final status = data['status'] as String;

    return FalPredictionStatus(
      status: status,
      output: status == 'COMPLETED' ? data['response'] as Map<String, dynamic>? : null,
      error: data['error'] as String?,
    );
  }

  /// Wait for a prediction to complete (polling)
  Future<Map<String, dynamic>> waitForResult({
    required String modelId,
    required String requestId,
    Duration pollInterval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 5),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      final status = await checkStatus(
        modelId: modelId,
        requestId: requestId,
      );

      if (status.isCompleted && status.output != null) {
        return status.output!;
      }

      if (status.isFailed) {
        throw Exception('Prediction failed: ${status.error}');
      }

      await Future<void>.delayed(pollInterval);
    }

    throw Exception('Prediction timed out after ${timeout.inMinutes} minutes');
  }

  /// Submit and wait for result in one call
  Future<Map<String, dynamic>> predict({
    required String modelId,
    required Map<String, dynamic> input,
  }) async {
    final requestId = await submitPrediction(
      modelId: modelId,
      input: input,
    );

    return waitForResult(
      modelId: modelId,
      requestId: requestId,
    );
  }
}

class FalPredictionStatus {
  final String status;
  final Map<String, dynamic>? output;
  final String? error;

  FalPredictionStatus({
    required this.status,
    this.output,
    this.error,
  });

  bool get isCompleted => status == 'COMPLETED';
  bool get isFailed => status == 'FAILED';
  bool get isProcessing => status == 'IN_PROGRESS' || status == 'IN_QUEUE';
}

/// Available AI model IDs for 3D reconstruction
abstract class FalAiModels {
  static const String sam3dBody = 'fal-ai/sam-3d-body';
  static const String trellis2 = 'fal-ai/trellis';
  static const String tripo3d = 'fal-ai/tripo3d';
  static const String hyperRodin = 'fal-ai/hyper3d-rodin';
}
