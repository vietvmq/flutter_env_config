#!/usr/bin/env dart

import 'dart:io';
import 'package:yaml/yaml.dart';

/// Simple script to generate type-safe environment configuration extension
/// on FlutterEnvironmentConfig. Only runs for consumer projects that import this library.
void main(List<String> args) async {
  print(_cyan('🔧 Generating FlutterEnvironmentConfig...'));
  print('');

  // Detect project context and configuration
  final projectConfig = await detectProjectConfig();

  if (projectConfig == null) {
    print(_yellow(
        '⚠️  This command should be run from a project that uses flutter_environment_config.'));
    print('');
    print(
        '💡 Make sure you have added flutter_environment_config to your pubspec.yaml:');
    print('   dependencies:');
    print('     flutter_environment_config: ^1.0.0');
    return;
  }

  final workingDirectory = Directory(projectConfig.workingDir);
  final outputPath = projectConfig.outputPath;

  print(_blue('📋 Configuration:'));
  print('📁 Working directory: ${workingDirectory.path}');
  print('📄 Output path: $outputPath');
  print('');

  // Read environment variables from all .env files in the working directory
  final envVariables = <String, EnvVariable>{};
  final envFiles = await scanEnvFiles(workingDirectory);

  if (envFiles.isEmpty) {
    print('❌ No .env.* files found in ${workingDirectory.path}');
    print(
        '💡 Create .env files like .env.develop, .env.staging, .env.production');
    return;
  }

  print(_yellow('📂 Reading environment files:'));
  for (final envFile in envFiles) {
    final file = File(envFile);
    if (await file.exists()) {
      print('📖 Reading $envFile');
      final variables = await readEnvFile(file);
      for (final entry in variables.entries) {
        if (!envVariables.containsKey(entry.key)) {
          envVariables[entry.key] = EnvVariable(
            entry.value.key,
            entry.value.value,
            entry.value.type,
            {envFile},
          );
        } else {
          // Add this file to the list of files that contain this variable
          envVariables[entry.key]!.availableInFiles.add(envFile);
        }
      }
    }
  }

  if (envVariables.isEmpty) {
    print('❌ No environment variables found. Make sure you have .env files.');
    return;
  }

  print('');
  print(_magenta('⚙️  Generating code...'));

  // Generate the extension
  final generatedCode =
      generateExtension(envVariables, envFiles, projectConfig);

  // Write to file
  final outputFile = File(outputPath);
  await outputFile.parent
      .create(recursive: true); // Create directories if needed
  await outputFile.writeAsString(generatedCode);

  print('');
  print(_green('✅ Generation completed:'));
  print('📊 Generated ${envVariables.length} environment variables');
  print('📁 Output: ${outputFile.path}');
  print('');
  print(_brightYellow('💡 Customize output directory in pubspec.yaml:'));
  print('   flutter_environment_config:');
  print('     output_dir: lib/generated  # or any other directory');

  print('');
  print(_brightCyan(
      '🎉 Done! You can now use FlutterEnvironmentConfigGeneration.propertyName for type-safe access.'));
}

class EnvVariable {
  final String key;
  final String value;
  final String type;
  final Set<String> availableInFiles;

  EnvVariable(this.key, this.value, this.type, this.availableInFiles);
}

Future<Map<String, EnvVariable>> readEnvFile(File file) async {
  final lines = await file.readAsLines();
  final variables = <String, EnvVariable>{};
  final fileName = file.path;

  for (final line in lines) {
    final trimmedLine = line.trim();

    // Skip empty lines and comments
    if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
      continue;
    }

    // Parse key=value pairs
    final equalIndex = trimmedLine.indexOf('=');
    if (equalIndex > 0) {
      final key = trimmedLine.substring(0, equalIndex).trim();
      final value = trimmedLine.substring(equalIndex + 1).trim();

      // Remove quotes if present
      var cleanValue = value;
      if ((cleanValue.startsWith('"') && cleanValue.endsWith('"')) ||
          (cleanValue.startsWith("'") && cleanValue.endsWith("'"))) {
        cleanValue = cleanValue.substring(1, cleanValue.length - 1);
      }

      final type = inferType(cleanValue);
      variables[key] = EnvVariable(key, cleanValue, type, {fileName});
    }
  }

  return variables;
}

String inferType(String value) {
  // Try to infer type from value
  if (value.toLowerCase() == 'true' || value.toLowerCase() == 'false') {
    return 'bool';
  }

  if (int.tryParse(value) != null) {
    return 'int';
  }

  if (double.tryParse(value) != null) {
    return 'double';
  }

  return 'String';
}

String generateExtension(Map<String, EnvVariable> variables,
    List<String> allEnvFiles, ProjectConfig config) {
  final buffer = StringBuffer();

  buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  buffer.writeln('// Generated on: ${DateTime.now().toIso8601String()}');
  buffer.writeln(
      '// Variables: ${variables.length} from ${allEnvFiles.length} environment files');
  buffer.writeln();

  buffer.writeln(
      'import \'package:flutter_environment_config/flutter_environment_config.dart\';');
  buffer.writeln();

  // Generate the Generation class
  buffer.writeln(
      '/// Type-safe access to environment variables through code generation.');
  buffer.writeln(
      '/// This class provides static-only access and cannot be instantiated.');
  buffer.writeln('abstract class FlutterEnvironmentConfigGeneration {');
  buffer.writeln('  // Private constructor to prevent instantiation');
  buffer.writeln('  FlutterEnvironmentConfigGeneration._();');
  buffer.writeln();

  // Generate getters for each environment variable
  for (final variable in variables.values) {
    final getterName = generateGetterName(variable.key);
    final returnType = variable.type;

    // Generate file availability comment
    final availableFiles = variable.availableInFiles
        .map((f) => f.split('/').last.replaceAll('.example', ''))
        .toList()
      ..sort();
    final allFileNames = allEnvFiles
        .map((f) => f.split('/').last.replaceAll('.example', ''))
        .toList();
    final missingFiles =
        allFileNames.where((f) => !availableFiles.contains(f)).toList();

    buffer.writeln(
        '  /// Gets the value of ${variable.key} environment variable.');
    buffer.writeln('  /// Available in: ${availableFiles.join(', ')}');
    if (missingFiles.isNotEmpty) {
      buffer.writeln('  /// Missing in: ${missingFiles.join(', ')}');
    }
    buffer.writeln('  /// Returns null if not set or invalid.');
    buffer.writeln('  static $returnType? get $getterName {');

    if (returnType == 'bool') {
      buffer.writeln(
          '    final value = FlutterEnvironmentConfig.get(\'${variable.key}\');');
      buffer.writeln('    return value?.toLowerCase() == \'true\';');
    } else if (returnType == 'int') {
      buffer.writeln(
          '    final value = FlutterEnvironmentConfig.get(\'${variable.key}\');');
      buffer.writeln('    return value != null ? int.tryParse(value) : null;');
    } else if (returnType == 'double') {
      buffer.writeln(
          '    final value = FlutterEnvironmentConfig.get(\'${variable.key}\');');
      buffer
          .writeln('    return value != null ? double.tryParse(value) : null;');
    } else {
      // String type
      buffer.writeln(
          '    return FlutterEnvironmentConfig.get(\'${variable.key}\');');
    }

    buffer.writeln('  }');
    buffer.writeln();
  }

  // Generate constants for environment variable keys
  buffer.writeln('  // Environment variable keys');
  for (final variable in variables.values) {
    final constantName = generateConstantName(variable.key);
    buffer
        .writeln('  static const String $constantName = \'${variable.key}\';');
  }

  buffer.writeln('}');

  return buffer.toString();
}

String generateGetterName(String envKey) {
  // Convert environment variable name to camelCase getter name
  final parts = envKey.toLowerCase().split('_');
  final first = parts.first;
  final rest = parts
      .skip(1)
      .map((part) =>
          part.isNotEmpty ? part[0].toUpperCase() + part.substring(1) : '')
      .join();
  return first + rest;
}

String generateConstantName(String envKey) {
  return 'k${envKey.toLowerCase().split('_').map((part) => part.isNotEmpty ? part[0].toUpperCase() + part.substring(1) : '').join()}Key';
}

/// Configuration for project detection and output path
class ProjectConfig {
  final String workingDir;
  final String outputPath;

  ProjectConfig({
    required this.workingDir,
    required this.outputPath,
  });
}

/// Detect project context and determine output configuration
/// Returns null if not a valid consumer project
Future<ProjectConfig?> detectProjectConfig() async {
  final currentDir = Directory.current.path;

  // Check if we're in a Flutter project (has pubspec.yaml)
  final pubspecFile = File('$currentDir/pubspec.yaml');
  if (await pubspecFile.exists()) {
    final pubspecContent = await pubspecFile.readAsString();
    final pubspec = loadYaml(pubspecContent) as Map;

    // Check if we're running from within the library itself - reject this case
    final libDir = Directory('$currentDir/lib');
    if (await libDir.exists()) {
      final mainFile = File('$currentDir/lib/flutter_environment_config.dart');
      if (await mainFile.exists()) {
        // We're in the library project - don't generate here
        return null;
      }
    }

    // Check if this project uses flutter_environment_config
    final dependencies = pubspec['dependencies'] as Map?;
    final devDependencies = pubspec['dev_dependencies'] as Map?;

    final usesThisLibrary =
        dependencies?.containsKey('flutter_environment_config') == true ||
            devDependencies?.containsKey('flutter_environment_config') == true;

    if (usesThisLibrary) {
      // This is a consumer project
      final outputDir = _getOutputDirFromPubspec(pubspec);
      return ProjectConfig(
        workingDir: currentDir,
        outputPath: '$currentDir/$outputDir/flutter_environment_config.g.dart',
      );
    }

    // If root project doesn't have flutter_environment_config, search in packages
    final configFromPackages = await _findConfigInPackages(currentDir);
    if (configFromPackages != null) {
      return configFromPackages;
    }
  }

  // Not a valid consumer project
  return null;
}

/// Get output directory from pubspec.yaml configuration
String _getOutputDirFromPubspec(Map pubspec) {
  // Check for flutter_environment_config specific configuration
  final config = pubspec['flutter_environment_config'] as Map?;
  if (config != null) {
    final outputDir = config['output_dir'] as String?;
    if (outputDir != null) {
      print('📁 Using custom output directory from pubspec.yaml: $outputDir');
      return outputDir;
    }
  }

  // Default to lib/generated directory
  print('📁 Using default output directory: lib/generated');
  return 'lib/generated';
}

/// Find flutter_environment_config configuration from packages subdirectories
Future<ProjectConfig?> _findConfigInPackages(String projectRoot) async {
  final packagesDir = Directory('$projectRoot/packages');
  if (!await packagesDir.exists()) return null;

  try {
    await for (final entity in packagesDir.list()) {
      if (entity is Directory) {
        final pubspecFile = File('${entity.path}/pubspec.yaml');
        if (await pubspecFile.exists()) {
          try {
            final pubspecContent = await pubspecFile.readAsString();
            final pubspec = loadYaml(pubspecContent) as Map;

            final dependencies = pubspec['dependencies'] as Map?;
            final devDependencies = pubspec['dev_dependencies'] as Map?;

            final usesThisLibrary = dependencies
                        ?.containsKey('flutter_environment_config') ==
                    true ||
                devDependencies?.containsKey('flutter_environment_config') ==
                    true;

            if (usesThisLibrary) {
              // Found flutter_environment_config in this package
              final outputDir = _getOutputDirFromPubspec(pubspec);
              return ProjectConfig(
                workingDir: projectRoot,
                outputPath:
                    '$projectRoot/$outputDir/flutter_environment_config.g.dart',
              );
            }
          } catch (e) {
            // Skip invalid pubspec files
            continue;
          }
        }
      }
    }
  } catch (e) {
    // Skip if there are permission errors
  }

  return null;
}

/// Scan for environment files in the specified directory (recursive)
Future<List<String>> scanEnvFiles(Directory directory) async {
  final envFiles = <String>[];

  // First scan root directory
  await for (final entity in directory.list()) {
    if (entity is File) {
      final name = entity.path.split('/').last;
      // Look for .env, .env.*, but skip .env.example files
      if (name == '.env' ||
          (name.startsWith('.env.') && !name.endsWith('.example'))) {
        envFiles.add(entity.path);
      }
    }
  }

  // Also scan subdirectories regardless of root files
  await for (final entity in directory.list()) {
    if (entity is Directory) {
      final dirName = entity.path.split('/').last;
      // Skip common directories that shouldn't contain env files
      if (!_shouldSkipDirectory(dirName)) {
        final subDirFiles = await _scanDirectoryForEnvFiles(entity);
        envFiles.addAll(subDirFiles);
      }
    }
  }

  envFiles.sort(); // Ensure consistent ordering
  return envFiles;
}

/// Scan a specific directory for env files (non-recursive to avoid going too deep)
Future<List<String>> _scanDirectoryForEnvFiles(Directory directory) async {
  final envFiles = <String>[];

  try {
    await for (final entity in directory.list()) {
      if (entity is File) {
        final name = entity.path.split('/').last;
        // Look for .env, .env.*, but skip .env.example files
        if (name == '.env' ||
            (name.startsWith('.env.') && !name.endsWith('.example'))) {
          envFiles.add(entity.path);
        }
      }
    }
  } catch (e) {
    // Ignore permission errors or other issues
  }

  return envFiles;
}

/// Check if directory should be skipped during env file scanning
bool _shouldSkipDirectory(String dirName) {
  final skipDirs = {
    'node_modules', '.git', '.dart_tool', 'build', '.vscode', '.idea',
    'ios', 'android', 'web', 'linux', 'macos',
    'windows', // Flutter platform dirs
    'lib', 'test',
    'integration_test', // Dart/Flutter source dirs (usually don't contain env)
    '.pub-cache', '.flutter-plugins-dependencies',
    'Pods', 'Runner.xcworkspace', 'Runner.xcodeproj', // iOS specific
    'gradle', '.gradle', 'app', 'src', // Android specific
  };

  return skipDirs.contains(dirName) || dirName.startsWith('.');
}

// Color helper functions for terminal output
String _cyan(String text) => '\x1B[36m$text\x1B[0m';
String _blue(String text) => '\x1B[34m$text\x1B[0m';
String _yellow(String text) => '\x1B[33m$text\x1B[0m';
String _magenta(String text) => '\x1B[35m$text\x1B[0m';
String _green(String text) => '\x1B[32m$text\x1B[0m';
String _brightYellow(String text) => '\x1B[93m$text\x1B[0m';
String _brightCyan(String text) => '\x1B[96m$text\x1B[0m';
