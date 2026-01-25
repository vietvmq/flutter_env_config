# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-01-25
- Update README.md
- Fix static analysis issues: Add missing return type annotations

## [1.0.0] - 2026-01-25

### 🎉 Initial Release

First stable release of Flutter Environment Config - A plugin that exposes environment variables to your Dart code in Flutter as well as to your native code in iOS and Android.

### ✨ Core Features

- 🔧 **Environment Variable Management**: Load and access environment variables across Flutter, Android, and iOS
- 📱 **Cross-Platform Support**: Seamless integration with Android and iOS native code
- 🎯 **Multiple Environment Support**: Support for development, staging, and production environments
- 📁 **Flexible File Structure**: Support for `.env` files with custom naming and locations

### 🛠️ Platform-Specific Features

#### Android
- 🎨 **Build Flavors Support**: Integration with Android build flavors
- 📦 **BuildConfig Integration**: Automatic injection of environment variables into BuildConfig
- ⚙️ **Gradle Configuration**: Easy setup with gradle scripts
- 🔒 **ProGuard Support**: Proper configuration for release builds

#### iOS  
- 🔧 **XCConfig Integration**: Automatic generation of XCConfig files
- 🎯 **Scheme Configuration**: Support for multiple Xcode schemes
- 📝 **Info.plist Integration**: Dynamic configuration of Info.plist values
- 🚀 **Build Script Automation**: Automated build pre-actions

### 📚 Documentation & Examples

- 📖 **Comprehensive Documentation**: Detailed setup guides for Android and iOS
- 💼 **Working Examples**: Complete example project with multi-environment setup
- 🖼️ **Visual Guides**: Step-by-step screenshots for Xcode and Android Studio configuration
- 🔧 **Troubleshooting Guides**: Common issues and solutions

### 🎨 Developer Experience

- ⚡ **Easy Setup**: Minimal configuration required
- 🔄 **Hot Reload Support**: Environment changes work with Flutter hot reload
- 🐛 **Debug Support**: Clear error messages and debugging information
- 📱 **Flutter Integration**: Type-safe access to environment variables in Dart code

### 🚀 Getting Started

Add to your `pubspec.yaml`:
```yaml
dependencies:
  flutter_environment_config: ^1.0.0
```

### 📋 Supported Platforms

- ✅ **Flutter**: 1.10.0+
- ✅ **Dart**: 2.12.0+
- ✅ **Android**: API 21+
- ✅ **iOS**: iOS 9.0+
- 🔧 **Configuration Reference**: Complete pubspec.yaml configuration options