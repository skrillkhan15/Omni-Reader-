import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'app_settings.dart';

part 'reading_item.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class ReadingItem extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? author;

  @HiveField(3)
  final ReadingType type;

  @HiveField(4)
  final ReadingStatus status;

  @HiveField(5)
  final double rating;

  @HiveField(6)
  final List<String> genres;

  @HiveField(7)
  final String? coverImageUrl;

  @HiveField(8)
  final String? localCoverPath;

  @HiveField(9)
  final String? readingUrl;

  @HiveField(10)
  final int currentChapter;

  @HiveField(11)
  final int? totalChapters;

  @HiveField(12)
  final String? description;

  @HiveField(13)
  final DateTime dateAdded;

  @HiveField(14)
  final DateTime lastUpdated;

  @HiveField(15)
  final DateTime? lastRead;

  @HiveField(16)
  final bool isFavorite;

  @HiveField(17)
  final bool hasNotifications;

  @HiveField(18)
  final NotificationSettings? notificationSettings;

  @HiveField(19)
  final Map<String, dynamic>? customFields;

  @HiveField(20)
  final List<String> tags;

  @HiveField(21)
  final String? publisher;

  @HiveField(22)
  final DateTime? startDate;

  @HiveField(23)
  final DateTime? endDate;

  @HiveField(24)
  final String? language;

  @HiveField(25)
  final bool isCompleted;

  @HiveField(26)
  final List<ChapterProgress> chapterProgress;

  @HiveField(27)
  final ReadingStatistics statistics;

  const ReadingItem({
    required this.id,
    required this.title,
    this.author,
    required this.type,
    required this.status,
    this.rating = 0.0,
    this.genres = const [],
    this.coverImageUrl,
    this.localCoverPath,
    this.readingUrl,
    this.currentChapter = 0,
    this.totalChapters,
    this.description,
    required this.dateAdded,
    required this.lastUpdated,
    this.lastRead,
    this.isFavorite = false,
    this.hasNotifications = false,
    this.notificationSettings,
    this.customFields,
    this.tags = const [],
    this.publisher,
    this.startDate,
    this.endDate,
    this.language,
    this.isCompleted = false,
    this.chapterProgress = const [],
    required this.statistics,
  });

  factory ReadingItem.fromJson(Map<String, dynamic> json) =>
      _$ReadingItemFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingItemToJson(this);

  ReadingItem copyWith({
    String? id,
    String? title,
    String? author,
    ReadingType? type,
    ReadingStatus? status,
    double? rating,
    List<String>? genres,
    String? coverImageUrl,
    String? localCoverPath,
    String? readingUrl,
    int? currentChapter,
    int? totalChapters,
    String? description,
    DateTime? dateAdded,
    DateTime? lastUpdated,
    DateTime? lastRead,
    bool? isFavorite,
    bool? hasNotifications,
    NotificationSettings? notificationSettings,
    Map<String, dynamic>? customFields,
    List<String>? tags,
    String? publisher,
    DateTime? startDate,
    DateTime? endDate,
    String? language,
    bool? isCompleted,
    List<ChapterProgress>? chapterProgress,
    ReadingStatistics? statistics,
  }) {
    return ReadingItem(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      type: type ?? this.type,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      genres: genres ?? this.genres,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      localCoverPath: localCoverPath ?? this.localCoverPath,
      readingUrl: readingUrl ?? this.readingUrl,
      currentChapter: currentChapter ?? this.currentChapter,
      totalChapters: totalChapters ?? this.totalChapters,
      description: description ?? this.description,
      dateAdded: dateAdded ?? this.dateAdded,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastRead: lastRead ?? this.lastRead,
      isFavorite: isFavorite ?? this.isFavorite,
      hasNotifications: hasNotifications ?? this.hasNotifications,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      customFields: customFields ?? this.customFields,
      tags: tags ?? this.tags,
      publisher: publisher ?? this.publisher,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      language: language ?? this.language,
      isCompleted: isCompleted ?? this.isCompleted,
      chapterProgress: chapterProgress ?? this.chapterProgress,
      statistics: statistics ?? this.statistics,
    );
  }

  double get progressPercentage {
    if (totalChapters == null || totalChapters == 0) return 0.0;
    return (currentChapter / totalChapters!) * 100;
  }

  bool get isOngoing => status == ReadingStatus.reading;
  bool get isOnHold => status == ReadingStatus.onHold;
  bool get isDropped => status == ReadingStatus.dropped;
  bool get isPlanToRead => status == ReadingStatus.planToRead;

  String get statusDisplayName {
    switch (status) {
      case ReadingStatus.reading:
        return 'Reading';
      case ReadingStatus.completed:
        return 'Completed';
      case ReadingStatus.onHold:
        return 'On Hold';
      case ReadingStatus.dropped:
        return 'Dropped';
      case ReadingStatus.planToRead:
        return 'Plan to Read';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case ReadingType.manga:
        return 'Manga';
      case ReadingType.manhwa:
        return 'Manhwa';
      case ReadingType.manhua:
        return 'Manhua';
      case ReadingType.novel:
        return 'Novel';
      case ReadingType.webtoon:
        return 'Webtoon';
      case ReadingType.lightNovel:
        return 'Light Novel';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        type,
        status,
        rating,
        genres,
        coverImageUrl,
        localCoverPath,
        readingUrl,
        currentChapter,
        totalChapters,
        description,
        dateAdded,
        lastUpdated,
        lastRead,
        isFavorite,
        hasNotifications,
        notificationSettings,
        customFields,
        tags,
        publisher,
        startDate,
        endDate,
        language,
        isCompleted,
        chapterProgress,
        statistics,
      ];
}

@HiveType(typeId: 1)
enum ReadingType {
  @HiveField(0)
  manga,
  @HiveField(1)
  manhwa,
  @HiveField(2)
  manhua,
  @HiveField(3)
  novel,
  @HiveField(4)
  webtoon,
  @HiveField(5)
  lightNovel,
}

extension ReadingTypeExtension on ReadingType {
  String get displayName {
    switch (this) {
      case ReadingType.manga:
        return 'Manga';
      case ReadingType.manhwa:
        return 'Manhwa';
      case ReadingType.manhua:
        return 'Manhua';
      case ReadingType.novel:
        return 'Novel';
      case ReadingType.webtoon:
        return 'Webtoon';
      case ReadingType.lightNovel:
        return 'Light Novel';
    }
  }
}

@HiveType(typeId: 2)
enum ReadingStatus {
  @HiveField(0)
  reading,
  @HiveField(1)
  completed,
  @HiveField(2)
  onHold,
  @HiveField(3)
  dropped,
  @HiveField(4)
  planToRead,
}

extension ReadingStatusExtension on ReadingStatus {
  String get displayName {
    switch (this) {
      case ReadingStatus.reading:
        return 'Reading';
      case ReadingStatus.completed:
        return 'Completed';
      case ReadingStatus.onHold:
        return 'On Hold';
      case ReadingStatus.dropped:
        return 'Dropped';
      case ReadingStatus.planToRead:
        return 'Plan to Read';
    }
  }
}

// NotificationSettings moved to app_settings.dart to avoid duplication

@HiveType(typeId: 4)
enum NotificationFrequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  custom,
}

@HiveType(typeId: 5)
@JsonSerializable()
class CustomTimeOfDay extends Equatable {
  @HiveField(0)
  final int hour;

  @HiveField(1)
  final int minute;

  const CustomTimeOfDay({required this.hour, required this.minute});

  factory CustomTimeOfDay.fromJson(Map<String, dynamic> json) =>
      _$CustomTimeOfDayFromJson(json);

  Map<String, dynamic> toJson() => _$CustomTimeOfDayToJson(this);

  @override
  List<Object> get props => [hour, minute];

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

@HiveType(typeId: 6)
@JsonSerializable()
class ChapterProgress extends Equatable {
  @HiveField(0)
  final int chapterNumber;

  @HiveField(1)
  final DateTime readDate;

  @HiveField(2)
  final int readingTimeMinutes;

  @HiveField(3)
  final double? rating;

  @HiveField(4)
  final String? notes;

  const ChapterProgress({
    required this.chapterNumber,
    required this.readDate,
    this.readingTimeMinutes = 0,
    this.rating,
    this.notes,
  });

  factory ChapterProgress.fromJson(Map<String, dynamic> json) =>
      _$ChapterProgressFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterProgressToJson(this);

  @override
  List<Object?> get props => [
        chapterNumber,
        readDate,
        readingTimeMinutes,
        rating,
        notes,
      ];
}

@HiveType(typeId: 7)
@JsonSerializable()
class ReadingStatistics extends Equatable {
  @HiveField(0)
  final int totalReadingTimeMinutes;

  @HiveField(1)
  final int chaptersRead;

  @HiveField(2)
  final int sessionsCount;

  @HiveField(3)
  final DateTime? firstReadDate;

  @HiveField(4)
  final DateTime? lastReadDate;

  @HiveField(5)
  final double averageReadingSpeed;

  @HiveField(6)
  final Map<String, int> readingStreaks;

  const ReadingStatistics({
    this.totalReadingTimeMinutes = 0,
    this.chaptersRead = 0,
    this.sessionsCount = 0,
    this.firstReadDate,
    this.lastReadDate,
    this.averageReadingSpeed = 0.0,
    this.readingStreaks = const {},
  });

  factory ReadingStatistics.fromJson(Map<String, dynamic> json) =>
      _$ReadingStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingStatisticsToJson(this);

  ReadingStatistics copyWith({
    int? totalReadingTimeMinutes,
    int? chaptersRead,
    int? sessionsCount,
    DateTime? firstReadDate,
    DateTime? lastReadDate,
    double? averageReadingSpeed,
    Map<String, int>? readingStreaks,
  }) {
    return ReadingStatistics(
      totalReadingTimeMinutes: totalReadingTimeMinutes ?? this.totalReadingTimeMinutes,
      chaptersRead: chaptersRead ?? this.chaptersRead,
      sessionsCount: sessionsCount ?? this.sessionsCount,
      firstReadDate: firstReadDate ?? this.firstReadDate,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      averageReadingSpeed: averageReadingSpeed ?? this.averageReadingSpeed,
      readingStreaks: readingStreaks ?? this.readingStreaks,
    );
  }

  @override
  List<Object?> get props => [
        totalReadingTimeMinutes,
        chaptersRead,
        sessionsCount,
        firstReadDate,
        lastReadDate,
        averageReadingSpeed,
        readingStreaks,
      ];
}

@HiveType(typeId: 8)
enum ViewMode {
  @HiveField(0)
  grid,
  @HiveField(1)
  list,
  @HiveField(2)
  card,
  @HiveField(3)
  compact,
}

extension ViewModeExtension on ViewMode {
  String get displayName {
    switch (this) {
      case ViewMode.grid:
        return 'Grid';
      case ViewMode.list:
        return 'List';
      case ViewMode.card:
        return 'Card';
      case ViewMode.compact:
        return 'Compact';
    }
  }
}

@HiveType(typeId: 9)
enum SortOption {
  @HiveField(0)
  title,
  @HiveField(1)
  author,
  @HiveField(2)
  dateAdded,
  @HiveField(3)
  lastUpdated,
  @HiveField(4)
  rating,
  @HiveField(5)
  progress,
  @HiveField(6)
  status,
  @HiveField(7)
  type,
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.title:
        return 'Title';
      case SortOption.author:
        return 'Author';
      case SortOption.dateAdded:
        return 'Date Added';
      case SortOption.lastUpdated:
        return 'Last Updated';
      case SortOption.rating:
        return 'Rating';
      case SortOption.progress:
        return 'Progress';
      case SortOption.status:
        return 'Status';
      case SortOption.type:
        return 'Type';
    }
  }
}
