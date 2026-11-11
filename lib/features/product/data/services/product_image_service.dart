import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ProductImageService {
  ProductImageService._();

  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickAndSaveImage(ImageSource source) async {
    try {
      XFile? pickedFile;
      try {
        if (source == ImageSource.camera) {
          // Menghindari parameter scaling pada intent kamera yang menyebabkan crash/OOM pada HP tertentu (Vivo/Oppo)
          pickedFile = await _picker.pickImage(source: source);
        } else {
          pickedFile = await _picker.pickImage(
            source: source,
            maxWidth: 1200,
            maxHeight: 1200,
            imageQuality: 85,
          );
        }
      } catch (e) {
        debugPrint('ProductImageService: primary pick failed, trying basic: $e');
        pickedFile = await _picker.pickImage(source: source);
      }

      if (pickedFile == null) {
        if (!kIsWeb && Platform.isAndroid) {
          try {
            final LostDataResponse response = await _picker.retrieveLostData();
            if (!response.isEmpty && response.file != null) {
              return await saveImageLocally(response.file!);
            }
          } catch (e) {
            debugPrint('ProductImageService: error retrieving lost data: $e');
          }
        }
        return null;
      }

      return await saveImageLocally(pickedFile);
    } catch (e) {
      debugPrint('ProductImageService: error picking image: $e');
      rethrow;
    }
  }

  static Future<String?> saveImageLocally(XFile pickedFile) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(dir.path, 'product_images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      final ext = p.extension(pickedFile.path).isNotEmpty ? p.extension(pickedFile.path) : '.jpg';
      final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}$ext';
      final targetFile = File(p.join(imagesDir.path, fileName));

      final bytes = await pickedFile.readAsBytes();
      await targetFile.writeAsBytes(bytes);
      return targetFile.path;
    } catch (e) {
      debugPrint('ProductImageService: error saving image locally: $e');
      return pickedFile.path;
    }
  }

  static Future<void> deleteImageFile(String? imagePath) async {
    if (imagePath == null || imagePath.trim().isEmpty) return;
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
