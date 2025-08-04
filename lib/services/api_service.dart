import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading_item.dart';
import '../providers/app_providers.dart';
import '../models/app_settings.dart';

class ApiService {
  static const String _malBaseUrl = 'https://api.myanimelist.net/v2';
  static const String _anilistBaseUrl = 'https://graphql.anilist.co';
  static const String _openaiBaseUrl = 'https://api.openai.com/v1';
  static const String _jikanBaseUrl = 'https://api.jikan.moe/v4';
  
  final String? _malApiKey;
  final String? _anilistApiKey;
  final String? _openaiApiKey;

  ApiService({
    String? malApiKey,
    String? anilistApiKey,
    String? openaiApiKey,
  })  : _malApiKey = malApiKey,
        _anilistApiKey = anilistApiKey,
        _openaiApiKey = openaiApiKey;

  // MyAnimeList API Integration
  Future<List<SearchResult>> searchMAL(String query, {ReadingType? type}) async {
    if (_malApiKey == null || _malApiKey!.isEmpty) {
      throw ApiException('MyAnimeList API key not configured');
    }

    try {
      final typeParam = _getMALType(type);
      final uri = Uri.parse('$_malBaseUrl/manga').replace(queryParameters: {
        'q': query,
        'limit': '20',
        if (typeParam != null) 'type': typeParam,
        'fields': 'id,title,main_picture,alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,num_list_users,num_scoring_users,nsfw,created_at,updated_at,media_type,status,genres,my_list_status,num_volumes,num_chapters,authors{first_name,last_name},pictures,background,related_anime,related_manga,recommendations,serialization{name}'
      });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_malApiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = <SearchResult>[];
        
        for (final item in data['data']) {
          results.add(SearchResult.fromMAL(item['node']));
        }
        
        return results;
      } else {
        throw ApiException('MAL API error: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Failed to search MAL: $e');
    }
  }

  Future<DetailedResult?> getMALDetails(String malId) async {
    if (_malApiKey == null || _malApiKey!.isEmpty) {
      throw ApiException('MyAnimeList API key not configured');
    }

    try {
      final uri = Uri.parse('$_malBaseUrl/manga/$malId').replace(queryParameters: {
        'fields': 'id,title,main_picture,alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,num_list_users,num_scoring_users,nsfw,created_at,updated_at,media_type,status,genres,my_list_status,num_volumes,num_chapters,authors{first_name,last_name},pictures,background,related_anime,related_manga,recommendations,serialization{name}'
      });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_malApiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DetailedResult.fromMAL(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ApiException('MAL API error: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Failed to get MAL details: $e');
    }
  }

  // AniList API Integration
  Future<List<SearchResult>> searchAniList(String query, {ReadingType? type}) async {
    try {
      const searchQuery = '''
        query (\$search: String, \$type: MediaType) {
          Page(page: 1, perPage: 20) {
            media(search: \$search, type: \$type) {
              id
              title {
                romaji
                english
                native
              }
              coverImage {
                large
                medium
              }
              description
              averageScore
              popularity
              chapters
              volumes
              status
              startDate {
                year
                month
                day
              }
              endDate {
                year
                month
                day
              }
              genres
              tags {
                name
              }
              staff {
                edges {
                  role
                  node {
                    name {
                      full
                    }
                  }
                }
              }
            }
          }
        }
      ''';

      final variables = {
        'search': query,
        'type': 'MANGA',
      };

      final response = await http.post(
        Uri.parse(_anilistBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'query': searchQuery,
          'variables': variables,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = <SearchResult>[];
        
        for (final item in data['data']['Page']['media']) {
          results.add(SearchResult.fromAniList(item));
        }
        
        return results;
      } else {
        throw ApiException('AniList API error: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Failed to search AniList: $e');
    }
  }

  Future<DetailedResult?> getAniListDetails(String anilistId) async {
    try {
      const detailQuery = '''
        query (\$id: Int) {
          Media(id: \$id, type: MANGA) {
            id
            title {
              romaji
              english
              native
            }
            coverImage {
              large
              medium
            }
            description
            averageScore
            popularity
            chapters
            volumes
            status
            startDate {
              year
              month
              day
            }
            endDate {
              year
              month
              day
            }
            genres
            tags {
              name
              description
            }
            staff {
              edges {
                role
                node {
                  name {
                    full
                  }
                }
              }
            }
            relations {
              edges {
                relationType
                node {
                  id
                  title {
                    romaji
                  }
                  type
                }
              }
            }
            recommendations {
              edges {
                node {
                  mediaRecommendation {
                    id
                    title {
                      romaji
                    }
                    coverImage {
                      medium
                    }
                  }
                }
              }
            }
          }
        }
      ''';

      final variables = {
        'id': int.parse(anilistId),
      };

      final response = await http.post(
        Uri.parse(_anilistBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'query': detailQuery,
          'variables': variables,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data']['Media'] != null) {
          return DetailedResult.fromAniList(data['data']['Media']);
        }
        return null;
      } else {
        throw ApiException('AniList API error: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Failed to get AniList details: $e');
    }
  }

  // Jikan API (MyAnimeList unofficial) - No API key required
  Future<List<SearchResult>> searchJikan(String query, {ReadingType? type}) async {
    try {
      final uri = Uri.parse('$_jikanBaseUrl/manga').replace(queryParameters: {
        'q': query,
        'limit': '20',
        'order_by': 'popularity',
        'sort': 'desc',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = <SearchResult>[];
        
        for (final item in data['data']) {
          results.add(SearchResult.fromJikan(item));
        }
        
        return results;
      } else {
        throw ApiException('Jikan API error: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Failed to search Jikan: $e');
    }
  }

  // OpenAI Integration for AI recommendations
  Future<List<String>> getAIRecommendations(List<ReadingItem> userLibrary) async {
    if (_openaiApiKey == null || _openaiApiKey!.isEmpty) {
      throw ApiException('OpenAI API key not configured');
    }

    try {
      final libraryContext = _buildLibraryContext(userLibrary);
      
      final prompt = '''
Based on the user's reading library below, recommend 5 manga, manhwa, or manhua titles that they might enjoy. Consider their favorite genres, reading patterns, and ratings.

User's Library:
$libraryContext

Please provide only the titles, one per line, without explanations or additional text.
''';

      final response = await http.post(
        Uri.parse('$_openaiBaseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_openaiApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 200,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();
      } else {
        throw ApiException('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Failed to get AI recommendations: $e');
    }
  }

  Future<String> getAIDescription(String title, String? author, List<String> genres) async {
    if (_openaiApiKey == null || _openaiApiKey!.isEmpty) {
      throw ApiException('OpenAI API key not configured');
    }

    try {
      final prompt = '''
Write a brief, engaging description for a ${genres.join(', ')} manga/manhwa/manhua titled "$title"${author != null ? ' by $author' : ''}. 
Keep it under 100 words and make it sound appealing to readers who enjoy ${genres.join(' and ')} genres.
''';

      final response = await http.post(
        Uri.parse('$_openaiBaseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_openaiApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 150,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        throw ApiException('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Failed to generate AI description: $e');
    }
  }

  // Manga/Manhwa/Manhua specific APIs
  Future<List<SearchResult>> searchMangaDex(String query) async {
    try {
      final uri = Uri.parse('https://api.mangadex.org/manga').replace(queryParameters: {
        'title': query,
        'limit': '20',
        'includes[]': ['cover_art', 'author', 'artist'],
        'order[relevance]': 'desc',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = <SearchResult>[];
        
        for (final item in data['data']) {
          results.add(SearchResult.fromMangaDex(item));
        }
        
        return results;
      } else {
        throw ApiException('MangaDex API error: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Failed to search MangaDex: $e');
    }
  }

  // Utility methods
  String? _getMALType(ReadingType? type) {
    if (type == null) return null;
    
    switch (type) {
      case ReadingType.manga:
        return 'manga';
      case ReadingType.manhwa:
        return 'manhwa';
      case ReadingType.manhua:
        return 'manhua';
      case ReadingType.novel:
        return 'novel';
      case ReadingType.lightNovel:
        return 'light_novel';
      case ReadingType.webtoon:
        return 'web_manga';
    }
  }

  String _buildLibraryContext(List<ReadingItem> library) {
    final buffer = StringBuffer();
    
    for (final item in library.take(20)) { // Limit to avoid token limits
      buffer.writeln('- ${item.title}${item.author != null ? ' by ${item.author}' : ''}');
      buffer.writeln('  Type: ${item.type.displayName}');
      buffer.writeln('  Genres: ${item.genres.join(', ')}');
      buffer.writeln('  Rating: ${item.rating}/10');
      buffer.writeln('  Status: ${item.status.displayName}');
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  // Batch operations
  Future<List<SearchResult>> searchMultipleSources(String query, {ReadingType? type}) async {
    final futures = <Future<List<SearchResult>>>[];
    
    // Always search Jikan (no API key required)
    futures.add(searchJikan(query, type: type));
    
    // Search AniList (no API key required)
    futures.add(searchAniList(query, type: type));
    
    // Search MangaDex (no API key required)
    futures.add(searchMangaDex(query));
    
    // Search MAL if API key is available
    if (_malApiKey != null && _malApiKey!.isNotEmpty) {
      futures.add(searchMAL(query, type: type));
    }

    try {
      final results = await Future.wait(futures, eagerError: false);
      final combinedResults = <SearchResult>[];
      
      for (final resultList in results) {
        combinedResults.addAll(resultList);
      }
      
      // Remove duplicates based on title similarity
      final uniqueResults = _removeDuplicates(combinedResults);
      
      // Sort by relevance/popularity
      uniqueResults.sort((a, b) => b.popularity.compareTo(a.popularity));
      
      return uniqueResults.take(50).toList();
    } catch (e) {
      throw ApiException('Failed to search multiple sources: $e');
    }
  }

  List<SearchResult> _removeDuplicates(List<SearchResult> results) {
    final seen = <String>{};
    final unique = <SearchResult>[];
    
    for (final result in results) {
      final normalizedTitle = result.title.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
      if (!seen.contains(normalizedTitle)) {
        seen.add(normalizedTitle);
        unique.add(result);
      }
    }
    
    return unique;
  }

  // Sync operations
  Future<void> syncWithMAL(List<ReadingItem> items) async {
    if (_malApiKey == null || _malApiKey!.isEmpty) {
      throw ApiException('MyAnimeList API key not configured');
    }

    // Implementation for syncing reading progress with MAL
    // This would involve updating the user's list on MAL
  }

  Future<void> syncWithAniList(List<ReadingItem> items) async {
    if (_anilistApiKey == null || _anilistApiKey!.isEmpty) {
      throw ApiException('AniList API key not configured');
    }

    // Implementation for syncing reading progress with AniList
    // This would involve updating the user's list on AniList
  }
}

// Data models for API responses
class SearchResult {
  final String id;
  final String title;
  final String? englishTitle;
  final String? author;
  final String? coverImageUrl;
  final String? description;
  final double rating;
  final int popularity;
  final List<String> genres;
  final ReadingType type;
  final String? status;
  final int? chapters;
  final int? volumes;
  final String source;

  SearchResult({
    required this.id,
    required this.title,
    this.englishTitle,
    this.author,
    this.coverImageUrl,
    this.description,
    required this.rating,
    required this.popularity,
    required this.genres,
    required this.type,
    this.status,
    this.chapters,
    this.volumes,
    required this.source,
  });

  factory SearchResult.fromMAL(Map<String, dynamic> data) {
    return SearchResult(
      id: data['id'].toString(),
      title: data['title'] ?? '',
      englishTitle: data['alternative_titles']?['en']?.isNotEmpty == true 
          ? data['alternative_titles']['en'][0] 
          : null,
      author: data['authors']?.isNotEmpty == true 
          ? '${data['authors'][0]['node']['first_name']} ${data['authors'][0]['node']['last_name']}'.trim()
          : null,
      coverImageUrl: data['main_picture']?['large'] ?? data['main_picture']?['medium'],
      description: data['synopsis'],
      rating: (data['mean'] ?? 0.0).toDouble(),
      popularity: data['popularity'] ?? 0,
      genres: (data['genres'] as List?)?.map((g) => g['name'] as String).toList() ?? [],
      type: _parseMALType(data['media_type']),
      status: data['status'],
      chapters: data['num_chapters'],
      volumes: data['num_volumes'],
      source: 'MyAnimeList',
    );
  }

  factory SearchResult.fromAniList(Map<String, dynamic> data) {
    return SearchResult(
      id: data['id'].toString(),
      title: data['title']['romaji'] ?? data['title']['english'] ?? data['title']['native'] ?? '',
      englishTitle: data['title']['english'],
      author: data['staff']?['edges']?.isNotEmpty == true 
          ? data['staff']['edges'][0]['node']['name']['full']
          : null,
      coverImageUrl: data['coverImage']?['large'] ?? data['coverImage']?['medium'],
      description: data['description'],
      rating: (data['averageScore'] ?? 0) / 10.0,
      popularity: data['popularity'] ?? 0,
      genres: (data['genres'] as List?)?.cast<String>() ?? [],
      type: ReadingType.manga, // AniList only has manga type
      status: data['status'],
      chapters: data['chapters'],
      volumes: data['volumes'],
      source: 'AniList',
    );
  }

  factory SearchResult.fromJikan(Map<String, dynamic> data) {
    return SearchResult(
      id: data['mal_id'].toString(),
      title: data['title'] ?? '',
      englishTitle: data['title_english'],
      author: data['authors']?.isNotEmpty == true 
          ? data['authors'][0]['name']
          : null,
      coverImageUrl: data['images']?['jpg']?['large_image_url'] ?? 
                     data['images']?['jpg']?['image_url'],
      description: data['synopsis'],
      rating: (data['score'] ?? 0.0).toDouble(),
      popularity: data['popularity'] ?? 0,
      genres: (data['genres'] as List?)?.map((g) => g['name'] as String).toList() ?? [],
      type: _parseJikanType(data['type']),
      status: data['status'],
      chapters: data['chapters'],
      volumes: data['volumes'],
      source: 'Jikan',
    );
  }

  factory SearchResult.fromMangaDex(Map<String, dynamic> data) {
    final attributes = data['attributes'];
    final relationships = data['relationships'] as List?;
    
    String? author;
    String? coverUrl;
    
    if (relationships != null) {
      for (final rel in relationships) {
        if (rel['type'] == 'author') {
          author = rel['attributes']?['name'];
        } else if (rel['type'] == 'cover_art') {
          final fileName = rel['attributes']?['fileName'];
          if (fileName != null) {
            coverUrl = 'https://uploads.mangadex.org/covers/${data['id']}/$fileName';
          }
        }
      }
    }

    return SearchResult(
      id: data['id'],
      title: attributes['title']?['en'] ?? 
             attributes['title']?.values?.first ?? '',
      englishTitle: attributes['title']?['en'],
      author: author,
      coverImageUrl: coverUrl,
      description: attributes['description']?['en'],
      rating: 0.0, // MangaDex doesn't provide ratings in search
      popularity: 0, // MangaDex doesn't provide popularity in search
      genres: (attributes['tags'] as List?)
          ?.where((tag) => tag['attributes']['group'] == 'genre')
          ?.map((tag) => tag['attributes']['name']['en'] as String)
          ?.toList() ?? [],
      type: ReadingType.manga,
      status: attributes['status'],
      chapters: null, // Not available in search
      volumes: null, // Not available in search
      source: 'MangaDex',
    );
  }

  static ReadingType _parseMALType(String? type) {
    switch (type?.toLowerCase()) {
      case 'manga':
        return ReadingType.manga;
      case 'manhwa':
        return ReadingType.manhwa;
      case 'manhua':
        return ReadingType.manhua;
      case 'novel':
        return ReadingType.novel;
      case 'light_novel':
        return ReadingType.lightNovel;
      case 'web_manga':
        return ReadingType.webtoon;
      default:
        return ReadingType.manga;
    }
  }

  static ReadingType _parseJikanType(String? type) {
    switch (type?.toLowerCase()) {
      case 'manga':
        return ReadingType.manga;
      case 'manhwa':
        return ReadingType.manhwa;
      case 'manhua':
        return ReadingType.manhua;
      case 'novel':
        return ReadingType.novel;
      case 'light novel':
        return ReadingType.lightNovel;
      case 'web manga':
        return ReadingType.webtoon;
      default:
        return ReadingType.manga;
    }
  }
}

class DetailedResult {
  final String id;
  final String title;
  final String? englishTitle;
  final String? author;
  final String? coverImageUrl;
  final String? description;
  final double rating;
  final int popularity;
  final List<String> genres;
  final List<String> tags;
  final ReadingType type;
  final String? status;
  final int? chapters;
  final int? volumes;
  final DateTime? startDate;
  final DateTime? endDate;
  final String source;
  final Map<String, dynamic> additionalData;

  DetailedResult({
    required this.id,
    required this.title,
    this.englishTitle,
    this.author,
    this.coverImageUrl,
    this.description,
    required this.rating,
    required this.popularity,
    required this.genres,
    required this.tags,
    required this.type,
    this.status,
    this.chapters,
    this.volumes,
    this.startDate,
    this.endDate,
    required this.source,
    required this.additionalData,
  });

  factory DetailedResult.fromMAL(Map<String, dynamic> data) {
    return DetailedResult(
      id: data['id'].toString(),
      title: data['title'] ?? '',
      englishTitle: data['alternative_titles']?['en']?.isNotEmpty == true 
          ? data['alternative_titles']['en'][0] 
          : null,
      author: data['authors']?.isNotEmpty == true 
          ? '${data['authors'][0]['node']['first_name']} ${data['authors'][0]['node']['last_name']}'.trim()
          : null,
      coverImageUrl: data['main_picture']?['large'] ?? data['main_picture']?['medium'],
      description: data['synopsis'],
      rating: (data['mean'] ?? 0.0).toDouble(),
      popularity: data['popularity'] ?? 0,
      genres: (data['genres'] as List?)?.map((g) => g['name'] as String).toList() ?? [],
      tags: [], // MAL doesn't have separate tags
      type: SearchResult._parseMALType(data['media_type']),
      status: data['status'],
      chapters: data['num_chapters'],
      volumes: data['num_volumes'],
      startDate: _parseDate(data['start_date']),
      endDate: _parseDate(data['end_date']),
      source: 'MyAnimeList',
      additionalData: data,
    );
  }

  factory DetailedResult.fromAniList(Map<String, dynamic> data) {
    return DetailedResult(
      id: data['id'].toString(),
      title: data['title']['romaji'] ?? data['title']['english'] ?? data['title']['native'] ?? '',
      englishTitle: data['title']['english'],
      author: data['staff']?['edges']?.isNotEmpty == true 
          ? data['staff']['edges'][0]['node']['name']['full']
          : null,
      coverImageUrl: data['coverImage']?['large'] ?? data['coverImage']?['medium'],
      description: data['description'],
      rating: (data['averageScore'] ?? 0) / 10.0,
      popularity: data['popularity'] ?? 0,
      genres: (data['genres'] as List?)?.cast<String>() ?? [],
      tags: (data['tags'] as List?)?.map((tag) => tag['name'] as String).toList() ?? [],
      type: ReadingType.manga,
      status: data['status'],
      chapters: data['chapters'],
      volumes: data['volumes'],
      startDate: _parseAniListDate(data['startDate']),
      endDate: _parseAniListDate(data['endDate']),
      source: 'AniList',
      additionalData: data,
    );
  }

  static DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static DateTime? _parseAniListDate(Map<String, dynamic>? date) {
    if (date == null) return null;
    try {
      final year = date['year'];
      final month = date['month'] ?? 1;
      final day = date['day'] ?? 1;
      if (year != null) {
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }
}

class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}

// Provider for API service
final apiServiceProvider = Provider<ApiService>((ref) {
  final settings = ref.watch(appSettingsProvider).value;
  
  return ApiService(
    malApiKey: settings?.malApiKey,
    anilistApiKey: settings?.anilistApiKey,
    openaiApiKey: settings?.openaiApiKey,
  );
});

