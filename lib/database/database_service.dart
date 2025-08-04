import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/reading_item.dart';
import '../models/app_settings.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static const String _databaseName = 'omnireader.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String readingItemsTable = 'reading_items';
  static const String chaptersTable = 'chapters';
  static const String statisticsTable = 'statistics';
  static const String backupsTable = 'backups';
  static const String syncTable = 'sync_data';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _createIndexes(db);
    await _insertDefaultData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < newVersion) {
      // Add migration logic for future versions
    }
  }

  Future<void> _createTables(Database db) async {
    // Reading Items table
    await db.execute('''
      CREATE TABLE $readingItemsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        rating REAL DEFAULT 0.0,
        genres TEXT,
        cover_image_url TEXT,
        local_cover_path TEXT,
        reading_url TEXT,
        current_chapter INTEGER DEFAULT 0,
        total_chapters INTEGER,
        description TEXT,
        date_added INTEGER NOT NULL,
        last_updated INTEGER NOT NULL,
        last_read INTEGER,
        is_favorite INTEGER DEFAULT 0,
        has_notifications INTEGER DEFAULT 0,
        notification_settings TEXT,
        custom_fields TEXT,
        tags TEXT,
        publisher TEXT,
        start_date INTEGER,
        end_date INTEGER,
        language TEXT,
        is_completed INTEGER DEFAULT 0,
        created_at INTEGER DEFAULT (strftime('%s', 'now')),
        updated_at INTEGER DEFAULT (strftime('%s', 'now'))
      )
    ''');

    // Chapters table for detailed chapter tracking
    await db.execute('''
      CREATE TABLE $chaptersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reading_item_id TEXT NOT NULL,
        chapter_number INTEGER NOT NULL,
        read_date INTEGER NOT NULL,
        reading_time_minutes INTEGER DEFAULT 0,
        rating REAL,
        notes TEXT,
        created_at INTEGER DEFAULT (strftime('%s', 'now')),
        FOREIGN KEY (reading_item_id) REFERENCES $readingItemsTable (id) ON DELETE CASCADE,
        UNIQUE(reading_item_id, chapter_number)
      )
    ''');

    // Statistics table for reading analytics
    await db.execute('''
      CREATE TABLE $statisticsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reading_item_id TEXT NOT NULL,
        total_reading_time_minutes INTEGER DEFAULT 0,
        chapters_read INTEGER DEFAULT 0,
        sessions_count INTEGER DEFAULT 0,
        first_read_date INTEGER,
        last_read_date INTEGER,
        average_reading_speed REAL DEFAULT 0.0,
        reading_streaks TEXT,
        created_at INTEGER DEFAULT (strftime('%s', 'now')),
        updated_at INTEGER DEFAULT (strftime('%s', 'now')),
        FOREIGN KEY (reading_item_id) REFERENCES $readingItemsTable (id) ON DELETE CASCADE
      )
    ''');

    // Backups table for data backup tracking
    await db.execute('''
      CREATE TABLE $backupsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        backup_name TEXT NOT NULL,
        backup_path TEXT NOT NULL,
        backup_size INTEGER,
        backup_date INTEGER NOT NULL,
        backup_type TEXT NOT NULL,
        is_automatic INTEGER DEFAULT 1,
        created_at INTEGER DEFAULT (strftime('%s', 'now'))
      )
    ''');

    // Sync table for cloud synchronization
    await db.execute('''
      CREATE TABLE $syncTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        last_sync_date INTEGER,
        sync_status TEXT DEFAULT 'pending',
        sync_provider TEXT,
        conflict_resolution TEXT,
        created_at INTEGER DEFAULT (strftime('%s', 'now')),
        updated_at INTEGER DEFAULT (strftime('%s', 'now')),
        UNIQUE(entity_type, entity_id)
      )
    ''');
  }

  Future<void> _createIndexes(Database db) async {
    // Indexes for better query performance
    await db.execute('CREATE INDEX idx_reading_items_type ON $readingItemsTable(type)');
    await db.execute('CREATE INDEX idx_reading_items_status ON $readingItemsTable(status)');
    await db.execute('CREATE INDEX idx_reading_items_rating ON $readingItemsTable(rating)');
    await db.execute('CREATE INDEX idx_reading_items_date_added ON $readingItemsTable(date_added)');
    await db.execute('CREATE INDEX idx_reading_items_last_updated ON $readingItemsTable(last_updated)');
    await db.execute('CREATE INDEX idx_reading_items_is_favorite ON $readingItemsTable(is_favorite)');
    await db.execute('CREATE INDEX idx_reading_items_title ON $readingItemsTable(title)');
    await db.execute('CREATE INDEX idx_reading_items_author ON $readingItemsTable(author)');
    
    await db.execute('CREATE INDEX idx_chapters_reading_item_id ON $chaptersTable(reading_item_id)');
    await db.execute('CREATE INDEX idx_chapters_read_date ON $chaptersTable(read_date)');
    
    await db.execute('CREATE INDEX idx_statistics_reading_item_id ON $statisticsTable(reading_item_id)');
    
    await db.execute('CREATE INDEX idx_sync_entity_type ON $syncTable(entity_type)');
    await db.execute('CREATE INDEX idx_sync_status ON $syncTable(sync_status)');
  }

  Future<void> _insertDefaultData(Database db) async {
    // Insert default genres
    final defaultGenres = [
      'Action', 'Adventure', 'Comedy', 'Drama', 'Fantasy', 'Horror',
      'Mystery', 'Romance', 'Sci-Fi', 'Slice of Life', 'Sports', 'Supernatural',
      'Thriller', 'Historical', 'Psychological', 'Martial Arts', 'School Life',
      'Shounen', 'Shoujo', 'Seinen', 'Josei', 'Isekai', 'Mecha', 'Music'
    ];
    
    // You can add default data insertion logic here if needed
  }

  // CRUD Operations for Reading Items
  Future<int> insertReadingItem(ReadingItem item) async {
    final db = await database;
    final map = _readingItemToMap(item);
    return await db.insert(readingItemsTable, map);
  }

  Future<List<ReadingItem>> getAllReadingItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      readingItemsTable,
      orderBy: 'last_updated DESC',
    );
    return maps.map((map) => _mapToReadingItem(map)).toList();
  }

  Future<ReadingItem?> getReadingItemById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      readingItemsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _mapToReadingItem(maps.first);
    }
    return null;
  }

  Future<List<ReadingItem>> getReadingItemsByType(ReadingType type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      readingItemsTable,
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'last_updated DESC',
    );
    return maps.map((map) => _mapToReadingItem(map)).toList();
  }

  Future<List<ReadingItem>> getReadingItemsByStatus(ReadingStatus status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      readingItemsTable,
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'last_updated DESC',
    );
    return maps.map((map) => _mapToReadingItem(map)).toList();
  }

  Future<List<ReadingItem>> getFavoriteReadingItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      readingItemsTable,
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'last_updated DESC',
    );
    return maps.map((map) => _mapToReadingItem(map)).toList();
  }

  Future<List<ReadingItem>> searchReadingItems(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      readingItemsTable,
      where: 'title LIKE ? OR author LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'last_updated DESC',
    );
    return maps.map((map) => _mapToReadingItem(map)).toList();
  }

  Future<int> updateReadingItem(ReadingItem item) async {
    final db = await database;
    final map = _readingItemToMap(item);
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update(
      readingItemsTable,
      map,
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteReadingItem(String id) async {
    final db = await database;
    return await db.delete(
      readingItemsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Chapter Progress Operations
  Future<int> insertChapterProgress(String readingItemId, ChapterProgress progress) async {
    final db = await database;
    final map = {
      'reading_item_id': readingItemId,
      'chapter_number': progress.chapterNumber,
      'read_date': progress.readDate.millisecondsSinceEpoch,
      'reading_time_minutes': progress.readingTimeMinutes,
      'rating': progress.rating,
      'notes': progress.notes,
    };
    return await db.insert(chaptersTable, map);
  }

  Future<List<ChapterProgress>> getChapterProgress(String readingItemId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      chaptersTable,
      where: 'reading_item_id = ?',
      whereArgs: [readingItemId],
      orderBy: 'chapter_number ASC',
    );
    return maps.map((map) => _mapToChapterProgress(map)).toList();
  }

  // Statistics Operations
  Future<Map<String, dynamic>> getReadingStatistics() async {
    final db = await database;
    
    final totalItems = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $readingItemsTable')
    ) ?? 0;
    
    final completedItems = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $readingItemsTable WHERE status = ?', ['completed'])
    ) ?? 0;
    
    final readingItems = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $readingItemsTable WHERE status = ?', ['reading'])
    ) ?? 0;
    
    final favoriteItems = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $readingItemsTable WHERE is_favorite = ?', [1])
    ) ?? 0;
    
    final averageRatingResult = await db.rawQuery('SELECT AVG(rating) FROM $readingItemsTable WHERE rating > 0');
    final averageRating = (averageRatingResult.first['AVG(rating)'] as double?) ?? 0.0;
    
    final totalChaptersRead = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(current_chapter) FROM $readingItemsTable')
    ) ?? 0;
    
    return {
      'totalItems': totalItems,
      'completedItems': completedItems,
      'readingItems': readingItems,
      'favoriteItems': favoriteItems,
      'averageRating': averageRating,
      'totalChaptersRead': totalChaptersRead,
    };
  }

  // Backup Operations
  Future<String> createBackup() async {
    final db = await database;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${documentsDirectory.path}/backups');
    
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = '${backupDir.path}/omnireader_backup_$timestamp.db';
    
    // Copy database file
    final dbFile = File(db.path);
    await dbFile.copy(backupPath);
    
    // Record backup in database
    await db.insert(backupsTable, {
      'backup_name': 'Auto Backup $timestamp',
      'backup_path': backupPath,
      'backup_size': await File(backupPath).length(),
      'backup_date': timestamp,
      'backup_type': 'automatic',
    });
    
    return backupPath;
  }

  Future<bool> restoreBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        return false;
      }
      
      // Close current database
      await _database?.close();
      _database = null;
      
      // Replace current database with backup
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final currentDbPath = join(documentsDirectory.path, _databaseName);
      await backupFile.copy(currentDbPath);
      
      // Reinitialize database
      await database;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Utility methods for data conversion
  Map<String, dynamic> _readingItemToMap(ReadingItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'author': item.author,
      'type': item.type.name,
      'status': item.status.name,
      'rating': item.rating,
      'genres': item.genres.join(','),
      'cover_image_url': item.coverImageUrl,
      'local_cover_path': item.localCoverPath,
      'reading_url': item.readingUrl,
      'current_chapter': item.currentChapter,
      'total_chapters': item.totalChapters,
      'description': item.description,
      'date_added': item.dateAdded.millisecondsSinceEpoch,
      'last_updated': item.lastUpdated.millisecondsSinceEpoch,
      'last_read': item.lastRead?.millisecondsSinceEpoch,
      'is_favorite': item.isFavorite ? 1 : 0,
      'has_notifications': item.hasNotifications ? 1 : 0,
      'notification_settings': item.notificationSettings?.toJson().toString(),
      'custom_fields': item.customFields?.toString(),
      'tags': item.tags.join(','),
      'publisher': item.publisher,
      'start_date': item.startDate?.millisecondsSinceEpoch,
      'end_date': item.endDate?.millisecondsSinceEpoch,
      'language': item.language,
      'is_completed': item.isCompleted ? 1 : 0,
    };
  }

  ReadingItem _mapToReadingItem(Map<String, dynamic> map) {
    return ReadingItem(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      type: ReadingType.values.firstWhere((e) => e.name == map['type']),
      status: ReadingStatus.values.firstWhere((e) => e.name == map['status']),
      rating: map['rating']?.toDouble() ?? 0.0,
      genres: map['genres']?.split(',').where((g) => g.isNotEmpty).toList() ?? [],
      coverImageUrl: map['cover_image_url'],
      localCoverPath: map['local_cover_path'],
      readingUrl: map['reading_url'],
      currentChapter: map['current_chapter'] ?? 0,
      totalChapters: map['total_chapters'],
      description: map['description'],
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['date_added']),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['last_updated']),
      lastRead: map['last_read'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['last_read'])
          : null,
      isFavorite: map['is_favorite'] == 1,
      hasNotifications: map['has_notifications'] == 1,
      tags: map['tags']?.split(',').where((t) => t.isNotEmpty).toList() ?? [],
      publisher: map['publisher'],
      startDate: map['start_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['start_date'])
          : null,
      endDate: map['end_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['end_date'])
          : null,
      language: map['language'],
      isCompleted: map['is_completed'] == 1,
      chapterProgress: [], // Load separately if needed
      statistics: const ReadingStatistics(), // Load separately if needed
    );
  }

  ChapterProgress _mapToChapterProgress(Map<String, dynamic> map) {
    return ChapterProgress(
      chapterNumber: map['chapter_number'],
      readDate: DateTime.fromMillisecondsSinceEpoch(map['read_date']),
      readingTimeMinutes: map['reading_time_minutes'] ?? 0,
      rating: map['rating']?.toDouble(),
      notes: map['notes'],
    );
  }

  // Database maintenance
  Future<void> vacuum() async {
    final db = await database;
    await db.execute('VACUUM');
  }

  Future<void> analyze() async {
    final db = await database;
    await db.execute('ANALYZE');
  }

  Future<int> getDatabaseSize() async {
    final db = await database;
    final file = File(db.path);
    return await file.length();
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

