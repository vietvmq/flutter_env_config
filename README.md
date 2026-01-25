# Flutter Environment Config

[![pub package](https://img.shields.io/pub/v/flutter_environment_config.svg)](https://pub.dev/packages/flutter_environment_config)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful Flutter plugin that provides type-safe access to environment variables with automatic code generation. Bring some [12 factor](https://12factor.net/config) love to your Flutter apps! 🚀

Inspired by [react-native-config](https://github.com/luggit/react-native-config)

## ✨ Features

- 🔧 **Type-Safe Code Generation**: Automatically generates type-safe getters for environment variables
- 📱 **Multi-Platform**: Access variables in Dart, iOS (Swift/Objective-C), and Android (Kotlin/Java)
- � **Multiple Environments**: Support for dev, staging, prod configurations
- 🧪 **Testing Support**: Mock values for testing environments
- ⚡ **Zero Configuration**: Works out of the box with intelligent defaults

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_environment_config: ^x.y.z # the latest version
```

## 🚀 Usage

### 1. Create Environment Files

Create environment files in the `env/` folder:

```text
my_app/
├── env/
│   ├── .env.develop     # Development environment
│   ├── .env.staging     # Staging environment
│   └── .env.production  # Production environment
└── pubspec.yaml
```

**Example `env/.env.develop`:**

```bash
API_URL=https://dev-api.myapp.com
API_KEY=dev-key-123
ENABLE_ANALYTICS=false
DEBUG_MODE=true
MAX_RETRIES=3
TIMEOUT_SECONDS=30.5
```

**Example `env/.env.staging`:**

```bash
API_URL=https://staging-api.myapp.com
API_KEY=staging-key-789
ENABLE_ANALYTICS=true
DEBUG_MODE=false
MAX_RETRIES=4
TIMEOUT_SECONDS=45.0
```

**Example `env/.env.production`:**

```bash
API_URL=https://api.myapp.com
API_KEY=prod-key-456
ENABLE_ANALYTICS=true
DEBUG_MODE=false
MAX_RETRIES=5
TIMEOUT_SECONDS=60.0
```

### 2. Load Environment Variables

```dart
import 'package:flutter_environment_config/flutter_environment_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await FlutterEnvironmentConfig.loadEnvVariables();
  
  runApp(MyApp());
}
```

### 3. Use in Your App

```dart
class ApiService {
  void makeRequest() {
    // Direct access
    final apiUrl = FlutterEnvironmentConfig.get('API_URL');
    final apiKey = FlutterEnvironmentConfig.get('API_KEY');
    
    // Type conversion helpers
    final maxRetries = FlutterEnvironmentConfig.getInt('MAX_RETRIES', defaultValue: 3);
    final enableAnalytics = FlutterEnvironmentConfig.getBool('ENABLE_ANALYTICS', defaultValue: false);
    
    print('API URL: $apiUrl');
    print('Max retries: $maxRetries');
  }
}
```

## 📱 Native Configuration

For accessing environment variables in native Android and iOS code:

📚 **Platform-Specific Setup Guides:**
- [📱 Android Setup Guide](docs/CONFIG_ANDROID.md) - Gradle configuration, build flavors, ProGuard setup
- [🍎 iOS Setup Guide](docs/CONFIG_IOS.md) - Xcode schemes, Info.plist, Swift/Objective-C usage

## ⚙️ Code Generator

Generate type-safe getters for your environment variables:

```bash
dart run flutter_environment_config:generate
```

This creates `lib/generated/flutter_environment_config.g.dart` with type-safe access:

```dart
// Auto-generated - DO NOT MODIFY
abstract class FlutterEnvironmentConfigGeneration {
  // Type-safe getters
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
  
  // Constant keys
  static const String kApiUrlKey = 'API_URL';
  static const String kApiKeyKey = 'API_KEY';
}
```

**Usage with Generated Code:**
```dart
import 'lib/generated/flutter_environment_config.g.dart';

class ApiService {
  void makeRequest() {
    final apiUrl = FlutterEnvironmentConfigGeneration.apiUrl;
    final maxRetries = FlutterEnvironmentConfigGeneration.maxRetries ?? 3;
  }
}
```

### Generator Configuration

Customize output directory in `pubspec.yaml`:

```yaml
flutter_environment_config:
  output_dir: lib/environment  # Default: lib/generated
```

## 🧪 Testing

Mock environment variables for testing:

```dart
import 'package:flutter_environment_config/flutter_environment_config.dart';

void main() {
  setUp(() {
    FlutterEnvironmentConfig.loadValueForTesting({
      'API_URL': 'https://test-api.com',
      'DEBUG_MODE': 'true',
      'MAX_RETRIES': '1',
    });
  });

  test('should use test environment variables', () {
    final apiUrl = FlutterEnvironmentConfig.get('API_URL');
    expect(apiUrl, equals('https://test-api.com'));
  });
}
```

## ⚠️ Security Notice

Environment variables are embedded in your app bundle and can be reverse-engineered. **Never store sensitive data in `.env` files**.

**❌ Never store:**
- API secrets and private keys
- Database credentials  
- Signing certificates

**✅ Safe to store:**
- API endpoints and URLs
- Feature flags
- Debug settings

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [react-native-config](https://github.com/luggit/react-native-config)
- Built with ❤️ for the Flutter community
