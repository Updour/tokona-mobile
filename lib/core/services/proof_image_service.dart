import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ProofImageService {
  ProofImageService._();

  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickProofImage(ImageSource source) async {
    try {
      XFile? picked;
      try {
        if (source == ImageSource.camera) {
          picked = await _picker.pickImage(source: source);
        } else {
          picked = await _picker.pickImage(
            source: source,
            maxWidth: 1600,
            maxHeight: 1600,
            imageQuality: 85,
          );
        }
      } catch (e) {
        debugPrint('ProofImageService: error in primary pick: $e');
        picked = await _picker.pickImage(source: source);
      }

      if (picked == null) {
        if (!kIsWeb && Platform.isAndroid) {
          try {
            final lost = await _picker.retrieveLostData();
            if (!lost.isEmpty && lost.file != null) {
              return await saveProofImage(lost.file!);
            }
          } catch (_) {}
        }
        return null;
      }
      return await saveProofImage(picked);
    } catch (e) {
      debugPrint('ProofImageService: failed to pick proof image: $e');
      return null;
    }
  }

  static Future<String?> saveProofImage(XFile file) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final proofDir = Directory(p.join(docDir.path, 'proof_images'));
      if (!await proofDir.exists()) {
        await proofDir.create(recursive: true);
      }
      final ext = p.extension(file.path).isNotEmpty ? p.extension(file.path) : '.jpg';
      final fileName = 'PROOF_${DateTime.now().millisecondsSinceEpoch}$ext';
      final target = File(p.join(proofDir.path, fileName));
      final bytes = await file.readAsBytes();
      await target.writeAsBytes(bytes);
      return target.path;
    } catch (e) {
      debugPrint('ProofImageService: error saving proof: $e');
      return file.path;
    }
  }

  static Future<void> deleteProofImage(String? path) async {
    if (path == null || path.trim().isEmpty) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
