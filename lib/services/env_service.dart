import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment Service
/// Handles loading and accessing environment variables
class EnvService {
  static bool _isInitialized = false;

  /// Initialize environment variables
  static Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        await dotenv.load(fileName: "config.env");
        _isInitialized = true;
        print('✅ Environment variables loaded successfully');
      } catch (e) {
        print('⚠️ Warning: Could not load config.env file: $e');
        print('📝 Using default/fallback values for SSLCommerz configuration');
        _isInitialized =
            true; // Still mark as initialized to prevent repeated attempts
      }
    }
  }

  /// Get SSLCommerz Store ID
  static String get sslcommerzStoreId {
    _checkInitialized();
    return dotenv.env['SSLCOMMERZ_STORE_ID'] ?? 'teamx68b12058b6036';
  }

  /// Get SSLCommerz Store Password
  static String get sslcommerzStorePassword {
    _checkInitialized();
    return dotenv.env['SSLCOMMERZ_STORE_PASSWORD'] ?? 'teamx68b12058b6036@ssl';
  }

  /// Check if SSLCommerz is in sandbox mode
  static bool get sslcommerzIsSandbox {
    _checkInitialized();
    return dotenv.env['SSLCOMMERZ_IS_SANDBOX']?.toLowerCase() == 'true';
  }

  /// Get production store ID (if available)
  static String? get sslcommerzProductionStoreId {
    _checkInitialized();
    return dotenv.env['SSLCOMMERZ_PRODUCTION_STORE_ID'];
  }

  /// Get production store password (if available)
  static String? get sslcommerzProductionStorePassword {
    _checkInitialized();
    return dotenv.env['SSLCOMMERZ_PRODUCTION_STORE_PASSWORD'];
  }

  /// Check if environment is initialized
  static void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'Environment not initialized. Call EnvService.initialize() first.',
      );
    }
  }

  /// Get all environment variables for debugging (be careful with sensitive data)
  static Map<String, String> getAllEnvVars() {
    _checkInitialized();
    return dotenv.env;
  }

  /// Check if required environment variables are set
  static bool get hasRequiredEnvVars {
    _checkInitialized();
    final storeId = dotenv.env['SSLCOMMERZ_STORE_ID'];
    final storePassword = dotenv.env['SSLCOMMERZ_STORE_PASSWORD'];

    return storeId != null &&
        storeId.isNotEmpty &&
        storeId != 'your_store_id_here' &&
        storePassword != null &&
        storePassword.isNotEmpty &&
        storePassword != 'your_store_password_here';
  }

  /// Check if environment file was loaded successfully
  static bool get isEnvFileLoaded {
    _checkInitialized();
    return dotenv.env.isNotEmpty;
  }

  /// Get environment status for debugging
  static Map<String, dynamic> getEnvironmentStatus() {
    _checkInitialized();
    return {
      'isInitialized': _isInitialized,
      'isEnvFileLoaded': isEnvFileLoaded,
      'hasRequiredVars': hasRequiredEnvVars,
      'isSandbox': sslcommerzIsSandbox,
      'storeIdSet': dotenv.env['SSLCOMMERZ_STORE_ID'] != null,
      'storePasswordSet': dotenv.env['SSLCOMMERZ_STORE_PASSWORD'] != null,
      'productionStoreIdSet':
          dotenv.env['SSLCOMMERZ_PRODUCTION_STORE_ID'] != null,
      'productionStorePasswordSet':
          dotenv.env['SSLCOMMERZ_PRODUCTION_STORE_PASSWORD'] != null,
    };
  }
}
