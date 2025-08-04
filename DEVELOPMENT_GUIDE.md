# OmniReader Development Guide 🛠️

This comprehensive guide will help you set up, develop, and deploy the OmniReader Flutter application using VS Code and GitHub for APK creation.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [VS Code Configuration](#vs-code-configuration)
4. [GitHub Setup](#github-setup)
5. [Development Workflow](#development-workflow)
6. [Building APKs](#building-apks)
7. [Testing](#testing)
8. [Debugging](#debugging)
9. [Performance Optimization](#performance-optimization)
10. [Deployment](#deployment)
11. [Troubleshooting](#troubleshooting)

## 🔧 Prerequisites

### Required Software

1. **Flutter SDK** (3.16.0 or higher)
   - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Add Flutter to your PATH environment variable

2. **Dart SDK** (3.2.0 or higher)
   - Included with Flutter SDK
   - Verify with `dart --version`

3. **Android Studio** (Latest version)
   - Download from [developer.android.com](https://developer.android.com/studio)
   - Install Android SDK and build tools
   - Set up Android emulator

4. **VS Code** (Latest version)
   - Download from [code.visualstudio.com](https://code.visualstudio.com/)
   - Primary development environment

5. **Git** (Latest version)
   - Download from [git-scm.com](https://git-scm.com/)
   - Required for version control and GitHub integration

6. **Java Development Kit (JDK)** (17 or higher)
   - Download OpenJDK from [adoptium.net](https://adoptium.net/)
   - Required for Android development

### System Requirements

- **Operating System**: Windows 10/11, macOS 10.14+, or Linux (Ubuntu 18.04+)
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 10GB free space for development tools
- **Internet**: Required for package downloads and API testing

## 🚀 Environment Setup

### 1. Flutter Installation

#### Windows
```powershell
# Download Flutter SDK
# Extract to C:\flutter
# Add C:\flutter\bin to PATH

# Verify installation
flutter doctor
```

#### macOS
```bash
# Using Homebrew
brew install flutter

# Or download manually
# Extract to ~/flutter
# Add ~/flutter/bin to PATH

# Verify installation
flutter doctor
```

#### Linux
```bash
# Download Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz

# Extract
tar xf flutter_linux_3.16.0-stable.tar.xz

# Add to PATH
echo 'export PATH="$PATH:`pwd`/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
flutter doctor
```

### 2. Android Setup

1. **Install Android Studio**
   - Download and install Android Studio
   - Open Android Studio and complete the setup wizard
   - Install Android SDK (API level 33 or higher)

2. **Configure Android SDK**
   ```bash
   # Set ANDROID_HOME environment variable
   export ANDROID_HOME=$HOME/Android/Sdk
   export PATH=$PATH:$ANDROID_HOME/tools
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   ```

3. **Accept Android Licenses**
   ```bash
   flutter doctor --android-licenses
   ```

4. **Create Android Emulator**
   - Open Android Studio
   - Go to Tools > AVD Manager
   - Create a new virtual device
   - Choose a recent Android version (API 33+)

### 3. Verify Setup

```bash
# Check Flutter installation
flutter doctor -v

# Expected output should show:
# ✓ Flutter (Channel stable, 3.16.0)
# ✓ Android toolchain
# ✓ VS Code
# ✓ Connected device (if emulator is running)
```

## 💻 VS Code Configuration

### 1. Install Required Extensions

Open VS Code and install these essential extensions:

```json
{
  "recommendations": [
    "dart-code.dart-code",
    "dart-code.flutter",
    "ms-vscode.vscode-json",
    "redhat.vscode-yaml",
    "ms-vscode.vscode-typescript-next",
    "bradlc.vscode-tailwindcss",
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-eslint",
    "github.vscode-pull-request-github",
    "eamodio.gitlens",
    "ms-vscode.vscode-github-actions",
    "gruntfuggly.todo-tree",
    "aaron-bond.better-comments",
    "usernamehw.errorlens",
    "pkief.material-icon-theme",
    "zhuangtongfa.material-theme",
    "formulahendry.auto-rename-tag",
    "christian-kohler.path-intellisense",
    "ms-vscode.vscode-flutter-tree",
    "alexisvt.flutter-snippets",
    "nash.awesome-flutter-snippets",
    "jeroen-meijer.pubspec-assist",
    "ryanluker.vscode-coverage-gutters"
  ]
}
```

### 2. Configure VS Code Settings

The project includes a comprehensive `.vscode/settings.json` file with optimized settings for Flutter development. Key configurations include:

- **Dart & Flutter**: Optimized for development workflow
- **Editor**: Auto-formatting, rulers, and code actions
- **File Management**: Proper exclusions and associations
- **Debugging**: Enhanced debugging experience
- **Extensions**: Configured for maximum productivity

### 3. Launch Configurations

The `.vscode/launch.json` file provides multiple launch configurations:

- **Debug Mode**: For development and testing
- **Profile Mode**: For performance analysis
- **Release Mode**: For production testing
- **Integration Tests**: For running integration tests
- **Custom Device**: For specific device targeting

### 4. Tasks Configuration

The `.vscode/tasks.json` file includes pre-configured tasks:

- **Build Tasks**: Clean, build APK, build bundle
- **Test Tasks**: Run tests, analyze code, format code
- **Git Tasks**: Add, commit, push operations
- **Pipeline Tasks**: Complete build and release workflows

## 🐙 GitHub Setup

### 1. Repository Setup

1. **Fork the Repository**
   ```bash
   # Fork the repository on GitHub
   # Clone your fork
   git clone https://github.com/YOUR_USERNAME/omnireader.git
   cd omnireader
   ```

2. **Set Up Remotes**
   ```bash
   # Add upstream remote
   git remote add upstream https://github.com/omnireader/omnireader.git
   
   # Verify remotes
   git remote -v
   ```

3. **Configure Git**
   ```bash
   # Set your identity
   git config user.name "Your Name"
   git config user.email "your.email@example.com"
   
   # Set up GPG signing (optional but recommended)
   git config commit.gpgsign true
   ```

### 2. GitHub Actions Setup

The repository includes a comprehensive GitHub Actions workflow (`.github/workflows/build.yml`) that:

- **Builds APKs**: Automatically builds debug and release APKs
- **Runs Tests**: Executes unit and integration tests
- **Code Quality**: Performs static analysis and formatting checks
- **Security Scanning**: Runs vulnerability scans
- **Releases**: Creates GitHub releases with APK files

#### Workflow Triggers

- **Push to main**: Builds release APK
- **Pull Requests**: Builds debug APK and runs tests
- **Tags**: Creates full release with all APK variants
- **Manual Dispatch**: Allows manual triggering with options

#### APK Variants

The workflow builds multiple APK variants:
- **Universal APK**: Works on all devices
- **ARM64 APK**: Optimized for 64-bit devices (recommended)
- **ARM APK**: For 32-bit devices
- **x86_64 APK**: For emulators and x86 devices

### 3. Secrets Configuration

For full functionality, configure these GitHub secrets:

1. **ANDROID_KEYSTORE**: Base64 encoded keystore file
2. **KEYSTORE_PASSWORD**: Keystore password
3. **KEY_ALIAS**: Key alias
4. **KEY_PASSWORD**: Key password

```bash
# Generate keystore (for release builds)
keytool -genkey -v -keystore omnireader-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias omnireader

# Encode keystore for GitHub secrets
base64 omnireader-key.jks | tr -d '\n' | pbcopy
```

## 🔄 Development Workflow

### 1. Daily Development

1. **Start Development Session**
   ```bash
   # Pull latest changes
   git pull upstream main
   
   # Create feature branch
   git checkout -b feature/your-feature-name
   
   # Open in VS Code
   code .
   ```

2. **Development Loop**
   - Make code changes
   - Use VS Code tasks for quick checks
   - Test on emulator/device
   - Commit changes regularly

3. **Code Quality Checks**
   ```bash
   # Run quick checks (VS Code task)
   # Or manually:
   flutter analyze
   dart format .
   flutter test
   ```

### 2. Feature Development

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

2. **Implement Feature**
   - Follow the project structure
   - Write tests for new functionality
   - Update documentation
   - Follow coding standards

3. **Test Thoroughly**
   ```bash
   # Run all tests
   flutter test
   
   # Test on multiple devices
   flutter run -d device-id
   
   # Performance testing
   flutter run --profile
   ```

4. **Submit Pull Request**
   ```bash
   # Push feature branch
   git push origin feature/amazing-feature
   
   # Create pull request on GitHub
   # Fill out the PR template
   # Wait for CI checks to pass
   ```

### 3. Code Review Process

1. **Automated Checks**
   - GitHub Actions runs automatically
   - Code quality checks must pass
   - All tests must pass
   - Security scans must be clean

2. **Manual Review**
   - Code review by maintainers
   - Testing on different devices
   - Performance impact assessment
   - Documentation review

3. **Merge Process**
   - Squash and merge for clean history
   - Automatic deployment to staging
   - Release notes generation

## 🏗️ Building APKs

### 1. Using VS Code (Recommended)

#### Quick Build
1. Open Command Palette (`Ctrl+Shift+P`)
2. Type "Tasks: Run Task"
3. Select "Flutter: Build APK (Release)"

#### Full Pipeline
1. Open Command Palette (`Ctrl+Shift+P`)
2. Type "Tasks: Run Task"
3. Select "OmniReader: Release Build"

This runs the complete pipeline:
- Clean project
- Get dependencies
- Run analysis
- Run tests with coverage
- Build split APKs
- Build app bundle

### 2. Using Command Line

#### Debug APK
```bash
# Basic debug APK
flutter build apk --debug

# Debug APK with specific flavor
flutter build apk --debug --flavor development
```

#### Release APK
```bash
# Single universal APK
flutter build apk --release

# Split APKs per ABI (recommended)
flutter build apk --split-per-abi --release

# Specific ABI
flutter build apk --target-platform android-arm64 --release
```

#### App Bundle (for Play Store)
```bash
# Release bundle
flutter build appbundle --release

# Bundle with obfuscation
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```

### 3. Using GitHub Actions

#### Automatic Builds
- **Push to main**: Triggers release build
- **Create tag**: Triggers full release with all variants
- **Pull request**: Triggers debug build and tests

#### Manual Builds
1. Go to GitHub Actions tab
2. Select "Build and Release APK" workflow
3. Click "Run workflow"
4. Choose build type (debug/release)
5. Click "Run workflow"

#### Download APKs
1. Go to GitHub Actions tab
2. Click on completed workflow run
3. Download APK artifacts
4. Or download from Releases page (for tagged builds)

### 4. Build Optimization

#### Reduce APK Size
```bash
# Enable R8 obfuscation
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Split APKs by ABI
flutter build apk --split-per-abi --release

# Remove unused resources
flutter build apk --release --tree-shake-icons
```

#### Performance Optimization
```bash
# Profile build for performance testing
flutter build apk --profile

# Release build with performance monitoring
flutter build apk --release --dart-define=PERFORMANCE_MONITORING=true
```

## 🧪 Testing

### 1. Test Structure

```
test/
├── unit/                    # Unit tests
│   ├── models/
│   ├── services/
│   └── repositories/
├── widget/                  # Widget tests
│   ├── screens/
│   └── widgets/
├── integration/             # Integration tests
│   ├── app_test.dart
│   └── flows/
└── test_utils/             # Test utilities
    ├── mocks.dart
    └── test_data.dart
```

### 2. Running Tests

#### VS Code
1. Open Command Palette (`Ctrl+Shift+P`)
2. Type "Tasks: Run Task"
3. Select test task:
   - "Flutter: Test" - Run all tests
   - "Flutter: Test with Coverage" - Run with coverage
   - "OmniReader: Quick Check" - Analysis + tests

#### Command Line
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/models/reading_item_test.dart

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

### 3. Writing Tests

#### Unit Test Example
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:omnireader/models/reading_item.dart';

void main() {
  group('ReadingItem', () {
    test('should calculate progress percentage correctly', () {
      // Arrange
      final item = ReadingItem(
        title: 'Test Manga',
        currentChapter: 50,
        totalChapters: 100,
      );

      // Act
      final progress = item.progressPercentage;

      // Assert
      expect(progress, equals(50.0));
    });
  });
}
```

#### Widget Test Example
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnireader/widgets/reading_item_card.dart';

void main() {
  testWidgets('ReadingItemCard displays title correctly', (tester) async {
    // Arrange
    const testItem = ReadingItem(title: 'Test Manga');

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: ReadingItemCard(item: testItem),
      ),
    );

    // Assert
    expect(find.text('Test Manga'), findsOneWidget);
  });
}
```

### 4. Test Coverage

#### Generate Coverage Report
```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html
```

#### Coverage Goals
- **Unit Tests**: 90%+ coverage
- **Widget Tests**: 80%+ coverage
- **Integration Tests**: Critical user flows
- **Overall**: 85%+ coverage

## 🐛 Debugging

### 1. VS Code Debugging

#### Debug Configuration
The project includes multiple debug configurations:
- **Debug Mode**: Standard debugging with hot reload
- **Profile Mode**: Performance profiling
- **Release Mode**: Production debugging
- **Custom Device**: Target specific devices

#### Debugging Steps
1. Set breakpoints in code
2. Press `F5` or select debug configuration
3. Use debug console for inspection
4. Utilize hot reload for quick iterations

#### Debug Tools
- **Flutter Inspector**: Widget tree inspection
- **Performance View**: Performance monitoring
- **Network View**: API call monitoring
- **Logging View**: Application logs

### 2. Common Debugging Scenarios

#### State Management Issues
```dart
// Use Riverpod's debugging features
final container = ProviderContainer(
  observers: [ProviderLogger()],
);
```

#### Network Issues
```dart
// Enable HTTP logging
import 'package:http/http.dart' as http;

class ApiService {
  static final _client = http.Client();
  
  Future<Response> get(String url) async {
    print('GET: $url');
    final response = await _client.get(Uri.parse(url));
    print('Response: ${response.statusCode}');
    return response;
  }
}
```

#### Database Issues
```dart
// Enable SQLite logging
Database.setLogLevel(sqflite.LogLevel.verbose);
```

### 3. Performance Debugging

#### Profile Mode
```bash
# Run in profile mode
flutter run --profile

# Build profile APK
flutter build apk --profile
```

#### Performance Monitoring
```dart
// Add performance monitoring
import 'dart:developer' as developer;

void performanceTrace(String name, Function() operation) {
  developer.Timeline.startSync(name);
  try {
    operation();
  } finally {
    developer.Timeline.finishSync();
  }
}
```

#### Memory Debugging
```bash
# Monitor memory usage
flutter run --enable-software-rendering
```

## ⚡ Performance Optimization

### 1. Build Optimization

#### APK Size Reduction
```bash
# Enable R8 obfuscation
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Tree shake icons
flutter build apk --release --tree-shake-icons

# Split by ABI
flutter build apk --split-per-abi --release
```

#### Startup Performance
```dart
// Optimize app startup
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Preload critical data
  await DatabaseService.initialize();
  await NotificationService.initialize();
  
  runApp(MyApp());
}
```

### 2. Runtime Optimization

#### Widget Performance
```dart
// Use const constructors
const ReadingItemCard(item: item);

// Implement efficient list building
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ReadingItemCard(
    item: items[index],
  ),
);

// Use RepaintBoundary for expensive widgets
RepaintBoundary(
  child: ExpensiveWidget(),
);
```

#### State Management Optimization
```dart
// Use selective rebuilds with Riverpod
final specificItemProvider = Provider.family<ReadingItem, String>((ref, id) {
  return ref.watch(readingItemsProvider).firstWhere((item) => item.id == id);
});
```

#### Image Optimization
```dart
// Optimize image loading
CachedNetworkImage(
  imageUrl: item.coverImageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  memCacheWidth: 300, // Limit memory usage
  memCacheHeight: 400,
);
```

### 3. Database Optimization

#### Query Optimization
```dart
// Use indexed queries
await database.query(
  'reading_items',
  where: 'status = ? AND type = ?', // Use indexed columns
  whereArgs: [status, type],
  orderBy: 'last_updated DESC',
  limit: 50,
);

// Batch operations
await database.transaction((txn) async {
  for (final item in items) {
    await txn.insert('reading_items', item.toMap());
  }
});
```

#### Caching Strategy
```dart
// Implement intelligent caching
class CacheService {
  static final _cache = <String, dynamic>{};
  static const _maxCacheSize = 100;
  
  static T? get<T>(String key) => _cache[key] as T?;
  
  static void set<T>(String key, T value) {
    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }
}
```

## 🚀 Deployment

### 1. GitHub Releases

#### Automatic Releases
1. **Create Tag**
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

2. **GitHub Actions**
   - Automatically builds all APK variants
   - Creates GitHub release
   - Uploads APK files as assets
   - Generates release notes

#### Manual Releases
1. Go to GitHub repository
2. Click "Releases" tab
3. Click "Create a new release"
4. Choose tag or create new one
5. Fill release information
6. Upload APK files manually
7. Publish release

### 2. Play Store Deployment

#### Prepare for Play Store
```bash
# Build app bundle
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info

# Sign the bundle (if not using GitHub Actions)
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 -keystore omnireader-key.jks build/app/outputs/bundle/release/app-release.aab omnireader
```

#### Play Store Console
1. Create developer account
2. Create new application
3. Upload app bundle
4. Fill store listing information
5. Set up pricing and distribution
6. Submit for review

### 3. Alternative Distribution

#### F-Droid
1. Fork F-Droid metadata repository
2. Add app metadata
3. Submit pull request
4. Wait for inclusion

#### Direct Distribution
1. Host APK files on your server
2. Create download page
3. Implement update checking
4. Handle installation instructions

## 🔧 Troubleshooting

### 1. Common Issues

#### Flutter Doctor Issues
```bash
# Android license issues
flutter doctor --android-licenses

# SDK path issues
flutter config --android-sdk /path/to/android/sdk

# Clear Flutter cache
flutter clean
flutter pub get
```

#### Build Issues
```bash
# Clear build cache
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get

# Reset Flutter
flutter channel stable
flutter upgrade
flutter doctor
```

#### VS Code Issues
```bash
# Restart Dart Analysis Server
Ctrl+Shift+P > "Dart: Restart Analysis Server"

# Clear VS Code cache
# Close VS Code
# Delete .vscode folder
# Reopen and reconfigure
```

### 2. Performance Issues

#### Slow Build Times
```bash
# Enable Gradle daemon
echo "org.gradle.daemon=true" >> android/gradle.properties

# Increase Gradle memory
echo "org.gradle.jvmargs=-Xmx4g -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8" >> android/gradle.properties

# Use parallel builds
echo "org.gradle.parallel=true" >> android/gradle.properties
```

#### Runtime Performance
```dart
// Profile widget rebuilds
import 'package:flutter/foundation.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('MyWidget rebuilt');
    }
    return Container();
  }
}
```

### 3. Debugging Tools

#### Flutter Inspector
- Access via VS Code or browser
- Inspect widget tree
- Analyze layout issues
- Monitor performance

#### Dart DevTools
```bash
# Launch DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

#### Logging
```dart
// Structured logging
import 'dart:developer' as developer;

void logInfo(String message, {Map<String, dynamic>? data}) {
  developer.log(
    message,
    name: 'OmniReader',
    level: 800,
    error: data,
  );
}
```

### 4. Getting Help

#### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Android Documentation](https://developer.android.com/docs)

#### Community
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Reddit r/FlutterDev](https://reddit.com/r/FlutterDev)

#### Project Support
- [GitHub Issues](https://github.com/omnireader/omnireader/issues)
- [GitHub Discussions](https://github.com/omnireader/omnireader/discussions)
- [Discord Server](https://discord.gg/omnireader)

---

## 📝 Final Notes

This development guide provides a comprehensive overview of developing OmniReader using VS Code and GitHub. The setup is optimized for:

- **Productivity**: Streamlined development workflow
- **Quality**: Automated testing and code quality checks
- **Collaboration**: Git-based workflow with code review
- **Deployment**: Automated APK building and distribution

Remember to:
- Keep dependencies updated
- Follow coding standards
- Write comprehensive tests
- Document your changes
- Engage with the community

Happy coding! 🚀📱

