import 'package:supabase_flutter/supabase_flutter.dart';
import 'environment.dart';

/// Supabase configuration and helper methods
class SupabaseConfig {
  // Prevent instantiation
  SupabaseConfig._();

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
      debug: Environment.isDevelopment,
    );
  }

  /// Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get current authenticated user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get current user ID
  static String? get currentUserId => currentUser?.id;

  /// Get current user email
  static String? get currentUserEmail => currentUser?.email;

  /// Auth state change stream
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Database client
  static PostgrestClient get database => client.from('');

  /// Storage client
  static SupabaseStorageClient get storage => client.storage;

  /// Realtime client
  static RealtimeClient get realtime => client.realtime;

  /// Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Get user session
  static Session? get session => client.auth.currentSession;

  /// Check if session is expired
  static bool get isSessionExpired {
    final session = client.auth.currentSession;
    if (session == null) return true;
    return DateTime.now().isAfter(
      DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000),
    );
  }

  /// Refresh session
  static Future<AuthResponse> refreshSession() async {
    return await client.auth.refreshSession();
  }
}
