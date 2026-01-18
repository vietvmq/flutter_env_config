#!/usr/bin/env dart

import "dart:io";

void main() async {
  print('🔧 Flutter Environment Config Generator');
  
  // When activated globally, look for generator in package installation
  final generatorPath = await _findGenerator();
  
  if (generatorPath != null) {
    print('🚀 Running generator from: $generatorPath');
    
    // Run generator directly in current directory
    final result = await Process.run(
      'dart', 
      [generatorPath],
      workingDirectory: Directory.current.path,
    );
    
    print(result.stdout);
    if (result.stderr.toString().isNotEmpty) {
      print('⚠️ ${result.stderr}');
    }
    
    exit(result.exitCode);
  } else {
    print('❌ Generator not found.');
    print('💡 Make sure you have activated flutter_environment_config globally:');
    print('   dart pub global activate flutter_environment_config');
    exit(1);
  }
}

Future<String?> _findGenerator() async {
  // For globally activated packages, try to find generator in script directory
  final scriptFile = Platform.script.toFilePath();
  final scriptDir = Directory(scriptFile).parent.path;
  
  // Look for generator relative to this script
  final possiblePaths = [
    '$scriptDir/../generator/generate_environment_config.dart', // Relative to bin
    '$scriptDir/generator/generate_environment_config.dart',     // Same level as bin
  ];
  
  for (final path in possiblePaths) {
    if (File(path).existsSync()) {
      return path;
    }
  }
  
  return null;
}


