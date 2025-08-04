import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

class ImageService {
  final ImagePicker _imagePicker = ImagePicker();
  final Dio _dio = Dio();
  
  late Directory _imagesDirectory;
  late Directory _cacheDirectory;
  late Directory _thumbnailsDirectory;

  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    _imagesDirectory = Directory('${appDir.path}/images');
    _cacheDirectory = Directory('${appDir.path}/cache/images');
    _thumbnailsDirectory = Directory('${appDir.path}/thumbnails');

    // Create directories if they don't exist
    await _imagesDirectory.create(recursive: true);
    await _cacheDirectory.create(recursive: true);
    await _thumbnailsDirectory.create(recursive: true);
  }

  // Image picking and cropping
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return await _cropImage(File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
    }
    return null;
  }

  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return await _cropImage(File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
    }
    return null;
  }

  Future<File?> _cropImage(File imageFile) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4), // Book cover ratio
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Cover Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
            showCropGrid: true,
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      debugPrint('Error cropping image: $e');
    }
    return null;
  }

  // Local image storage
  Future<String> saveLocalImage(File imageFile, String itemId) async {
    try {
      await initialize();
      
      final String fileName = '${itemId}_cover.jpg';
      final String filePath = '${_imagesDirectory.path}/$fileName';
      
      // Copy and compress image
      final File savedFile = await imageFile.copy(filePath);
      
      // Generate thumbnail
      await _generateThumbnail(savedFile, itemId);
      
      return filePath;
    } catch (e) {
      debugPrint('Error saving local image: $e');
      rethrow;
    }
  }

  Future<String?> downloadAndSaveImage(String imageUrl, String itemId) async {
    try {
      await initialize();
      
      // Generate filename from URL hash
      final urlHash = sha256.convert(utf8.encode(imageUrl)).toString();
      final String fileName = '${itemId}_${urlHash.substring(0, 8)}.jpg';
      final String filePath = '${_imagesDirectory.path}/$fileName';
      
      // Check if already downloaded
      final File localFile = File(filePath);
      if (await localFile.exists()) {
        return filePath;
      }

      // Download image
      final Response response = await _dio.download(
        imageUrl,
        filePath,
        options: Options(
          headers: {
            'User-Agent': 'OmniReader/1.0',
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        // Generate thumbnail
        await _generateThumbnail(localFile, itemId);
        return filePath;
      }
    } catch (e) {
      debugPrint('Error downloading image: $e');
    }
    return null;
  }

  Future<void> _generateThumbnail(File imageFile, String itemId) async {
    try {
      // This is a placeholder for thumbnail generation
      // In a real implementation, you would use image processing libraries
      // like image package to resize the image
      
      final String thumbnailPath = '${_thumbnailsDirectory.path}/${itemId}_thumb.jpg';
      await imageFile.copy(thumbnailPath);
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
    }
  }

  // Image retrieval
  Future<File?> getLocalImage(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        return file;
      }
    } catch (e) {
      debugPrint('Error getting local image: $e');
    }
    return null;
  }

  Future<File?> getThumbnail(String itemId) async {
    try {
      await initialize();
      final String thumbnailPath = '${_thumbnailsDirectory.path}/${itemId}_thumb.jpg';
      final File thumbnailFile = File(thumbnailPath);
      
      if (await thumbnailFile.exists()) {
        return thumbnailFile;
      }
    } catch (e) {
      debugPrint('Error getting thumbnail: $e');
    }
    return null;
  }

  // Image widgets
  Widget buildCoverImage({
    required String? imageUrl,
    required String? localPath,
    required String itemId,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    // Try local image first
    if (localPath != null) {
      return FutureBuilder<File?>(
        future: getLocalImage(localPath),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.file(
              snapshot.data!,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return _buildNetworkImage(imageUrl, width, height, fit, placeholder, errorWidget);
              },
            );
          }
          return _buildNetworkImage(imageUrl, width, height, fit, placeholder, errorWidget);
        },
      );
    }

    // Fallback to network image
    return _buildNetworkImage(imageUrl, width, height, fit, placeholder, errorWidget);
  }

  Widget _buildNetworkImage(
    String? imageUrl,
    double? width,
    double? height,
    BoxFit fit,
    Widget? placeholder,
    Widget? errorWidget,
  ) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildDefaultCover(width, height);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(width, height),
      errorWidget: (context, url, error) => errorWidget ?? _buildDefaultCover(width, height),
      httpHeaders: const {
        'User-Agent': 'OmniReader/1.0',
      },
      cacheManager: DefaultCacheManager(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildDefaultCover(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[400]!,
            Colors.purple[400]!,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.book,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  // Image management
  Future<void> deleteLocalImage(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting local image: $e');
    }
  }

  Future<void> deleteThumbnail(String itemId) async {
    try {
      await initialize();
      final String thumbnailPath = '${_thumbnailsDirectory.path}/${itemId}_thumb.jpg';
      final File thumbnailFile = File(thumbnailPath);
      
      if (await thumbnailFile.exists()) {
        await thumbnailFile.delete();
      }
    } catch (e) {
      debugPrint('Error deleting thumbnail: $e');
    }
  }

  Future<void> clearImageCache() async {
    try {
      await initialize();
      
      // Clear cached network images
      await DefaultCacheManager().emptyCache();
      
      // Clear local cache directory
      if (await _cacheDirectory.exists()) {
        await _cacheDirectory.delete(recursive: true);
        await _cacheDirectory.create(recursive: true);
      }
    } catch (e) {
      debugPrint('Error clearing image cache: $e');
    }
  }

  Future<int> getCacheSize() async {
    try {
      await initialize();
      
      int totalSize = 0;
      
      // Calculate size of images directory
      if (await _imagesDirectory.exists()) {
        final List<FileSystemEntity> files = _imagesDirectory.listSync(recursive: true);
        for (final file in files) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
      
      // Calculate size of cache directory
      if (await _cacheDirectory.exists()) {
        final List<FileSystemEntity> files = _cacheDirectory.listSync(recursive: true);
        for (final file in files) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
      
      // Calculate size of thumbnails directory
      if (await _thumbnailsDirectory.exists()) {
        final List<FileSystemEntity> files = _thumbnailsDirectory.listSync(recursive: true);
        for (final file in files) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('Error calculating cache size: $e');
      return 0;
    }
  }

  // Image optimization
  Future<File?> optimizeImage(File imageFile, {
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 85,
  }) async {
    try {
      // This is a placeholder for image optimization
      // In a real implementation, you would use image processing libraries
      // to resize and compress the image
      
      return imageFile;
    } catch (e) {
      debugPrint('Error optimizing image: $e');
      return null;
    }
  }

  // Batch operations
  Future<void> preloadImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        await DefaultCacheManager().downloadFile(url);
      } catch (e) {
        debugPrint('Error preloading image $url: $e');
      }
    }
  }

  Future<void> cleanupOrphanedImages(List<String> validItemIds) async {
    try {
      await initialize();
      
      // Get all image files
      final List<FileSystemEntity> imageFiles = _imagesDirectory.listSync();
      final List<FileSystemEntity> thumbnailFiles = _thumbnailsDirectory.listSync();
      
      // Check images directory
      for (final file in imageFiles) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          final itemId = fileName.split('_').first;
          
          if (!validItemIds.contains(itemId)) {
            await file.delete();
            debugPrint('Deleted orphaned image: $fileName');
          }
        }
      }
      
      // Check thumbnails directory
      for (final file in thumbnailFiles) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          final itemId = fileName.split('_').first;
          
          if (!validItemIds.contains(itemId)) {
            await file.delete();
            debugPrint('Deleted orphaned thumbnail: $fileName');
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up orphaned images: $e');
    }
  }

  // Image validation
  bool isValidImageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return false;
      }
      
      final path = uri.path.toLowerCase();
      return path.endsWith('.jpg') ||
             path.endsWith('.jpeg') ||
             path.endsWith('.png') ||
             path.endsWith('.gif') ||
             path.endsWith('.webp');
    } catch (e) {
      return false;
    }
  }

  Future<bool> isImageAccessible(String url) async {
    try {
      final response = await _dio.head(url);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Image metadata
  Future<Map<String, dynamic>?> getImageMetadata(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) return null;
      
      final stat = await file.stat();
      
      return {
        'size': stat.size,
        'modified': stat.modified,
        'path': filePath,
      };
    } catch (e) {
      debugPrint('Error getting image metadata: $e');
      return null;
    }
  }
}

