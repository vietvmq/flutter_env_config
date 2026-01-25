library flutter_environment_config;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Flutter environment config writes environment variables
/// to `BuildConfig` class for android
/// and as a `NSDictionary` for iOS
class FlutterEnvironmentConfig {
  /// An instance of all environment variables
  late Map<String, dynamic> _variables;

  // Private Constructor
  FlutterEnvironmentConfig._internal();

  // Instance of FlutterEnvironmentConfig
  static final FlutterEnvironmentConfig _instance =
      FlutterEnvironmentConfig._internal();

  static const MethodChannel _channel =
      MethodChannel('flutter_environment_config');

  /// Check if the current platform supports environment variable loading
  static bool get isPlatformSupported {
    if (kIsWeb) {
      return true; // Web is supported with webVariables parameter
    }
    try {
      return defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android;
    } catch (e) {
      return false;
    }
  }

  /// Get platform name for debugging
  static String get platformName {
    if (kIsWeb) return 'Web';

    try {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          return 'iOS';
        case TargetPlatform.android:
          return 'Android';
        case TargetPlatform.macOS:
          return 'macOS';
        case TargetPlatform.windows:
          return 'Windows';
        case TargetPlatform.linux:
          return 'Linux';
        case TargetPlatform.fuchsia:
          return 'Fuchsia';
        default:
          return 'Unknown';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Variables need to be loaded on app startup, recommend to do it `main.dart`
  static Future<void> loadEnvVariables({
    Map<String, dynamic>? webVariables,
  }) async {
    if (kDebugMode) {
      print(
        'FlutterEnvironmentConfig: Target platform: $platformName',
      );
    }

    // Check if platform is supported
    if (!isPlatformSupported) {
      if (kDebugMode) {
        print(
          'FlutterEnvironmentConfig: Platform $platformName is not supported. '
          'Supported platforms: iOS, Android, Web',
        );
      }
      _instance._variables = {};
      return;
    }

    Map<String, dynamic>? loadedVariables;

    if (kIsWeb) {
      // Web platform - use provided variables
      if (kDebugMode) {
        print('FlutterEnvironmentConfig: Loading variables for Web platform');
      }
      loadedVariables = webVariables;

      if (webVariables == null) {
        if (kDebugMode) {
          print(
            'FlutterEnvironmentConfig: No webVariables provided for Web platform. '
            'Pass your environment variables to loadEnvVariables(webVariables: {...})',
          );
        }
      }
    } else {
      // Native platforms (iOS/Android) - use method channel
      if (kDebugMode) {
        print(
          'FlutterEnvironmentConfig: Loading variables for $platformName platform',
        );
      }

      try {
        loadedVariables = await _channel.invokeMapMethod('loadEnvVariables');
      } catch (e) {
        if (kDebugMode) {
          print(
            'FlutterEnvironmentConfig: Failed to load environment variables on $platformName: $e',
          );
        }
        loadedVariables = {};
      }
    }

    _instance._variables = loadedVariables ?? {};

    if (kDebugMode) {
      print(
        'FlutterEnvironmentConfig: Successfully loaded ${_instance._variables.length} variables',
      );
    }
  }

  /// Returns a specific variable value give a [key]
  static dynamic get(String key) {
    // Check if platform is supported
    if (!isPlatformSupported) {
      if (kDebugMode) {
        print(
          'FlutterEnvironmentConfig: Cannot get variable "$key" - '
          'Platform $platformName is not supported',
        );
      }
      return null;
    }

    var variables = _instance._variables;

    if (variables.isEmpty) {
      if (kDebugMode) {
        print(
          'FlutterEnvironmentConfig: Variables are empty for platform $platformName\n'
          'Ensure you have called loadEnvVariables() and have a .env file',
        );
      }
      return null;
    } else if (variables.containsKey(key)) {
      return variables[key];
    } else {
      if (kDebugMode) {
        print(
          'FlutterEnvironmentConfig: Value for Key($key) not found on $platformName\n'
          'Available keys: ${variables.keys.join(", ")}\n'
          'Ensure you have "$key" in your .env file',
        );
      }
      return null;
    }
  }

  /// returns all the current loaded variables;
  static Map<String, dynamic> get variables {
    return Map<String, dynamic>.of(_instance._variables);
  }

  @visibleForTesting
  static void loadValueForTesting(Map<String, dynamic> values) {
    _instance._variables = values;
  }
}
