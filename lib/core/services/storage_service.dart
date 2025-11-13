import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../errors/exceptions.dart';

/// Service for handling file uploads to Supabase Storage
class StorageService {
  final SupabaseClient _client;

  StorageService({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  /// Upload an event image
  /// Returns the public URL of the uploaded image
  Future<String> uploadEventImage({
    required File file,
    required String userId,
    String? eventId,
  }) async {
    try {
      final fileName = _generateFileName(file, userId, eventId);
      final path = 'events/$fileName';

      // Upload to Supabase Storage
      await _client.storage.from('event-images').upload(
            path,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _client.storage.from('event-images').getPublicUrl(path);

      return publicUrl;
    } on StorageException catch (e) {
      throw ServerException(
        message: 'Failed to upload image: ${e.message}',
        code: e.statusCode != null ? int.parse(e.statusCode!) : null,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to upload image: $e');
    }
  }

  /// Upload multiple event images (for gallery)
  Future<List<String>> uploadEventImages({
    required List<File> files,
    required String userId,
    String? eventId,
  }) async {
    final urls = <String>[];

    for (final file in files) {
      final url = await uploadEventImage(
        file: file,
        userId: userId,
        eventId: eventId,
      );
      urls.add(url);
    }

    return urls;
  }

  /// Delete an event image
  Future<void> deleteEventImage(String imageUrl) async {
    try {
      // Extract path from URL
      final uri = Uri.parse(imageUrl);
      final path = uri.pathSegments.last;

      await _client.storage.from('event-images').remove(['events/$path']);
    } on StorageException catch (e) {
      throw ServerException(
        message: 'Failed to delete image: ${e.message}',
        code: e.statusCode != null ? int.parse(e.statusCode!) : null,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to delete image: $e');
    }
  }

  /// Delete multiple event images
  Future<void> deleteEventImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      await deleteEventImage(url);
    }
  }

  /// Upload user profile image
  Future<String> uploadProfileImage({
    required File file,
    required String userId,
  }) async {
    try {
      final fileName = _generateFileName(file, userId, null);
      final path = 'profiles/$fileName';

      // Upload to Supabase Storage
      await _client.storage.from('avatars').upload(
            path,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true, // Allow overwriting for profile images
            ),
          );

      // Get public URL
      final publicUrl = _client.storage.from('avatars').getPublicUrl(path);

      return publicUrl;
    } on StorageException catch (e) {
      throw ServerException(
        message: 'Failed to upload profile image: ${e.message}',
        code: e.statusCode != null ? int.parse(e.statusCode!) : null,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to upload profile image: $e');
    }
  }

  /// Generate a unique file name
  String _generateFileName(File file, String userId, String? eventId) {
    final extension = file.path.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final prefix = eventId != null ? '${eventId}_' : '';

    return '${prefix}${userId}_$timestamp.$extension';
  }

  /// Get image size in bytes
  Future<int> getImageSize(File file) async {
    return await file.length();
  }

  /// Validate image file
  bool isValidImageFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  /// Validate image size (max 5MB by default)
  Future<bool> isValidImageSize(File file, {int maxSizeInBytes = 5242880}) async {
    final size = await getImageSize(file);
    return size <= maxSizeInBytes;
  }
}
