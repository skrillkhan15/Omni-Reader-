class AppConstants {
  // App Information
  static const String appName = 'OmniReader';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'The ultimate manga, manhwa, and manhua reading tracker';
  
  // Database
  static const String databaseName = 'omnireader.db';
  static const int databaseVersion = 1;
  
  // Hive Boxes
  static const String readingItemsBox = 'reading_items';
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  
  // Shared Preferences Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyColorScheme = 'color_scheme';
  static const String keyViewMode = 'view_mode';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyReminderTime = 'reminder_time';
  static const String keyAutoBackup = 'auto_backup';
  static const String keyLastBackup = 'last_backup';
  
  // API Keys
  static const String keyMalApiKey = 'mal_api_key';
  static const String keyAnilistApiKey = 'anilist_api_key';
  static const String keyOpenaiApiKey = 'openai_api_key';
  
  // Notification Channels
  static const String notificationChannelId = 'omnireader_notifications';
  static const String notificationChannelName = 'OmniReader Notifications';
  static const String notificationChannelDescription = 'Reading reminders and updates';
  
  // File Paths
  static const String backupDirectory = 'OmniReader/Backups';
  static const String imagesDirectory = 'OmniReader/Images';
  static const String cacheDirectory = 'OmniReader/Cache';
  
  // Network
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // Grid and List
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 0.7;
  static const double gridSpacing = 12.0;
  static const int maxSearchResults = 50;
  static const int itemsPerPage = 20;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Image Sizes
  static const double coverImageWidth = 120;
  static const double coverImageHeight = 160;
  static const double thumbnailSize = 50;
  static const double iconSize = 24;
  static const double smallIconSize = 16;
  static const double largeIconSize = 32;
  
  // Text Limits
  static const int maxTitleLength = 200;
  static const int maxAuthorLength = 100;
  static const int maxDescriptionLength = 2000;
  static const int maxTagLength = 50;
  static const int maxTagsCount = 20;
  static const int maxGenresCount = 10;
  
  // Rating
  static const double minRating = 0.0;
  static const double maxRating = 10.0;
  static const double defaultRating = 0.0;
  
  // Progress
  static const int minChapter = 0;
  static const int maxChapter = 99999;
  static const int defaultCurrentChapter = 0;
  
  // Cache
  static const int maxCacheSize = 100; // MB
  static const Duration cacheExpiry = Duration(days: 7);
  static const int maxCachedImages = 500;
  
  // Backup
  static const String backupFileExtension = '.omnireader';
  static const String exportFileExtension = '.json';
  static const Duration autoBackupInterval = Duration(days: 7);
  
  // URLs
  static const String supportUrl = 'https://github.com/omnireader/support';
  static const String privacyPolicyUrl = 'https://omnireader.app/privacy';
  static const String termsOfServiceUrl = 'https://omnireader.app/terms';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.omnireader.app';
  static const String githubUrl = 'https://github.com/omnireader/omnireader';
  
  // Error Messages
  static const String errorGeneric = 'An unexpected error occurred';
  static const String errorNetwork = 'Network connection error';
  static const String errorDatabase = 'Database error occurred';
  static const String errorPermission = 'Permission denied';
  static const String errorFileNotFound = 'File not found';
  static const String errorInvalidData = 'Invalid data format';
  static const String errorApiKey = 'API key not configured';
  static const String errorApiLimit = 'API rate limit exceeded';
  
  // Success Messages
  static const String successItemAdded = 'Item added successfully';
  static const String successItemUpdated = 'Item updated successfully';
  static const String successItemDeleted = 'Item deleted successfully';
  static const String successBackupCreated = 'Backup created successfully';
  static const String successDataImported = 'Data imported successfully';
  static const String successSettingsSaved = 'Settings saved successfully';
  
  // Default Values
  static const String defaultLanguage = 'English';
  static const String defaultPublisher = 'Unknown';
  static const String defaultAuthor = 'Unknown';
  static const List<String> defaultGenres = [];
  static const List<String> defaultTags = [];
  
  // Validation
  static const int minTitleLength = 1;
  static const int minPasswordLength = 8;
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String urlPattern = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
  
  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableBetaFeatures = false;
  static const bool enableOfflineMode = true;
  static const bool enableCloudSync = false;
  
  // Permissions
  static const List<String> requiredPermissions = [
    'android.permission.INTERNET',
    'android.permission.ACCESS_NETWORK_STATE',
    'android.permission.WRITE_EXTERNAL_STORAGE',
    'android.permission.READ_EXTERNAL_STORAGE',
    'android.permission.CAMERA',
    'android.permission.VIBRATE',
    'android.permission.WAKE_LOCK',
    'android.permission.RECEIVE_BOOT_COMPLETED',
  ];
  
  // Notification IDs
  static const int reminderNotificationId = 1001;
  static const int updateNotificationId = 1002;
  static const int backupNotificationId = 1003;
  static const int syncNotificationId = 1004;
  
  // Intent Actions
  static const String actionOpenItem = 'com.omnireader.OPEN_ITEM';
  static const String actionAddItem = 'com.omnireader.ADD_ITEM';
  static const String actionSearch = 'com.omnireader.SEARCH';
  
  // Deep Link Patterns
  static const String deepLinkScheme = 'omnireader';
  static const String deepLinkHost = 'app';
  static const String deepLinkItem = '/item';
  static const String deepLinkSearch = '/search';
  static const String deepLinkAdd = '/add';
  
  // Statistics
  static const int statisticsRetentionDays = 365;
  static const int maxRecentItems = 10;
  static const int maxRecommendations = 20;
  
  // Search
  static const int minSearchLength = 2;
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);
  static const int maxSearchHistory = 50;
  
  // Sync
  static const Duration syncInterval = Duration(hours: 6);
  static const int maxSyncRetries = 3;
  static const Duration syncTimeout = Duration(minutes: 5);
  
  // Performance
  static const int maxConcurrentRequests = 5;
  static const int imageLoadTimeout = 10; // seconds
  static const int maxImageCacheSize = 50; // MB
  
  // Accessibility
  static const double minTouchTargetSize = 48.0;
  static const Duration tooltipDelay = Duration(milliseconds: 500);
  
  // Localization
  static const List<String> supportedLanguages = [
    'en', // English
    'ja', // Japanese
    'ko', // Korean
    'zh', // Chinese
    'es', // Spanish
    'fr', // French
    'de', // German
    'pt', // Portuguese
    'ru', // Russian
    'ar', // Arabic
  ];
  
  // Theme
  static const List<String> availableThemes = [
    'system',
    'light',
    'dark',
    'amoled',
  ];
  
  // Export Formats
  static const List<String> exportFormats = [
    'json',
    'csv',
    'xml',
    'pdf',
  ];
  
  // Import Sources
  static const List<String> importSources = [
    'myanimelist',
    'anilist',
    'kitsu',
    'mangadex',
    'local_file',
  ];
}

class AppStrings {
  // Navigation
  static const String navHome = 'Home';
  static const String navLibrary = 'Library';
  static const String navSearch = 'Search';
  static const String navStatistics = 'Statistics';
  static const String navSettings = 'Settings';
  
  // Actions
  static const String actionAdd = 'Add';
  static const String actionEdit = 'Edit';
  static const String actionDelete = 'Delete';
  static const String actionSave = 'Save';
  static const String actionCancel = 'Cancel';
  static const String actionConfirm = 'Confirm';
  static const String actionRetry = 'Retry';
  static const String actionShare = 'Share';
  static const String actionExport = 'Export';
  static const String actionImport = 'Import';
  static const String actionBackup = 'Backup';
  static const String actionRestore = 'Restore';
  static const String actionSync = 'Sync';
  static const String actionRead = 'Read';
  static const String actionUpdate = 'Update';
  static const String actionClear = 'Clear';
  static const String actionReset = 'Reset';
  
  // Status
  static const String statusReading = 'Reading';
  static const String statusCompleted = 'Completed';
  static const String statusOnHold = 'On Hold';
  static const String statusDropped = 'Dropped';
  static const String statusPlanToRead = 'Plan to Read';
  
  // Types
  static const String typeManga = 'Manga';
  static const String typeManhwa = 'Manhwa';
  static const String typeManhua = 'Manhua';
  static const String typeNovel = 'Novel';
  static const String typeWebtoon = 'Webtoon';
  static const String typeLightNovel = 'Light Novel';
  
  // Common
  static const String loading = 'Loading...';
  static const String noData = 'No data available';
  static const String noResults = 'No results found';
  static const String searchHint = 'Search manga, manhwa, manhua...';
  static const String optional = 'Optional';
  static const String required = 'Required';
  static const String unknown = 'Unknown';
  static const String none = 'None';
  static const String all = 'All';
  static const String favorites = 'Favorites';
  static const String recent = 'Recent';
  static const String popular = 'Popular';
  static const String trending = 'Trending';
  static const String recommended = 'Recommended';
  
  // Time
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String thisWeek = 'This Week';
  static const String thisMonth = 'This Month';
  static const String thisYear = 'This Year';
  static const String justNow = 'Just now';
  static const String minutesAgo = 'minutes ago';
  static const String hoursAgo = 'hours ago';
  static const String daysAgo = 'days ago';
  static const String weeksAgo = 'weeks ago';
  static const String monthsAgo = 'months ago';
  static const String yearsAgo = 'years ago';
}

class AppAssets {
  // Images
  static const String logoPath = 'assets/images/logo.png';
  static const String splashPath = 'assets/images/splash.png';
  static const String placeholderPath = 'assets/images/placeholder.png';
  static const String emptyStatePath = 'assets/images/empty_state.png';
  static const String errorStatePath = 'assets/images/error_state.png';
  
  // Icons
  static const String mangaIconPath = 'assets/icons/manga.png';
  static const String manhwaIconPath = 'assets/icons/manhwa.png';
  static const String manhuaIconPath = 'assets/icons/manhua.png';
  static const String novelIconPath = 'assets/icons/novel.png';
  static const String webtoonIconPath = 'assets/icons/webtoon.png';
  static const String lightNovelIconPath = 'assets/icons/light_novel.png';
  
  // Animations
  static const String loadingAnimationPath = 'assets/animations/loading.json';
  static const String successAnimationPath = 'assets/animations/success.json';
  static const String errorAnimationPath = 'assets/animations/error.json';
  static const String emptyAnimationPath = 'assets/animations/empty.json';
  
  // Fonts
  static const String primaryFontFamily = 'Roboto';
  static const String secondaryFontFamily = 'Noto Sans';
  static const String monospaceFontFamily = 'Roboto Mono';
  
  // Audio
  static const String notificationSoundPath = 'assets/audio/notification.mp3';
  static const String successSoundPath = 'assets/audio/success.mp3';
  static const String errorSoundPath = 'assets/audio/error.mp3';
}

class AppColors {
  // Primary Colors
  static const int primaryBlue = 0xFF2196F3;
  static const int primaryGreen = 0xFF4CAF50;
  static const int primaryPurple = 0xFF9C27B0;
  static const int primaryOrange = 0xFFFF9800;
  static const int primaryRed = 0xFFF44336;
  static const int primaryPink = 0xFFE91E63;
  
  // Type Colors
  static const int mangaColor = 0xFF2196F3;
  static const int manhwaColor = 0xFFE91E63;
  static const int manhuaColor = 0xFFFF9800;
  static const int novelColor = 0xFF4CAF50;
  static const int webtoonColor = 0xFF9C27B0;
  static const int lightNovelColor = 0xFF009688;
  
  // Status Colors
  static const int readingColor = 0xFF2196F3;
  static const int completedColor = 0xFF4CAF50;
  static const int onHoldColor = 0xFFFF9800;
  static const int droppedColor = 0xFFF44336;
  static const int planToReadColor = 0xFF9E9E9E;
  
  // Semantic Colors
  static const int successColor = 0xFF4CAF50;
  static const int warningColor = 0xFFFF9800;
  static const int errorColor = 0xFFF44336;
  static const int infoColor = 0xFF2196F3;
  
  // Neutral Colors
  static const int blackColor = 0xFF000000;
  static const int whiteColor = 0xFFFFFFFF;
  static const int greyColor = 0xFF9E9E9E;
  static const int lightGreyColor = 0xFFE0E0E0;
  static const int darkGreyColor = 0xFF424242;
}

class AppDimensions {
  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;
  
  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 50.0;
  
  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;
  
  // Icon Sizes
  static const double iconXS = 12.0;
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;
  
  // Button Heights
  static const double buttonHeightS = 32.0;
  static const double buttonHeightM = 40.0;
  static const double buttonHeightL = 48.0;
  static const double buttonHeightXL = 56.0;
  
  // App Bar
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 4.0;
  
  // Bottom Navigation
  static const double bottomNavHeight = 60.0;
  static const double bottomNavElevation = 8.0;
  
  // Cards
  static const double cardElevation = 2.0;
  static const double cardRadius = 12.0;
  static const double cardPadding = 16.0;
  
  // List Items
  static const double listItemHeight = 72.0;
  static const double listItemPadding = 16.0;
  
  // Grid Items
  static const double gridItemAspectRatio = 0.7;
  static const double gridSpacing = 12.0;
  
  // Images
  static const double coverImageWidth = 120.0;
  static const double coverImageHeight = 160.0;
  static const double thumbnailSize = 50.0;
  static const double avatarSize = 40.0;
  
  // Progress Indicators
  static const double progressHeight = 4.0;
  static const double progressRadius = 2.0;
  
  // Dividers
  static const double dividerHeight = 1.0;
  static const double dividerIndent = 16.0;
}

