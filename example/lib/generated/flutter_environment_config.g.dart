// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated on: 2026-01-20T21:16:54.009333
// Variables: 6 from 3 environment files

import 'package:flutter_environment_config/flutter_environment_config.dart';

/// Type-safe access to environment variables through code generation.
/// This class provides static-only access and cannot be instantiated.
abstract class FlutterEnvironmentConfigGeneration {
  // Private constructor to prevent instantiation
  FlutterEnvironmentConfigGeneration._();

  /// Gets the value of APP_NAME environment variable.
  /// Available in: .env.develop, .env.production, .env.staging
  /// Returns null if not set or invalid.
  static String? get appName {
    return FlutterEnvironmentConfig.get('APP_NAME');
  }

  /// Gets the value of APP_BUNDLE_ID environment variable.
  /// Available in: .env.develop, .env.production, .env.staging
  /// Returns null if not set or invalid.
  static String? get appBundleId {
    return FlutterEnvironmentConfig.get('APP_BUNDLE_ID');
  }

  /// Gets the value of APP_VERSION_NAME environment variable.
  /// Available in: .env.develop, .env.production, .env.staging
  /// Returns null if not set or invalid.
  static String? get appVersionName {
    return FlutterEnvironmentConfig.get('APP_VERSION_NAME');
  }

  /// Gets the value of APP_VERSION_BUILD environment variable.
  /// Available in: .env.develop, .env.production, .env.staging
  /// Returns null if not set or invalid.
  static int? get appVersionBuild {
    final value = FlutterEnvironmentConfig.get('APP_VERSION_BUILD');
    return value != null ? int.tryParse(value) : null;
  }

  /// Gets the value of API_KEY environment variable.
  /// Available in: .env.develop, .env.production, .env.staging
  /// Returns null if not set or invalid.
  static String? get apiKey {
    return FlutterEnvironmentConfig.get('API_KEY');
  }

  /// Gets the value of EMPTY_VALUE environment variable.
  /// Available in: .env.develop, .env.production, .env.staging
  /// Returns null if not set or invalid.
  static String? get emptyValue {
    return FlutterEnvironmentConfig.get('EMPTY_VALUE');
  }

  // Environment variable keys
  static const String kAppNameKey = 'APP_NAME';
  static const String kAppBundleIdKey = 'APP_BUNDLE_ID';
  static const String kAppVersionNameKey = 'APP_VERSION_NAME';
  static const String kAppVersionBuildKey = 'APP_VERSION_BUILD';
  static const String kApiKeyKey = 'API_KEY';
  static const String kEmptyValueKey = 'EMPTY_VALUE';
}
