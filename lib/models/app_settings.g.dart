// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 10;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      themeMode: fields[0] as ThemeMode,
      primaryColor: fields[1] as String,
      accentColor: fields[2] as String,
      useDynamicColors: fields[3] as bool,
      fontFamily: fields[4] as String,
      fontSize: fields[5] as double,
      enableAnimations: fields[6] as bool,
      enableHapticFeedback: fields[7] as bool,
      enableSounds: fields[8] as bool,
      defaultViewMode: fields[9] as ViewMode,
      defaultSortOption: fields[10] as SortOption,
      defaultSortOrder: fields[11] as SortOption,
      showProgressBars: fields[12] as bool,
      showRatings: fields[13] as bool,
      showGenres: fields[14] as bool,
      enableBiometricAuth: fields[15] as bool,
      autoBackup: fields[16] as bool,
      backupFrequency: fields[17] as BackupFrequency,
      backupLocation: fields[18] as String?,
      enableNotifications: fields[19] as bool,
      globalNotificationSettings: fields[20] as NotificationSettings,
      enableAnalytics: fields[21] as bool,
      enableCrashReporting: fields[22] as bool,
      apiConfigurations: (fields[23] as Map).cast<String, ApiConfiguration>(),
      enableAIFeatures: fields[24] as bool,
      openAIApiKey: fields[25] as String?,
      geminiApiKey: fields[26] as String?,
      enableSmartRecommendations: fields[27] as bool,
      enableAutoGenreTags: fields[28] as bool,
      enableReadingTimeTracking: fields[29] as bool,
      enableReadingGoals: fields[30] as bool,
      dailyReadingGoalMinutes: fields[31] as int,
      weeklyReadingGoalChapters: fields[32] as int,
      enableSyncAcrossDevices: fields[33] as bool,
      cloudSyncProvider: fields[34] as String?,
      customSettings: (fields[35] as Map).cast<String, dynamic>(),
      colorScheme: fields[36] as AppColorScheme,
      showGridLines: fields[37] as bool,
      autoMarkAsReading: fields[38] as bool,
      autoComplete: fields[39] as bool,
      dailyReminders: fields[40] as bool,
      reminderTime: fields[41] as CustomTimeOfDay,
      updateNotifications: fields[42] as bool,
      enableSync: fields[43] as bool,
      malApiKey: fields[44] as String?,
      anilistApiKey: fields[45] as String?,
      openaiApiKey: fields[46] as String?,
      autoSyncApis: fields[47] as bool,
      debugMode: fields[48] as bool,
      cacheSize: fields[49] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(50)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.primaryColor)
      ..writeByte(2)
      ..write(obj.accentColor)
      ..writeByte(3)
      ..write(obj.useDynamicColors)
      ..writeByte(4)
      ..write(obj.fontFamily)
      ..writeByte(5)
      ..write(obj.fontSize)
      ..writeByte(6)
      ..write(obj.enableAnimations)
      ..writeByte(7)
      ..write(obj.enableHapticFeedback)
      ..writeByte(8)
      ..write(obj.enableSounds)
      ..writeByte(9)
      ..write(obj.defaultViewMode)
      ..writeByte(10)
      ..write(obj.defaultSortOption)
      ..writeByte(11)
      ..write(obj.defaultSortOrder)
      ..writeByte(12)
      ..write(obj.showProgressBars)
      ..writeByte(13)
      ..write(obj.showRatings)
      ..writeByte(14)
      ..write(obj.showGenres)
      ..writeByte(15)
      ..write(obj.enableBiometricAuth)
      ..writeByte(16)
      ..write(obj.autoBackup)
      ..writeByte(17)
      ..write(obj.backupFrequency)
      ..writeByte(18)
      ..write(obj.backupLocation)
      ..writeByte(19)
      ..write(obj.enableNotifications)
      ..writeByte(20)
      ..write(obj.globalNotificationSettings)
      ..writeByte(21)
      ..write(obj.enableAnalytics)
      ..writeByte(22)
      ..write(obj.enableCrashReporting)
      ..writeByte(23)
      ..write(obj.apiConfigurations)
      ..writeByte(24)
      ..write(obj.enableAIFeatures)
      ..writeByte(25)
      ..write(obj.openAIApiKey)
      ..writeByte(26)
      ..write(obj.geminiApiKey)
      ..writeByte(27)
      ..write(obj.enableSmartRecommendations)
      ..writeByte(28)
      ..write(obj.enableAutoGenreTags)
      ..writeByte(29)
      ..write(obj.enableReadingTimeTracking)
      ..writeByte(30)
      ..write(obj.enableReadingGoals)
      ..writeByte(31)
      ..write(obj.dailyReadingGoalMinutes)
      ..writeByte(32)
      ..write(obj.weeklyReadingGoalChapters)
      ..writeByte(33)
      ..write(obj.enableSyncAcrossDevices)
      ..writeByte(34)
      ..write(obj.cloudSyncProvider)
      ..writeByte(35)
      ..write(obj.customSettings)
      ..writeByte(36)
      ..write(obj.colorScheme)
      ..writeByte(37)
      ..write(obj.showGridLines)
      ..writeByte(38)
      ..write(obj.autoMarkAsReading)
      ..writeByte(39)
      ..write(obj.autoComplete)
      ..writeByte(40)
      ..write(obj.dailyReminders)
      ..writeByte(41)
      ..write(obj.reminderTime)
      ..writeByte(42)
      ..write(obj.updateNotifications)
      ..writeByte(43)
      ..write(obj.enableSync)
      ..writeByte(44)
      ..write(obj.malApiKey)
      ..writeByte(45)
      ..write(obj.anilistApiKey)
      ..writeByte(46)
      ..write(obj.openaiApiKey)
      ..writeByte(47)
      ..write(obj.autoSyncApis)
      ..writeByte(48)
      ..write(obj.debugMode)
      ..writeByte(49)
      ..write(obj.cacheSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ApiConfigurationAdapter extends TypeAdapter<ApiConfiguration> {
  @override
  final int typeId = 12;

  @override
  ApiConfiguration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApiConfiguration(
      name: fields[0] as String,
      baseUrl: fields[1] as String,
      apiKey: fields[2] as String?,
      headers: (fields[3] as Map).cast<String, String>(),
      enabled: fields[4] as bool,
      type: fields[5] as ApiType,
      settings: (fields[6] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ApiConfiguration obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.baseUrl)
      ..writeByte(2)
      ..write(obj.apiKey)
      ..writeByte(3)
      ..write(obj.headers)
      ..writeByte(4)
      ..write(obj.enabled)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.settings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiConfigurationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationSettingsAdapter extends TypeAdapter<NotificationSettings> {
  @override
  final int typeId = 14;

  @override
  NotificationSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSettings(
      enabled: fields[0] as bool,
      showOnLockScreen: fields[1] as bool,
      enableVibration: fields[2] as bool,
      enableSound: fields[3] as bool,
      soundPath: fields[4] as String,
      priority: fields[5] as NotificationPriority,
      enableLED: fields[6] as bool,
      ledColor: fields[7] as String,
      reminderTime: fields[8] as CustomTimeOfDay,
      frequency: fields[9] as NotificationFrequency,
      customMessage: fields[10] as String?,
      reminderDays: (fields[11] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSettings obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.enabled)
      ..writeByte(1)
      ..write(obj.showOnLockScreen)
      ..writeByte(2)
      ..write(obj.enableVibration)
      ..writeByte(3)
      ..write(obj.enableSound)
      ..writeByte(4)
      ..write(obj.soundPath)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.enableLED)
      ..writeByte(7)
      ..write(obj.ledColor)
      ..writeByte(8)
      ..write(obj.reminderTime)
      ..writeByte(9)
      ..write(obj.frequency)
      ..writeByte(10)
      ..write(obj.customMessage)
      ..writeByte(11)
      ..write(obj.reminderDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BackupFrequencyAdapter extends TypeAdapter<BackupFrequency> {
  @override
  final int typeId = 11;

  @override
  BackupFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BackupFrequency.daily;
      case 1:
        return BackupFrequency.weekly;
      case 2:
        return BackupFrequency.monthly;
      case 3:
        return BackupFrequency.manual;
      default:
        return BackupFrequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, BackupFrequency obj) {
    switch (obj) {
      case BackupFrequency.daily:
        writer.writeByte(0);
        break;
      case BackupFrequency.weekly:
        writer.writeByte(1);
        break;
      case BackupFrequency.monthly:
        writer.writeByte(2);
        break;
      case BackupFrequency.manual:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ApiTypeAdapter extends TypeAdapter<ApiType> {
  @override
  final int typeId = 13;

  @override
  ApiType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ApiType.manga;
      case 1:
        return ApiType.anime;
      case 2:
        return ApiType.ai;
      case 3:
        return ApiType.recommendation;
      case 4:
        return ApiType.metadata;
      case 5:
        return ApiType.sync;
      case 6:
        return ApiType.backup;
      default:
        return ApiType.manga;
    }
  }

  @override
  void write(BinaryWriter writer, ApiType obj) {
    switch (obj) {
      case ApiType.manga:
        writer.writeByte(0);
        break;
      case ApiType.anime:
        writer.writeByte(1);
        break;
      case ApiType.ai:
        writer.writeByte(2);
        break;
      case ApiType.recommendation:
        writer.writeByte(3);
        break;
      case ApiType.metadata:
        writer.writeByte(4);
        break;
      case ApiType.sync:
        writer.writeByte(5);
        break;
      case ApiType.backup:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationPriorityAdapter extends TypeAdapter<NotificationPriority> {
  @override
  final int typeId = 15;

  @override
  NotificationPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationPriority.low;
      case 1:
        return NotificationPriority.normal;
      case 2:
        return NotificationPriority.high;
      case 3:
        return NotificationPriority.max;
      default:
        return NotificationPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationPriority obj) {
    switch (obj) {
      case NotificationPriority.low:
        writer.writeByte(0);
        break;
      case NotificationPriority.normal:
        writer.writeByte(1);
        break;
      case NotificationPriority.high:
        writer.writeByte(2);
        break;
      case NotificationPriority.max:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppColorSchemeAdapter extends TypeAdapter<AppColorScheme> {
  @override
  final int typeId = 16;

  @override
  AppColorScheme read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppColorScheme.blue;
      case 1:
        return AppColorScheme.green;
      case 2:
        return AppColorScheme.purple;
      case 3:
        return AppColorScheme.orange;
      case 4:
        return AppColorScheme.red;
      case 5:
        return AppColorScheme.pink;
      default:
        return AppColorScheme.blue;
    }
  }

  @override
  void write(BinaryWriter writer, AppColorScheme obj) {
    switch (obj) {
      case AppColorScheme.blue:
        writer.writeByte(0);
        break;
      case AppColorScheme.green:
        writer.writeByte(1);
        break;
      case AppColorScheme.purple:
        writer.writeByte(2);
        break;
      case AppColorScheme.orange:
        writer.writeByte(3);
        break;
      case AppColorScheme.red:
        writer.writeByte(4);
        break;
      case AppColorScheme.pink:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppColorSchemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
      themeMode: $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
          ThemeMode.system,
      primaryColor: json['primaryColor'] as String? ?? '#6366F1',
      accentColor: json['accentColor'] as String? ?? '#EC4899',
      useDynamicColors: json['useDynamicColors'] as bool? ?? true,
      fontFamily: json['fontFamily'] as String? ?? 'Poppins',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      enableAnimations: json['enableAnimations'] as bool? ?? true,
      enableHapticFeedback: json['enableHapticFeedback'] as bool? ?? true,
      enableSounds: json['enableSounds'] as bool? ?? true,
      defaultViewMode:
          $enumDecodeNullable(_$ViewModeEnumMap, json['defaultViewMode']) ??
              ViewMode.grid,
      defaultSortOption:
          $enumDecodeNullable(_$SortOptionEnumMap, json['defaultSortOption']) ??
              SortOption.lastUpdated,
      defaultSortOrder:
          $enumDecodeNullable(_$SortOptionEnumMap, json['defaultSortOrder']) ??
              SortOption.title,
      showProgressBars: json['showProgressBars'] as bool? ?? true,
      showRatings: json['showRatings'] as bool? ?? true,
      showGenres: json['showGenres'] as bool? ?? true,
      enableBiometricAuth: json['enableBiometricAuth'] as bool? ?? false,
      autoBackup: json['autoBackup'] as bool? ?? true,
      backupFrequency: $enumDecodeNullable(
              _$BackupFrequencyEnumMap, json['backupFrequency']) ??
          BackupFrequency.weekly,
      backupLocation: json['backupLocation'] as String?,
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      globalNotificationSettings: NotificationSettings.fromJson(
          json['globalNotificationSettings'] as Map<String, dynamic>),
      enableAnalytics: json['enableAnalytics'] as bool? ?? false,
      enableCrashReporting: json['enableCrashReporting'] as bool? ?? true,
      apiConfigurations:
          (json['apiConfigurations'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k, ApiConfiguration.fromJson(e as Map<String, dynamic>)),
              ) ??
              const {},
      enableAIFeatures: json['enableAIFeatures'] as bool? ?? false,
      openAIApiKey: json['openAIApiKey'] as String?,
      geminiApiKey: json['geminiApiKey'] as String?,
      enableSmartRecommendations:
          json['enableSmartRecommendations'] as bool? ?? false,
      enableAutoGenreTags: json['enableAutoGenreTags'] as bool? ?? false,
      enableReadingTimeTracking:
          json['enableReadingTimeTracking'] as bool? ?? true,
      enableReadingGoals: json['enableReadingGoals'] as bool? ?? false,
      dailyReadingGoalMinutes:
          (json['dailyReadingGoalMinutes'] as num?)?.toInt() ?? 30,
      weeklyReadingGoalChapters:
          (json['weeklyReadingGoalChapters'] as num?)?.toInt() ?? 7,
      enableSyncAcrossDevices:
          json['enableSyncAcrossDevices'] as bool? ?? false,
      cloudSyncProvider: json['cloudSyncProvider'] as String?,
      customSettings:
          json['customSettings'] as Map<String, dynamic>? ?? const {},
      colorScheme:
          $enumDecodeNullable(_$AppColorSchemeEnumMap, json['colorScheme']) ??
              AppColorScheme.blue,
      showGridLines: json['showGridLines'] as bool? ?? true,
      autoMarkAsReading: json['autoMarkAsReading'] as bool? ?? false,
      autoComplete: json['autoComplete'] as bool? ?? true,
      dailyReminders: json['dailyReminders'] as bool? ?? false,
      reminderTime: json['reminderTime'] == null
          ? const CustomTimeOfDay(hour: 9, minute: 0)
          : CustomTimeOfDay.fromJson(
              json['reminderTime'] as Map<String, dynamic>),
      updateNotifications: json['updateNotifications'] as bool? ?? true,
      enableSync: json['enableSync'] as bool? ?? false,
      malApiKey: json['malApiKey'] as String?,
      anilistApiKey: json['anilistApiKey'] as String?,
      openaiApiKey: json['openaiApiKey'] as String?,
      autoSyncApis: json['autoSyncApis'] as bool? ?? false,
      debugMode: json['debugMode'] as bool? ?? false,
      cacheSize: (json['cacheSize'] as num?)?.toInt() ?? 100,
    );

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'primaryColor': instance.primaryColor,
      'accentColor': instance.accentColor,
      'useDynamicColors': instance.useDynamicColors,
      'fontFamily': instance.fontFamily,
      'fontSize': instance.fontSize,
      'enableAnimations': instance.enableAnimations,
      'enableHapticFeedback': instance.enableHapticFeedback,
      'enableSounds': instance.enableSounds,
      'defaultViewMode': _$ViewModeEnumMap[instance.defaultViewMode]!,
      'defaultSortOption': _$SortOptionEnumMap[instance.defaultSortOption]!,
      'defaultSortOrder': _$SortOptionEnumMap[instance.defaultSortOrder]!,
      'showProgressBars': instance.showProgressBars,
      'showRatings': instance.showRatings,
      'showGenres': instance.showGenres,
      'enableBiometricAuth': instance.enableBiometricAuth,
      'autoBackup': instance.autoBackup,
      'backupFrequency': _$BackupFrequencyEnumMap[instance.backupFrequency]!,
      'backupLocation': instance.backupLocation,
      'enableNotifications': instance.enableNotifications,
      'globalNotificationSettings': instance.globalNotificationSettings,
      'enableAnalytics': instance.enableAnalytics,
      'enableCrashReporting': instance.enableCrashReporting,
      'apiConfigurations': instance.apiConfigurations,
      'enableAIFeatures': instance.enableAIFeatures,
      'openAIApiKey': instance.openAIApiKey,
      'geminiApiKey': instance.geminiApiKey,
      'enableSmartRecommendations': instance.enableSmartRecommendations,
      'enableAutoGenreTags': instance.enableAutoGenreTags,
      'enableReadingTimeTracking': instance.enableReadingTimeTracking,
      'enableReadingGoals': instance.enableReadingGoals,
      'dailyReadingGoalMinutes': instance.dailyReadingGoalMinutes,
      'weeklyReadingGoalChapters': instance.weeklyReadingGoalChapters,
      'enableSyncAcrossDevices': instance.enableSyncAcrossDevices,
      'cloudSyncProvider': instance.cloudSyncProvider,
      'customSettings': instance.customSettings,
      'colorScheme': _$AppColorSchemeEnumMap[instance.colorScheme]!,
      'showGridLines': instance.showGridLines,
      'autoMarkAsReading': instance.autoMarkAsReading,
      'autoComplete': instance.autoComplete,
      'dailyReminders': instance.dailyReminders,
      'reminderTime': instance.reminderTime,
      'updateNotifications': instance.updateNotifications,
      'enableSync': instance.enableSync,
      'malApiKey': instance.malApiKey,
      'anilistApiKey': instance.anilistApiKey,
      'openaiApiKey': instance.openaiApiKey,
      'autoSyncApis': instance.autoSyncApis,
      'debugMode': instance.debugMode,
      'cacheSize': instance.cacheSize,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$ViewModeEnumMap = {
  ViewMode.grid: 'grid',
  ViewMode.list: 'list',
  ViewMode.card: 'card',
  ViewMode.compact: 'compact',
};

const _$SortOptionEnumMap = {
  SortOption.title: 'title',
  SortOption.author: 'author',
  SortOption.dateAdded: 'dateAdded',
  SortOption.lastUpdated: 'lastUpdated',
  SortOption.rating: 'rating',
  SortOption.progress: 'progress',
  SortOption.status: 'status',
  SortOption.type: 'type',
};

const _$BackupFrequencyEnumMap = {
  BackupFrequency.daily: 'daily',
  BackupFrequency.weekly: 'weekly',
  BackupFrequency.monthly: 'monthly',
  BackupFrequency.manual: 'manual',
};

const _$AppColorSchemeEnumMap = {
  AppColorScheme.blue: 'blue',
  AppColorScheme.green: 'green',
  AppColorScheme.purple: 'purple',
  AppColorScheme.orange: 'orange',
  AppColorScheme.red: 'red',
  AppColorScheme.pink: 'pink',
};

ApiConfiguration _$ApiConfigurationFromJson(Map<String, dynamic> json) =>
    ApiConfiguration(
      name: json['name'] as String,
      baseUrl: json['baseUrl'] as String,
      apiKey: json['apiKey'] as String?,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      enabled: json['enabled'] as bool? ?? false,
      type: $enumDecode(_$ApiTypeEnumMap, json['type']),
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ApiConfigurationToJson(ApiConfiguration instance) =>
    <String, dynamic>{
      'name': instance.name,
      'baseUrl': instance.baseUrl,
      'apiKey': instance.apiKey,
      'headers': instance.headers,
      'enabled': instance.enabled,
      'type': _$ApiTypeEnumMap[instance.type]!,
      'settings': instance.settings,
    };

const _$ApiTypeEnumMap = {
  ApiType.manga: 'manga',
  ApiType.anime: 'anime',
  ApiType.ai: 'ai',
  ApiType.recommendation: 'recommendation',
  ApiType.metadata: 'metadata',
  ApiType.sync: 'sync',
  ApiType.backup: 'backup',
};

NotificationSettings _$NotificationSettingsFromJson(
        Map<String, dynamic> json) =>
    NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      showOnLockScreen: json['showOnLockScreen'] as bool? ?? true,
      enableVibration: json['enableVibration'] as bool? ?? true,
      enableSound: json['enableSound'] as bool? ?? true,
      soundPath: json['soundPath'] as String? ?? 'default',
      priority: $enumDecodeNullable(
              _$NotificationPriorityEnumMap, json['priority']) ??
          NotificationPriority.high,
      enableLED: json['enableLED'] as bool? ?? true,
      ledColor: json['ledColor'] as String? ?? '#6366F1',
      reminderTime: json['reminderTime'] == null
          ? const CustomTimeOfDay(hour: 9, minute: 0)
          : CustomTimeOfDay.fromJson(
              json['reminderTime'] as Map<String, dynamic>),
      frequency: $enumDecodeNullable(
              _$NotificationFrequencyEnumMap, json['frequency']) ??
          NotificationFrequency.daily,
      customMessage: json['customMessage'] as String?,
      reminderDays: (json['reminderDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1, 2, 3, 4, 5, 6, 7],
    );

Map<String, dynamic> _$NotificationSettingsToJson(
        NotificationSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'showOnLockScreen': instance.showOnLockScreen,
      'enableVibration': instance.enableVibration,
      'enableSound': instance.enableSound,
      'soundPath': instance.soundPath,
      'priority': _$NotificationPriorityEnumMap[instance.priority]!,
      'enableLED': instance.enableLED,
      'ledColor': instance.ledColor,
      'reminderTime': instance.reminderTime,
      'frequency': _$NotificationFrequencyEnumMap[instance.frequency]!,
      'customMessage': instance.customMessage,
      'reminderDays': instance.reminderDays,
    };

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
  NotificationPriority.max: 'max',
};

const _$NotificationFrequencyEnumMap = {
  NotificationFrequency.daily: 'daily',
  NotificationFrequency.weekly: 'weekly',
  NotificationFrequency.monthly: 'monthly',
  NotificationFrequency.custom: 'custom',
};
