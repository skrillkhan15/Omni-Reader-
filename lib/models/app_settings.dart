import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'reading_item.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 10)
@JsonSerializable()
class AppSettings extends Equatable {
  @HiveField(0)
  final ThemeMode themeMode;

  @HiveField(1)
  final String primaryColor;

  @HiveField(2)
  final String accentColor;

  @HiveField(3)
  final bool useDynamicColors;

  @HiveField(4)
  final String fontFamily;

  @HiveField(5)
  final double fontSize;

  @HiveField(6)
  final bool enableAnimations;

  @HiveField(7)
  final bool enableHapticFeedback;

  @HiveField(8)
  final bool enableSounds;

  @HiveField(9)
  final ViewMode defaultViewMode;

  @HiveField(10)
  final SortOption defaultSortOption;

  @HiveField(11)
  final SortOption defaultSortOrder;

  @HiveField(12)
  final bool showProgressBars;

  @HiveField(13)
  final bool showRatings;

  @HiveField(14)
  final bool showGenres;

  @HiveField(15)
  final bool enableBiometricAuth;

  @HiveField(16)
  final bool autoBackup;

  @HiveField(17)
  final BackupFrequency backupFrequency;

  @HiveField(18)
  final String? backupLocation;

  @HiveField(19)
  final bool enableNotifications;

  @HiveField(20)
  final NotificationSettings globalNotificationSettings;

  @HiveField(21)
  final bool enableAnalytics;

  @HiveField(22)
  final bool enableCrashReporting;

  @HiveField(23)
  final Map<String, ApiConfiguration> apiConfigurations;

  @HiveField(24)
  final bool enableAIFeatures;

  @HiveField(25)
  final String? openAIApiKey;

  @HiveField(26)
  final String? geminiApiKey;

  @HiveField(27)
  final bool enableSmartRecommendations;

  @HiveField(28)
  final bool enableAutoGenreTags;

  @HiveField(29)
  final bool enableReadingTimeTracking;

  @HiveField(30)
  final bool enableReadingGoals;

  @HiveField(31)
  final int dailyReadingGoalMinutes;

  @HiveField(32)
  final int weeklyReadingGoalChapters;

  @HiveField(33)
  final bool enableSyncAcrossDevices;

  @HiveField(34)
  final String? cloudSyncProvider;

  @HiveField(35)
  final Map<String, dynamic> customSettings;

  // Additional properties that were missing
  @HiveField(36)
  final AppColorScheme colorScheme;

  @HiveField(37)
  final bool showGridLines;

  @HiveField(38)
  final bool autoMarkAsReading;

  @HiveField(39)
  final bool autoComplete;

  @HiveField(40)
  final bool dailyReminders;

  @HiveField(41)
  final CustomTimeOfDay reminderTime;

  @HiveField(42)
  final bool updateNotifications;

  @HiveField(43)
  final bool enableSync;

  @HiveField(44)
  final String? malApiKey;

  @HiveField(45)
  final String? anilistApiKey;

  @HiveField(46)
  final String? openaiApiKey;

  @HiveField(47)
  final bool autoSyncApis;

  @HiveField(48)
  final bool debugMode;

  @HiveField(49)
  final int cacheSize;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.primaryColor = '#6366F1',
    this.accentColor = '#EC4899',
    this.useDynamicColors = true,
    this.fontFamily = 'Poppins',
    this.fontSize = 14.0,
    this.enableAnimations = true,
    this.enableHapticFeedback = true,
    this.enableSounds = true,
    this.defaultViewMode = ViewMode.grid,
    this.defaultSortOption = SortOption.lastUpdated,
    this.defaultSortOrder = SortOption.title,
    this.showProgressBars = true,
    this.showRatings = true,
    this.showGenres = true,
    this.enableBiometricAuth = false,
    this.autoBackup = true,
    this.backupFrequency = BackupFrequency.weekly,
    this.backupLocation,
    this.enableNotifications = true,
    required this.globalNotificationSettings,
    this.enableAnalytics = false,
    this.enableCrashReporting = true,
    this.apiConfigurations = const {},
    this.enableAIFeatures = false,
    this.openAIApiKey,
    this.geminiApiKey,
    this.enableSmartRecommendations = false,
    this.enableAutoGenreTags = false,
    this.enableReadingTimeTracking = true,
    this.enableReadingGoals = false,
    this.dailyReadingGoalMinutes = 30,
    this.weeklyReadingGoalChapters = 7,
    this.enableSyncAcrossDevices = false,
    this.cloudSyncProvider,
    this.customSettings = const {},
    this.colorScheme = AppColorScheme.blue,
    this.showGridLines = true,
    this.autoMarkAsReading = false,
    this.autoComplete = true,
    this.dailyReminders = false,
    this.reminderTime = const CustomTimeOfDay(hour: 9, minute: 0),
    this.updateNotifications = true,
    this.enableSync = false,
    this.malApiKey,
    this.anilistApiKey,
    this.openaiApiKey,
    this.autoSyncApis = false,
    this.debugMode = false,
    this.cacheSize = 100,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? primaryColor,
    String? accentColor,
    bool? useDynamicColors,
    String? fontFamily,
    double? fontSize,
    bool? enableAnimations,
    bool? enableHapticFeedback,
    bool? enableSounds,
    ViewMode? defaultViewMode,
    SortOption? defaultSortOption,
    SortOption? defaultSortOrder,
    bool? showProgressBars,
    bool? showRatings,
    bool? showGenres,
    bool? enableBiometricAuth,
    bool? autoBackup,
    BackupFrequency? backupFrequency,
    String? backupLocation,
    bool? enableNotifications,
    NotificationSettings? globalNotificationSettings,
    bool? enableAnalytics,
    bool? enableCrashReporting,
    Map<String, ApiConfiguration>? apiConfigurations,
    bool? enableAIFeatures,
    String? openAIApiKey,
    String? geminiApiKey,
    bool? enableSmartRecommendations,
    bool? enableAutoGenreTags,
    bool? enableReadingTimeTracking,
    bool? enableReadingGoals,
    int? dailyReadingGoalMinutes,
    int? weeklyReadingGoalChapters,
    bool? enableSyncAcrossDevices,
    String? cloudSyncProvider,
    Map<String, dynamic>? customSettings,
    AppColorScheme? colorScheme,
    bool? showGridLines,
    bool? autoMarkAsReading,
    bool? autoComplete,
    bool? dailyReminders,
    CustomTimeOfDay? reminderTime,
    bool? updateNotifications,
    bool? enableSync,
    String? malApiKey,
    String? anilistApiKey,
    String? openaiApiKey,
    bool? autoSyncApis,
    bool? debugMode,
    int? cacheSize,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      useDynamicColors: useDynamicColors ?? this.useDynamicColors,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableSounds: enableSounds ?? this.enableSounds,
      defaultViewMode: defaultViewMode ?? this.defaultViewMode,
      defaultSortOption: defaultSortOption ?? this.defaultSortOption,
      defaultSortOrder: defaultSortOrder ?? this.defaultSortOrder,
      showProgressBars: showProgressBars ?? this.showProgressBars,
      showRatings: showRatings ?? this.showRatings,
      showGenres: showGenres ?? this.showGenres,
      enableBiometricAuth: enableBiometricAuth ?? this.enableBiometricAuth,
      autoBackup: autoBackup ?? this.autoBackup,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      backupLocation: backupLocation ?? this.backupLocation,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      globalNotificationSettings: globalNotificationSettings ?? this.globalNotificationSettings,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      apiConfigurations: apiConfigurations ?? this.apiConfigurations,
      enableAIFeatures: enableAIFeatures ?? this.enableAIFeatures,
      openAIApiKey: openAIApiKey ?? this.openAIApiKey,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      enableSmartRecommendations: enableSmartRecommendations ?? this.enableSmartRecommendations,
      enableAutoGenreTags: enableAutoGenreTags ?? this.enableAutoGenreTags,
      enableReadingTimeTracking: enableReadingTimeTracking ?? this.enableReadingTimeTracking,
      enableReadingGoals: enableReadingGoals ?? this.enableReadingGoals,
      dailyReadingGoalMinutes: dailyReadingGoalMinutes ?? this.dailyReadingGoalMinutes,
      weeklyReadingGoalChapters: weeklyReadingGoalChapters ?? this.weeklyReadingGoalChapters,
      enableSyncAcrossDevices: enableSyncAcrossDevices ?? this.enableSyncAcrossDevices,
      cloudSyncProvider: cloudSyncProvider ?? this.cloudSyncProvider,
      customSettings: customSettings ?? this.customSettings,
      colorScheme: colorScheme ?? this.colorScheme,
      showGridLines: showGridLines ?? this.showGridLines,
      autoMarkAsReading: autoMarkAsReading ?? this.autoMarkAsReading,
      autoComplete: autoComplete ?? this.autoComplete,
      dailyReminders: dailyReminders ?? this.dailyReminders,
      reminderTime: reminderTime ?? this.reminderTime,
      updateNotifications: updateNotifications ?? this.updateNotifications,
      enableSync: enableSync ?? this.enableSync,
      malApiKey: malApiKey ?? this.malApiKey,
      anilistApiKey: anilistApiKey ?? this.anilistApiKey,
      openaiApiKey: openaiApiKey ?? this.openaiApiKey,
      autoSyncApis: autoSyncApis ?? this.autoSyncApis,
      debugMode: debugMode ?? this.debugMode,
      cacheSize: cacheSize ?? this.cacheSize,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        primaryColor,
        accentColor,
        useDynamicColors,
        fontFamily,
        fontSize,
        enableAnimations,
        enableHapticFeedback,
        enableSounds,
        defaultViewMode,
        defaultSortOption,
        defaultSortOrder,
        showProgressBars,
        showRatings,
        showGenres,
        enableBiometricAuth,
        autoBackup,
        backupFrequency,
        backupLocation,
        enableNotifications,
        globalNotificationSettings,
        enableAnalytics,
        enableCrashReporting,
        apiConfigurations,
        enableAIFeatures,
        openAIApiKey,
        geminiApiKey,
        enableSmartRecommendations,
        enableAutoGenreTags,
        enableReadingTimeTracking,
        enableReadingGoals,
        dailyReadingGoalMinutes,
        weeklyReadingGoalChapters,
        enableSyncAcrossDevices,
        cloudSyncProvider,
        customSettings,
        colorScheme,
        showGridLines,
        autoMarkAsReading,
        autoComplete,
        dailyReminders,
        reminderTime,
        updateNotifications,
        enableSync,
        malApiKey,
        anilistApiKey,
        openaiApiKey,
        autoSyncApis,
        debugMode,
        cacheSize,
      ];
}

@HiveType(typeId: 11)
enum BackupFrequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  manual,
}

@HiveType(typeId: 12)
@JsonSerializable()
class ApiConfiguration extends Equatable {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String baseUrl;

  @HiveField(2)
  final String? apiKey;

  @HiveField(3)
  final Map<String, String> headers;

  @HiveField(4)
  final bool enabled;

  @HiveField(5)
  final ApiType type;

  @HiveField(6)
  final Map<String, dynamic> settings;

  const ApiConfiguration({
    required this.name,
    required this.baseUrl,
    this.apiKey,
    this.headers = const {},
    this.enabled = false,
    required this.type,
    this.settings = const {},
  });

  factory ApiConfiguration.fromJson(Map<String, dynamic> json) =>
      _$ApiConfigurationFromJson(json);

  Map<String, dynamic> toJson() => _$ApiConfigurationToJson(this);

  @override
  List<Object?> get props => [
        name,
        baseUrl,
        apiKey,
        headers,
        enabled,
        type,
        settings,
      ];
}

@HiveType(typeId: 13)
enum ApiType {
  @HiveField(0)
  manga,
  @HiveField(1)
  anime,
  @HiveField(2)
  ai,
  @HiveField(3)
  recommendation,
  @HiveField(4)
  metadata,
  @HiveField(5)
  sync,
  @HiveField(6)
  backup,
}

@HiveType(typeId: 14)
@JsonSerializable()
class NotificationSettings extends Equatable {
  @HiveField(0)
  final bool enabled;

  @HiveField(1)
  final bool showOnLockScreen;

  @HiveField(2)
  final bool enableVibration;

  @HiveField(3)
  final bool enableSound;

  @HiveField(4)
  final String soundPath;

  @HiveField(5)
  final NotificationPriority priority;

  @HiveField(6)
  final bool enableLED;

  @HiveField(7)
  final String ledColor;

  @HiveField(8)
  final CustomTimeOfDay reminderTime;

  @HiveField(9)
  final NotificationFrequency frequency;

  @HiveField(10)
  final String? customMessage;

  @HiveField(11)
  final List<int> reminderDays;

  const NotificationSettings({
    this.enabled = true,
    this.showOnLockScreen = true,
    this.enableVibration = true,
    this.enableSound = true,
    this.soundPath = 'default',
    this.priority = NotificationPriority.high,
    this.enableLED = true,
    this.ledColor = '#6366F1',
    this.reminderTime = const CustomTimeOfDay(hour: 9, minute: 0),
    this.frequency = NotificationFrequency.daily,
    this.customMessage,
    this.reminderDays = const [1, 2, 3, 4, 5, 6, 7],
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSettingsToJson(this);

  @override
  List<Object?> get props => [
        enabled,
        showOnLockScreen,
        enableVibration,
        enableSound,
        soundPath,
        priority,
        enableLED,
        ledColor,
        reminderTime,
        frequency,
        customMessage,
        reminderDays,
      ];
}

@HiveType(typeId: 15)
enum NotificationPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  normal,
  @HiveField(2)
  high,
  @HiveField(3)
  max,
}

@HiveType(typeId: 16)
enum AppColorScheme {
  @HiveField(0)
  blue,
  @HiveField(1)
  green,
  @HiveField(2)
  purple,
  @HiveField(3)
  orange,
  @HiveField(4)
  red,
  @HiveField(5)
  pink,
}

// CustomTimeOfDay is imported from reading_item.dart
