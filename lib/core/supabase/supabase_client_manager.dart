import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_constants.dart';

class SupabaseClientManager {
  SupabaseClientManager._();
  static final SupabaseClientManager _instance = SupabaseClientManager._();
  static SupabaseClientManager get instance => _instance;

  bool _isInitialized = false;

  SupabaseClient get client => Supabase.instance.client;

  GoTrueClient get auth => client.auth;

  SupabaseStorageClient get storage => client.storage;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await Supabase.initialize(
      url: SupabaseConstants.url,
      anonKey: SupabaseConstants.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _isInitialized = true;
  }

  /// Current authenticated user or null
  User? get currentUser => auth.currentUser;

  /// Current session or null
  Session? get currentSession => auth.currentSession;

  /// Whether user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes
  Stream<AuthState> get onAuthStateChange => auth.onAuthStateChange;

  /// Query helper for a table
  SupabaseQueryBuilder from(String table) => client.from(table);

  /// Storage bucket helper
  StorageFileApi bucket(String name) => storage.from(name);
}
