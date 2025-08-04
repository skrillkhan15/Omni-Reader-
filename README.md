# OmniReader 📚

[![Build Status](https://github.com/omnireader/omnireader/workflows/Build%20and%20Release%20APK/badge.svg)](https://github.com/omnireader/omnireader/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.16.0-blue.svg)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android-green.svg)](https://developer.android.com/)

**The Ultimate Manga, Manhwa, and Manhua Reading Tracker**

OmniReader is a comprehensive, feature-rich Flutter application designed for manga, manhwa, and manhua enthusiasts. Track your reading progress, discover new series, manage your collection, and never miss an update with intelligent notifications and AI-powered recommendations.

## ✨ Features

### 📖 **Reading Management**
- **Complete CRUD Operations**: Add, edit, delete, and organize your reading collection
- **Progress Tracking**: Track current chapter, total chapters, and reading progress
- **Status Management**: Reading, Completed, On Hold, Dropped, Plan to Read
- **Rating System**: 10-point rating system with visual indicators
- **Favorites**: Mark and filter your favorite series
- **Reading History**: Track when you last read each series

### 🎨 **Modern UI/UX**
- **Material Design 3**: Beautiful, modern interface following Google's latest design guidelines
- **Dark/Light Themes**: Automatic theme switching based on system preferences
- **Responsive Design**: Optimized for all Android screen sizes and orientations
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Customizable Views**: Grid, list, and card view modes
- **Accessibility**: Full support for screen readers and accessibility features

### 🔍 **Advanced Search & Discovery**
- **Powerful Search**: Search by title, author, genre, or custom tags
- **Smart Filters**: Filter by type, status, rating, genre, and more
- **API Integration**: Search and import from MyAnimeList, AniList, and MangaDex
- **AI Recommendations**: Get personalized recommendations based on your reading history
- **Trending & Popular**: Discover what's trending in the community

### 📊 **Statistics & Analytics**
- **Reading Statistics**: Detailed analytics of your reading habits
- **Progress Visualization**: Charts and graphs showing your reading progress
- **Time Tracking**: See how much time you spend reading
- **Achievement System**: Unlock achievements for reading milestones
- **Export Data**: Export your statistics and collection data

### 🔔 **Smart Notifications**
- **Reading Reminders**: Customizable reminders to continue reading
- **Update Notifications**: Get notified when new chapters are available
- **Milestone Alerts**: Celebrate when you complete series or reach goals
- **Flexible Scheduling**: Set notification times that work for you

### 🌐 **API Integration & Sync**
- **Multiple Sources**: MyAnimeList, AniList, Jikan, MangaDex integration
- **Auto-Import**: Import your existing lists from popular platforms
- **Sync Capabilities**: Keep your data synchronized across platforms
- **AI Features**: OpenAI integration for descriptions and recommendations
- **Offline Mode**: Full functionality without internet connection

### 💾 **Data Management**
- **Local Storage**: All data stored locally using SQLite and Hive
- **Backup & Restore**: Create and restore backups of your collection
- **Import/Export**: Support for JSON, CSV, and custom formats
- **Cloud Sync**: Optional cloud synchronization (future feature)
- **Data Privacy**: Your data stays on your device

### 🎯 **Advanced Features**
- **Deep Linking**: Open specific manga from external links
- **Share Functionality**: Share your favorite series with friends
- **Custom Tags**: Create and manage custom tags for organization
- **Bulk Operations**: Edit multiple items at once
- **Advanced Sorting**: Sort by any field with custom criteria
- **Reading Goals**: Set and track reading goals

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.16.0 or higher
- **Dart SDK**: 3.2.0 or higher
- **Android Studio**: Latest version with Android SDK
- **VS Code**: Recommended for development
- **Git**: For version control

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/omnireader/omnireader.git
   cd omnireader
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building APK

#### Using VS Code (Recommended)

1. Open the project in VS Code
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
3. Type "Tasks: Run Task"
4. Select one of the build tasks:
   - `OmniReader: Quick Check` - Run tests and analysis
   - `OmniReader: Full Build Pipeline` - Complete build process
   - `OmniReader: Release Build` - Build production APK

#### Using Command Line

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APK per ABI (recommended for distribution)
flutter build apk --split-per-abi --release

# Android App Bundle (for Play Store)
flutter build appbundle --release
```

#### Using GitHub Actions

1. Fork the repository
2. Push your changes to the `main` branch
3. GitHub Actions will automatically build and release APK files
4. Download the APK from the Actions tab or Releases page

## 🛠️ Development

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── reading_item.dart
│   └── app_settings.dart
├── services/                 # Business logic services
│   ├── database_service.dart
│   ├── notification_service.dart
│   ├── image_service.dart
│   └── api_service.dart
├── repositories/             # Data access layer
│   └── reading_item_repository.dart
├── providers/                # State management
│   └── app_providers.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── library_screen.dart
│   ├── search_screen.dart
│   ├── add_item_screen.dart
│   ├── item_detail_screen.dart
│   ├── statistics_screen.dart
│   └── settings_screen.dart
├── widgets/                  # Reusable UI components
│   ├── reading_item_card.dart
│   ├── statistics_card.dart
│   └── quick_action_button.dart
└── utils/                    # Utilities and helpers
    ├── app_theme.dart
    ├── app_router.dart
    └── constants.dart
```

### State Management

OmniReader uses **Riverpod** for state management, providing:
- Type-safe state management
- Automatic dependency injection
- Easy testing and mocking
- Excellent performance

### Database

The app uses a hybrid approach for data storage:
- **SQLite**: For complex relational data and queries
- **Hive**: For simple key-value storage and caching
- **Shared Preferences**: For app settings and preferences

### API Integration

Supported APIs:
- **MyAnimeList API**: Official MAL API for manga data
- **AniList API**: GraphQL API for anime/manga information
- **Jikan API**: Unofficial MAL API (no authentication required)
- **MangaDex API**: Open-source manga database
- **OpenAI API**: For AI-powered features and recommendations

### Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Generate coverage report
# genhtml coverage/lcov.info -o coverage/html
```

### Code Quality

The project includes comprehensive code quality tools:
- **Flutter Analyze**: Static code analysis
- **Dart Format**: Code formatting
- **Import Sorter**: Organize imports
- **Custom Lints**: Project-specific linting rules

## 📱 Screenshots

| Home Screen | Library View | Search & Discovery |
|-------------|--------------|-------------------|
| ![Home](screenshots/home.png) | ![Library](screenshots/library.png) | ![Search](screenshots/search.png) |

| Statistics | Settings | Dark Theme |
|------------|----------|------------|
| ![Stats](screenshots/stats.png) | ![Settings](screenshots/settings.png) | ![Dark](screenshots/dark.png) |

## 🔧 Configuration

### API Keys

To enable full functionality, configure API keys in the app settings:

1. **MyAnimeList API**:
   - Create an account at [MyAnimeList](https://myanimelist.net/)
   - Register for API access
   - Add your API key in Settings > API Integration

2. **OpenAI API** (for AI features):
   - Get an API key from [OpenAI](https://platform.openai.com/)
   - Add your API key in Settings > AI Features

3. **AniList** (optional):
   - Create an account at [AniList](https://anilist.co/)
   - Register for API access
   - Add your credentials in Settings > API Integration

### Notifications

Configure notifications in Settings > Notifications:
- **Reading Reminders**: Set daily/weekly reminders
- **Update Notifications**: Get notified about new chapters
- **Milestone Alerts**: Celebrate achievements
- **Custom Schedules**: Set specific times for notifications

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Run tests: `flutter test`
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing framework
- **Material Design**: For the beautiful design system
- **MyAnimeList**: For the comprehensive manga database
- **AniList**: For the excellent GraphQL API
- **MangaDex**: For the open-source manga platform
- **Community**: For feedback and contributions

## 📞 Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/omnireader/omnireader/issues)
- **Discussions**: [Join the community discussion](https://github.com/omnireader/omnireader/discussions)
- **Email**: support@omnireader.app
- **Discord**: [Join our Discord server](https://discord.gg/omnireader)

## 🗺️ Roadmap

### Version 1.1.0
- [ ] Cloud synchronization
- [ ] Social features (friends, sharing)
- [ ] Advanced statistics and insights
- [ ] Custom themes and personalization

### Version 1.2.0
- [ ] Web version
- [ ] iOS support
- [ ] Offline reading mode
- [ ] Enhanced AI recommendations

### Version 2.0.0
- [ ] Community features
- [ ] Reading groups and clubs
- [ ] Advanced discovery algorithms
- [ ] Integration with reading platforms

## 📊 Stats

![GitHub stars](https://img.shields.io/github/stars/omnireader/omnireader?style=social)
![GitHub forks](https://img.shields.io/github/forks/omnireader/omnireader?style=social)
![GitHub issues](https://img.shields.io/github/issues/omnireader/omnireader)
![GitHub pull requests](https://img.shields.io/github/issues-pr/omnireader/omnireader)

---

**Made with ❤️ by the OmniReader Team**

*Happy Reading! 📚✨*