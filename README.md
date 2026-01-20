# Flutter Environment Config

[![pub package](https://img.shields.io/pub/v/flutter_environment_config.svg)](https://pub.dev/packages/flutter_environment_config)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful Flutter plugin that provides type-safe access to environment variables with automatic code generation. Bring some [12 factor](https://12factor.net/config) love to your Flutter apps! 🚀

Inspired by [react-native-config](https://github.com/luggit/react-native-config)

## ✨ Features

- 🔧 **Type-Safe Code Generation**: Automatically generates type-safe getters for environment variables
- 📱 **Multi-Platform**: Access variables in Dart, iOS (Swift/Objective-C), and Android (Kotlin/Java)
- 🔍 **Recursive File Scanning**: Automatically discovers `.env` files in subdirectories
- 📦 **Multi-Package Support**: Works seamlessly with complex project structures
- 🌍 **Cross-Platform**: Supports Windows, macOS, and Linux development environments
- 🧪 **Testing Support**: Mock values for testing environments
- 🔒 **Multiple Environments**: Support for dev, staging, prod configurations
- ⚡ **Zero Configuration**: Works out of the box with intelligent defaults
- 🎨 **Colored Output**: Beautiful terminal output for better developer experience

## 🚀 Quick Start

### 1. Add Dependency

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_environment_config: ^x.y.z # the latest version
```

### 2. Create Environment Files

Create `.env` files in your project root or subdirectories:

**Development Environment (`.env.develop`):**

```bash
API_URL=https://dev-api.myapp.com
API_KEY=dev-key-123
ENABLE_ANALYTICS=false
DEBUG_MODE=true
MAX_RETRIES=3
TIMEOUT_SECONDS=30.5
```

**Staging Environment (`.env.staging`):**

```bash
API_URL=https://staging-api.myapp.com
API_KEY=staging-key-789
ENABLE_ANALYTICS=true
DEBUG_MODE=false
MAX_RETRIES=4
TIMEOUT_SECONDS=45.0
```

**Production Environment (`.env.production`):**

```bash
API_URL=https://api.myapp.com
API_KEY=prod-key-456
ENABLE_ANALYTICS=true
DEBUG_MODE=false
MAX_RETRIES=5
TIMEOUT_SECONDS=60.0
```

### 3. Generate Type-Safe Code

Run the code generator:

```bash
dart run flutter_environment_config:generate
```

This generates `lib/generated/flutter_environment_config.g.dart` with type-safe getters:

```dart
// Auto-generated - DO NOT MODIFY
abstract class FlutterEnvironmentConfigGeneration {
  // Type-safe getters with automatic type inference
  static String? get apiUrl => FlutterEnvironmentConfig.get('API_URL');
  static String? get apiKey => FlutterEnvironmentConfig.get('API_KEY');
  static bool? get enableAnalytics {
    final value = FlutterEnvironmentConfig.get('ENABLE_ANALYTICS');
    return value?.toLowerCase() == 'true';
  }
  static int? get maxRetries {
    final value = FlutterEnvironmentConfig.get('MAX_RETRIES');
    return value != null ? int.tryParse(value) : null;
  }
  static double? get timeoutSeconds {
    final value = FlutterEnvironmentConfig.get('TIMEOUT_SECONDS');
    return value != null ? double.tryParse(value) : null;
  }
  
  // Constant keys for direct access
  static const String kApiUrlKey = 'API_URL';
  static const String kApiKeyKey = 'API_KEY';
  // ... more constants
}
```

### 4. Use in Your App

```dart
import 'package:flutter_environment_config/flutter_environment_config.dart';
import 'lib/generated/flutter_environment_config.g.dart'; // Generated file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await FlutterEnvironmentConfig.loadEnvVariables();

  runApp(MyApp());
}

class ApiService {
  void makeRequest() {
    // Type-safe access with auto-completion
    final apiUrl = FlutterEnvironmentConfigGeneration.apiUrl;
    final apiKey = FlutterEnvironmentConfigGeneration.apiKey;
    final maxRetries = FlutterEnvironmentConfigGeneration.maxRetries ?? 3;
}
```

## 🔧 Advanced Configuration

### Custom Output Directory

Configure where generated files are placed:

```yaml
# pubspec.yaml
flutter_environment_config:
  output_dir: lib/environment  # Default: lib/generated
```

### Multi-Package Projects

For complex projects with multiple packages, the generator automatically detects configuration from sub-packages:

```yaml
my_app/
├── pubspec.yaml
├── packages/
│   ├── core/
│   │   ├── pubspec.yaml          # Contains flutter_environment_config dependency
│   │   └── lib/environment/      # Generated code goes here
│   └── common/
├── env/
│   ├── .env.develop
│   ├── .env.staging
│   └── .env.production
```

### Environment File Discovery

The generator automatically discovers `.env` files in:

- Project root directory
- All subdirectories (recursive)
- Excludes common directories: `build/`, `.dart_tool/`, `node_modules/`, etc.

### Supported Data Types

The generator automatically infers types from values:

```bash
# String (default)
APP_NAME=MyApp
BASE_URL=https://api.example.com

# Boolean (case-insensitive)
DEBUG_MODE=true
ENABLE_FEATURE=false

# Integer
MAX_RETRIES=5
PORT=8080

# Double/Float
TIMEOUT_SECONDS=30.5
API_VERSION=1.2
```

## ⚠️ Security Notice

This plugin doesn't obfuscate or encrypt secrets for packaging. **Never store sensitive information in `.env` files** as they can be reverse-engineered from your app bundle.

For sensitive data, use:

- Server-side configuration
- Secure storage solutions
- Runtime environment variables
- Key management services

## 📱 Native Platform Usage

### iOS (Swift/Objective-C)

Access environment variables in native iOS code:

```swift
import flutter_environment_config

// Swift
let apiKey = flutter_environment_config.FlutterEnvironmentConfigPlugin.env(for: "API_KEY")
let debugMode = flutter_environment_config.FlutterEnvironmentConfigPlugin.env(for: "DEBUG_MODE")
```

```objc
// Objective-C
#import <flutter_environment_config/flutter_environment_config-Swift.h>

NSString *apiKey = [FlutterEnvironmentConfigPlugin envFor:@"API_KEY"];
```

### Android (Kotlin/Java)

Environment variables are available in your Android build process. See the [Android Setup Guide](docs/ANDROID.md) for detailed configuration.

## 📝 Installation

Add as a project dependency:

```yaml
# pubspec.yaml
dependencies:
  flutter_environment_config: ^1.0.0
```

Then run:

```bash
flutter pub get

# Generate code
dart run flutter_environment_config:generate
```

## 🛠️ Setup

### Generator Setup

No additional setup required! The generator automatically:

- Detects your project structure
- Finds environment files recursively
- Generates type-safe code with intelligent defaults

### iOS Setup

No additional setup required! 🎉

### Android Setup

Refer to the [Android Setup Guide](docs/ANDROID.md) for initial configuration and advanced options.

## 🧪 Testing

Use `loadValueForTesting` to mock environment variables in your tests:

```dart
import 'package:flutter_environment_config/flutter_environment_config.dart';
import 'lib/generated/flutter_environment_config.g.dart';

void main() {
  setUp(() {
    FlutterEnvironmentConfig.loadValueForTesting({
      'API_URL': 'https://test-api.com',
      'DEBUG_MODE': 'true',
      'MAX_RETRIES': '1',
    });
  });

  test('should use test environment variables', () {
    // Direct access
    final apiUrl = FlutterEnvironmentConfig.get('API_URL');
    expect(apiUrl, equals('https://test-api.com'));
    
    // Type-safe access
    final maxRetries = FlutterEnvironmentConfigGeneration.maxRetries;
    expect(maxRetries, equals(1));
  });
}
```

## 🌍 Multiple Environments

You can use different `.env` files for different environments:

```bash
.env               # Default
.env.develop       # Development
.env.staging       # Staging
.env.production    # Production
```

The generator automatically discovers and merges variables from all files, showing which files contain each variable in the generated documentation.

## 🚀 Generator CLI

The code generator provides several useful features:

### Basic Usage

```bash
# Generate code with current configuration
dart run flutter_environment_config:generate

# Force regeneration
dart run flutter_environment_config:generate --force
```

### Output Information

The generator provides detailed information:

```bash
🔧 Flutter Environment Config Generator
📋 Configuration:
📁 Working directory: /path/to/project
📄 Output path: /path/to/project/lib/generated/flutter_environment_config.g.dart

📂 Reading environment files:
📖 Reading .env.develop
📖 Reading .env.staging
📖 Reading .env.production

✅ Generation completed:
📊 Generated 18 environment variables
📁 Output: lib/generated/flutter_environment_config.g.dart
```

### Multi-Package Support

For complex projects, the generator intelligently detects configuration from sub-packages:

```bash
# Project structure
my_app/
├── pubspec.yaml
├── packages/
│   └── core/
│       └── pubspec.yaml  # Contains flutter_environment_config config
├── env/
    ├── .env.develop
    ├── .env.staging
    └── .env.production

# Generator automatically uses config from packages/core/pubspec.yaml
flutter_environment_config:
  output_dir: packages/core/lib/environment
```

## 📚 Documentation

- [Android Setup Guide](docs/CONFIG_ANDROID.md) - Detailed Android configuration
- [iOS Setup Guide](docs/CONFIG_IOS.md) - Advanced iOS usage

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [react-native-config](https://github.com/luggit/react-native-config)
- Built with ❤️ for the Flutter community
