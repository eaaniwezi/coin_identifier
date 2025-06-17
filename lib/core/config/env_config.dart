// lib/core/config/env_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
      print('✅ Environment variables loaded successfully');
    } catch (e) {
      print('❌ Failed to load .env file: $e');
      throw Exception('Failed to load environment configuration');
    }
  }

  // Supabase Configuration
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('SUPABASE_URL not found in .env file');
    }
    return url;
  }

  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY not found in .env file');
    }
    return key;
  }

  // Optional: Add other configuration values as needed
  static String get appName => dotenv.env['APP_NAME'] ?? 'Coin Identifier Pro';
  static bool get isDebugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  // For future use - AI API configuration
  static String get aiApiUrl => dotenv.env['AI_API_URL'] ?? '';
  static String get aiApiKey => dotenv.env['AI_API_KEY'] ?? '';

  // For future use - Apphud configuration
  static String get apphudApiKey => dotenv.env['APPHUD_API_KEY'] ?? '';
}
