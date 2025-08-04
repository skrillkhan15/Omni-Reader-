// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingItemAdapter extends TypeAdapter<ReadingItem> {
  @override
  final int typeId = 0;

  @override
  ReadingItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingItem(
      id: fields[0] as String,
      title: fields[1] as String,
      author: fields[2] as String?,
      type: fields[3] as ReadingType,
      status: fields[4] as ReadingStatus,
      rating: fields[5] as double,
      genres: (fields[6] as List).cast<String>(),
      coverImageUrl: fields[7] as String?,
      localCoverPath: fields[8] as String?,
      readingUrl: fields[9] as String?,
      currentChapter: fields[10] as int,
      totalChapters: fields[11] as int?,
      description: fields[12] as String?,
      dateAdded: fields[13] as DateTime,
      lastUpdated: fields[14] as DateTime,
      lastRead: fields[15] as DateTime?,
      isFavorite: fields[16] as bool,
      hasNotifications: fields[17] as bool,
      notificationSettings: fields[18] as NotificationSettings?,
      customFields: (fields[19] as Map?)?.cast<String, dynamic>(),
      tags: (fields[20] as List).cast<String>(),
      publisher: fields[21] as String?,
      startDate: fields[22] as DateTime?,
      endDate: fields[23] as DateTime?,
      language: fields[24] as String?,
      isCompleted: fields[25] as bool,
      chapterProgress: (fields[26] as List).cast<ChapterProgress>(),
      statistics: fields[27] as ReadingStatistics,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingItem obj) {
    writer
      ..writeByte(28)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.genres)
      ..writeByte(7)
      ..write(obj.coverImageUrl)
      ..writeByte(8)
      ..write(obj.localCoverPath)
      ..writeByte(9)
      ..write(obj.readingUrl)
      ..writeByte(10)
      ..write(obj.currentChapter)
      ..writeByte(11)
      ..write(obj.totalChapters)
      ..writeByte(12)
      ..write(obj.description)
      ..writeByte(13)
      ..write(obj.dateAdded)
      ..writeByte(14)
      ..write(obj.lastUpdated)
      ..writeByte(15)
      ..write(obj.lastRead)
      ..writeByte(16)
      ..write(obj.isFavorite)
      ..writeByte(17)
      ..write(obj.hasNotifications)
      ..writeByte(18)
      ..write(obj.notificationSettings)
      ..writeByte(19)
      ..write(obj.customFields)
      ..writeByte(20)
      ..write(obj.tags)
      ..writeByte(21)
      ..write(obj.publisher)
      ..writeByte(22)
      ..write(obj.startDate)
      ..writeByte(23)
      ..write(obj.endDate)
      ..writeByte(24)
      ..write(obj.language)
      ..writeByte(25)
      ..write(obj.isCompleted)
      ..writeByte(26)
      ..write(obj.chapterProgress)
      ..writeByte(27)
      ..write(obj.statistics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustomTimeOfDayAdapter extends TypeAdapter<CustomTimeOfDay> {
  @override
  final int typeId = 5;

  @override
  CustomTimeOfDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomTimeOfDay(
      hour: fields[0] as int,
      minute: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CustomTimeOfDay obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.hour)
      ..writeByte(1)
      ..write(obj.minute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomTimeOfDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChapterProgressAdapter extends TypeAdapter<ChapterProgress> {
  @override
  final int typeId = 6;

  @override
  ChapterProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChapterProgress(
      chapterNumber: fields[0] as int,
      readDate: fields[1] as DateTime,
      readingTimeMinutes: fields[2] as int,
      rating: fields[3] as double?,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChapterProgress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.chapterNumber)
      ..writeByte(1)
      ..write(obj.readDate)
      ..writeByte(2)
      ..write(obj.readingTimeMinutes)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReadingStatisticsAdapter extends TypeAdapter<ReadingStatistics> {
  @override
  final int typeId = 7;

  @override
  ReadingStatistics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingStatistics(
      totalReadingTimeMinutes: fields[0] as int,
      chaptersRead: fields[1] as int,
      sessionsCount: fields[2] as int,
      firstReadDate: fields[3] as DateTime?,
      lastReadDate: fields[4] as DateTime?,
      averageReadingSpeed: fields[5] as double,
      readingStreaks: (fields[6] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReadingStatistics obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.totalReadingTimeMinutes)
      ..writeByte(1)
      ..write(obj.chaptersRead)
      ..writeByte(2)
      ..write(obj.sessionsCount)
      ..writeByte(3)
      ..write(obj.firstReadDate)
      ..writeByte(4)
      ..write(obj.lastReadDate)
      ..writeByte(5)
      ..write(obj.averageReadingSpeed)
      ..writeByte(6)
      ..write(obj.readingStreaks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingStatisticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReadingTypeAdapter extends TypeAdapter<ReadingType> {
  @override
  final int typeId = 1;

  @override
  ReadingType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReadingType.manga;
      case 1:
        return ReadingType.manhwa;
      case 2:
        return ReadingType.manhua;
      case 3:
        return ReadingType.novel;
      case 4:
        return ReadingType.webtoon;
      case 5:
        return ReadingType.lightNovel;
      default:
        return ReadingType.manga;
    }
  }

  @override
  void write(BinaryWriter writer, ReadingType obj) {
    switch (obj) {
      case ReadingType.manga:
        writer.writeByte(0);
        break;
      case ReadingType.manhwa:
        writer.writeByte(1);
        break;
      case ReadingType.manhua:
        writer.writeByte(2);
        break;
      case ReadingType.novel:
        writer.writeByte(3);
        break;
      case ReadingType.webtoon:
        writer.writeByte(4);
        break;
      case ReadingType.lightNovel:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReadingStatusAdapter extends TypeAdapter<ReadingStatus> {
  @override
  final int typeId = 2;

  @override
  ReadingStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReadingStatus.reading;
      case 1:
        return ReadingStatus.completed;
      case 2:
        return ReadingStatus.onHold;
      case 3:
        return ReadingStatus.dropped;
      case 4:
        return ReadingStatus.planToRead;
      default:
        return ReadingStatus.reading;
    }
  }

  @override
  void write(BinaryWriter writer, ReadingStatus obj) {
    switch (obj) {
      case ReadingStatus.reading:
        writer.writeByte(0);
        break;
      case ReadingStatus.completed:
        writer.writeByte(1);
        break;
      case ReadingStatus.onHold:
        writer.writeByte(2);
        break;
      case ReadingStatus.dropped:
        writer.writeByte(3);
        break;
      case ReadingStatus.planToRead:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationFrequencyAdapter extends TypeAdapter<NotificationFrequency> {
  @override
  final int typeId = 4;

  @override
  NotificationFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationFrequency.daily;
      case 1:
        return NotificationFrequency.weekly;
      case 2:
        return NotificationFrequency.monthly;
      case 3:
        return NotificationFrequency.custom;
      default:
        return NotificationFrequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationFrequency obj) {
    switch (obj) {
      case NotificationFrequency.daily:
        writer.writeByte(0);
        break;
      case NotificationFrequency.weekly:
        writer.writeByte(1);
        break;
      case NotificationFrequency.monthly:
        writer.writeByte(2);
        break;
      case NotificationFrequency.custom:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ViewModeAdapter extends TypeAdapter<ViewMode> {
  @override
  final int typeId = 8;

  @override
  ViewMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ViewMode.grid;
      case 1:
        return ViewMode.list;
      case 2:
        return ViewMode.card;
      case 3:
        return ViewMode.compact;
      default:
        return ViewMode.grid;
    }
  }

  @override
  void write(BinaryWriter writer, ViewMode obj) {
    switch (obj) {
      case ViewMode.grid:
        writer.writeByte(0);
        break;
      case ViewMode.list:
        writer.writeByte(1);
        break;
      case ViewMode.card:
        writer.writeByte(2);
        break;
      case ViewMode.compact:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SortOptionAdapter extends TypeAdapter<SortOption> {
  @override
  final int typeId = 9;

  @override
  SortOption read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SortOption.title;
      case 1:
        return SortOption.author;
      case 2:
        return SortOption.dateAdded;
      case 3:
        return SortOption.lastUpdated;
      case 4:
        return SortOption.rating;
      case 5:
        return SortOption.progress;
      case 6:
        return SortOption.status;
      case 7:
        return SortOption.type;
      default:
        return SortOption.title;
    }
  }

  @override
  void write(BinaryWriter writer, SortOption obj) {
    switch (obj) {
      case SortOption.title:
        writer.writeByte(0);
        break;
      case SortOption.author:
        writer.writeByte(1);
        break;
      case SortOption.dateAdded:
        writer.writeByte(2);
        break;
      case SortOption.lastUpdated:
        writer.writeByte(3);
        break;
      case SortOption.rating:
        writer.writeByte(4);
        break;
      case SortOption.progress:
        writer.writeByte(5);
        break;
      case SortOption.status:
        writer.writeByte(6);
        break;
      case SortOption.type:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortOptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingItem _$ReadingItemFromJson(Map<String, dynamic> json) => ReadingItem(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      type: $enumDecode(_$ReadingTypeEnumMap, json['type']),
      status: $enumDecode(_$ReadingStatusEnumMap, json['status']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      coverImageUrl: json['coverImageUrl'] as String?,
      localCoverPath: json['localCoverPath'] as String?,
      readingUrl: json['readingUrl'] as String?,
      currentChapter: (json['currentChapter'] as num?)?.toInt() ?? 0,
      totalChapters: (json['totalChapters'] as num?)?.toInt(),
      description: json['description'] as String?,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      lastRead: json['lastRead'] == null
          ? null
          : DateTime.parse(json['lastRead'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      hasNotifications: json['hasNotifications'] as bool? ?? false,
      notificationSettings: json['notificationSettings'] == null
          ? null
          : NotificationSettings.fromJson(
              json['notificationSettings'] as Map<String, dynamic>),
      customFields: json['customFields'] as Map<String, dynamic>?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      publisher: json['publisher'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      language: json['language'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      chapterProgress: (json['chapterProgress'] as List<dynamic>?)
              ?.map((e) => ChapterProgress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      statistics: ReadingStatistics.fromJson(
          json['statistics'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReadingItemToJson(ReadingItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'author': instance.author,
      'type': _$ReadingTypeEnumMap[instance.type]!,
      'status': _$ReadingStatusEnumMap[instance.status]!,
      'rating': instance.rating,
      'genres': instance.genres,
      'coverImageUrl': instance.coverImageUrl,
      'localCoverPath': instance.localCoverPath,
      'readingUrl': instance.readingUrl,
      'currentChapter': instance.currentChapter,
      'totalChapters': instance.totalChapters,
      'description': instance.description,
      'dateAdded': instance.dateAdded.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'lastRead': instance.lastRead?.toIso8601String(),
      'isFavorite': instance.isFavorite,
      'hasNotifications': instance.hasNotifications,
      'notificationSettings': instance.notificationSettings,
      'customFields': instance.customFields,
      'tags': instance.tags,
      'publisher': instance.publisher,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'language': instance.language,
      'isCompleted': instance.isCompleted,
      'chapterProgress': instance.chapterProgress,
      'statistics': instance.statistics,
    };

const _$ReadingTypeEnumMap = {
  ReadingType.manga: 'manga',
  ReadingType.manhwa: 'manhwa',
  ReadingType.manhua: 'manhua',
  ReadingType.novel: 'novel',
  ReadingType.webtoon: 'webtoon',
  ReadingType.lightNovel: 'lightNovel',
};

const _$ReadingStatusEnumMap = {
  ReadingStatus.reading: 'reading',
  ReadingStatus.completed: 'completed',
  ReadingStatus.onHold: 'onHold',
  ReadingStatus.dropped: 'dropped',
  ReadingStatus.planToRead: 'planToRead',
};

CustomTimeOfDay _$CustomTimeOfDayFromJson(Map<String, dynamic> json) =>
    CustomTimeOfDay(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
    );

Map<String, dynamic> _$CustomTimeOfDayToJson(CustomTimeOfDay instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
    };

ChapterProgress _$ChapterProgressFromJson(Map<String, dynamic> json) =>
    ChapterProgress(
      chapterNumber: (json['chapterNumber'] as num).toInt(),
      readDate: DateTime.parse(json['readDate'] as String),
      readingTimeMinutes: (json['readingTimeMinutes'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ChapterProgressToJson(ChapterProgress instance) =>
    <String, dynamic>{
      'chapterNumber': instance.chapterNumber,
      'readDate': instance.readDate.toIso8601String(),
      'readingTimeMinutes': instance.readingTimeMinutes,
      'rating': instance.rating,
      'notes': instance.notes,
    };

ReadingStatistics _$ReadingStatisticsFromJson(Map<String, dynamic> json) =>
    ReadingStatistics(
      totalReadingTimeMinutes:
          (json['totalReadingTimeMinutes'] as num?)?.toInt() ?? 0,
      chaptersRead: (json['chaptersRead'] as num?)?.toInt() ?? 0,
      sessionsCount: (json['sessionsCount'] as num?)?.toInt() ?? 0,
      firstReadDate: json['firstReadDate'] == null
          ? null
          : DateTime.parse(json['firstReadDate'] as String),
      lastReadDate: json['lastReadDate'] == null
          ? null
          : DateTime.parse(json['lastReadDate'] as String),
      averageReadingSpeed:
          (json['averageReadingSpeed'] as num?)?.toDouble() ?? 0.0,
      readingStreaks: (json['readingStreaks'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$ReadingStatisticsToJson(ReadingStatistics instance) =>
    <String, dynamic>{
      'totalReadingTimeMinutes': instance.totalReadingTimeMinutes,
      'chaptersRead': instance.chaptersRead,
      'sessionsCount': instance.sessionsCount,
      'firstReadDate': instance.firstReadDate?.toIso8601String(),
      'lastReadDate': instance.lastReadDate?.toIso8601String(),
      'averageReadingSpeed': instance.averageReadingSpeed,
      'readingStreaks': instance.readingStreaks,
    };
