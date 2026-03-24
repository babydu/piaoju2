import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class StorageService {
  Future<String> get _imagesDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, 'images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir.path;
  }

  Future<String> get _thumbnailsDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final thumbsDir = Directory(p.join(appDir.path, 'thumbnails'));
    if (!await thumbsDir.exists()) {
      await thumbsDir.create(recursive: true);
    }
    return thumbsDir.path;
  }

  Future<String> get _tempDir async {
    final appDir = await getTemporaryDirectory();
    final tempDir = Directory(p.join(appDir.path, 'temp'));
    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
    }
    return tempDir.path;
  }

  Future<String> saveImage(File sourceFile) async {
    final imagesPath = await _imagesDir;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(sourceFile.path)}';
    final destPath = p.join(imagesPath, fileName);
    await sourceFile.copy(destPath);
    return destPath;
  }

  Future<String> saveThumbnail(String originalPath, String thumbnailPath) async {
    final thumbsPath = await _thumbnailsDir;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_thumb.jpg';
    final destPath = p.join(thumbsPath, fileName);
    final sourceFile = File(thumbnailPath);
    if (await sourceFile.exists()) {
      await sourceFile.copy(destPath);
    }
    return destPath;
  }

  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<int> calculateStorageUsed() async {
    int totalSize = 0;
    
    final imagesPath = await _imagesDir;
    final imagesDir = Directory(imagesPath);
    if (await imagesDir.exists()) {
      await for (final entity in imagesDir.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    }

    final thumbsPath = await _thumbnailsDir;
    final thumbsDir = Directory(thumbsPath);
    if (await thumbsDir.exists()) {
      await for (final entity in thumbsDir.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    }

    return totalSize;
  }

  Future<int> clearCache() async {
    int freedSize = 0;
    
    final thumbsPath = await _thumbnailsDir;
    final thumbsDir = Directory(thumbsPath);
    if (await thumbsDir.exists()) {
      await for (final entity in thumbsDir.list()) {
        if (entity is File) {
          freedSize += await entity.length();
          await entity.delete();
        }
      }
    }

    final tempPath = await _tempDir;
    final tempDir = Directory(tempPath);
    if (await tempDir.exists()) {
      await for (final entity in tempDir.list()) {
        if (entity is File) {
          freedSize += await entity.length();
          await entity.delete();
        }
      }
    }

    return freedSize;
  }

  Future<String> getTempFile(String extension) async {
    final tempPath = await _tempDir;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
    return p.join(tempPath, fileName);
  }
}
