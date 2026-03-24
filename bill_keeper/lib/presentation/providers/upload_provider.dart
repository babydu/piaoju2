import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:bill_keeper/data/services/storage_service.dart';
import 'package:bill_keeper/data/services/ocr_service.dart';
import 'package:bill_keeper/data/services/image_processing_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final ocrServiceProvider = Provider<OCRService>((ref) {
  return OCRService();
});

final imageProcessingServiceProvider = Provider<ImageProcessingService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ImageProcessingService(storageService);
});

final imagePickerProvider = Provider<ImagePicker>((ref) {
  return ImagePicker();
});

class UploadImage {
  final String id;
  final String originalPath;
  final String? processedPath;
  final String? thumbnailPath;
  final bool isProcessing;
  final bool isOcrProcessing;
  final String? ocrText;
  final List<String> recommendedTags;

  const UploadImage({
    required this.id,
    required this.originalPath,
    this.processedPath,
    this.thumbnailPath,
    this.isProcessing = false,
    this.isOcrProcessing = false,
    this.ocrText,
    this.recommendedTags = const [],
  });

  UploadImage copyWith({
    String? id,
    String? originalPath,
    String? processedPath,
    String? thumbnailPath,
    bool? isProcessing,
    bool? isOcrProcessing,
    String? ocrText,
    List<String>? recommendedTags,
  }) {
    return UploadImage(
      id: id ?? this.id,
      originalPath: originalPath ?? this.originalPath,
      processedPath: processedPath ?? this.processedPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isProcessing: isProcessing ?? this.isProcessing,
      isOcrProcessing: isOcrProcessing ?? this.isOcrProcessing,
      ocrText: ocrText ?? this.ocrText,
      recommendedTags: recommendedTags ?? this.recommendedTags,
    );
  }
}

class UploadState {
  final List<UploadImage> images;
  final String title;
  final String ocrContent;
  final List<String> selectedTags;
  final String? collectionId;
  final String? location;
  final String remark;
  final bool isLoading;
  final String? error;

  const UploadState({
    this.images = const [],
    this.title = '',
    this.ocrContent = '',
    this.selectedTags = const [],
    this.collectionId,
    this.location,
    this.remark = '',
    this.isLoading = false,
    this.error,
  });

  UploadState copyWith({
    List<UploadImage>? images,
    String? title,
    String? ocrContent,
    List<String>? selectedTags,
    String? collectionId,
    String? location,
    String? remark,
    bool? isLoading,
    String? error,
  }) {
    return UploadState(
      images: images ?? this.images,
      title: title ?? this.title,
      ocrContent: ocrContent ?? this.ocrContent,
      selectedTags: selectedTags ?? this.selectedTags,
      collectionId: collectionId ?? this.collectionId,
      location: location ?? this.location,
      remark: remark ?? this.remark,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UploadNotifier extends StateNotifier<UploadState> {
  final ImagePicker _picker;
  final StorageService _storageService;
  final OCRService _ocrService;
  final ImageProcessingService _imageProcessingService;
  final Uuid _uuid = const Uuid();

  UploadNotifier(
    this._picker,
    this._storageService,
    this._ocrService,
    this._imageProcessingService,
  ) : super(const UploadState());

  Future<void> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _addImage(image.path);
    }
  }

  Future<void> pickFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage(limit: 9 - state.images.length);
    for (final image in images) {
      await _addImage(image.path);
    }
  }

  Future<void> _addImage(String path) async {
    if (state.images.length >= 9) return;

    final id = _uuid.v4();
    final uploadImage = UploadImage(id: id, originalPath: path);
    
    state = state.copyWith(images: [...state.images, uploadImage]);
    
    await _generateThumbnail(id, path);
  }

  Future<void> _generateThumbnail(String id, String originalPath) async {
    final thumbnailPath = await _imageProcessingService.generateThumbnail(originalPath);
    
    _updateImage(id, (img) => img.copyWith(thumbnailPath: thumbnailPath));
  }

  Future<void> scanAndCorrect(String id) async {
    _updateImage(id, (img) => img.copyWith(isProcessing: true));

    final image = state.images.firstWhere((img) => img.id == id);
    final processedPath = await _imageProcessingService.scanAndCorrect(image.originalPath);
    
    _updateImage(id, (img) => img.copyWith(
      processedPath: processedPath,
      isProcessing: false,
    ));
  }

  Future<void> rotateImage(String id) async {
    _updateImage(id, (img) => img.copyWith(isProcessing: true));

    final image = state.images.firstWhere((img) => img.id == id);
    final currentPath = image.processedPath ?? image.originalPath;
    final rotatedPath = await _imageProcessingService.rotate(currentPath, 90);
    
    _updateImage(id, (img) => img.copyWith(
      processedPath: rotatedPath,
      isProcessing: false,
    ));
  }

  Future<void> recognizeText() async {
    if (state.images.isEmpty) return;

    state = state.copyWith(isLoading: true);

    final allTexts = <String>[];
    final allTags = <String>{};

    for (final image in state.images) {
      _updateImage(image.id, (img) => img.copyWith(isOcrProcessing: true));
    }

    for (final image in state.images) {
      final path = image.processedPath ?? image.originalPath;
      final result = await _ocrService.recognizeText(path);
      
      allTexts.add(result.text);
      allTags.addAll(result.recommendedTags);
      
      _updateImage(image.id, (img) => img.copyWith(
        ocrText: result.text,
        recommendedTags: result.recommendedTags,
        isOcrProcessing: false,
      ));
    }

    state = state.copyWith(
      ocrContent: allTexts.join('\n'),
      selectedTags: [...state.selectedTags, ...allTags].toSet().toList(),
      isLoading: false,
    );
  }

  void removeImage(String id) {
    state = state.copyWith(
      images: state.images.where((img) => img.id != id).toList(),
    );
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateOcrContent(String content) {
    state = state.copyWith(ocrContent: content);
  }

  void addTag(String tag) {
    if (!state.selectedTags.contains(tag)) {
      state = state.copyWith(selectedTags: [...state.selectedTags, tag]);
    }
  }

  void removeTag(String tag) {
    state = state.copyWith(
      selectedTags: state.selectedTags.where((t) => t != tag).toList(),
    );
  }

  void updateCollection(String? collectionId) {
    state = state.copyWith(collectionId: collectionId);
  }

  void updateLocation(String? location) {
    state = state.copyWith(location: location);
  }

  void updateRemark(String remark) {
    state = state.copyWith(remark: remark);
  }

  void _updateImage(String id, UploadImage Function(UploadImage) updater) {
    state = state.copyWith(
      images: state.images.map((img) {
        if (img.id == id) {
          return updater(img);
        }
        return img;
      }).toList(),
    );
  }

  void reset() {
    state = const UploadState();
  }
}

final uploadNotifierProvider = StateNotifierProvider<UploadNotifier, UploadState>((ref) {
  final picker = ref.watch(imagePickerProvider);
  final storageService = ref.watch(storageServiceProvider);
  final ocrService = ref.watch(ocrServiceProvider);
  final imageProcessingService = ref.watch(imageProcessingServiceProvider);
  
  return UploadNotifier(picker, storageService, ocrService, imageProcessingService);
});
