import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import 'sync_status.dart';

part 'sync_operation.g.dart';

/// Represents a single sync operation that needs to be sent to the server
/// when the device comes back online.
@HiveType(typeId: 2)
class SyncOperation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final SyncOperationType operationType;

  @HiveField(2)
  final String entityType;

  @HiveField(3)
  final String entityId;

  @HiveField(4)
  final String payload;

  @HiveField(5)
  final String endpoint;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  int retryCount;

  @HiveField(8)
  SyncStatus status;

  @HiveField(9)
  String? errorMessage;

  @HiveField(10)
  DateTime? lastAttemptAt;

  SyncOperation({
    required this.id,
    required this.operationType,
    required this.entityType,
    required this.entityId,
    required this.payload,
    required this.endpoint,
    required this.createdAt,
    this.retryCount = 0,
    this.status = SyncStatus.pending,
    this.errorMessage,
    this.lastAttemptAt,
  });

  /// Create a new sync operation with auto-generated ID
  factory SyncOperation.create({
    required SyncOperationType operationType,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
    required String endpoint,
  }) {
    return SyncOperation(
      id: const Uuid().v4(),
      operationType: operationType,
      entityType: entityType,
      entityId: entityId,
      payload: jsonEncode(data),
      endpoint: endpoint,
      createdAt: DateTime.now(),
    );
  }

  /// Decode the payload back to a Map
  Map<String, dynamic> get payloadAsMap {
    try {
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// Mark operation as in progress
  void markInProgress() {
    status = SyncStatus.inProgress;
    lastAttemptAt = DateTime.now();
    save();
  }

  /// Mark operation as completed
  void markCompleted() {
    status = SyncStatus.completed;
    save();
  }

  /// Mark operation as failed with retry
  void markFailed(String error, {int maxRetries = 3}) {
    retryCount++;
    errorMessage = error;
    lastAttemptAt = DateTime.now();

    if (retryCount >= maxRetries) {
      status = SyncStatus.failed;
    } else {
      status = SyncStatus.pending;
    }
    save();
  }

  /// Check if operation can be retried
  bool get canRetry => retryCount < 3 && status != SyncStatus.completed;

  /// Check if this is a stale operation (older than 7 days)
  bool get isStale {
    final staleDuration = DateTime.now().difference(createdAt);
    return staleDuration.inDays > 7;
  }

  @override
  String toString() {
    return 'SyncOperation(id: $id, type: $operationType, entity: $entityType/$entityId, status: $status)';
  }
}

/// Metadata for tracking sync state of an entity
@HiveType(typeId: 3)
class SyncMetadata extends HiveObject {
  @HiveField(0)
  final String entityType;

  @HiveField(1)
  final String entityId;

  @HiveField(2)
  DateTime? lastSyncedAt;

  @HiveField(3)
  bool isDirty;

  @HiveField(4)
  bool isDeleted;

  @HiveField(5)
  int version;

  SyncMetadata({
    required this.entityType,
    required this.entityId,
    this.lastSyncedAt,
    this.isDirty = false,
    this.isDeleted = false,
    this.version = 1,
  });

  /// Mark entity as modified locally
  void markDirty() {
    isDirty = true;
    version++;
    save();
  }

  /// Mark entity as synced with server
  void markSynced() {
    isDirty = false;
    lastSyncedAt = DateTime.now();
    save();
  }

  /// Mark entity as deleted (soft delete)
  void markDeleted() {
    isDeleted = true;
    isDirty = true;
    save();
  }

  /// Unique key for storing metadata
  @override
  String get key => '$entityType:$entityId';

  /// Check if entity needs sync
  bool get needsSync => isDirty || isDeleted;
}
