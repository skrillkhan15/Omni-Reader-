import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/reading_item.dart';
import '../database/database_service.dart';
import '../services/image_service.dart';
import '../services/notification_service.dart';

final readingItemRepositoryProvider = Provider<ReadingItemRepository>((ref) {
  return ReadingItemRepository(
    databaseService: DatabaseService(),
    imageService: ref.read(imageServiceProvider),
    notificationService: ref.read(notificationServiceProvider),
  );
});

class ReadingItemRepository {
  final DatabaseService _databaseService;
  final ImageService _imageService;
  final NotificationService _notificationService;
  final Uuid _uuid = const Uuid();

  // Hive box for caching
  late Box<ReadingItem> _readingItemsBox;
  late Box<Map<String, dynamic>> _cacheBox;

  ReadingItemRepository({
    required DatabaseService databaseService,
    required ImageService imageService,
    required NotificationService notificationService,
  })  : _databaseService = databaseService,
        _imageService = imageService,
        _notificationService = notificationService;

  Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ReadingItemAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ReadingTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ReadingStatusAdapter());
    }

    // Open boxes
    _readingItemsBox = await Hive.openBox<ReadingItem>('reading_items');
    _cacheBox = await Hive.openBox<Map<String, dynamic>>('cache');
  }

  // Create operations
  Future<ReadingItem> createReadingItem({
    required String title,
    String? author,
    required ReadingType type,
    ReadingStatus status = ReadingStatus.planToRead,
    double rating = 0.0,
    List<String> genres = const [],
    String? coverImageUrl,
    File? coverImageFile,
    String? readingUrl,
    int currentChapter = 0,
    int? totalChapters,
    String? description,
    List<String> tags = const [],
    String? publisher,
    String? language,
    Map<String, dynamic>? customFields,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    String? localCoverPath;
    if (coverImageFile != null) {
      localCoverPath = await _imageService.saveLocalImage(coverImageFile, id);
    } else if (coverImageUrl != null) {
      localCoverPath = await _imageService.downloadAndSaveImage(coverImageUrl, id);
    }

    final readingItem = ReadingItem(
      id: id,
      title: title,
      author: author,
      type: type,
      status: status,
      rating: rating,
      genres: genres,
      coverImageUrl: coverImageUrl,
      localCoverPath: localCoverPath,
      readingUrl: readingUrl,
      currentChapter: currentChapter,
      totalChapters: totalChapters,
      description: description,
      dateAdded: now,
      lastUpdated: now,
      tags: tags,
      publisher: publisher,
      language: language,
      customFields: customFields,
      statistics: const ReadingStatistics(),
    );

    // Save to database
    await _databaseService.insertReadingItem(readingItem);

    // Cache in Hive
    await _readingItemsBox.put(id, readingItem);

    // Set up notifications if enabled
    if (readingItem.hasNotifications && readingItem.notificationSettings != null) {
      await _notificationService.scheduleReadingReminder(readingItem);
    }

    return readingItem;
  }

  // Read operations
  Future<List<ReadingItem>> getAllReadingItems({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _readingItemsBox.isNotEmpty) {
      return _readingItemsBox.values.toList();
    }

    final items = await _databaseService.getAllReadingItems();

    // Update cache
    await _readingItemsBox.clear();
    for (final item in items) {
      await _readingItemsBox.put(item.id, item);
    }

    return items;
  }

  Future<ReadingItem?> getReadingItemById(String id) async {
    // Check cache first
    if (_readingItemsBox.containsKey(id)) {
      return _readingItemsBox.get(id);
    }

    // Fallback to database
    final item = await _databaseService.getReadingItemById(id);
    if (item != null) {
      await _readingItemsBox.put(id, item);
    }

    return item;
  }

  Future<List<ReadingItem>> getReadingItemsByType(ReadingType type) async {
    final items = await getAllReadingItems();
    return items.where((item) => item.type == type).toList();
  }

  Future<List<ReadingItem>> getReadingItemsByStatus(ReadingStatus status) async {
    final items = await getAllReadingItems();
    return items.where((item) => item.status == status).toList();
  }

  Future<List<ReadingItem>> getFavoriteReadingItems() async {
    final items = await getAllReadingItems();
    return items.where((item) => item.isFavorite).toList();
  }

  Future<List<ReadingItem>> getRecentlyUpdatedItems({int limit = 10}) async {
    final items = await getAllReadingItems();
    items.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return items.take(limit).toList();
  }

  Future<List<ReadingItem>> getRecentlyAddedItems({int limit = 10}) async {
    final items = await getAllReadingItems();
    items.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return items.take(limit).toList();
  }

  Future<List<ReadingItem>> getCurrentlyReadingItems() async {
    return getReadingItemsByStatus(ReadingStatus.reading);
  }

  Future<List<ReadingItem>> getCompletedItems() async {
    return getReadingItemsByStatus(ReadingStatus.completed);
  }

  // Search operations
  Future<List<ReadingItem>> searchReadingItems(String query) async {
    if (query.isEmpty) {
      return getAllReadingItems();
    }

    final items = await getAllReadingItems();
    final lowercaseQuery = query.toLowerCase();

    return items.where((item) {
      return item.title.toLowerCase().contains(lowercaseQuery) ||
             (item.author?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             item.genres.any((genre) => genre.toLowerCase().contains(lowercaseQuery)) ||
             item.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
             (item.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  Future<List<ReadingItem>> getFilteredItems({
    List<ReadingType>? types,
    List<ReadingStatus>? statuses,
    List<String>? genres,
    double? minRating,
    double? maxRating,
    bool? isFavorite,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final items = await getAllReadingItems();

    return items.where((item) {
      if (types != null && !types.contains(item.type)) return false;
      if (statuses != null && !statuses.contains(item.status)) return false;
      if (genres != null && !genres.any((genre) => item.genres.contains(genre))) return false;
      if (minRating != null && item.rating < minRating) return false;
      if (maxRating != null && item.rating > maxRating) return false;
      if (isFavorite != null && item.isFavorite != isFavorite) return false;
      if (startDate != null && item.dateAdded.isBefore(startDate)) return false;
      if (endDate != null && item.dateAdded.isAfter(endDate)) return false;

      return true;
    }).toList();
  }

  // Update operations
  Future<ReadingItem> updateReadingItem(ReadingItem item) async {
    final updatedItem = item.copyWith(lastUpdated: DateTime.now());

    // Update database
    await _databaseService.updateReadingItem(updatedItem);

    // Update cache
    await _readingItemsBox.put(updatedItem.id, updatedItem);

    // Update notifications if settings changed
    if (updatedItem.hasNotifications && updatedItem.notificationSettings != null) {
      await _notificationService.scheduleReadingReminder(updatedItem);
    } else {
      await _notificationService.cancelReadingReminder(updatedItem.id);
    }

    return updatedItem;
  }

  Future<ReadingItem> updateProgress({
    required String id,
    required int currentChapter,
    int? totalChapters,
    ReadingStatus? newStatus,
  }) async {
    final item = await getReadingItemById(id);
    if (item == null) throw Exception('Reading item not found');

    final updatedItem = item.copyWith(
      currentChapter: currentChapter,
      totalChapters: totalChapters ?? item.totalChapters,
      status: newStatus ?? item.status,
      lastRead: DateTime.now(),
      lastUpdated: DateTime.now(),
      isCompleted: newStatus == ReadingStatus.completed,
    );

    // Record chapter progress
    final chapterProgress = ChapterProgress(
      chapterNumber: currentChapter,
      readDate: DateTime.now(),
    );

    await _databaseService.insertChapterProgress(id, chapterProgress);

    return updateReadingItem(updatedItem);
  }

  Future<ReadingItem> updateRating(String id, double rating) async {
    final item = await getReadingItemById(id);
    if (item == null) throw Exception('Reading item not found');

    return updateReadingItem(item.copyWith(rating: rating));
  }

  Future<ReadingItem> toggleFavorite(String id) async {
    final item = await getReadingItemById(id);
    if (item == null) throw Exception('Reading item not found');

    return updateReadingItem(item.copyWith(isFavorite: !item.isFavorite));
  }

  Future<ReadingItem> updateCoverImage({
    required String id,
    String? coverImageUrl,
    File? coverImageFile,
  }) async {
    final item = await getReadingItemById(id);
    if (item == null) throw Exception('Reading item not found');

    String? localCoverPath = item.localCoverPath;

    if (coverImageFile != null) {
      // Delete old local image if exists
      if (localCoverPath != null) {
        await _imageService.deleteLocalImage(localCoverPath);
      }
      localCoverPath = await _imageService.saveLocalImage(coverImageFile, id);
    } else if (coverImageUrl != null && coverImageUrl != item.coverImageUrl) {
      // Delete old local image if exists
      if (localCoverPath != null) {
        await _imageService.deleteLocalImage(localCoverPath);
      }
      localCoverPath = await _imageService.downloadAndSaveImage(coverImageUrl, id);
    }

    return updateReadingItem(item.copyWith(
      coverImageUrl: coverImageUrl,
      localCoverPath: localCoverPath,
    ));
  }

  // Delete operations
  Future<void> deleteReadingItem(String id) async {
    final item = await getReadingItemById(id);
    if (item == null) return;

    // Delete local cover image if exists
    if (item.localCoverPath != null) {
      await _imageService.deleteLocalImage(item.localCoverPath!);
    }

    // Cancel notifications
    await _notificationService.cancelReadingReminder(id);

    // Delete from database
    await _databaseService.deleteReadingItem(id);

    // Remove from cache
    await _readingItemsBox.delete(id);
  }

  Future<void> deleteMultipleItems(List<String> ids) async {
    for (final id in ids) {
      await deleteReadingItem(id);
    }
  }

  // Bulk operations
  Future<List<ReadingItem>> importFromJson(String jsonData) async {
    final List<dynamic> data = json.decode(jsonData);
    final List<ReadingItem> importedItems = [];

    for (final itemData in data) {
      try {
        final item = ReadingItem.fromJson(itemData);
        final newItem = await createReadingItem(
          title: item.title,
          author: item.author,
          type: item.type,
          status: item.status,
          rating: item.rating,
          genres: item.genres,
          coverImageUrl: item.coverImageUrl,
          readingUrl: item.readingUrl,
          currentChapter: item.currentChapter,
          totalChapters: item.totalChapters,
          description: item.description,
          tags: item.tags,
          publisher: item.publisher,
          language: item.language,
        );
        importedItems.add(newItem);
      } catch (e) {
        // Skip invalid items
        continue;
      }
    }

    return importedItems;
  }

  Future<String> exportToJson({List<String>? itemIds}) async {
    List<ReadingItem> items;

    if (itemIds != null) {
      items = [];
      for (final id in itemIds) {
        final item = await getReadingItemById(id);
        if (item != null) items.add(item);
      }
    } else {
      items = await getAllReadingItems();
    }

    final jsonData = items.map((item) => item.toJson()).toList();
    return json.encode(jsonData);
  }

  // Statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final items = await getAllReadingItems();

    final typeStats = <ReadingType, int>{};
    final statusStats = <ReadingStatus, int>{};
    final genreStats = <String, int>{};

    double totalRating = 0;
    int ratedItems = 0;
    int totalChapters = 0;

    for (final item in items) {
      // Type statistics
      typeStats[item.type] = (typeStats[item.type] ?? 0) + 1;

      // Status statistics
      statusStats[item.status] = (statusStats[item.status] ?? 0) + 1;

      // Genre statistics
      for (final genre in item.genres) {
        genreStats[genre] = (genreStats[genre] ?? 0) + 1;
      }

      // Rating statistics
      if (item.rating > 0) {
        totalRating += item.rating;
        ratedItems++;
      }

      // Chapter statistics
      totalChapters += item.currentChapter;
    }

    return {
      'totalItems': items.length,
      'typeStats': typeStats,
      'statusStats': statusStats,
      'genreStats': genreStats,
      'averageRating': ratedItems > 0 ? totalRating / ratedItems : 0.0,
      'totalChaptersRead': totalChapters,
      'favoriteItems': items.where((item) => item.isFavorite).length,
    };
  }

  // Sorting
  List<ReadingItem> sortItems(List<ReadingItem> items, SortOption sortOption, {bool ascending = true}) {
    items.sort((a, b) {
      int comparison;

      switch (sortOption) {
        case SortOption.title:
          comparison = a.title.compareTo(b.title);
          break;
        case SortOption.author:
          comparison = (a.author ?? '').compareTo(b.author ?? '');
          break;
        case SortOption.rating:
          comparison = a.rating.compareTo(b.rating);
          break;
        case SortOption.dateAdded:
          comparison = a.dateAdded.compareTo(b.dateAdded);
          break;
        case SortOption.lastUpdated:
          comparison = a.lastUpdated.compareTo(b.lastUpdated);
          break;
        case SortOption.progress:
          comparison = a.progressPercentage.compareTo(b.progressPercentage);
          break;
        case SortOption.type:
          comparison = a.type.index.compareTo(b.type.index);
          break;
        case SortOption.status:
          comparison = a.status.index.compareTo(b.status.index);
          break;
      }

      return ascending ? comparison : -comparison;
    });

    return items;
  }

  // Cache management
  Future<void> clearCache() async {
    await _readingItemsBox.clear();
    await _cacheBox.clear();
  }

  Future<void> clearAllData() async {
    await _readingItemsBox.clear();
    await _cacheBox.clear();
    // Also clear from database if needed
    // await _databaseService.clearAllData();
  }

  Future<void> refreshCache() async {
    await clearCache();
    await getAllReadingItems(forceRefresh: true);
  }

  // Cleanup
  Future<void> dispose() async {
    await _readingItemsBox.close();
    await _cacheBox.close();
  }
}


