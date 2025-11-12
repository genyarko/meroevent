import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration class
/// Handles loading and accessing environment variables
class Environment {
  // Prevent instantiation
  Environment._();

  /// Initialize environment variables
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  // Supabase Configuration
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'your-project-url.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'your-anon-key';

  static String get supabaseServiceRoleKey =>
      dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? 'your-service-role-key';

  // Stripe Configuration
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? 'pk_test_your-key';

  static String get stripeSecretKey =>
      dotenv.env['STRIPE_SECRET_KEY'] ?? 'sk_test_your-key';

  static String get stripeWebhookSecret =>
      dotenv.env['STRIPE_WEBHOOK_SECRET'] ?? 'whsec_your-secret';

  // App Configuration
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.yourdomain.com';

  // Helper methods
  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';
  static bool get isStaging => appEnv == 'staging';
}
