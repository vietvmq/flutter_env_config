# Android Setup Guide

A step-by-step guide to configure Flutter Environment Config for Android projects.

## 📁 Create Environment Files

First, create environment files in your project root:

```text
my_app/
├── env/
│   ├── .env.develop     # Development environment
│   ├── .env.staging     # Staging environment
│   └── .env.production  # Production environment
├── pubspec.yaml
└── android/
    └── app/
        └── build.gradle
```

**Example `env/.env.develop`:**

```bash
APP_NAME=[DEV] My App
APP_ID=com.dev.my_app
VERSION_CODE=1
VERSION_NAME=1.0.0-dev
API_URL=https://dev-api.my_app.com
API_KEY=dev-key-123
DEBUG_MODE=true
```

**Example `env/.env.staging`:**

```bash
APP_NAME=[STAGING] My App
APP_ID=com.staging.my_app
VERSION_CODE=1
VERSION_NAME=1.0.0-staging
API_URL=https://staging-api.my_app.com
API_KEY=staging-key-456
DEBUG_MODE=false
```

**Example `env/.env.production`:**

```bash
APP_NAME=My App
APP_ID=com.my_app
VERSION_CODE=1
VERSION_NAME=1.0.0
API_URL=https://api.my_app.com
API_KEY=prod-key-789
DEBUG_MODE=false
```

## 🛠️ Setup

### 1. Configure Without Flavors

If you are not using flavors in your project, specify a single environment file.

In your `android/app/build.gradle` file:

```gradle
// Directly specify the environment file to use
project.ext.defaultEnvFile = "env/.env.production" // Replace with your desired environment file
apply from: project(':flutter_environment_config').projectDir.getPath() + "/dotenv.gradle"
```

**Default Behavior**: If no environment file is specified, the library will look for a `.env` file in the project root.

### 2. Configure Flavors

For projects with multiple environments using build flavors.

In your `android/app/build.gradle` file:

```gradle
// Environment file mapping for multiple environments
project.ext.envConfigFiles = [
    develop: "env/.env.develop",
    staging: "env/.env.staging",
    production: "env/.env.production"
]
apply from: project(':flutter_environment_config').projectDir.getPath() + "/dotenv.gradle"
```

### 3. Configure Specific Flavors

Configure Android build flavors in `android/app/build.gradle`:

```gradle
android {
    flavorDimensions "environment"
    productFlavors {
        develop {
            dimension "environment"
            applicationIdSuffix ".dev"
        }
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
        }
        production {
            dimension "environment"
            applicationIdSuffix ""
        }
    }
}
```

### 4. Configure ENVFILE Variable

You can specify the environment file dynamically using the `ENVFILE` environment variable:

```bash
# Example: Use production environment file
ENVFILE=env/.env.production ./gradlew assembleRelease

# Example: Use staging environment file
ENVFILE=env/.env.staging flutter build apk
```

### 5. Configure BuildConfig

Enable BuildConfig generation in `android/app/build.gradle`:

```gradle
android {
    buildFeatures {
        buildConfig = true
    }
}
```

### 6. Configure ProGuard (Release Builds)

Create `android/app/proguard-rules.pro`:

```proguard
# Keep BuildConfig class and all its fields
-keep class **.BuildConfig { *; }
```

Add to `android/app/build.gradle`:

```gradle
android {
    buildTypes {
        release {
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

## 💻 Usage

### Gradle Configuration

```gradle
android {
    defaultConfig {
        applicationId project.env.get("APP_ID")
        versionName project.env.get("VERSION_NAME")
        versionCode project.env.get("VERSION_CODE").toInteger()
    }
}
```

### AndroidManifest.xml

```xml
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="@string/GOOGLE_MAPS_API_KEY" />

    <meta-data
        android:name="firebase_analytics_collection_enabled"
        android:value="@string/ENABLE_ANALYTICS" />
</application>
```

### Kotlin

```kotlin
class ApiService {
    private val apiUrl = BuildConfig.API_URL
    private val apiKey = BuildConfig.API_KEY
    private val debugMode = BuildConfig.DEBUG_MODE.toBoolean()

    fun createHttpClient(): OkHttpClient {
        return OkHttpClient.Builder()
            .addInterceptor { chain ->
                val request = chain.request().newBuilder()
                    .addHeader("Authorization", "Bearer $apiKey")
                    .build()
                chain.proceed(request)
            }
            .build()
    }
}
```

### Java

```java
public class ApiService {
    private static final String API_URL = BuildConfig.API_URL;
    private static final String API_KEY = BuildConfig.API_KEY;

    public HttpURLConnection createConnection() throws IOException {
        URL url = new URL(API_URL + "/api/data");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestProperty("Authorization", "Bearer " + API_KEY);
        return connection;
    }
}
```

### Build Commands

```bash
# Run without flavors
flutter run

# Run with flavors
flutter run --flavor develop
flutter run --flavor staging
flutter run --flavor production

# Build APKs
flutter build apk --flavor develop
flutter build apk --flavor staging
flutter build apk --flavor production --release
```

## 📋 Best Practices

### 1. Environment Variable Naming

Use consistent naming conventions:

```bash
# App Information
APP_NAME=My App
APP_ID=com.company.myapp
VERSION_NAME=1.0.0
VERSION_CODE=1

# API Configuration
API_URL=https://api.example.com
API_TIMEOUT=30000

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=false
DEBUG_MODE=true

# Third-party Keys (be careful with sensitive data)
GOOGLE_MAPS_API_KEY=your_key_here
FIREBASE_PROJECT_ID=your_project_id
```

## ⚠️ Security

**Environment variables are embedded in your APK and can be extracted.**

### Never store

- API secrets and private keys
- Database credentials
- Signing certificates

### Safe to store

- API endpoints and URLs
- Feature flags
- Debug settings

## 🆘 Troubleshooting

### Common Issues

1. **Environment variables not loading**
   - Ensure environment files exist in the correct location
   - Verify file naming matches exactly (case-sensitive)
   - Check that the correct environment file is being referenced

2. **Variables are null in release builds**
   - Check ProGuard rules are applied correctly
   - Verify BuildConfig is enabled
   - Ensure variables are defined in the correct environment file

3. **Android build issues**
   - Ensure gradle files are properly configured
   - Check that flavor names match environment file configurations
   - Verify ProGuard rules are in place for release builds

### Debug Tips

Add debugging to see which environment file is loaded:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterEnvironmentConfig.loadEnvVariables();

  // Debug: Print all loaded variables
  print('Loaded environment variables:');
  FlutterEnvironmentConfig.variables.forEach((key, value) {
    print('$key: $value');
  });

  runApp(const MyApp());
}
```

**Variables not updating:**

- Run `flutter clean && flutter pub get`
- Verify file paths and syntax

For help, check the [example implementation](../example/) or open an issue.
