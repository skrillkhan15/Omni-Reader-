import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/reading_item.dart';
import '../models/app_settings.dart';
import 'package:flutter/material.dart';
import '../utils/app_router.dart';

// App settings providers
final appSettingsProvider = AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(() {
  return AppSettingsNotifier();
});

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  late Box<AppSettings> _settingsBox;

  @override
  Future<AppSettings> build() async {
    try {
      _settingsBox = await Hive.openBox<AppSettings>('app_settings');

      // Return default settings if none exist
      if (_settingsBox.isEmpty) {
        final defaultSettings = AppSettings(
          globalNotificationSettings: NotificationSettings(
            reminderTime: CustomTimeOfDay(hour: 20, minute: 0),
          ),
        );
        await _settingsBox.add(defaultSettings);
        return defaultSettings;
      }

      return _settingsBox.getAt(0)!;
    } catch (e, st) {
      // Explicitly set the state to error if an exception occurs during initialization
      state = AsyncValue.error(e, st);
      rethrow; // Re-throw the error to propagate it
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    await _settingsBox.putAt(0, settings);
    state = AsyncValue.data(settings);
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      await updateSettings(currentSettings.copyWith(themeMode: themeMode));
    }
  }

  Future<void> toggleAIFeatures() async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      await updateSettings(currentSettings.copyWith(enableAIFeatures: !currentSettings.enableAIFeatures));
    }
  }

  Future<void> updateFontSize(double fontSize) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      await updateSettings(currentSettings.copyWith(fontSize: fontSize));
    }
  }

  Future<void> updateDefaultViewMode(ViewMode viewMode) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      await updateSettings(currentSettings.copyWith(defaultViewMode: viewMode));
    }
  }

  Future<void> updateDefaultSortOption(SortOption sortOption) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      await updateSettings(currentSettings.copyWith(defaultSortOption: sortOption));
    }
  }

  Future<void> resetToDefaults() async {
    final defaultSettings = AppSettings(
      globalNotificationSettings: NotificationSettings(
        reminderTime: CustomTimeOfDay(hour: 20, minute: 0),
      ),
    );
    await updateSettings(defaultSettings);
  }
}

// Reading items providers
final readingItemsProvider = AsyncNotifierProvider<ReadingItemsNotifier, List<ReadingItem>>(() {
  return ReadingItemsNotifier();
});

class ReadingItemsNotifier extends AsyncNotifier<List<ReadingItem>> {
  late Box<ReadingItem> _itemsBox;

  @override
  Future<List<ReadingItem>> build() async {
    _itemsBox = await Hive.openBox<ReadingItem>('reading_items');
    return _itemsBox.values.toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final items = _itemsBox.values.toList();
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addItem(ReadingItem item) async {
    await _itemsBox.add(item);
    await refresh();
  }

  Future<void> updateItem(ReadingItem item) async {
    final index = _itemsBox.values.toList().indexWhere((i) => i.id == item.id);
    if (index != -1) {
      await _itemsBox.putAt(index, item);
      await refresh();
    }
  }

  Future<void> deleteItem(String id) async {
    final index = _itemsBox.values.toList().indexWhere((item) => item.id == id);
    if (index != -1) {
      await _itemsBox.deleteAt(index);
      await refresh();
    }
  }

  Future<void> clearAllData() async {
    await _itemsBox.clear();
    await refresh();
  }

  Future<void> toggleFavorite(String id) async {
    final items = _itemsBox.values.toList();
    final index = items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = items[index];
      final updatedItem = item.copyWith(isFavorite: !item.isFavorite);
      await _itemsBox.putAt(index, updatedItem);
      await refresh();
    }
  }

  Future<void> updateProgress(String id, int currentChapter, {int? totalChapters, ReadingStatus? newStatus}) async {
    final items = _itemsBox.values.toList();
    final index = items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = items[index];
      final updatedItem = item.copyWith(
        currentChapter: currentChapter,
        totalChapters: totalChapters ?? item.totalChapters,
        status: newStatus ?? item.status,
        lastUpdated: DateTime.now(),
        lastRead: DateTime.now(),
      );
      await _itemsBox.putAt(index, updatedItem);
      await refresh();
    }
  }

  Future<void> updateRating(String id, double rating) async {
    final items = _itemsBox.values.toList();
    final index = items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = items[index];
      final updatedItem = item.copyWith(
        rating: rating,
        lastUpdated: DateTime.now(),
      );
      await _itemsBox.putAt(index, updatedItem);
      await refresh();
    }
  }
}

// Filtered reading items providers
final mangaItemsProvider = Provider<AsyncValue<List<ReadingItem>>>((ref) {
  return ref.watch(readingItemsProvider).whenData(
    (items) => items.where((item) => item.type == ReadingType.manga).toList(),
  );
});

final manhwaItemsProvider = Provider<AsyncValue<List<ReadingItem>>>((ref) {
  return ref.watch(readingItemsProvider).whenData(
    (items) => items.where((item) => item.type == ReadingType.manhwa).toList(),
  );
});

final manhuaItemsProvider = Provider<AsyncValue<List<ReadingItem>>>((ref) {
  return ref.watch(readingItemsProvider).whenData(
    (items) => items.where((item) => item.type == ReadingType.manhua).toList(),
  );
});

final favoriteItemsProvider = Provider<AsyncValue<List<ReadingItem>>>((ref) {
  return ref.watch(readingItemsProvider).whenData(
    (items) => items.where((item) => item.isFavorite).toList(),
  );
});

final currentlyReadingProvider = Provider<AsyncValue<List<ReadingItem>>>((ref) {
  return ref.watch(readingItemsProvider).whenData(
    (items) => items.where((item) => item.status == ReadingStatus.reading).toList(),
  );
});

final completedItemsProvider = Provider<AsyncValue<List<ReadingItem>>>((ref) {
  return ref.watch(readingItemsProvider).whenData(
    (items) => items.where((item) => item.status == ReadingStatus.completed).toList(),
  );
});

final recentlyAddedProvider = Provider<AsyncValue<List<ReadingItem>>>((ref) {
  return ref.watch(readingItemsProvider).whenData((items) {
    final sortedItems = List<ReadingItem>.from(items);
    sortedItems.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return sortedItems.take(10).toList();
  });
});

final recentlyUpdatedProvider = Provider<AsyncValue<List<ReadingItem>>>((ref) {
  return ref.watch(readingItemsProvider).whenData((items) {
    final sortedItems = List<ReadingItem>.from(items);
    sortedItems.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return sortedItems.take(10).toList();
  });
});

final statisticsProvider = Provider<AsyncValue<Map<String, dynamic>>>((ref) {
  return ref.watch(readingItemsProvider).whenData((items) {
    final totalItems = items.length;
    final completedItems = items.where((item) => item.status == ReadingStatus.completed).length;
    final readingItems = items.where((item) => item.status == ReadingStatus.reading).length;
    final favoriteItems = items.where((item) => item.isFavorite).length;
    final onHoldItems = items.where((item) => item.status == ReadingStatus.onHold).length;
    final droppedItems = items.where((item) => item.status == ReadingStatus.dropped).length;
    final planToReadItems = items.where((item) => item.status == ReadingStatus.planToRead).length;
    
    final mangaCount = items.where((item) => item.type == ReadingType.manga).length;
    final manhwaCount = items.where((item) => item.type == ReadingType.manhwa).length;
    final manhuaCount = items.where((item) => item.type == ReadingType.manhua).length;
    final novelCount = items.where((item) => item.type == ReadingType.novel).length;
    final webtoonCount = items.where((item) => item.type == ReadingType.webtoon).length;
    final lightNovelCount = items.where((item) => item.type == ReadingType.lightNovel).length;
    
    // Calculate total reading time
    int totalReadingTime = 0;
    int totalChaptersRead = 0;
    
    for (final item in items) {
      totalReadingTime += item.statistics.totalReadingTimeMinutes;
      totalChaptersRead += item.statistics.chaptersRead;
    }
    
    return {
      'totalItems': totalItems,
      'completedItems': completedItems,
      'readingItems': readingItems,
      'favoriteItems': favoriteItems,
      'onHoldItems': onHoldItems,
      'droppedItems': droppedItems,
      'planToReadItems': planToReadItems,
      'mangaCount': mangaCount,
      'manhwaCount': manhwaCount,
      'manhuaCount': manhuaCount,
      'novelCount': novelCount,
      'webtoonCount': webtoonCount,
      'lightNovelCount': lightNovelCount,
      'totalReadingTime': totalReadingTime,
      'totalChaptersRead': totalChaptersRead,
      'averageRating': items.isNotEmpty ? items.map((e) => e.rating).reduce((a, b) => a + b) / items.length : 0.0,
    };
  });
});

// Alias for filtered items (used by LibraryScreen)
final filteredReadingItemsProvider = filteredItemsProvider;

// Search and filter providers
final searchQueryProvider = StateProvider<String>((ref) => '');

final selectedTypesProvider = StateProvider<Set<String>>((ref) => {});

final selectedStatusesProvider = StateProvider<Set<String>>((ref) => {});

final selectedGenresProvider = StateProvider<Set<String>>((ref) => {});

final sortOptionProvider = StateProvider<SortOption>((ref) {
  final settings = ref.watch(appSettingsProvider).value;
  return settings?.defaultSortOption ?? SortOption.lastUpdated;
});

final sortAscendingProvider = StateProvider<bool>((ref) => true);

final viewModeProvider = StateProvider<ViewMode>((ref) {
  final settings = ref.watch(appSettingsProvider).value;
  return settings?.defaultViewMode ?? ViewMode.grid;
});

final filteredItemsProvider = Provider<AsyncValue<List<ReadingItem>>>((ref) {
  final itemsAsync = ref.watch(readingItemsProvider);
  final query = ref.watch(searchQueryProvider);
  final selectedTypes = ref.watch(selectedTypesProvider);
  final selectedStatuses = ref.watch(selectedStatusesProvider);
  final selectedGenres = ref.watch(selectedGenresProvider);
  final sortOption = ref.watch(sortOptionProvider);
  final sortAscending = ref.watch(sortAscendingProvider);

  return itemsAsync.whenData((items) {
    List<ReadingItem> filteredItems = items;

    // Apply search filter
    if (query.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        return item.title.toLowerCase().contains(query.toLowerCase()) ||
               (item.author?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
               item.genres.any((genre) => genre.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    }

    // Apply type filter
    if (selectedTypes.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        return selectedTypes.contains(item.type.displayName);
      }).toList();
    }

    // Apply status filter
    if (selectedStatuses.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        return selectedStatuses.contains(item.status.displayName);
      }).toList();
    }

    // Apply genre filter
    if (selectedGenres.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        return selectedGenres.any((genre) => item.genres.contains(genre));
      }).toList();
    }

    // Apply sorting
    filteredItems.sort((a, b) {
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

      return sortAscending ? comparison : -comparison;
    });

    return filteredItems;
  });
});

// Navigation providers
final selectedIndexProvider = StateProvider<int>((ref) => 0);

final routerProvider = Provider((ref) {
  return AppRouter.router;
});

// UI state providers
final isLoadingProvider = StateProvider<bool>((ref) => false);

final errorMessageProvider = StateProvider<String?>((ref) => null);

final selectedItemsProvider = StateProvider<Set<String>>((ref) => {});

final isSelectionModeProvider = Provider<bool>((ref) {
  return ref.watch(selectedItemsProvider).isNotEmpty;
});

// Theme providers
final isDarkModeProvider = Provider<bool>((ref) {
  final settings = ref.watch(appSettingsProvider).value;
  if (settings == null) return false;

  switch (settings.themeMode) {
    case ThemeMode.dark:
      return true;
    case ThemeMode.light:
      return false;
    case ThemeMode.system:
      return false;
  }
});

// Cleanup function for providers
void disposeProviders(WidgetRef ref) {
  // Dispose of any resources that need cleanup
}
