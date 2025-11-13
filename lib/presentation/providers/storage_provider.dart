import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';

/// Provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Upload state
class UploadState {
  final bool isUploading;
  final double progress;
  final String? error;
  final String? uploadedUrl;

  const UploadState({
    this.isUploading = false,
    this.progress = 0.0,
    this.error,
    this.uploadedUrl,
  });

  UploadState copyWith({
    bool? isUploading,
    double? progress,
    String? error,
    String? uploadedUrl,
  }) {
    return UploadState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      error: error,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
    );
  }
}

/// Upload notifier
class UploadNotifier extends StateNotifier<UploadState> {
  final StorageService _storageService;

  UploadNotifier(this._storageService) : super(const UploadState());

  /// Upload event image
  Future<String?> uploadEventImage({
    required File file,
    required String userId,
    String? eventId,
  }) async {
    try {
      // Validate file
      if (!_storageService.isValidImageFile(file)) {
        state = state.copyWith(
          error: 'Invalid file type. Only images are allowed.',
        );
        return null;
      }

      // Validate size (5MB max)
      final isValidSize = await _storageService.isValidImageSize(file);
      if (!isValidSize) {
        state = state.copyWith(
          error: 'Image size too large. Maximum size is 5MB.',
        );
        return null;
      }

      state = state.copyWith(isUploading: true, progress: 0.5, error: null);

      final url = await _storageService.uploadEventImage(
        file: file,
        userId: userId,
        eventId: eventId,
      );

      state = state.copyWith(
        isUploading: false,
        progress: 1.0,
        uploadedUrl: url,
      );

      return url;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Upload multiple event images
  Future<List<String>?> uploadEventImages({
    required List<File> files,
    required String userId,
    String? eventId,
  }) async {
    try {
      // Validate all files
      for (final file in files) {
        if (!_storageService.isValidImageFile(file)) {
          state = state.copyWith(
            error: 'Invalid file type. Only images are allowed.',
          );
          return null;
        }

        final isValidSize = await _storageService.isValidImageSize(file);
        if (!isValidSize) {
          state = state.copyWith(
            error: 'One or more images are too large. Maximum size is 5MB each.',
          );
          return null;
        }
      }

      state = state.copyWith(isUploading: true, progress: 0.0, error: null);

      final urls = await _storageService.uploadEventImages(
        files: files,
        userId: userId,
        eventId: eventId,
      );

      state = state.copyWith(
        isUploading: false,
        progress: 1.0,
      );

      return urls;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Upload profile image
  Future<String?> uploadProfileImage({
    required File file,
    required String userId,
  }) async {
    try {
      // Validate file
      if (!_storageService.isValidImageFile(file)) {
        state = state.copyWith(
          error: 'Invalid file type. Only images are allowed.',
        );
        return null;
      }

      // Validate size (5MB max)
      final isValidSize = await _storageService.isValidImageSize(file);
      if (!isValidSize) {
        state = state.copyWith(
          error: 'Image size too large. Maximum size is 5MB.',
        );
        return null;
      }

      state = state.copyWith(isUploading: true, progress: 0.5, error: null);

      final url = await _storageService.uploadProfileImage(
        file: file,
        userId: userId,
      );

      state = state.copyWith(
        isUploading: false,
        progress: 1.0,
        uploadedUrl: url,
      );

      return url;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const UploadState();
  }
}

/// Provider for upload state
final uploadProvider = StateNotifierProvider<UploadNotifier, UploadState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return UploadNotifier(storageService);
});
