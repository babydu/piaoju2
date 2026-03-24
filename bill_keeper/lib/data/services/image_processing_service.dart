import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:bill_keeper/data/services/storage_service.dart';

class ImageProcessingService {
  final StorageService _storageService;

  ImageProcessingService(this._storageService);

  Future<String> scanAndCorrect(String imagePath) async {
    try {
      final originalFile = File(imagePath);
      final bytes = await originalFile.readAsBytes();
      var image = img.decodeImage(bytes);

      if (image == null) {
        return imagePath;
      }

      image = _autoRotate(image);
      image = _autoDeskew(image);
      image = _autoContrast(image);

      final tempPath = await _storageService.getTempFile(p.extension(imagePath));
      final outputFile = File(tempPath);
      await outputFile.writeAsBytes(img.encodeJpg(image, quality: 90));

      return tempPath;
    } catch (e) {
      return imagePath;
    }
  }

  img.Image _autoRotate(img.Image image) {
    if (image.width > image.height && image.width > 1024) {
      return img.copyRotate(image, angle: 90);
    }
    return image;
  }

  img.Image _autoDeskew(img.Image image) {
    return image;
  }

  img.Image _autoContrast(img.Image image) {
    return img.adjustColor(image, contrast: 1.1);
  }

  Future<String> rotate(String imagePath, int degrees) async {
    try {
      final originalFile = File(imagePath);
      final bytes = await originalFile.readAsBytes();
      var image = img.decodeImage(bytes);

      if (image == null) {
        return imagePath;
      }

      image = img.copyRotate(image, angle: degrees.toDouble());

      final tempPath = await _storageService.getTempFile(p.extension(imagePath));
      final outputFile = File(tempPath);
      await outputFile.writeAsBytes(img.encodeJpg(image, quality: 90));

      return tempPath;
    } catch (e) {
      return imagePath;
    }
  }

  Future<String> generateThumbnail(String imagePath, {int maxSize = 300}) async {
    try {
      final originalFile = File(imagePath);
      final bytes = await originalFile.readAsBytes();
      var image = img.decodeImage(bytes);

      if (image == null) {
        return imagePath;
      }

      if (image.width > image.height) {
        image = img.copyResize(image, width: maxSize);
      } else {
        image = img.copyResize(image, height: maxSize);
      }

      final tempPath = await _storageService.getTempFile('.jpg');
      final outputFile = File(tempPath);
      await outputFile.writeAsBytes(img.encodeJpg(image, quality: 80));

      return tempPath;
    } catch (e) {
      return imagePath;
    }
  }
}
