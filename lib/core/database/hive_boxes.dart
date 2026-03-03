/// Constants for Hive box names used throughout the application.
/// Centralizing box names prevents typos and makes refactoring easier.
abstract class HiveBoxes {
  // ─────────────────────────────────────────────────────────────
  // SYNC BOXES
  // ─────────────────────────────────────────────────────────────

  /// Box for storing pending sync operations
  static const String syncQueue = 'sync_queue';

  /// Box for storing sync metadata per entity
  static const String syncMetadata = 'sync_metadata';

  // ─────────────────────────────────────────────────────────────
  // ENTITY BOXES
  // ─────────────────────────────────────────────────────────────

  /// Box for caching user data
  static const String users = 'users';

  /// Box for app settings (offline-capable)
  static const String settings = 'settings';

  // ─────────────────────────────────────────────────────────────
  // CACHE BOXES
  // ─────────────────────────────────────────────────────────────

  /// Box for generic cache entries
  static const String cache = 'cache';

  /// Box for API response cache
  static const String apiCache = 'api_cache';

  // ─────────────────────────────────────────────────────────────
  // ALL BOXES (for initialization)
  // ─────────────────────────────────────────────────────────────

  /// List of all box names for batch operations
  static const List<String> allBoxes = [
    syncQueue,
    syncMetadata,
    users,
    settings,
    cache,
    apiCache,
  ];
}

/// Type IDs for Hive TypeAdapters.
/// Keep these unique across the entire application.
abstract class HiveTypeIds {
  // Sync related (0-9)
  static const int syncOperationType = 0;
  static const int syncStatus = 1;
  static const int syncOperation = 2;
  static const int syncMetadata = 3;

  // Entities (10-99)
  static const int user = 10;
  static const int authToken = 11;

  // Cache (100-199)
  static const int cacheEntry = 100;
}
