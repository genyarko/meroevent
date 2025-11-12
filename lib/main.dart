import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/environment.dart';
import 'core/config/supabase_config.dart';
import 'app.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (optional - mobile only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize environment variables
  try {
    await Environment.initialize();
  } catch (e) {
    debugPrint('Environment initialization warning: $e');
    // Continue without environment file in development
  }

  // Initialize Supabase
  try {
    await SupabaseConfig.initialize();
    debugPrint('Supabase initialized successfully');
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
    // App can still run, but features requiring Supabase will fail gracefully
  }

  // Run the app with ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: EventApp(),
    ),
  );
}
