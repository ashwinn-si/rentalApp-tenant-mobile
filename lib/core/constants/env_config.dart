import 'package:flutter/foundation.dart';

/// Environment enumeration
enum Environment {
  development,
  production,
}

/// Get current environment from compile-time string
/// Build with: flutter build apk --dart-define=FLUTTER_ENV=prod
Environment _getEnvironmentFromString(String env) {
  switch (env.toLowerCase()) {
    case 'prod':
    case 'production':
      return Environment.production;
    default:
      return Environment.development;
  }
}

const String _envFromCompile =
    String.fromEnvironment('FLUTTER_ENV', defaultValue: 'dev');
final Environment currentEnvironment =
    _getEnvironmentFromString(_envFromCompile);

/// Environment configuration
class EnvConfig {
  static const Map<Environment, EnvConfigData> configs = {
    Environment.development: EnvConfigData(
      baseUrl: 'http://localhost:8080',
      // For Android emulator, use: http://10.0.2.2:8080
      androidEmulatorUrl: 'http://10.0.2.2:8080',
      apiVersion: 'v1',
      debugLogging: true,
      name: 'Development',
    ),
    Environment.production: EnvConfigData(
      baseUrl:
          'https://api.rental.ashwinsi.in/v1/api', // Change to your production URL
      androidEmulatorUrl: 'https://api.rental.ashwinsi.in/v1',
      apiVersion: 'v1',
      debugLogging: false,
      name: 'Production',
    ),
  };

  /// Get current environment config
  static EnvConfigData get current => configs[currentEnvironment]!;

  /// Get base URL for current platform
  static String getBaseUrl() {
    final config = current;

    // Android emulator cannot reach localhost, use 10.0.2.2
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return config.androidEmulatorUrl;
    }

    return config.baseUrl;
  }

  /// Get full API base URL (includes /api suffix)
  static String getApiUrl() {
    final baseUrl = getBaseUrl();
    return baseUrl.endsWith('/') ? '${baseUrl}api' : '$baseUrl/api';
  }

  /// Print current environment info (debug only)
  static void printEnvInfo() {
    if (kDebugMode) {
      final config = current;
      print('═════════════════════════════════════');
      print('ENVIRONMENT: ${config.name}');
      print('BASE URL: ${getBaseUrl()}');
      print('API URL: ${getApiUrl()}');
      print('═════════════════════════════════════');
    }
  }
}

/// Data class for environment configuration
class EnvConfigData {
  final String baseUrl;
  final String androidEmulatorUrl;
  final String apiVersion;
  final bool debugLogging;
  final String name;

  const EnvConfigData({
    required this.baseUrl,
    required this.androidEmulatorUrl,
    required this.apiVersion,
    required this.debugLogging,
    required this.name,
  });
}
