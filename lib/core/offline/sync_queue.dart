import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

import '../database/hive_manager.dart';
import '../network/dio_client.dart';
import 'sync_operation.dart';
import 'sync_status.dart';

/// Callback for when sync queue changes
typedef SyncQueueCallback = void Function(int pendingCount);

/// Manages the queue of operations to be synced when online.
///
/// Usage:
/// ```dart
/// final queue = SyncQueue.instance;
///
/// // Add operation to queue
/// queue.addOperation(
///   operationType: SyncOperationType.create,
///   entityType: 'user',
///   entityId: '123',
///   data: {'name': 'John'},
///   endpoint: '/api/users',
/// );
///
/// // Process queue when online
/// await queue.processQueue();
/// ```
class SyncQueue {
  SyncQueue._();

  static final SyncQueue _instance = SyncQueue._();
  static SyncQueue get instance => _instance;

  final DioClient _dioClient = DioClient.instance;
  final HiveManager _hiveManager = HiveManager.instance;

  bool _isProcessing = false;
  final _onQueueChanged = StreamController<int>.broadcast();

  /// Stream of queue size changes
  Stream<int> get onQueueChanged => _onQueueChanged.stream;

  /// Whether the queue is currently being processed
  bool get isProcessing => _isProcessing;

  /// Get the sync queue box
  Box<SyncOperation> get _box => _hiveManager.getSyncQueueBox();

  /// Get all pending operations
  List<SyncOperation> get pendingOperations {
    return _box.values
        .where((op) => op.status == SyncStatus.pending)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Get count of pending operations
  int get pendingCount {
    return _box.values.where((op) => op.status == SyncStatus.pending).length;
  }

  /// Get all operations (including completed/failed)
  List<SyncOperation> get allOperations {
    return _box.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Add a new operation to the sync queue
  Future<SyncOperation> addOperation({
    required SyncOperationType operationType,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
    required String endpoint,
  }) async {
    final operation = SyncOperation.create(
      operationType: operationType,
      entityType: entityType,
      entityId: entityId,
      data: data,
      endpoint: endpoint,
    );

    await _box.put(operation.id, operation);
    _notifyQueueChanged();

    if (kDebugMode) {
      print('SyncQueue: Added operation ${operation.id} (${operation.operationType})');
    }

    return operation;
  }

  /// Remove an operation from the queue
  Future<void> removeOperation(String id) async {
    await _box.delete(id);
    _notifyQueueChanged();
  }

  /// Clear all completed operations
  Future<void> clearCompleted() async {
    final completed = _box.values
        .where((op) => op.status == SyncStatus.completed)
        .map((op) => op.id)
        .toList();

    for (final id in completed) {
      await _box.delete(id);
    }

    if (kDebugMode) {
      print('SyncQueue: Cleared ${completed.length} completed operations');
    }
  }

  /// Clear all failed operations
  Future<void> clearFailed() async {
    final failed = _box.values
        .where((op) => op.status == SyncStatus.failed)
        .map((op) => op.id)
        .toList();

    for (final id in failed) {
      await _box.delete(id);
    }

    if (kDebugMode) {
      print('SyncQueue: Cleared ${failed.length} failed operations');
    }
  }

  /// Clear stale operations (older than 7 days)
  Future<void> clearStale() async {
    final stale = _box.values.where((op) => op.isStale).map((op) => op.id).toList();

    for (final id in stale) {
      await _box.delete(id);
    }

    if (kDebugMode) {
      print('SyncQueue: Cleared ${stale.length} stale operations');
    }
  }

  /// Process all pending operations in the queue
  Future<SyncResult> processQueue() async {
    if (_isProcessing) {
      return const SyncResult(
        processed: 0,
        succeeded: 0,
        failed: 0,
        message: 'Queue is already being processed',
      );
    }

    _isProcessing = true;
    int processed = 0;
    int succeeded = 0;
    int failed = 0;

    try {
      final operations = pendingOperations;

      if (kDebugMode) {
        print('SyncQueue: Processing ${operations.length} operations');
      }

      for (final operation in operations) {
        processed++;
        final success = await _processOperation(operation);

        if (success) {
          succeeded++;
        } else {
          failed++;
        }

        _notifyQueueChanged();
      }

      return SyncResult(
        processed: processed,
        succeeded: succeeded,
        failed: failed,
        message: 'Processed $processed operations: $succeeded succeeded, $failed failed',
      );
    } finally {
      _isProcessing = false;
    }
  }

  /// Process a single operation
  Future<bool> _processOperation(SyncOperation operation) async {
    operation.markInProgress();

    try {
      Response<dynamic> response;

      switch (operation.operationType) {
        case SyncOperationType.create:
          response = await _dioClient.post(
            operation.endpoint,
            data: operation.payloadAsMap,
          );
          break;

        case SyncOperationType.update:
          response = await _dioClient.put(
            operation.endpoint,
            data: operation.payloadAsMap,
          );
          break;

        case SyncOperationType.delete:
          response = await _dioClient.delete(operation.endpoint);
          break;
      }

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        operation.markCompleted();

        if (kDebugMode) {
          print('SyncQueue: Operation ${operation.id} completed successfully');
        }

        return true;
      } else {
        operation.markFailed('Server returned ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      final errorMessage = e.message ?? 'Network error';
      operation.markFailed(errorMessage);

      if (kDebugMode) {
        print('SyncQueue: Operation ${operation.id} failed: $errorMessage');
      }

      return false;
    } catch (e) {
      operation.markFailed(e.toString());

      if (kDebugMode) {
        print('SyncQueue: Operation ${operation.id} failed: $e');
      }

      return false;
    }
  }

  /// Retry a specific failed operation
  Future<bool> retryOperation(String id) async {
    final operation = _box.get(id);
    if (operation == null) return false;

    if (operation.status != SyncStatus.failed) return false;

    operation.status = SyncStatus.pending;
    operation.retryCount = 0;
    operation.errorMessage = null;
    await operation.save();

    _notifyQueueChanged();
    return true;
  }

  /// Retry all failed operations
  Future<void> retryAllFailed() async {
    final failed = _box.values.where((op) => op.status == SyncStatus.failed);

    for (final operation in failed) {
      operation.status = SyncStatus.pending;
      operation.retryCount = 0;
      operation.errorMessage = null;
      await operation.save();
    }

    _notifyQueueChanged();
  }

  void _notifyQueueChanged() {
    _onQueueChanged.add(pendingCount);
  }

  void dispose() {
    _onQueueChanged.close();
  }
}

/// Result of processing the sync queue
class SyncResult {
  final int processed;
  final int succeeded;
  final int failed;
  final String message;

  const SyncResult({
    required this.processed,
    required this.succeeded,
    required this.failed,
    required this.message,
  });

  bool get hasFailures => failed > 0;
  bool get allSucceeded => processed > 0 && failed == 0;

  @override
  String toString() => message;
}
