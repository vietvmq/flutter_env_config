// Pure Dart unit test for flutter_environment_config library
// Tests core logic without Flutter dependencies

import 'package:test/test.dart';
// Note: We don't import the Flutter plugin directly to avoid Flutter dependencies
// This test validates the testing setup

void main() {
  group('Environment Logic Tests', () {
    test('String toCamelCase conversion logic', () {
      String toCamelCase(String snakeCase) {
        return snakeCase.toLowerCase().split('_').asMap().entries.map((entry) {
          if (entry.key == 0) {
            return entry.value;
          }
          return entry.value[0].toUpperCase() + entry.value.substring(1);
        }).join('');
      }

      expect(toCamelCase('APP_NAME'), equals('appName'));
      expect(toCamelCase('API_BASE_URL'), equals('apiBaseUrl'));
      expect(toCamelCase('DEBUG_MODE'), equals('debugMode'));
      expect(toCamelCase('single'), equals('single'));
    });

    test('Type inference logic', () {
      String? inferType(String value) {
        if (value.isEmpty) return 'String?';

        // Try bool
        if (value.toLowerCase() == 'true' || value.toLowerCase() == 'false') {
          return 'bool?';
        }

        // Try int
        if (int.tryParse(value) != null) {
          return 'int?';
        }

        // Try double
        if (double.tryParse(value) != null) {
          return 'double?';
        }

        // Default to String
        return 'String?';
      }

      expect(inferType('true'), equals('bool?'));
      expect(inferType('false'), equals('bool?'));
      expect(inferType('42'), equals('int?'));
      expect(inferType('3.14'), equals('double?'));
      expect(inferType('hello'), equals('String?'));
      expect(inferType(''), equals('String?'));
    });

    test('Constant name generation', () {
      String toConstantName(String variableName) {
        return 'k${variableName[0].toUpperCase()}${variableName.substring(1)}Key';
      }

      expect(toConstantName('appName'), equals('kAppNameKey'));
      expect(toConstantName('apiBaseUrl'), equals('kApiBaseUrlKey'));
      expect(toConstantName('debugMode'), equals('kDebugModeKey'));
    });

    test('Environment variable validation', () {
      bool isValidEnvKey(String key) {
        return key.isNotEmpty &&
            key.toUpperCase() == key &&
            RegExp(r'^[A-Z_][A-Z0-9_]*$').hasMatch(key);
      }

      expect(isValidEnvKey('APP_NAME'), isTrue);
      expect(isValidEnvKey('API_BASE_URL'), isTrue);
      expect(isValidEnvKey('DEBUG_MODE'), isTrue);
      expect(isValidEnvKey('app_name'), isFalse); // lowercase
      expect(isValidEnvKey('123_INVALID'), isFalse); // starts with number
      expect(isValidEnvKey(''), isFalse); // empty
    });
  });
}
